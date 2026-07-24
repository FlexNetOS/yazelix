#!/usr/bin/env nu
# FlexNetOS runner boot wrapper — idempotent mint → register → run.
#
# Why not just `run`: the runner's mutable state (.runner/.credentials) lives under
# profile-runtime, which is on /run (tmpfs) and is wiped on reboot. So a reboot-durable
# unit cannot merely restart a listener — it must re-register from a fresh token each boot.
# `config.sh --replace` makes re-registration idempotent against GitHub's view of the runner.
#
# This is the ExecStart target of the `gha-runner.service` systemd --user unit.
# The flake packages it as `flexnetos-runner-boot` in the active profile. Its
# runner launcher and mint script are exact store paths injected by the wrapper,
# so boot never depends on a mutable or tmpfs-backed source checkout.
#
# Owner fence: minting requires the envctl vault UNLOCKED at boot (USB-gated). If the vault
# is locked, mint fails closed and this wrapper exits non-zero — the unit will retry per its
# Restart= policy, and `systemctl --user status gha-runner` shows the wall. That is the correct
# fail-closed behavior; it must never fall back to a hardcoded or logged token.

def main [] {
    let nu_bin = ($env.GHA_NU? | default "")
    let mint_script = ($env.GHA_MINT_SCRIPT? | default "")
    let runner_launch = ($env.GHA_RUNNER_LAUNCH? | default "")

    if ($nu_bin | is-empty) or ($mint_script | is-empty) or ($runner_launch | is-empty) {
        print -e "[runner-boot] closure wiring is incomplete; install/run the flake's runner-service package."
        exit 2
    }

    let registration = (do { ^$runner_launch is-registered } | complete)
    if $registration.exit_code == 0 {
        print "[runner-boot] reusing registered profile-runtime state."
    } else {
        print "[runner-boot] minting registration token via envctl (never logged)…"
        let token = (^$nu_bin $mint_script | str trim)
        if ($token | is-empty) {
            print -e "[runner-boot] empty token — vault locked or App lacks organization_self_hosted_runners:write. Failing closed."
            exit 2
        }

        print "[runner-boot] registering runner (idempotent --replace)…"
        with-env { GHA_RUNNER_TOKEN: $token } {
            ^$runner_launch register
        }
    }

    print "[runner-boot] starting listener (executes all workflows)…"
    ^$runner_launch run
}
