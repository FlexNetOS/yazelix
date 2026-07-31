use std::{
    env,
    ffi::OsStr,
    fs::{self, File, OpenOptions},
    io::{self, Read, Write},
    net::{Ipv4Addr, SocketAddrV4, TcpStream},
    os::unix::{fs::PermissionsExt, process::CommandExt},
    path::{Path, PathBuf},
    process::{Child, Command, Stdio},
    thread,
    time::{Duration, Instant},
};

const RUNTIME_ROOT: &str = "@runtimeRoot@";
const XDG_RUNTIME_DIR: &str = "@xdgRuntimeDir@";
const LOG_ROOT: &str = "@logRoot@";
const CONFIG_HOME: &str = "@configHome@";
const DATA_HOME: &str = "@dataHome@";
const STATE_HOME: &str = "@stateHome@";
const CACHE_HOME: &str = "@cacheHome@";
const YAZELIX_STATE_DIR: &str = "@yazelixStateDir@";
const SQLD: &str = "@sqld@";
const SECRETD: &str = "@secretd@";
const SECRETCTL: &str = "@secretctl@";
const SEED_CA: &str = "@seedCa@";
const SQLD_AUTH_KEY: &str = "@sqldAuthKey@";
const SQLD_CLIENT_TOKEN: &str = "@sqldClientToken@";
const SQLD_DATA: &str = "@sqldData@";
const PG_CTL: &str = "@pgCtl@";
const PG_DATA: &str = "@pgData@";
const PG_SOCKET: &str = "@pgSocket@";
const REDB_OWNER: &str = "@redbOwner@";
const REDB_ROOT: &str = "@redbRoot@";
const ICM: &str = "@icm@";
const ICM_DB: &str = "@icmDb@";
const ICM_CONFIG: &str = "@icmConfig@";
const MOSQUITTO: &str = "@mosquitto@";
const NMCLI: &str = "@nmcli@";
const RUNNER: &str = "@runner@";
const RUNNER_LISTENER: &str = "@runnerListener@";

unsafe extern "C" {
    fn setsid() -> i32;
    fn kill(pid: i32, signal: i32) -> i32;
}

fn main() {
    if env::args_os().nth(1).as_deref() == Some(OsStr::new("--seed-monitor")) {
        seed_monitor();
        return;
    }
    if let Err(error) = ensure_runtime() {
        eprintln!("yzx runtime: {error}");
        std::process::exit(1);
    }
}

fn ensure_runtime() -> io::Result<()> {
    secure_dir(Path::new(RUNTIME_ROOT))?;
    secure_dir(Path::new(XDG_RUNTIME_DIR))?;
    secure_dir(Path::new(LOG_ROOT))?;
    secure_dir(&Path::new(RUNTIME_ROOT).join("tmp"))?;
    refresh_seed_ca()?;
    ensure_seed_network()?;
    ensure_sqld()?;
    ensure_postgres()?;
    ensure_secretd()?;
    unlock_vault()?;
    ensure_seed_monitor()?;
    ensure_icm_web()?;
    ensure_mqtt()?;
    ensure_background(
        "redb",
        REDB_OWNER,
        [OsStr::new("serve"), OsStr::new(REDB_ROOT)],
        &[],
        Duration::from_secs(2),
        Duration::from_secs(2),
        |_| true,
    )?;
    ensure_runner()?;
    Ok(())
}

fn ensure_runner() -> io::Result<()> {
    let pid_file = Path::new(RUNTIME_ROOT).join("runner.pid");
    let listener = Path::new(RUNNER_LISTENER);
    if process_identity_alive(&pid_file, listener)? {
        return Ok(());
    }
    retire_recorded_process(&pid_file)?;
    let existing = find_exact_processes(listener)?;
    match existing.as_slice() {
        [pid] => {
            write_process_identity(&pid_file, *pid)?;
            return Ok(());
        }
        [] => {}
        _ => {
            return Err(io::Error::other(format!(
                "multiple Yazelix runner listeners are active: {existing:?}"
            )))
        }
    }

    let log_path = Path::new(LOG_ROOT).join("runner.log");
    let stdout = OpenOptions::new()
        .create(true)
        .append(true)
        .open(&log_path)?;
    let stderr = stdout.try_clone()?;
    let mut command = Command::new(RUNNER);
    prepare_managed_command(&mut command);
    command
        .env("SECRETCTL_BIN", SECRETCTL)
        .env(
            "FLEXNETOS_RUNNER_STATE_DIR",
            "/home/flexnetos/meta/var/lib/yazelix/runtime/runner/state",
        )
        .env(
            "FLEXNETOS_RUNNER_WORK_DIR",
            "/home/flexnetos/meta/var/lib/yazelix/runtime/runner/work",
        )
        .stdin(Stdio::null())
        .stdout(Stdio::from(stdout))
        .stderr(Stdio::from(stderr));
    unsafe {
        command.pre_exec(|| {
            if setsid() < 0 {
                return Err(io::Error::last_os_error());
            }
            Ok(())
        });
    }
    let mut child = command.spawn()?;
    let deadline = Instant::now() + Duration::from_secs(30);
    loop {
        if let Some(status) = child.try_wait()? {
            return Err(io::Error::other(format!(
                "runner exited during Yazelix startup with {status}; see {}",
                log_path.display()
            )));
        }
        let listeners = find_exact_processes(listener)?;
        if let [pid] = listeners.as_slice() {
            write_process_identity(&pid_file, *pid)?;
            return Ok(());
        }
        if listeners.len() > 1 {
            return Err(io::Error::other(format!(
                "runner start produced multiple listeners: {listeners:?}"
            )));
        }
        if Instant::now() >= deadline {
            return Err(io::Error::new(
                io::ErrorKind::TimedOut,
                format!("runner listener did not start; see {}", log_path.display()),
            ));
        }
        thread::sleep(Duration::from_millis(100));
    }
}

fn secure_dir(path: &Path) -> io::Result<()> {
    fs::create_dir_all(path)?;
    fs::set_permissions(path, fs::Permissions::from_mode(0o700))
}

fn refresh_seed_ca() -> io::Result<()> {
    let Some(source) = find_seed_ca()? else {
        return Ok(());
    };
    let destination = Path::new(SEED_CA);
    if destination.is_file() && fs::read(&source)? == fs::read(destination)? {
        return Ok(());
    }
    if let Some(parent) = destination.parent() {
        fs::create_dir_all(parent)?;
    }
    fs::copy(&source, destination)?;
    fs::set_permissions(destination, fs::Permissions::from_mode(0o644))?;
    eprintln!(
        "yzx runtime: refreshed Cognitum Seed CA from {}",
        source.display()
    );
    Ok(())
}

fn find_seed_ca() -> io::Result<Option<PathBuf>> {
    for mount_root in [Path::new("/run/media"), Path::new("/media")] {
        let Ok(users) = fs::read_dir(mount_root) else {
            continue;
        };
        for user in users.flatten() {
            let trust = user.path().join("COGNITUM/trust");
            for name in ["cognitum-ca.pem", "cognitum-ca.crt"] {
                let candidate = trust.join(name);
                if candidate.is_file() {
                    return Ok(Some(candidate));
                }
            }
        }
    }
    Ok(None)
}

fn ensure_seed_network() -> io::Result<()> {
    let Some(interface) = cognitum_seed_interface()? else {
        return Ok(());
    };
    let profile = "cognitum-seed-linklocal";
    let profile_exists = Command::new(NMCLI)
        .args(["-g", "connection.id", "connection", "show", profile])
        .output()
        .is_ok_and(|output| output.status.success());
    if !profile_exists {
        run_command(
            "Cognitum Seed NetworkManager profile creation",
            Command::new(NMCLI).args([
                "connection",
                "add",
                "type",
                "ethernet",
                "ifname",
                &interface,
                "con-name",
                profile,
                "ipv4.method",
                "manual",
                "ipv4.addresses",
                "169.254.42.2/24",
                "ipv4.never-default",
                "yes",
                "ipv6.method",
                "link-local",
                "connection.autoconnect",
                "yes",
            ]),
        )?;
    }
    if seed_network_ready(&interface, profile) {
        return Ok(());
    }
    run_command(
        "Cognitum Seed NetworkManager profile update",
        Command::new(NMCLI).args([
            "connection",
            "modify",
            profile,
            "connection.interface-name",
            &interface,
            "ipv4.method",
            "manual",
            "ipv4.addresses",
            "169.254.42.2/24",
            "ipv4.never-default",
            "yes",
            "ipv6.method",
            "link-local",
            "connection.autoconnect",
            "yes",
        ]),
    )?;
    run_command(
        "Cognitum Seed NetworkManager activation",
        Command::new(NMCLI).args(["connection", "up", profile]),
    )
}

fn seed_network_ready(interface: &str, profile: &str) -> bool {
    Command::new(NMCLI)
        .args([
            "-g",
            "GENERAL.CONNECTION,IP4.ADDRESS",
            "device",
            "show",
            interface,
        ])
        .output()
        .is_ok_and(|output| {
            output.status.success()
                && String::from_utf8_lossy(&output.stdout)
                    .lines()
                    .any(|line| line == profile)
                && String::from_utf8_lossy(&output.stdout)
                    .lines()
                    .any(|line| line == "169.254.42.2/24")
        })
}

fn cognitum_seed_interface() -> io::Result<Option<String>> {
    for entry in fs::read_dir("/sys/class/net")? {
        let entry = entry?;
        let uevent = entry.path().join("device/uevent");
        let Ok(properties) = fs::read_to_string(uevent) else {
            continue;
        };
        let is_seed = entry
            .path()
            .join("device")
            .canonicalize()
            .ok()
            .and_then(|device| device.parent().map(|parent| parent.join("product")))
            .and_then(|product| fs::read_to_string(product).ok())
            .is_some_and(|product| product.trim() == "Cognitum Seed");
        if is_seed && properties.lines().any(|line| line == "DRIVER=cdc_ncm") {
            return Ok(Some(entry.file_name().to_string_lossy().into_owned()));
        }
    }
    Ok(None)
}

fn run_command(label: &str, command: &mut Command) -> io::Result<()> {
    let output = command.output()?;
    if output.status.success() {
        Ok(())
    } else {
        Err(command_error(label, &output.stderr))
    }
}

fn ensure_sqld() -> io::Result<()> {
    for required in [SQLD_AUTH_KEY, SQLD_CLIENT_TOKEN] {
        if !Path::new(required).is_file() {
            return Err(io::Error::new(
                io::ErrorKind::NotFound,
                format!("required envctl sqld credential is absent: {required}"),
            ));
        }
    }
    secure_dir(Path::new(SQLD_DATA))?;
    reject_competing_listener("sqld", SQLD, 8080)?;
    ensure_background(
        "sqld",
        SQLD,
        [
            OsStr::new("--http-listen-addr"),
            OsStr::new("127.0.0.1:8080"),
            OsStr::new("--auth-jwt-key-file"),
            OsStr::new(SQLD_AUTH_KEY),
            OsStr::new("-d"),
            OsStr::new(SQLD_DATA),
        ],
        &[],
        Duration::from_secs(20),
        Duration::ZERO,
        |_| tcp_ready(8080),
    )
}

fn ensure_secretd() -> io::Result<()> {
    ensure_background(
        "secretd",
        SECRETD,
        std::iter::empty::<&OsStr>(),
        &[
            ("XDG_CONFIG_HOME", CONFIG_HOME),
            ("XDG_DATA_HOME", DATA_HOME),
            ("XDG_STATE_HOME", STATE_HOME),
            ("XDG_RUNTIME_DIR", XDG_RUNTIME_DIR),
            ("ENVCTL_SEED_CA", SEED_CA),
            ("SECRETD_STORE_BACKEND", "libsql"),
            ("SECRETD_LIBSQL_URL", "http://127.0.0.1:8080"),
            ("SECRETD_LIBSQL_AUTH_TOKEN_FILE", SQLD_CLIENT_TOKEN),
        ],
        Duration::from_secs(30),
        Duration::ZERO,
        |command| {
            command
                .env("XDG_RUNTIME_DIR", XDG_RUNTIME_DIR)
                .arg("--json")
                .arg("status");
            command.output().is_ok_and(|output| output.status.success())
        },
    )
}

fn unlock_vault() -> io::Result<()> {
    let output = Command::new(SECRETCTL)
        .env("XDG_RUNTIME_DIR", XDG_RUNTIME_DIR)
        .arg("--json")
        .arg("unlock")
        .output()?;
    if output.status.success() {
        eprintln!("yzx runtime: vault unlocked through the USB possession factor");
        return Ok(());
    }
    Err(command_error("USB-only vault unlock", &output.stderr))
}

fn vault_is_unlocked() -> bool {
    Command::new(SECRETCTL)
        .env("XDG_RUNTIME_DIR", XDG_RUNTIME_DIR)
        .arg("--json")
        .arg("status")
        .output()
        .is_ok_and(|output| {
            output.status.success()
                && String::from_utf8_lossy(&output.stdout).contains("\"unlocked\":true")
        })
}

fn ensure_seed_monitor() -> io::Result<()> {
    let pid_file = Path::new(RUNTIME_ROOT).join("seed-monitor.pid");
    let monitor_executable = env::current_exe()?;
    if process_identity_alive(&pid_file, &monitor_executable)? {
        return Ok(());
    }
    retire_recorded_process(&pid_file)?;
    let _ = fs::remove_file(&pid_file);
    let log_path = Path::new(LOG_ROOT).join("seed-monitor.log");
    let stdout = OpenOptions::new()
        .create(true)
        .append(true)
        .open(&log_path)?;
    let stderr = stdout.try_clone()?;
    let mut command = Command::new(env::current_exe()?);
    prepare_managed_command(&mut command);
    command
        .arg("--seed-monitor")
        .stdin(Stdio::null())
        .stdout(Stdio::from(stdout))
        .stderr(Stdio::from(stderr));
    unsafe {
        command.pre_exec(|| {
            if setsid() < 0 {
                return Err(io::Error::last_os_error());
            }
            Ok(())
        });
    }
    let child = command.spawn()?;
    write_process_identity(&pid_file, child.id())
}

fn seed_monitor() {
    let mut was_present = true;
    loop {
        let present = find_seed_ca().ok().flatten().is_some();
        if present && !was_present {
            if let Err(error) = refresh_seed_ca().and_then(|_| ensure_seed_network()) {
                eprintln!("yzx runtime: Cognitum Seed reconnect preparation failed: {error}");
            }
        }
        if present && !vault_is_unlocked() {
            if let Err(error) = unlock_vault() {
                eprintln!("yzx runtime: Cognitum Seed automatic unlock failed: {error}");
            }
        }
        was_present = present;
        thread::sleep(Duration::from_secs(2));
    }
}

fn ensure_icm_web() -> io::Result<()> {
    reject_competing_listener("ICM web", ICM, 8420)?;
    ensure_background(
        "icm-web",
        ICM,
        [OsStr::new("serve"), OsStr::new("--expose")],
        &[
            ("XDG_CONFIG_HOME", CONFIG_HOME),
            ("XDG_DATA_HOME", DATA_HOME),
            ("XDG_STATE_HOME", STATE_HOME),
            ("XDG_RUNTIME_DIR", XDG_RUNTIME_DIR),
            ("ICM_DB", ICM_DB),
            ("ICM_CONFIG", ICM_CONFIG),
        ],
        Duration::from_secs(30),
        Duration::ZERO,
        |_| tcp_ready(8420),
    )
}

fn ensure_mqtt() -> io::Result<()> {
    reject_competing_listener("LifeOS MQTT", MOSQUITTO, 1883)?;
    ensure_background(
        "lifeos-mqtt",
        MOSQUITTO,
        [OsStr::new("-p"), OsStr::new("1883"), OsStr::new("-v")],
        &[],
        Duration::from_secs(10),
        Duration::ZERO,
        |_| tcp_ready(1883),
    )
}

fn ensure_postgres() -> io::Result<()> {
    secure_dir(Path::new(PG_SOCKET))?;
    if pg_ctl("status", &[]).is_ok() {
        let pid = fs::read_to_string(Path::new(PG_DATA).join("postmaster.pid"))?
            .lines()
            .next()
            .and_then(|value| value.parse::<u32>().ok())
            .ok_or_else(|| {
                io::Error::other("PostgreSQL status is up but postmaster.pid is invalid")
            })?;
        let expected = Path::new(PG_CTL).canonicalize()?.with_file_name("postgres");
        if exact_process(pid, &expected) && process_environment_obeys_path_law(pid) {
            return Ok(());
        }
        if exact_process(pid, &expected) {
            pg_ctl("stop", &[OsStr::new("-m"), OsStr::new("fast")])?;
        } else {
            return Err(io::Error::other(
                "PostgreSQL is running from a competing binary outside the Yazelix closure",
            ));
        }
    }
    let log = Path::new(LOG_ROOT).join("postgresql.log");
    let options =
        format!("-c unix_socket_directories='{PG_SOCKET}' -c listen_addresses='127.0.0.1'");
    let mut command = Command::new(PG_CTL);
    prepare_managed_command(&mut command);
    let output = command
        .arg("-D")
        .arg(PG_DATA)
        .arg("start")
        .arg("-l")
        .arg(log)
        .arg("-o")
        .arg(options)
        .arg("-w")
        .arg("-t")
        .arg("30")
        .output()?;
    if output.status.success() {
        Ok(())
    } else {
        Err(command_error("PostgreSQL start", &output.stderr))
    }
}

fn pg_ctl(operation: &str, extra: &[&OsStr]) -> io::Result<()> {
    let mut command = Command::new(PG_CTL);
    prepare_managed_command(&mut command);
    let output = command
        .arg("-D")
        .arg(PG_DATA)
        .arg(operation)
        .args(extra)
        .output()?;
    if output.status.success() {
        Ok(())
    } else {
        Err(command_error(
            &format!("PostgreSQL {operation}"),
            &output.stderr,
        ))
    }
}

fn ensure_background<I, S, F>(
    name: &str,
    program: &str,
    args: I,
    environment: &[(&str, &str)],
    timeout: Duration,
    minimum_alive: Duration,
    mut ready: F,
) -> io::Result<()>
where
    I: IntoIterator<Item = S>,
    S: AsRef<OsStr>,
    F: FnMut(&mut Command) -> bool,
{
    let pid_file = Path::new(RUNTIME_ROOT).join(format!("{name}.pid"));
    if process_identity_alive(&pid_file, Path::new(program))? {
        let mut probe = Command::new(SECRETCTL);
        if ready(&mut probe) {
            return Ok(());
        }
    }
    retire_recorded_process(&pid_file)?;
    if let Some(pid) = find_exact_process(program)? {
        write_process_identity(&pid_file, pid)?;
        let mut probe = Command::new(SECRETCTL);
        if ready(&mut probe) {
            return Ok(());
        }
        return Err(io::Error::other(format!(
            "{name} has a Yazelix-owned process but failed its readiness check"
        )));
    }
    let _ = fs::remove_file(&pid_file);
    let log_path = Path::new(LOG_ROOT).join(format!("{name}.log"));
    let stdout = OpenOptions::new()
        .create(true)
        .append(true)
        .open(&log_path)?;
    let stderr = stdout.try_clone()?;
    let mut command = Command::new(program);
    prepare_managed_command(&mut command);
    command
        .args(args)
        .envs(environment.iter().copied())
        .stdin(Stdio::null())
        .stdout(Stdio::from(stdout))
        .stderr(Stdio::from(stderr));
    unsafe {
        command.pre_exec(|| {
            if setsid() < 0 {
                return Err(io::Error::last_os_error());
            }
            Ok(())
        });
    }
    let mut child = command.spawn()?;
    write_process_identity(&pid_file, child.id())?;
    wait_until_ready(
        name,
        &pid_file,
        &log_path,
        timeout,
        minimum_alive,
        &mut child,
        &mut ready,
    )
}

fn wait_until_ready<F>(
    name: &str,
    pid_file: &Path,
    log_path: &Path,
    timeout: Duration,
    minimum_alive: Duration,
    child: &mut Child,
    ready: &mut F,
) -> io::Result<()>
where
    F: FnMut(&mut Command) -> bool,
{
    let started = Instant::now();
    let deadline = started + timeout;
    loop {
        if let Some(status) = child.try_wait()? {
            let _ = fs::remove_file(pid_file);
            return Err(io::Error::other(format!(
                "{name} exited during Yazelix startup with {status}; see {}",
                log_path.display()
            )));
        }
        let mut probe = Command::new(SECRETCTL);
        if ready(&mut probe) && started.elapsed() >= minimum_alive {
            return Ok(());
        }
        if Instant::now() >= deadline {
            let _ = fs::remove_file(pid_file);
            return Err(io::Error::new(
                io::ErrorKind::TimedOut,
                format!("{name} did not become ready; see {}", log_path.display()),
            ));
        }
        thread::sleep(Duration::from_millis(100));
    }
}

fn tcp_ready(port: u16) -> bool {
    TcpStream::connect_timeout(
        &SocketAddrV4::new(Ipv4Addr::LOCALHOST, port).into(),
        Duration::from_millis(200),
    )
    .is_ok()
}

fn reject_competing_listener(name: &str, program: &str, port: u16) -> io::Result<()> {
    if tcp_ready(port) && find_exact_process(program)?.is_none() {
        return Err(io::Error::other(format!(
            "{name} port {port} is owned by a non-Yazelix binary; retire the competing runtime owner"
        )));
    }
    Ok(())
}

fn find_exact_process(program: &str) -> io::Result<Option<u32>> {
    Ok(find_exact_processes(Path::new(program))?.into_iter().next())
}

fn find_exact_processes(expected: &Path) -> io::Result<Vec<u32>> {
    let expected = fs::canonicalize(expected)?;
    let mut matches = Vec::new();
    for entry in fs::read_dir("/proc")? {
        let Ok(entry) = entry else {
            continue;
        };
        let Some(pid) = entry
            .file_name()
            .to_str()
            .and_then(|value| value.parse::<u32>().ok())
        else {
            continue;
        };
        if exact_process(pid, &expected) {
            matches.push(pid);
        }
    }
    matches.sort_unstable();
    Ok(matches)
}

fn exact_process(pid: u32, expected: &Path) -> bool {
    let Ok(actual) = fs::canonicalize(format!("/proc/{pid}/exe")) else {
        return false;
    };
    let expected = fs::canonicalize(expected).unwrap_or_else(|_| expected.to_path_buf());
    actual == expected
}

fn write_process_identity(path: &Path, pid: u32) -> io::Result<()> {
    let start = process_start_time(pid)?;
    let temporary = path.with_extension("pid.tmp");
    let mut file = File::create(&temporary)?;
    writeln!(file, "{pid} {start}")?;
    file.sync_all()?;
    fs::rename(temporary, path)
}

fn process_identity_alive(path: &Path, expected_executable: &Path) -> io::Result<bool> {
    let Some((pid, expected_start)) = read_process_identity(path)? else {
        return Ok(false);
    };
    Ok(process_start_time(pid)
        .map(|actual| {
            actual == expected_start
                && exact_process(pid, expected_executable)
                && process_environment_obeys_path_law(pid)
        })
        .unwrap_or(false))
}

fn process_environment_obeys_path_law(pid: u32) -> bool {
    fs::read(format!("/proc/{pid}/environ"))
        .map(|environment| {
            !environment
                .windows(b"/run/user/".len())
                .any(|window| window == b"/run/user/")
        })
        .unwrap_or(false)
}

fn prepare_managed_command(command: &mut Command) {
    for (key, value) in env::vars_os() {
        if value.to_string_lossy().contains("/run/user/") {
            command.env_remove(key);
        }
    }
    command
        .env("XDG_RUNTIME_DIR", XDG_RUNTIME_DIR)
        .env("XDG_DATA_HOME", DATA_HOME)
        .env("XDG_STATE_HOME", STATE_HOME)
        .env("XDG_CACHE_HOME", CACHE_HOME)
        .env("YAZELIX_STATE_DIR", YAZELIX_STATE_DIR)
        .env("TMPDIR", Path::new(RUNTIME_ROOT).join("tmp"))
        .env("TMP", Path::new(RUNTIME_ROOT).join("tmp"))
        .env("TEMP", Path::new(RUNTIME_ROOT).join("tmp"));
}

fn read_process_identity(path: &Path) -> io::Result<Option<(u32, String)>> {
    let mut identity = String::new();
    match File::open(path) {
        Ok(mut file) => file.read_to_string(&mut identity)?,
        Err(error) if error.kind() == io::ErrorKind::NotFound => return Ok(None),
        Err(error) => return Err(error),
    };
    let mut fields = identity.split_whitespace();
    let Some(pid) = fields.next().and_then(|value| value.parse::<u32>().ok()) else {
        return Ok(None);
    };
    let Some(start) = fields.next() else {
        return Ok(None);
    };
    Ok(Some((pid, start.to_owned())))
}

fn retire_recorded_process(path: &Path) -> io::Result<()> {
    let Some((pid, expected_start)) = read_process_identity(path)? else {
        return Ok(());
    };
    match process_start_time(pid) {
        Ok(actual) if actual == expected_start => {}
        Ok(_) => return Ok(()),
        Err(error) if error.kind() == io::ErrorKind::NotFound => return Ok(()),
        Err(error) => return Err(error),
    }
    if unsafe { kill(pid as i32, 15) } < 0 {
        let error = io::Error::last_os_error();
        if error.raw_os_error() != Some(3) {
            return Err(error);
        }
    }
    let deadline = Instant::now() + Duration::from_secs(5);
    while Instant::now() < deadline {
        match process_start_time(pid) {
            Err(error) if error.kind() == io::ErrorKind::NotFound => return Ok(()),
            Ok(actual) if actual != expected_start => return Ok(()),
            Err(error) => return Err(error),
            Ok(_) => {}
        }
        thread::sleep(Duration::from_millis(50));
    }
    Err(io::Error::other(format!(
        "recorded Yazelix process {pid} did not terminate during profile generation turnover"
    )))
}

fn process_start_time(pid: u32) -> io::Result<String> {
    let stat = fs::read_to_string(format!("/proc/{pid}/stat"))?;
    let close = stat
        .rfind(')')
        .ok_or_else(|| io::Error::new(io::ErrorKind::InvalidData, "invalid /proc process stat"))?;
    stat[close + 2..]
        .split_whitespace()
        .nth(19)
        .map(str::to_owned)
        .ok_or_else(|| io::Error::new(io::ErrorKind::InvalidData, "missing process start time"))
}

fn command_error(action: &str, stderr: &[u8]) -> io::Error {
    io::Error::other(format!(
        "{action} failed: {}",
        String::from_utf8_lossy(stderr).trim()
    ))
}
