use std::{ffi::OsString, path::Path};

use crate::{error::AppError, DESKTOP_ENTRY_SOURCE};

pub(crate) fn run(args: Vec<OsString>) -> Result<(), AppError> {
    let print_path = match args.as_slice() {
        [] => false,
        [flag] if flag == "--print-path" || flag == "-p" => true,
        _ => return Err(desktop_usage()),
    };
    let desktop_path = profile_desktop_path(DESKTOP_ENTRY_SOURCE)?;

    if print_path {
        println!("{}", desktop_path.display());
    } else {
        println!(
            "Profile-owned Yazelix desktop entry: {}",
            desktop_path.display()
        );
    }
    Ok(())
}

fn desktop_usage() -> AppError {
    AppError::Usage("Usage: yzx desktop [--print-path]\n".to_string())
}

fn profile_desktop_path(source: &str) -> Result<&Path, AppError> {
    if source.is_empty() {
        Err(AppError::Usage(
            "yzx desktop is unavailable in this package\n".to_string(),
        ))
    } else {
        Ok(Path::new(source))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn desktop_command_reports_one_profile_owned_entry() {
        let path =
            "/home/flexnetos/.nix-profile/share/applications/com.flexnetos.Yazelix.Agent.desktop";
        assert!(matches!(
            profile_desktop_path(path),
            Ok(actual) if actual == Path::new(path)
        ));
        assert!(matches!(profile_desktop_path(""), Err(AppError::Usage(_))));
    }
}
