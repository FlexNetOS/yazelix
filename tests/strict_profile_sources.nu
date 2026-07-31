def main [root: path] {
    let source_root = ($root | path expand)
    # Anchored to the retired home tree itself. A bare "." + "local" substring also
    # matched innocent text such as "example.local", so the absolute and tilde forms
    # are matched instead -- the only two ways a source file can actually name it.
    # Patterns stay assembled from parts because this gate scans its own source.
    let retired_home_tree = (["/home/flexnetos/" "." "local"] | str join)
    let retired_home_tree_tilde = (["~/" "." "local"] | str join)
    # Same reasoning as the retired home tree above, applied to the agent overlays.
    # The bare "/" + "." + name form matched any path that merely CONTAINS the
    # segment -- including a reference into a pinned input, such as installing that
    # input's own committed policy file from its store path. That is a path inside
    # another repository, not an agent home on this host. The retired shadows are
    # home-rooted (see nushell/system/volatile_runtime.nu), so the absolute and
    # tilde forms are the only two ways a source file can actually name them.
    let retired_agent_home = (["/home/flexnetos/" "." "codex"] | str join)
    let retired_agent_home_tilde = (["~/" "." "codex"] | str join)
    let retired_claude_home = (["/home/flexnetos/" "." "claude"] | str join)
    let retired_claude_home_tilde = (["~/" "." "claude"] | str join)
    let text_extensions = ["" "conf" "json" "kdl" "lua" "md" "nix" "nu" "path" "rs" "service" "socket" "src" "toml" "yaml" "yml"]
    let candidates = (
        glob --no-dir ($source_root | path join "**/*")
        | where {|path|
            let relative = ($path | path relative-to $source_root)
            (($path | path type) == "file") and (not ($relative | str starts-with ".beads/")) and (not ($relative | str starts-with ".doctor/")) and (not ($relative | str starts-with ".git/")) and (not ($relative | str starts-with ".gitnexus/")) and (not ($relative | str ends-with ".lock")) and (($relative | path parse | get extension) in $text_extensions)
        }
    )
    # Upstream yazelix ships no systemd at all: at upstream/main 78d18c94 both
    # `git grep -i systemd upstream/main` and a tree scan for unit extensions return
    # empty. Upstream creates directories in-process (fs::create_dir_all) and resolves
    # runtime state from YAZELIX_STATE_DIR / $XDG_DATA_HOME/yazelix (upstream
    # ARCHITECTURE.md:266). Every unit here is therefore a fork addition.
    #
    # This is a PATH-SHAPE gate, not a content gate -- a unit is rejected for existing,
    # wherever it sits. A `systemd/` directory check alone is not enough, because
    # host-policy/nix-daemon.service sat outside that directory.
    let unit_extensions = ["service" "socket" "timer" "path"]
    let unit_files = (
        glob --no-dir ($source_root | path join "**/*")
        | where {|path|
            let relative = ($path | path relative-to $source_root)
            (($path | path type) == "file") and (not ($relative | str starts-with ".beads/")) and (not ($relative | str starts-with ".doctor/")) and (not ($relative | str starts-with ".git/")) and (not ($relative | str starts-with ".gitnexus/")) and ((($relative | path parse | get extension) in $unit_extensions) or ($relative | str starts-with "systemd/") or ($relative | str contains "/systemd/"))
        }
    )
    mut failures = []
    for path in $unit_files {
        $failures = ($failures | append {
            path: ($path | path relative-to $source_root)
            pattern: "systemd unit (fork addition; upstream ships none)"
        })
    }
    for path in $candidates {
        let raw = (open --raw $path)
        if ($raw | describe) == "string" {
            for pattern in [$retired_home_tree $retired_home_tree_tilde $retired_agent_home $retired_agent_home_tilde $retired_claude_home $retired_claude_home_tilde] {
                if ($raw | str contains $pattern) {
                    $failures = ($failures | append {
                        path: ($path | path relative-to $source_root)
                        pattern: $pattern
                    })
                }
            }
        }
    }
    if not ($failures | is-empty) {
        print --stderr ($failures | to json --indent 2)
        error make {msg: "strict profile source ownership gate failed"}
    }
    print $"ok strict profile source ownership: ($candidates | length) text files"
}
