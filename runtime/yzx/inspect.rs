use std::{
    env, fs,
    path::{Path, PathBuf},
};

use crate::{
    error::{startup, AppError},
    paths::{nonempty_env, zellij_session_label},
    runtime::Runtime,
    status::json_string,
    PACKAGE_VARIANT, VERSION,
};

struct InspectReport {
    runtime: Runtime,
    current_executable: PathBuf,
    invoked_as: String,
    profile: PathBuf,
    profile_manifest: PathBuf,
    active_profile_elements: Option<usize>,
    profile_frontdoor: PathBuf,
    profile_frontdoor_resolved: Option<PathBuf>,
    profile_frontdoor_is_current: bool,
    profile_desktop_entry: PathBuf,
    local_shadow: PathBuf,
    local_desktop_dir: PathBuf,
    local_desktop_shadows: Vec<PathBuf>,
}

pub(crate) fn print_inspect() -> Result<(), AppError> {
    let report = InspectReport::collect()?;
    println!("Yazelix Nova inspect");
    println!("version: {VERSION}");
    println!("package: {PACKAGE_VARIANT}");
    println!(
        "current executable: {}",
        report.current_executable.display()
    );
    println!("profile: {}", report.profile.display());
    println!("profile frontdoor: {}", report.profile_frontdoor.display());
    println!(
        "profile frontdoor resolved: {}",
        display_optional_path(report.profile_frontdoor_resolved.as_deref())
    );
    println!(
        "profile frontdoor is current: {}",
        report.profile_frontdoor_is_current
    );
    println!(
        "profile elements: {}",
        report
            .active_profile_elements
            .map(|count| count.to_string())
            .unwrap_or_else(|| "unavailable".to_string())
    );
    println!(
        "profile desktop entry: {} ({})",
        report.profile_desktop_entry.display(),
        presence(&report.profile_desktop_entry)
    );
    println!("config home: {}", report.runtime.config_home.display());
    println!("state dir: {}", report.runtime.state_dir.display());
    println!("local binary shadow: {}", presence(&report.local_shadow));
    println!(
        "local desktop shadow: {}",
        if report.local_desktop_shadows.is_empty() {
            "absent"
        } else {
            "present"
        }
    );
    println!("inside zellij: {}", zellij_session_label("yes", "no"));
    Ok(())
}

pub(crate) fn print_inspect_json() -> Result<(), AppError> {
    let report = InspectReport::collect()?;
    println!("{}", report.json());
    Ok(())
}

impl InspectReport {
    fn collect() -> Result<Self, AppError> {
        let runtime = Runtime::prepare()?;
        let current_executable = env::current_exe()
            .map_err(|error| {
                startup(
                    format!("failed to resolve current yzx executable: {error}"),
                    "yzx inspect",
                    1,
                )
            })?
            .canonicalize()
            .map_err(|error| {
                startup(
                    format!("failed to resolve current yzx executable target: {error}"),
                    "yzx inspect",
                    1,
                )
            })?;
        let invoked_as = env::args_os()
            .next()
            .unwrap_or_default()
            .to_string_lossy()
            .into_owned();
        let home = nonempty_env("HOME").map(PathBuf::from).ok_or_else(|| {
            startup(
                "HOME is required to inspect the profile owner.",
                "yzx inspect",
                1,
            )
        })?;
        let profile = home.join(".nix-profile");
        let profile_manifest = profile.join("manifest.json");
        let active_profile_elements = active_profile_element_count(&profile_manifest);
        let profile_frontdoor = profile.join("bin/yzx");
        let profile_frontdoor_resolved = fs::canonicalize(&profile_frontdoor).ok();
        let profile_frontdoor_is_current = profile_frontdoor_resolved
            .as_ref()
            .is_some_and(|resolved| resolved == &current_executable);
        let profile_desktop_entry =
            profile.join("share/applications/com.flexnetos.Yazelix.Agent.desktop");
        let local_shadow = home.join(".local/bin/yzx");
        let local_desktop_dir = home.join(".local/share/applications");
        let local_desktop_shadows = local_desktop_shadows(&local_desktop_dir);

        Ok(Self {
            runtime,
            current_executable,
            invoked_as,
            profile,
            profile_manifest,
            active_profile_elements,
            profile_frontdoor,
            profile_frontdoor_resolved,
            profile_frontdoor_is_current,
            profile_desktop_entry,
            local_shadow,
            local_desktop_dir,
            local_desktop_shadows,
        })
    }

    fn json(&self) -> String {
        let desktop_entries = self
            .local_desktop_shadows
            .iter()
            .map(|path| json_string(&path.to_string_lossy()))
            .collect::<Vec<_>>()
            .join(",");
        format!(
            concat!(
                "{{\"schema_version\":1,",
                "\"runtime\":{{\"name\":\"Yazelix Nova\",\"version\":{},\"package\":{},\"current_executable\":{},\"invoked_as\":{}}},",
                "\"paths\":{{\"config_home\":{},\"state_dir\":{},\"runtime_identity\":{},\"layout\":{}}},",
                "\"ownership\":{{",
                "\"profile\":{},\"profile_manifest\":{},\"profile_manifest_exists\":{},\"active_profile_elements\":{},",
                "\"profile_frontdoor\":{},\"profile_frontdoor_exists\":{},\"profile_frontdoor_resolved\":{},\"profile_frontdoor_is_current\":{},",
                "\"profile_desktop_entry\":{},\"profile_desktop_entry_exists\":{},",
                "\"local_shadow\":{{\"path\":{},\"exists\":{}}},",
                "\"local_desktop_shadow\":{{\"directory\":{},\"exists\":{},\"entries\":[{}]}}",
                "}},",
                "\"session\":{{\"inside_zellij\":{}}}",
                "}}"
            ),
            json_string(VERSION),
            json_string(PACKAGE_VARIANT),
            json_path(&self.current_executable),
            json_string(&self.invoked_as),
            json_path(&self.runtime.config_home),
            json_path(&self.runtime.state_dir),
            json_path(&self.runtime.runtime_identity),
            json_string(&self.runtime.layout()),
            json_path(&self.profile),
            json_path(&self.profile_manifest),
            path_exists(&self.profile_manifest),
            json_optional_usize(self.active_profile_elements),
            json_path(&self.profile_frontdoor),
            path_exists(&self.profile_frontdoor),
            json_optional_path(self.profile_frontdoor_resolved.as_deref()),
            self.profile_frontdoor_is_current,
            json_path(&self.profile_desktop_entry),
            path_exists(&self.profile_desktop_entry),
            json_path(&self.local_shadow),
            path_exists(&self.local_shadow),
            json_path(&self.local_desktop_dir),
            !self.local_desktop_shadows.is_empty(),
            desktop_entries,
            zellij_session_label("true", "false"),
        )
    }
}

fn active_profile_element_count(manifest: &Path) -> Option<usize> {
    let text = fs::read_to_string(manifest).ok()?;
    let compact = text
        .chars()
        .filter(|character| !character.is_whitespace())
        .collect::<String>();
    Some(compact.matches("\"active\":true").count())
}

fn local_desktop_shadows(directory: &Path) -> Vec<PathBuf> {
    let mut entries = fs::read_dir(directory)
        .ok()
        .into_iter()
        .flatten()
        .filter_map(Result::ok)
        .map(|entry| entry.path())
        .filter(|path| {
            let name = path
                .file_name()
                .unwrap_or_default()
                .to_string_lossy()
                .to_ascii_lowercase();
            name.ends_with(".desktop") && (name.contains("yazelix") || name.contains("yzx"))
        })
        .collect::<Vec<_>>();
    entries.sort();
    entries
}

fn path_exists(path: &Path) -> bool {
    fs::symlink_metadata(path).is_ok()
}

fn presence(path: &Path) -> &'static str {
    if path_exists(path) {
        "present"
    } else {
        "absent"
    }
}

fn display_optional_path(path: Option<&Path>) -> String {
    path.map(|path| path.display().to_string())
        .unwrap_or_else(|| "unavailable".to_string())
}

fn json_path(path: &Path) -> String {
    json_string(&path.to_string_lossy())
}

fn json_optional_path(path: Option<&Path>) -> String {
    path.map(json_path).unwrap_or_else(|| "null".to_string())
}

fn json_optional_usize(value: Option<usize>) -> String {
    value
        .map(|value| value.to_string())
        .unwrap_or_else(|| "null".to_string())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn active_profile_count_ignores_json_whitespace() {
        let root = env::temp_dir().join(format!("yzx-inspect-{}", std::process::id()));
        fs::create_dir_all(&root).unwrap();
        let manifest = root.join("manifest.json");
        fs::write(
            &manifest,
            "{\n  \"a\": {\"active\": true}, \"b\": {\"active\":false}\n}",
        )
        .unwrap();
        assert_eq!(active_profile_element_count(&manifest), Some(1));
        fs::remove_dir_all(root).unwrap();
    }
}
