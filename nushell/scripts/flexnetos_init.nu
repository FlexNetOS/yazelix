# FlexNetOS interactive behavior layered onto Yazelix Nova's packaged Nushell.

$env.config.show_banner = false
$env.PROMPT_COMMAND_RIGHT = {|| "" }

export alias lg = lazygit
export def clp [] { clip copy }

# Session-triggered runner autostart — nix-native, NO systemd, OFF by default.
# Enable with FLEXNETOS_RUNNER_AUTOSTART=1. No-op unless enabled; cheap liveness
# fast-path makes repeat shells free. See flexnetos_runner_autostart.nu.
use flexnetos_runner_autostart.nu flexnetos-runner-autostart
flexnetos-runner-autostart
