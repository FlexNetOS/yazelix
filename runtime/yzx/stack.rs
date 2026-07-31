use std::process::Command;

use crate::{command::run_checked, error::AppError, YZX_STACK_BOOTSTRAP};

/// Start the complete FlexNetOS-owned stack before either managed terminal path.
///
/// The upstream runtime has no foundation services, so the empty substitution is
/// intentional for the upstream-compatible packages. The FlexNetOS foundation
/// substitutes a single Yazelix-owned bootstrap executable; no systemd unit,
/// external unlock hook, or manual rerun is part of this boundary.
pub(crate) fn bootstrap_owned_stack() -> Result<(), AppError> {
    if YZX_STACK_BOOTSTRAP.is_empty() {
        return Ok(());
    }

    run_checked(
        std::path::Path::new(YZX_STACK_BOOTSTRAP),
        &mut Command::new(YZX_STACK_BOOTSTRAP),
    )
    .map(|_| ())
}
