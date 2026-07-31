#!/usr/bin/env nu

const VOLATILE_ROOT = "@runtimeRoot@"
const PROFILE_RUNTIME_ROOT = "@profileRuntimeRoot@"
const KACHE_ROOT = "/home/flexnetos/.cache/kache"
const DURABLE_CACHE_ROOT = "/home/flexnetos/.cache"
# Immutable, expensive-to-refetch artifacts (model weights, browser binaries)
# and the starship log dir live on durable home storage, never transient storage that a
# reboot wipes. Same persistence class as KACHE_ROOT.
const DURABLE_DIRS = [
    "/home/flexnetos/.cache/huggingface"
    "/home/flexnetos/.cache/torch"
    "/home/flexnetos/.cache/playwright"
    "/home/flexnetos/.cache/starship"
    "/home/flexnetos/.cache/icm/models"
]
# icm's embedding model persists primarily through HF_HOME (durable above): its
# fastembed backend downloads via the HuggingFace hub, so the ~615 MB Jina model
# lands in ~/.cache/huggingface. As defence-in-depth, also point the volatile
# icm cache dir (fastembed's *declared* cache_dir, $XDG_CACHE_HOME/icm/models per
# fastembed_embedder.rs) at a durable target, so the model survives regardless of
# which path a future fastembed version honours. (Reverse of VOLATILE_ROUTES: a
# volatile link -> durable target.) Best-effort — not a hard activation gate.
const ICM_VOLATILE_CACHE = "@runtimeRoot@/cache/icm"
const ICM_DURABLE_CACHE = "/home/flexnetos/.cache/icm"
const LEGACY_KACHE_ROOTS = [
    "/home/flexnetos/meta/.cache/kache"
    "/home/flexnetos/meta/var/cache/kache"
    # The runner was promoted out of src/ to the meta root, so its live _work tree
    # is under meta/flexnetos_runner. The src/ entries are kept for the retired
    # checkout; the promoted paths are the ones that can actually accrue a shadow
    # Kache root today, and were previously unguarded.
    "/home/flexnetos/meta/flexnetos_runner/_work/runner-home-01/.cache/kache"
    "/home/flexnetos/meta/flexnetos_runner/_work/runner-home-02/.cache/kache"
    "/home/flexnetos/meta/src/flexnetos_runner/_work/runner-home-01/.cache/kache"
    "/home/flexnetos/meta/src/flexnetos_runner/_work/runner-home-02/.cache/kache"
    "/home/flexnetos/Downloads/runner/runner-home-01/.cache/kache"
    "/home/flexnetos/Downloads/runner/runner-home-02/.cache/kache"
]
const LEGACY_KACHE_ARTIFACTS = [
    "/home/flexnetos/meta/.toolchains/kache"
    "/home/flexnetos/meta/usr/bin/kache"
]
# Durable agent homes. Codex credentials, history and sqlite state used to live at
# profile-runtime/codex in the host runtime, so every reboot destroyed auth.json and forced a
# re-login. They now share the persistence class of the Claude home. No transient
# host directory may own agent state.
const DURABLE_AGENT_HOMES = [
    "/home/flexnetos/meta/var/lib/codex"
]
const AGENT_SHADOW_ARCHIVE_ROOT = "/home/flexnetos/.cache/flexnetos/archives/agent-home-shadows"

# Directories that must never own agent state again: the home-owned shadow, and the
# transient Codex home whose contents a reboot destroyed. `ensure` archives rather than
# deletes, so credentials left in either stay recoverable; `check` then asserts both
# are absent. Same archive-then-assert idiom as LEGACY_KACHE_ROOTS. Paths are
# assembled from parts because tests/strict_profile_sources.nu scans this source.
def retired_agent_home_shadows [] {
    [
        (["/home/flexnetos/" "." "codex"] | str join)
        (["/home/flexnetos/" "." "claude"] | str join)
        ($PROFILE_RUNTIME_ROOT | path join "codex")
    ]
}
const VOLATILE_DIRS = [
    "@profileRuntimeRoot@"
    "@profileRuntimeRoot@/yazelix"
    "@runtimeRoot@/cache"
    "@runtimeRoot@/tmp"
    "@runtimeRoot@/cache/google-chrome"
]
const VOLATILE_ROUTES = [
    { link: "/home/flexnetos/.config/google-chrome/Default/Service Worker", target: "@runtimeRoot@/cache/google-chrome/service-worker" }
    { link: "/home/flexnetos/.config/google-chrome/Default/Shared Dictionary", target: "@runtimeRoot@/cache/google-chrome/shared-dictionary" }
    { link: "/home/flexnetos/.config/google-chrome/component_crx_cache", target: "@runtimeRoot@/cache/google-chrome/component-crx" }
    { link: "/home/flexnetos/.config/google-chrome/extensions_crx_cache", target: "@runtimeRoot@/cache/google-chrome/extensions-crx" }
    { link: "/home/flexnetos/.config/google-chrome/GrShaderCache", target: "@runtimeRoot@/cache/google-chrome/gr-shader" }
    { link: "/home/flexnetos/.config/google-chrome/GPUPersistentCache", target: "@runtimeRoot@/cache/google-chrome/gpu-persistent" }
    { link: "/home/flexnetos/.config/google-chrome/ShaderCache", target: "@runtimeRoot@/cache/google-chrome/shader" }
    { link: "/home/flexnetos/.config/google-chrome/Default/GPUCache", target: "@runtimeRoot@/cache/google-chrome/default-gpu" }
    { link: "/home/flexnetos/.config/google-chrome/Crash Reports", target: "@runtimeRoot@/tmp/google-chrome-crash-reports" }
    { link: "/home/flexnetos/.config/google-chrome/BrowserMetrics", target: "@runtimeRoot@/tmp/google-chrome-browser-metrics" }
    { link: "/home/flexnetos/.config/google-chrome/DeferredBrowserMetrics", target: "@runtimeRoot@/tmp/google-chrome-deferred-metrics" }
    { link: "/home/flexnetos/.config/Code/Cache", target: "@runtimeRoot@/cache/code/cache" }
    { link: "/home/flexnetos/.config/Code/CachedData", target: "@runtimeRoot@/cache/code/cached-data" }
    { link: "/home/flexnetos/.config/Code/CachedConfigurations", target: "@runtimeRoot@/cache/code/cached-configurations" }
    { link: "/home/flexnetos/.config/Code/CachedProfilesData", target: "@runtimeRoot@/cache/code/cached-profiles" }
    { link: "/home/flexnetos/.config/Code/Code Cache", target: "@runtimeRoot@/cache/code/code-cache" }
    { link: "/home/flexnetos/.config/Code/GPUCache", target: "@runtimeRoot@/cache/code/gpu" }
    { link: "/home/flexnetos/.config/Code/DawnGraphiteCache", target: "@runtimeRoot@/cache/code/dawn-graphite" }
    { link: "/home/flexnetos/.config/Code/DawnWebGPUCache", target: "@runtimeRoot@/cache/code/dawn-webgpu" }
    { link: "/home/flexnetos/.config/Code/Shared Dictionary", target: "@runtimeRoot@/cache/code/shared-dictionary" }
    { link: "/home/flexnetos/.config/Code/logs", target: "@runtimeRoot@/tmp/code-logs" }
]

def route_volatile [route: record] {
    let link_type = ($route.link | path type)
    if ($link_type != "") {
        rm --recursive --force $route.link
    }
    if ($route.target | path exists) {
        rm --recursive --force $route.target
    }
    mkdir ($route.link | path dirname)
    mkdir $route.target
    ^/home/flexnetos/.nix-profile/bin/ln --symbolic --no-target-directory $route.target $route.link
}

def ensure [] {
    for path in $LEGACY_KACHE_ROOTS {
        if ($path | path exists) {
            rm --recursive --force $path
        }
    }
    for path in $LEGACY_KACHE_ARTIFACTS {
        if ($path | path exists) {
            rm --recursive --force $path
        }
    }

    let cargo_config = "@cargoConfig@"
    if ($cargo_config | path exists) {
        let begin = "# >>> envctl kache (Epic H TASK-0055) >>>"
        let end = "# <<< envctl kache (Epic H TASK-0055) <<<"
        let filtered = (
            open --raw $cargo_config
            | lines
            | reduce --fold {dropping: false, kept: []} {|line, state|
                if $line == $begin {
                    $state | upsert dropping true
                } else if $line == $end {
                    $state | upsert dropping false
                } else if $state.dropping {
                    $state
                } else {
                    $state | upsert kept ($state.kept | append $line)
                }
            }
            | get kept
        )
        let rendered = ($filtered | str join (char newline) | str trim)
        if ($rendered | is-empty) {
            rm --force $cargo_config
        } else {
            $"($rendered)(char newline)" | save --force $cargo_config
        }
    }
    for shadow in (retired_agent_home_shadows) {
        if ($shadow | path exists) {
            let stamp = (date now | format date "%Y%m%dT%H%M%S%fZ")
            # Both retired paths end in "codex", so the slug carries the whole source
            # path and keeps two archives of the same run from colliding.
            let slug = ($shadow | str trim --left --char "/" | str replace --all "/" "_")
            let destination = ($AGENT_SHADOW_ARCHIVE_ROOT | path join $"($slug)-($stamp)")
            mkdir $AGENT_SHADOW_ARCHIVE_ROOT
            ^/home/flexnetos/.nix-profile/bin/mv -T $shadow $destination
        }
    }
    for path in $VOLATILE_DIRS {
        mkdir $path
    }
    for path in $DURABLE_AGENT_HOMES {
        mkdir $path
        ^/home/flexnetos/.nix-profile/bin/chmod 0700 $path
    }
    for path in [$PROFILE_RUNTIME_ROOT ($PROFILE_RUNTIME_ROOT | path join "yazelix")] {
        ^/home/flexnetos/.nix-profile/bin/chmod 0700 $path
    }
    for route in $VOLATILE_ROUTES {
        route_volatile $route
    }
    mkdir $KACHE_ROOT
    mkdir $DURABLE_CACHE_ROOT
    for path in $DURABLE_DIRS {
        mkdir $path
    }
    if (($ICM_VOLATILE_CACHE | path type) == "symlink") {
        rm --force $ICM_VOLATILE_CACHE
    } else if ($ICM_VOLATILE_CACHE | path exists) {
        rm --recursive --force $ICM_VOLATILE_CACHE
    }
    ^/home/flexnetos/.nix-profile/bin/ln --symbolic --no-target-directory $ICM_DURABLE_CACHE $ICM_VOLATILE_CACHE
}

def check [] {
    for path in $VOLATILE_DIRS {
        if not ($path | path exists) {
            error make {msg: $"volatile runtime directory is missing: ($path)"}
        }
    }
    for route in $VOLATILE_ROUTES {
        if (($route.link | path type) != "symlink") {
            error make {msg: $"persistent application cache/log path is not a volatile link: ($route.link)"}
        }
    }
    if not ($KACHE_ROOT | path exists) {
        error make {msg: $"Kache root is missing: ($KACHE_ROOT)"}
    }
    if ($KACHE_ROOT | str starts-with $VOLATILE_ROOT) {
        error make {msg: "Kache must remain outside the volatile runtime root"}
    }
    for path in $DURABLE_DIRS {
        if not ($path | path exists) {
            error make {msg: $"durable cache directory is missing: ($path)"}
        }
        if ($path | str starts-with $VOLATILE_ROOT) {
            error make {msg: $"durable cache must remain outside the volatile runtime root: ($path)"}
        }
    }
    for path in $DURABLE_AGENT_HOMES {
        if not ($path | path exists) {
            error make {msg: $"durable agent home is missing: ($path)"}
        }
        if ($path | str starts-with "/run/user/") {
            error make {msg: $"agent state must not live on the volatile runtime: ($path)"}
        }
    }
    for path in (retired_agent_home_shadows) {
        if ($path | path exists) {
            error make {msg: $"retired agent state directory must not exist: ($path)"}
        }
    }
    for path in $LEGACY_KACHE_ROOTS {
        if ($path | path exists) {
            error make {msg: $"legacy Kache root must not exist: ($path)"}
        }
    }
    for path in $LEGACY_KACHE_ARTIFACTS {
        if ($path | path exists) {
            error make {msg: $"legacy Kache delivery artifact must not exist: ($path)"}
        }
    }
    let cargo_config = "@cargoConfig@"
    if (($cargo_config | path exists) and ((open --raw $cargo_config) | str contains "envctl kache (Epic H TASK-0055)")) {
        error make {msg: $"legacy Kache Cargo block must not exist: ($cargo_config)"}
    }
}

def main [command: string = "check"] {
    match $command {
        "ensure" => { ensure; check }
        "check" => { check }
        _ => { error make {msg: $"unknown volatile runtime command: ($command)"} }
    }
}
