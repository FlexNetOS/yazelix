#!/usr/bin/env nu
# FlexNetOS rUv-native GitHub runner launcher — Nushell, zero OS deps.
#
# Path law: work/config lives under the profile-runtime link, NEVER ~/.local.
# Secret law: the registration token is minted by envctl and read from the
#   environment (GHA_RUNNER_TOKEN); it is never hardcoded, logged, or persisted here.
# Runtime law: the harness (plain-ESM bin/cli.js) runs via `bun run`, never bare node/npx.
#
# Grounded rUv commands (metaharness primer / ruv-drone bin/cli.js):
#   <harness> init    — boot the kernel + github-actions host adapter, report status
#   <harness> doctor  — verify the install end-to-end (kernel + host resolve)

def profile-runtime [] {
    let base = ($env.XDG_RUNTIME_DIR? | default "/run/user/1001")
    $"($base)/yazelix/profile-runtime"
}

def work-dir [] {
    let d = $"(profile-runtime)/gha-runner"
    mkdir $d
    $d
}

# Resolve the harness bin from the nix build output on PATH, or the local scaffold.
def harness-cli [] {
    let local = ($env.PWD | path join "harness" "bin" "cli.js")
    if ($local | path exists) { $local } else { "flexnetos-runner" }
}

def main [
    command: string = "doctor"   # doctor | init | run
] {
    let wd = (work-dir)
    print $"[flexnetos-runner] work-dir: ($wd)  (path-law: profile-runtime, not ~/.local)"

    if ($env.GHA_RUNNER_TOKEN? | is-empty) {
        print "[flexnetos-runner] GHA_RUNNER_TOKEN is unset."
        print "  Mint it via envctl (sole secret boundary), then re-run. This launcher never stores it."
        exit 2
    }

    let cli = (harness-cli)
    match $command {
        "doctor" => { ^bun run $cli doctor }
        "init"   => { with-env { RUNNER_WORKDIR: $wd } { ^bun run $cli init } }
        "run"    => { with-env { RUNNER_WORKDIR: $wd } { ^bun run $cli run --gha-mode } }
        _ => {
            print $"[flexnetos-runner] unknown command: ($command) — expected doctor|init|run"
            exit 2
        }
    }
}
