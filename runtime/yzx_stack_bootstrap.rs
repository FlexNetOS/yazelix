use std::{
    ffi::OsStr,
    fs::{self, File, OpenOptions},
    io::{self, Read, Write},
    net::{Ipv4Addr, SocketAddrV4, TcpStream},
    os::unix::process::CommandExt,
    path::Path,
    process::{Child, Command, Stdio},
    thread,
    time::{Duration, Instant},
};

const RUNTIME_ROOT: &str = "@runtimeRoot@";
const LOG_ROOT: &str = "@logRoot@";
const CONFIG_HOME: &str = "@configHome@";
const DATA_HOME: &str = "@dataHome@";
const STATE_HOME: &str = "@stateHome@";
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
const RUNNER: &str = "@runner@";

unsafe extern "C" {
    fn setsid() -> i32;
}

fn main() {
    if let Err(error) = ensure_runtime() {
        eprintln!("yzx runtime: {error}");
        std::process::exit(1);
    }
}

fn ensure_runtime() -> io::Result<()> {
    secure_dir(Path::new(RUNTIME_ROOT))?;
    secure_dir(Path::new(LOG_ROOT))?;
    ensure_sqld()?;
    ensure_postgres()?;
    ensure_secretd()?;
    unlock_vault()?;
    ensure_background(
        "redb",
        REDB_OWNER,
        [OsStr::new("serve"), OsStr::new(REDB_ROOT)],
        &[],
        Duration::from_secs(2),
        Duration::from_secs(2),
        |_| true,
    )?;
    ensure_background(
        "runner",
        RUNNER,
        std::iter::empty::<&OsStr>(),
        &[
            ("SECRETCTL_BIN", SECRETCTL),
            (
                "FLEXNETOS_RUNNER_STATE_DIR",
                "/home/flexnetos/meta/var/lib/gha-runner/state",
            ),
            (
                "FLEXNETOS_RUNNER_WORK_DIR",
                "/home/flexnetos/meta/var/lib/gha-runner/work",
            ),
        ],
        Duration::from_secs(4),
        Duration::from_secs(3),
        |_| true,
    )?;
    Ok(())
}

fn secure_dir(path: &Path) -> io::Result<()> {
    use std::os::unix::fs::PermissionsExt;
    fs::create_dir_all(path)?;
    fs::set_permissions(path, fs::Permissions::from_mode(0o700))
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
    let daemon_reachable = {
        let mut command = Command::new(SECRETCTL);
        command
            .env("XDG_RUNTIME_DIR", "/run/user/1001")
            .arg("--json")
            .arg("status");
        command.output().is_ok_and(|output| output.status.success())
    };
    if daemon_reachable && find_exact_process(SECRETD)?.is_none() {
        return Err(io::Error::other(
            "secretd socket is owned by a non-Yazelix binary; retire the competing runtime owner",
        ));
    }
    ensure_background(
        "secretd",
        SECRETD,
        std::iter::empty::<&OsStr>(),
        &[
            ("XDG_CONFIG_HOME", CONFIG_HOME),
            ("XDG_DATA_HOME", DATA_HOME),
            ("XDG_STATE_HOME", STATE_HOME),
            ("XDG_RUNTIME_DIR", "/run/user/1001"),
            ("ENVCTL_SEED_CA", SEED_CA),
            ("SECRETD_STORE_BACKEND", "libsql"),
            ("SECRETD_LIBSQL_URL", "http://127.0.0.1:8080"),
            ("SECRETD_LIBSQL_AUTH_TOKEN_FILE", SQLD_CLIENT_TOKEN),
        ],
        Duration::from_secs(30),
        Duration::ZERO,
        |command| {
            command
                .env("XDG_RUNTIME_DIR", "/run/user/1001")
                .arg("--json")
                .arg("status");
            command.output().is_ok_and(|output| output.status.success())
        },
    )
}

fn unlock_vault() -> io::Result<()> {
    let output = Command::new(SECRETCTL)
        .env("XDG_RUNTIME_DIR", "/run/user/1001")
        .arg("unlock")
        .arg("--json")
        .output()?;
    if output.status.success() {
        eprintln!("yzx runtime: vault unlocked through the USB possession factor");
        return Ok(());
    }
    Err(command_error("USB-only vault unlock", &output.stderr))
}

fn ensure_postgres() -> io::Result<()> {
    secure_dir(Path::new(PG_SOCKET))?;
    if pg_ctl("status", &[]).is_ok() {
        let pid = fs::read_to_string(Path::new(PG_DATA).join("postmaster.pid"))?
            .lines()
            .next()
            .and_then(|value| value.parse::<u32>().ok())
            .ok_or_else(|| io::Error::other("PostgreSQL status is up but postmaster.pid is invalid"))?;
        let expected = Path::new(PG_CTL).canonicalize()?.with_file_name("postgres");
        if exact_process(pid, &expected) {
            return Ok(());
        }
        return Err(io::Error::other(
            "PostgreSQL is running from a competing binary outside the Yazelix closure",
        ));
    }
    let log = Path::new(LOG_ROOT).join("postgresql.log");
    let options = format!(
        "-c unix_socket_directories='{PG_SOCKET}' -c listen_addresses='127.0.0.1'"
    );
    let output = Command::new(PG_CTL)
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
    let output = Command::new(PG_CTL)
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
    if process_identity_alive(&pid_file)? {
        let mut probe = Command::new(SECRETCTL);
        if ready(&mut probe) {
            return Ok(());
        }
    }
    if let Some(pid) = find_exact_process(program)? {
        write_process_identity(&pid_file, pid)?;
        let mut probe = Command::new(SECRETCTL);
        if ready(&mut probe) {
            return Ok(());
        }
    }
    let _ = fs::remove_file(&pid_file);
    let log_path = Path::new(LOG_ROOT).join(format!("{name}.log"));
    let stdout = OpenOptions::new()
        .create(true)
        .append(true)
        .open(&log_path)?;
    let stderr = stdout.try_clone()?;
    let mut command = Command::new(program);
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
    let expected = fs::canonicalize(program)?;
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
            return Ok(Some(pid));
        }
    }
    Ok(None)
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

fn process_identity_alive(path: &Path) -> io::Result<bool> {
    let mut identity = String::new();
    match File::open(path) {
        Ok(mut file) => file.read_to_string(&mut identity)?,
        Err(error) if error.kind() == io::ErrorKind::NotFound => return Ok(false),
        Err(error) => return Err(error),
    };
    let mut fields = identity.split_whitespace();
    let Some(pid) = fields.next().and_then(|value| value.parse::<u32>().ok()) else {
        return Ok(false);
    };
    let Some(expected_start) = fields.next() else {
        return Ok(false);
    };
    Ok(process_start_time(pid)
        .map(|actual| actual == expected_start)
        .unwrap_or(false))
}

fn process_start_time(pid: u32) -> io::Result<String> {
    let stat = fs::read_to_string(format!("/proc/{pid}/stat"))?;
    let close = stat.rfind(')').ok_or_else(|| {
        io::Error::new(io::ErrorKind::InvalidData, "invalid /proc process stat")
    })?;
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
