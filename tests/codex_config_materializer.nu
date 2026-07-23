# Contract check for the Codex config, rules, and hooks materializer (YZXCONV-004)
#
# Proves:
#   1. all three reviewed inputs exist and satisfy their format contracts
#   2. source-only materialization is deterministic for all three outputs
#   3. every output carries its source hash, generated marker, and mode 0644
#   4. every input and staged output validates before any live file changes
#   5. forbidden paths and malformed or missing inputs fail closed
#   6. reviewed top-level tables replace stale live tables while live-only runtime
#      tables and unrelated hooks survive
#   7. legacy v1 recovery and interruptions after either early publication restore
#      the exact prior three-file generation

def fail [message: string] {
    print --stderr $"codex materializer contract: ($message)"
    exit 1
}

def invoke-materializer [materializer: path, config_src: path, config_out: path, rules_src: path, rules_out: path, hooks_src: path, hooks_out: path] {
    do { ^$nu.current-exe $materializer $config_src $config_out $rules_src $rules_out $hooks_src $hooks_out } | complete
}

def expect-config-reject [materializer: path, workdir: path, rules_src: path, hooks_src: path, label: string, content: string] {
    let config_src = ($workdir | path join $"reject-config-($label).toml.src")
    $content | save --force --raw $config_src
    let config_out = ($workdir | path join $"reject-config-($label).toml")
    let rules_out = ($workdir | path join $"reject-config-($label).md")
    let hooks_out = ($workdir | path join $"reject-config-($label).json")
    let result = (invoke-materializer $materializer $config_src $config_out $rules_src $rules_out $hooks_src $hooks_out)
    if $result.exit_code == 0 {
        fail $"materializer accepted forbidden config input: ($label)"
    }
    if ($config_out | path exists) or ($rules_out | path exists) or ($hooks_out | path exists) {
        fail $"materializer wrote output despite rejecting config input: ($label)"
    }
}

def expect-rules-reject [materializer: path, workdir: path, config_src: path, hooks_src: path, label: string, content: string] {
    let rules_src = ($workdir | path join $"reject-rules-($label).md.src")
    $content | save --force --raw $rules_src
    let config_out = ($workdir | path join $"reject-rules-($label).toml")
    let rules_out = ($workdir | path join $"reject-rules-($label).md")
    let hooks_out = ($workdir | path join $"reject-rules-($label).json")
    let result = (invoke-materializer $materializer $config_src $config_out $rules_src $rules_out $hooks_src $hooks_out)
    if $result.exit_code == 0 {
        fail $"materializer accepted malformed rules input: ($label)"
    }
    if ($config_out | path exists) or ($rules_out | path exists) or ($hooks_out | path exists) {
        fail $"materializer wrote output despite rejecting rules input: ($label)"
    }
}

def expect-hooks-reject [materializer: path, workdir: path, config_src: path, rules_src: path, label: string, content: string] {
    let hooks_src = ($workdir | path join $"reject-hooks-($label).json.src")
    $content | save --force --raw $hooks_src
    let config_out = ($workdir | path join $"reject-hooks-($label).toml")
    let rules_out = ($workdir | path join $"reject-hooks-($label).md")
    let hooks_out = ($workdir | path join $"reject-hooks-($label).json")
    let result = (invoke-materializer $materializer $config_src $config_out $rules_src $rules_out $hooks_src $hooks_out)
    if $result.exit_code == 0 {
        fail $"materializer accepted malformed hooks input: ($label)"
    }
    if ($config_out | path exists) or ($rules_out | path exists) or ($hooks_out | path exists) {
        fail $"materializer wrote output despite rejecting hooks input: ($label)"
    }
}

def main [root: path] {
    let materializer = ($root | path join "nushell/scripts/materialize_codex_config.nu")
    let config_src = ($root | path join "agent_configs/codex/config.toml.src")
    let rules_src = ($root | path join "agent_configs/codex/RULES.md.src")
    let hooks_src = ($root | path join "agent_configs/codex/hooks.json.src")
    for required in [$materializer $config_src $rules_src $hooks_src] {
        if not ($required | path exists) {
            fail $"required source missing: ($required)"
        }
    }

    let config_raw = (open --raw $config_src)
    try { $config_raw | from toml | ignore } catch {
        fail "reviewed config input is not valid TOML"
    }
    let retired_home_tree = (["." "local"] | str join)
    let forbidden = [
        "/home/flexnetos/FlexNetOS"
        "/nix/store/"
        "/nix/var/nix/profiles/"
        $retired_home_tree
    ]
    for pattern in $forbidden {
        if ($config_raw | str contains $pattern) or ((open --raw $hooks_src) | str contains $pattern) {
            fail $"reviewed input contains forbidden path ($pattern)"
        }
    }

    let rules_raw = (open --raw $rules_src)
    if not ($rules_raw | str starts-with "# FlexNetOS Codex Durable Rules\n") {
        fail "reviewed rules input lacks the durable rules heading"
    }
    let hooks_raw = (open --raw $hooks_src)
    let hooks_declared = (try { $hooks_raw | from json } catch {
        fail "reviewed hooks input is not valid JSON"
    })
    let required_events = ["PreCompact" "PreToolUse" "SessionStart" "Stop" "UserPromptSubmit"]
    if ($hooks_declared.hooks | columns | sort) != $required_events {
        fail "reviewed hooks input does not declare the exact lifecycle event set"
    }
    if $hooks_declared.hooks.PreToolUse.0.matcher != "^Bash$" {
        fail "reviewed PreToolUse hook does not match only Bash"
    }
    let hook_commands = ($hooks_declared.hooks | values | flatten | get hooks | flatten | get command | sort)
    let required_commands = [
        "/home/flexnetos/.nix-profile/bin/icm hook compact"
        "/home/flexnetos/.nix-profile/bin/icm hook end"
        "/home/flexnetos/.nix-profile/bin/icm hook pre"
        "/home/flexnetos/.nix-profile/bin/icm hook prompt"
        "/home/flexnetos/.nix-profile/bin/icm hook start"
        "/home/flexnetos/.nix-profile/bin/rtk hook codex"
    ]
    if $hook_commands != $required_commands {
        fail "reviewed hooks input does not use the exact profile-owned RTK and ICM commands"
    }
    if ($hooks_declared | columns | any {|column| $column =~ '(?i)trust' }) {
        fail "reviewed hooks input attempts to author Codex trust state"
    }

    let workdir = (mktemp --directory --tmpdir "codex-materializer-check.XXXXXX")
    let config_out_a = ($workdir | path join "a" "config.toml")
    let config_out_b = ($workdir | path join "b" "config.toml")
    let rules_out_a = ($workdir | path join "a" "RULES.md")
    let rules_out_b = ($workdir | path join "b" "RULES.md")
    let hooks_out_a = ($workdir | path join "a" "hooks.json")
    let hooks_out_b = ($workdir | path join "b" "hooks.json")
    for pair in [
        {config: $config_out_a, rules: $rules_out_a, hooks: $hooks_out_a}
        {config: $config_out_b, rules: $rules_out_b, hooks: $hooks_out_b}
    ] {
        let result = (invoke-materializer $materializer $config_src $pair.config $rules_src $pair.rules $hooks_src $pair.hooks)
        if $result.exit_code != 0 {
            fail $"materializer failed on reviewed inputs: ($result.stderr)"
        }
    }

    let config_hash_a = (open --raw $config_out_a | hash sha256)
    let config_hash_b = (open --raw $config_out_b | hash sha256)
    let rules_hash_a = (open --raw $rules_out_a | hash sha256)
    let rules_hash_b = (open --raw $rules_out_b | hash sha256)
    let hooks_hash_a = (open --raw $hooks_out_a | hash sha256)
    let hooks_hash_b = (open --raw $hooks_out_b | hash sha256)
    if $config_hash_a != $config_hash_b {
        fail $"non-deterministic config output: ($config_hash_a) vs ($config_hash_b)"
    }
    if $rules_hash_a != $rules_hash_b {
        fail $"non-deterministic rules output: ($rules_hash_a) vs ($rules_hash_b)"
    }
    if $hooks_hash_a != $hooks_hash_b {
        fail $"non-deterministic hooks output: ($hooks_hash_a) vs ($hooks_hash_b)"
    }

    let rendered_config = (open --raw $config_out_a)
    try { $rendered_config | from toml | ignore } catch {
        fail "materialized config output is not valid TOML"
    }
    if not ($rendered_config | str contains "GENERATED by yazelix codex config materializer") {
        fail "materialized config output lacks its generated marker"
    }
    let source_config_hash = ($config_raw | hash sha256)
    if not ($rendered_config | str contains $"# source_sha256 = ($source_config_hash)") {
        fail "materialized config output lacks its exact source hash"
    }
    if not ($rendered_config | str contains "# runtime_projection_sha256 = ") {
        fail "materialized config output lacks its runtime projection hash"
    }
    let rendered_rules = (open --raw $rules_out_a)
    if not ($rendered_rules | str contains "GENERATED by yazelix codex rules materializer") {
        fail "materialized rules output lacks its generated marker"
    }
    if not ($rendered_rules | str contains "# FlexNetOS Codex Durable Rules") {
        fail "materialized rules output lacks its durable rules body"
    }
    let source_rules_hash = ($rules_raw | hash sha256)
    if not ($rendered_rules | str contains $"<!-- source_sha256 = ($source_rules_hash) -->") {
        fail "materialized rules output lacks its exact source hash"
    }
    let rendered_hooks_raw = (open --raw $hooks_out_a)
    let rendered_hooks = (try { $rendered_hooks_raw | from json } catch {
        fail "materialized hooks output is not valid JSON"
    })
    if not ($rendered_hooks.description | str contains "GENERATED by yazelix codex hooks materializer") {
        fail "materialized hooks output lacks its generated marker"
    }
    let source_hooks_hash = ($hooks_raw | hash sha256)
    if not ($rendered_hooks.description | str contains $"source_sha256 = ($source_hooks_hash)") {
        fail "materialized hooks output lacks its exact source hash"
    }
    if not ($rendered_hooks.description | str contains "/home/flexnetos/.nix-profile/share/yazelix/agent_configs/codex/hooks.json.src") {
        fail "materialized hooks output lacks its exact profile-owned authorship input"
    }
    if ($rendered_hooks | columns | any {|column| $column =~ '(?i)trust' }) {
        fail "materialized hooks output attempts to author Codex trust state"
    }
    for output in [$config_out_a $rules_out_a $hooks_out_a $config_out_b $rules_out_b $hooks_out_b] {
        let mode = (ls -l $output | get mode.0)
        if $mode != "rw-r--r--" {
            fail $"materialized output mode is not 0644: ($output) mode=($mode)"
        }
    }

    expect-config-reject $materializer $workdir $rules_src $hooks_src "retired-workspace" ('[projects."/home/flexnetos/FlexNetOS"]' + "\ntrust_level = \"trusted\"\n")
    expect-config-reject $materializer $workdir $rules_src $hooks_src "raw-store-pin" ("[mcp_servers.icm]\ncommand = \"/nix/store/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa-icm-0.0.1/bin/icm\"\n")
    expect-config-reject $materializer $workdir $rules_src $hooks_src "system-profile-pin" ("[mcp_servers.icm]\ncommand = \"/nix/var/nix/profiles/default/bin/icm\"\n")
    let retired_home_tree = (["." "local"] | str join)
    expect-config-reject $materializer $workdir $rules_src $hooks_src "retired-home-shadow" ($"[mcp_servers.icm]\ncommand = \"/home/flexnetos/($retired_home_tree)/bin/icm\"\n")
    expect-config-reject $materializer $workdir $rules_src $hooks_src "bare-icm-shadow" ("[mcp_servers.icm]\ncommand = \"icm\"\n")
    expect-config-reject $materializer $workdir $rules_src $hooks_src "system-icm-shadow" ("[mcp_servers.icm]\ncommand = \"/usr/bin/icm\"\n")
    expect-config-reject $materializer $workdir $rules_src $hooks_src "invalid-toml" "[unterminated\n"
    expect-rules-reject $materializer $workdir $config_src $hooks_src "missing-heading" "# Different Rules\n"
    expect-rules-reject $materializer $workdir $config_src $hooks_src "generated-input" "# FlexNetOS Codex Durable Rules\nGENERATED by yazelix codex rules materializer\n"
    expect-hooks-reject $materializer $workdir $config_src $rules_src "invalid-json" "["
    expect-hooks-reject $materializer $workdir $config_src $rules_src "inactive-rtk" ($hooks_raw | str replace "/home/flexnetos/.nix-profile/bin/rtk" "/usr/bin/rtk")
    expect-hooks-reject $materializer $workdir $config_src $rules_src "missing-stop" ($hooks_declared | reject hooks.Stop | to json --indent 2)
    expect-hooks-reject $materializer $workdir $config_src $rules_src "generated-input" ($hooks_raw | str replace "FlexNetOS profile-owned" "GENERATED by yazelix codex hooks materializer")

    let missing_config = (invoke-materializer $materializer ($workdir | path join "missing.toml.src") ($workdir | path join "never-config.toml") $rules_src ($workdir | path join "never-rules.md") $hooks_src ($workdir | path join "never-hooks.json"))
    if $missing_config.exit_code == 0 {
        fail "materializer accepted a missing config input"
    }
    let missing_rules = (invoke-materializer $materializer $config_src ($workdir | path join "never-config-2.toml") ($workdir | path join "missing-rules.md.src") ($workdir | path join "never-rules-2.md") $hooks_src ($workdir | path join "never-hooks-2.json"))
    if $missing_rules.exit_code == 0 {
        fail "materializer accepted a missing rules input"
    }
    let missing_hooks = (invoke-materializer $materializer $config_src ($workdir | path join "never-config-3.toml") $rules_src ($workdir | path join "never-rules-3.md") ($workdir | path join "missing-hooks.json.src") ($workdir | path join "never-hooks-3.json"))
    if $missing_hooks.exit_code == 0 {
        fail "materializer accepted a missing hooks input"
    }

    let sentinel_config = ($workdir | path join "sentinel" "config.toml")
    let sentinel_rules = ($workdir | path join "sentinel" "RULES.md")
    let sentinel_hooks = ($workdir | path join "sentinel" "hooks.json")
    mkdir ($sentinel_config | path dirname)
    "preserve-config" | save --raw $sentinel_config
    "preserve-rules" | save --raw $sentinel_rules
    '{"description":"preserve-hooks","hooks":{}}' | save --raw $sentinel_hooks
    let invalid_rules = ($workdir | path join "invalid-rules.md.src")
    "# Wrong heading\n" | save --raw $invalid_rules
    let failed_update = (invoke-materializer $materializer $config_src $sentinel_config $invalid_rules $sentinel_rules $hooks_src $sentinel_hooks)
    if $failed_update.exit_code == 0 {
        fail "materializer accepted invalid rules during an update"
    }
    if (open --raw $sentinel_config) != "preserve-config" or (open --raw $sentinel_rules) != "preserve-rules" or (open --raw $sentinel_hooks) != '{"description":"preserve-hooks","hooks":{}}' {
        fail "materializer changed an existing output before all inputs validated"
    }

    let split_config = ($workdir | path join "split-a" "config.toml")
    let split_rules = ($workdir | path join "split-b" "RULES.md")
    let split_hooks = ($workdir | path join "split-a" "hooks.json")
    let split_result = (invoke-materializer $materializer $config_src $split_config $rules_src $split_rules $hooks_src $split_hooks)
    if $split_result.exit_code == 0 {
        fail "materializer accepted outputs in different directories"
    }
    if ($split_config | path exists) or ($split_rules | path exists) or ($split_hooks | path exists) {
        fail "materializer changed output while rejecting a split-directory transaction"
    }

    let merge_dir = ($workdir | path join "merge-existing")
    mkdir $merge_dir
    let merge_config = ($merge_dir | path join "config.toml")
    let merge_rules = ($merge_dir | path join "RULES.md")
    let merge_hooks = ($merge_dir | path join "hooks.json")
    [
        'approvals_reviewer = "runtime-stale"'
        ''
        '[runtime_only]'
        'token = "keep"'
        ''
        '[projects."/home/flexnetos/FlexNetOS"]'
        'trust_level = "trusted"'
        ''
        '[hooks.state."fixture"]'
        'trusted_hash = "sha256:keep"'
        ''
    ] | str join "\n" | save --raw $merge_config
    "prior rules\n" | save --raw $merge_rules
    {
        description: "unrelated description"
        extension: {keep: true}
        hooks: {
            PreToolUse: [{matcher: "^Bash$", hooks: [
                {type: "command", command: "/opt/custom/pre"}
                {type: "command", command: "/home/flexnetos/.nix-profile/bin/rtk hook codex"}
            ]}]
            PermissionRequest: [{matcher: "^Bash$", hooks: [{type: "command", command: "/opt/custom/permission"}]}]
            PostToolUse: [{matcher: "^Bash$", hooks: [{type: "command", command: "/home/flexnetos/.nix-profile/bin/icm hook post"}]}]
            Stop: [{hooks: [
                {type: "command", command: "/opt/custom/stop"}
                {type: "command", command: "/home/flexnetos/.nix-profile/bin/icm hook end"}
            ]}]
        }
    } | to json --indent 2 | save --raw $merge_hooks
    let merge_result = (invoke-materializer $materializer $config_src $merge_config $rules_src $merge_rules $hooks_src $merge_hooks)
    if $merge_result.exit_code != 0 {
        fail $"materializer failed while preserving runtime-only config: ($merge_result.stderr)"
    }
    let merged = (open --raw $merge_config | from toml)
    if $merged.approvals_reviewer != "user" {
        fail "reviewed root preference did not replace stale runtime value"
    }
    if $merged.runtime_only.token != "keep" or $merged.hooks.state.fixture.trusted_hash != "sha256:keep" {
        fail "live-only runtime tables were not preserved"
    }
    if ($merged.projects | columns | any {|name| $name == "/home/flexnetos/FlexNetOS" }) {
        fail "reviewed projects table did not replace the retired live table"
    }
    let merged_hooks = (open --raw $merge_hooks | from json)
    if $merged_hooks.extension.keep != true {
        fail "unrelated hooks metadata was not preserved"
    }
    let merged_hook_commands = ($merged_hooks.hooks | values | flatten | get hooks | flatten | get command)
    for command in ["/opt/custom/pre" "/opt/custom/permission" "/opt/custom/stop"] {
        if $command not-in $merged_hook_commands {
            fail $"unrelated hook was not preserved: ($command)"
        }
    }
    for command in $required_commands {
        if ($merged_hook_commands | where {|candidate| $candidate == $command } | length) != 1 {
            fail $"profile-owned hook is missing or duplicated after merge: ($command)"
        }
    }
    if ($merged_hook_commands | where {|candidate| $candidate == "/home/flexnetos/.nix-profile/bin/icm hook post" } | length) != 1 {
        fail "explicitly opted-in Codex PostToolUse hook was not preserved"
    }
    let first_merge_hash = (open --raw $merge_hooks | hash sha256)
    let repeated_merge = (invoke-materializer $materializer $config_src $merge_config $rules_src $merge_rules $hooks_src $merge_hooks)
    if $repeated_merge.exit_code != 0 or (open --raw $merge_hooks | hash sha256) != $first_merge_hash {
        fail "repeated hooks publication was not idempotent"
    }

    for crash_point in ["config" "rules" "hooks"] {
        let rollback_dir = ($workdir | path join $"rollback-($crash_point)")
        mkdir $rollback_dir
        let rollback_config = ($rollback_dir | path join "config.toml")
        let rollback_rules = ($rollback_dir | path join "RULES.md")
        let rollback_hooks = ($rollback_dir | path join "hooks.json")
        [
            'approvals_reviewer = "prior"'
            ''
            '[runtime_only]'
            'token = "prior"'
            ''
        ] | str join "\n" | save --raw $rollback_config
        "prior rules\n" | save --raw $rollback_rules
        '{"description":"prior hooks","hooks":{}}' | save --raw $rollback_hooks
        let prior_hashes = {
            config: (open --raw $rollback_config | hash sha256)
            rules: (open --raw $rollback_rules | hash sha256)
            hooks: (open --raw $rollback_hooks | hash sha256)
        }
        let interrupted_result = if $crash_point == "config" {
            with-env {YAZELIX_TEST_CRASH_AFTER_CONFIG_REPLACE: "1"} {
                invoke-materializer $materializer $config_src $rollback_config $rules_src $rollback_rules $hooks_src $rollback_hooks
            }
        } else if $crash_point == "rules" {
            with-env {YAZELIX_TEST_CRASH_AFTER_RULES_REPLACE: "1"} {
                invoke-materializer $materializer $config_src $rollback_config $rules_src $rollback_rules $hooks_src $rollback_hooks
            }
        } else {
            with-env {YAZELIX_TEST_CRASH_AFTER_HOOKS_REPLACE: "1"} {
                invoke-materializer $materializer $config_src $rollback_config $rules_src $rollback_rules $hooks_src $rollback_hooks
            }
        }
        let expected_status = if $crash_point == "config" { 86 } else if $crash_point == "rules" { 87 } else { 88 }
        if $interrupted_result.exit_code != $expected_status {
            fail $"injected ($crash_point) interruption returned unexpected status: ($interrupted_result.exit_code)"
        }
        let journal = ($rollback_dir | path join ".yazelix-codex-transaction.json")
        if not ($journal | path exists) {
            fail $"interrupted ($crash_point) publication did not retain its durable recovery journal"
        }
        let recovery_result = (do {
            ^$nu.current-exe $materializer $config_src $rollback_config $rules_src $rollback_rules $hooks_src $rollback_hooks --recover-only
        } | complete)
        if $recovery_result.exit_code != 0 {
            fail $"durable ($crash_point) recovery failed: ($recovery_result.stderr)"
        }
        if (open --raw $rollback_config | hash sha256) != $prior_hashes.config or (open --raw $rollback_rules | hash sha256) != $prior_hashes.rules or (open --raw $rollback_hooks | hash sha256) != $prior_hashes.hooks {
            fail $"($crash_point) interruption recovery did not restore the exact prior output set"
        }
        let leftovers = (ls -a $rollback_dir | where {|entry| $entry.name | str contains ".yazelix-" })
        if not ($leftovers | is-empty) {
            fail $"($crash_point) interruption recovery left a journal, stage, or backup file"
        }
    }

    let legacy_dir = ($workdir | path join "legacy-v1-recovery")
    mkdir $legacy_dir
    let legacy_config = ($legacy_dir | path join "config.toml")
    let legacy_rules = ($legacy_dir | path join "RULES.md")
    let legacy_hooks = ($legacy_dir | path join "hooks.json")
    "new config\n" | save --raw $legacy_config
    "new rules\n" | save --raw $legacy_rules
    '{"description":"untouched hooks","hooks":{}}' | save --raw $legacy_hooks
    let legacy_hooks_hash = (open --raw $legacy_hooks | hash sha256)
    let legacy_token = "deadbeef-0000"
    "prior config\n" | save --raw ($legacy_dir | path join $".config.toml.yazelix-backup-($legacy_token)")
    "prior rules\n" | save --raw ($legacy_dir | path join $".RULES.md.yazelix-backup-($legacy_token)")
    {
        schema: "yazelix.codex-config-transaction.v1"
        token: $legacy_token
        config_name: "config.toml"
        rules_name: "RULES.md"
        had_config: true
        had_rules: true
    } | to json --indent 2 | save --raw ($legacy_dir | path join ".yazelix-codex-transaction.json")
    let legacy_recovery = (do {
        ^$nu.current-exe $materializer $config_src $legacy_config $rules_src $legacy_rules $hooks_src $legacy_hooks --recover-only
    } | complete)
    if $legacy_recovery.exit_code != 0 or (open --raw $legacy_config) != "prior config\n" or (open --raw $legacy_rules) != "prior rules\n" {
        fail "legacy v1 transaction did not restore its prior config/rules pair"
    }
    if (open --raw $legacy_hooks | hash sha256) != $legacy_hooks_hash {
        fail "legacy v1 transaction recovery changed hooks that were outside its schema"
    }
    let legacy_leftovers = (ls -a $legacy_dir | where {|entry| $entry.name | str contains ".yazelix-" })
    if not ($legacy_leftovers | is-empty) {
        fail "legacy v1 recovery left a journal, stage, or backup file"
    }

    print "ok codex materializer: deterministic three-file source, unrelated-hook preservation, v1/v2 interruption recovery, provenance, fail-closed"
}
