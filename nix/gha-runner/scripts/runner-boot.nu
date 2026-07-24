#!/usr/bin/env nu
# FlexNetOS runner boot wrapper — idempotent mint → register → run.
#
# Why not just `run`: the runner's mutable state (.runner/.credentials) lives under
# profile-runtime, which is on /run (tmpfs) and is wiped on reboot. So a reboot-durable
# unit cannot merely restart a listener — it must re-register from a fresh token each boot.
# `config.sh --replace` makes re-registration idempotent against GitHub's view of the runner.
#
# This is the ExecStart target of the `gha-runner.service` systemd --user unit.
# It runs entirely from the flake closure via `nix run` — no host PATH, no system units.
#
# Owner fence: minting requires the envctl vault UNLOCKED at boot (USB-gated). If the vault
# is locked, mint fails closed and this wrapper exits non-zero — the unit will retry per its
# Restart= policy, and `systemctl --user status gha-runner` shows the wall. That is the correct
# fail-closed behavior; it must never fall back to a hardcoded or logged token.

def flake-dir [] {
    # The flake lives beside this script (…/nix/gha-runner). Resolve from $env.FILE_PWD
    # when invoked by nu directly, else fall back to the unit's WorkingDirectory ($env.PWD).
    $env.GHA_FLAKE_DIR? | default $env.PWD
}

def main [] {
    let dir = (flake-dir)
    cd $dir

    print "[runner-boot] minting registration token via envctl (never logged)…"
    let token = (nu scripts/mint-runner-token.nu)
    if ($token | is-empty) {
        print -e "[runner-boot] empty token — vault locked or App lacks organization_self_hosted_runners:write. Failing closed."
        exit 2
    }

    print "[runner-boot] registering runner (idempotent --replace)…"
    with-env { GHA_RUNNER_TOKEN: $token } {
        nix run $".#register"
    }

    print "[runner-boot] starting listener (executes all workflows)…"
    nix run $".#runner" -- run
}
