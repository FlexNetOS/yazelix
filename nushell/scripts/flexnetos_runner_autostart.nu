# FlexNetOS self-hosted runner — session autostart (nix-native, NO systemd, opt-in).
#
# This is the "session-triggered" resolution of tasks/gha-runner-nix-native-persistence:
# under NO_SYSTEM_DEPTHS a user process cannot be started at raw boot without a system
# depth (systemd/linger/cron@reboot/DM-autostart). The maximal alternative is to bring the
# runner up when the owner's yazelix session comes up — via the passive nix-store entry
# `nix run <flexnetos_runner>/nix/gha-runner#start`, which mints → registers (--replace) → runs.
#
# OFF BY DEFAULT. A self-hosted runner executes arbitrary org CI jobs, so activation is a
# deliberate owner choice — set `FLEXNETOS_RUNNER_AUTOSTART=1` to enable. Follows rUv's
# daemon-autostart contract (ruflo/v3/@claude-flow/cli/src/services/daemon-autostart.ts):
# single-instance via a liveness check, best-effort, silent — it never blocks or fails the shell.

# Bring the runner up once per session if enabled and not already running. Safe to call from
# every interactive shell: the liveness fast-path makes repeat calls a cheap no-op.
export def flexnetos-runner-autostart [] {
    let enabled = ($env.FLEXNETOS_RUNNER_AUTOSTART? | default "0")
    if $enabled not-in ["1" "true" "yes" "on"] { return }

    # The canonical runner flake (promoted to the meta root). Absent → nothing to start.
    let flake = ($env.FLEXNETOS_RUNNER_FLAKE? | default "/home/flexnetos/meta/flexnetos_runner/nix/gha-runner")
    if not ($flake | path exists) { return }

    # Single-instance: if a listener is already running, this session has nothing to do.
    let alive = ((^pgrep -f "Runner.Listener run" | complete).exit_code == 0)
    if $alive { return }

    let rt = ($env.XDG_RUNTIME_DIR? | default "/run/user/1001")
    let dir = $"($rt)/yazelix/profile-runtime/gha-runner"
    mkdir $dir
    let log = $"($dir)/autostart.log"

    # Detached (setsid, new session) so the runner outlives this shell; best-effort — if the
    # mint fails closed (vault locked / no token), `nix run …#start` exits non-zero into the
    # log and the session is unaffected. The token is never logged by the start closure.
    ^setsid --fork sh -c $"exec nix run ($flake)#start >> ($log) 2>&1"
}
