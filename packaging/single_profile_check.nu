# YZXCONV-003 — single-profile closure contract check (read-only).
#
# Verifies that exactly one Nix profile selector owns the LifeOS foundation:
#   1. direct_profile_selector     ~/.nix-profile is the explicit selector and
#                                  its generation points directly into the store
#   2. selector_resolves           the selected profile has manifest.json
#   3. single_foundation_element   the manifest contains one active element
#                                  with one lifeos-foundation-yzx store path
#   4. legacy_xdg_inactive         ~/.local/state/nix/profile is absent
#   5. legacy_nested_inactive      ~/.local/state/nix/profiles/profile is absent
#   6. foundation_binaries_resolve the product, agent, intelligence, Beads,
#                                  Bun/Bunx, alternate-editor, and CodeDB tools
#                                  (bin) plus nu (toolbin) are executable and
#                                  store-backed
#   7. path_single_owner           (YZX_CHECK_PATH=1) every PATH resolution of
#                                  the foundation binaries resolves identically
#   8. closure_matches_expected    (YZX_EXPECTED_CLOSURE set) the manifest
#                                  element storePaths equal [expected closure]
#
# Prints a JSON report to stdout; exits 0 only if every evaluated clause holds.
# Environment overrides (used by fixtures, staging, and the flake check):
#   YZX_PROFILE_LINK        default /home/flexnetos/.nix-profile
#   YZX_LEGACY_XDG_PROFILE  default /home/flexnetos/.local/state/nix/profile
#   YZX_LEGACY_NESTED_PROFILE default /home/flexnetos/.local/state/nix/profiles/profile
#   YZX_STORE_PREFIX        default /nix/store
#   YZX_EXPECTED_CLOSURE, YZX_CHECK_PATH  optional clause activators

def resolve [path: string] {
  let res = (do { ^readlink -f $path } | complete)
  if $res.exit_code == 0 { $res.stdout | str trim } else { "" }
}

def read-link [path: string] {
  let res = (do { ^readlink $path } | complete)
  {
    ok: ($res.exit_code == 0)
    target: (if $res.exit_code == 0 { $res.stdout | str trim } else { "" })
  }
}

def is-executable [path: string] {
  if not ($path | path exists) { return false }
  (ls -l $path | get 0.mode | str contains "x")
}

def main [] {
  let profile_link = ($env.YZX_PROFILE_LINK? | default "/home/flexnetos/.nix-profile")
  let legacy_xdg_profile = (
    $env.YZX_LEGACY_XDG_PROFILE? | default "/home/flexnetos/.local/state/nix/profile"
  )
  let legacy_nested_profile = (
    $env.YZX_LEGACY_NESTED_PROFILE? | default "/home/flexnetos/.local/state/nix/profiles/profile"
  )
  let store_prefix = ($env.YZX_STORE_PREFIX? | default "/nix/store")
  let expected = ($env.YZX_EXPECTED_CLOSURE? | default "")
  let check_path = (($env.YZX_CHECK_PATH? | default "") == "1")

  let selector_link = (read-link $profile_link)
  let profile_name = ($profile_link | path basename)
  let generation_prefix = $"($profile_name)-"
  let generation_body = ($selector_link.target | str replace $generation_prefix "")
  let generation_path = ($profile_link | path dirname | path join $selector_link.target)
  let generation_link = (read-link $generation_path)
  let direct_profile_selector = (
    $selector_link.ok
    and not ($selector_link.target | str contains "/")
    and ($selector_link.target | str starts-with $generation_prefix)
    and ($generation_body =~ '^[0-9]+-link$')
    and $generation_link.ok
    and ($generation_link.target | str starts-with $"($store_prefix)/")
  )

  let resolved_profile = (resolve $profile_link)
  let selector_resolves = (
    $direct_profile_selector
    and $resolved_profile != ""
    and ($resolved_profile | path type) == "dir"
    and (($resolved_profile | path join "manifest.json") | path exists)
  )

  mut single_element = false
  mut element_paths = []
  if $selector_resolves {
    let manifest = (open --raw ($resolved_profile | path join "manifest.json") | from json)
    if ($manifest.version? | default 0) == 3 {
      let names = ($manifest.elements | columns)
      if ($names | length) == 1 {
        let element = ($manifest.elements | get ($names | first))
        let paths = ($element.storePaths? | default [])
        if (
          ($element.active? | default false) == true
          and ($paths | length) == 1
          and ($paths | all {|p|
            ($p | str starts-with $store_prefix) and ($p | path basename | str ends-with "-lifeos-foundation-yzx")
          })
        ) {
          $single_element = true
          $element_paths = $paths
        }
      }
    }
  }

  let legacy_probe = (read-link $legacy_xdg_profile)
  let legacy_xdg_inactive = (
    not $legacy_probe.ok and not ($legacy_xdg_profile | path exists)
  )
  let nested_probe = (read-link $legacy_nested_profile)
  let legacy_nested_inactive = (
    not $nested_probe.ok and not ($legacy_nested_profile | path exists)
  )

  let bin_specs = [[dir name path_policy];
    [bin yzx strict]
    [bin codex strict]
    [bin claude strict]
    [bin rtk strict]
    [bin rtk_nu strict]
    [bin br strict]
    [bin bv strict]
    [bin bun strict]
    [bin bunx strict]
    [bin ccboard strict]
    [bin codedb strict]
    [bin git-kb strict]
    [bin icm strict]
    [bin nix profile-first]
    [bin nu_plugin_codedb strict]
    [bin nvim strict]
    [toolbin nu strict]
  ]
  let binary_reports = if $selector_resolves {
    $bin_specs | each {|s|
      let p = ($resolved_profile | path join $s.dir | path join $s.name)
      let rp = (resolve $p)
      {
        name: $s.name
        path: $p
        realpath: $rp
        path_policy: $s.path_policy
        ok: ($rp != "" and ($rp | str starts-with $store_prefix) and (is-executable $rp))
      }
    }
  } else { [] }
  let foundation_binaries_resolve = (
    $selector_resolves and ($binary_reports | all {|b| $b.ok })
  )

  let path_single_owner = if not $check_path {
    null
  } else if not $foundation_binaries_resolve {
    false
  } else {
    $binary_reports | all {|b|
      let hits = (which --all $b.name | where type == "external" | get path)
      let resolved_hits = ($hits | each {|h| resolve $h })
      let profile_first = (($resolved_hits | length) > 0 and ($resolved_hits | first) == $b.realpath)
      $profile_first and ($b.path_policy == "profile-first" or ($resolved_hits | all {|h| $h == $b.realpath }))
    }
  }

  let closure_matches_expected = if $expected == "" {
    null
  } else {
    $single_element and $element_paths == [$expected]
  }

  let clauses = {
    direct_profile_selector: $direct_profile_selector
    selector_resolves: $selector_resolves
    single_foundation_element: $single_element
    legacy_xdg_inactive: $legacy_xdg_inactive
    legacy_nested_inactive: $legacy_nested_inactive
    foundation_binaries_resolve: $foundation_binaries_resolve
    path_single_owner: $path_single_owner
    closure_matches_expected: $closure_matches_expected
  }
  let pass = ($clauses | values | all {|v| $v == null or $v == true })

  let report = {
    schema: "yazelix.single-profile-check.v2"
    task: "YZXCONV-003"
    observed_at: (^date -u +%Y-%m-%dT%H:%M:%SZ | str trim)
    profile_link: $profile_link
    profile_link_target: $selector_link.target
    profile_generation: $generation_path
    profile_generation_target: $generation_link.target
    legacy_xdg_profile: $legacy_xdg_profile
    legacy_xdg_target: $legacy_probe.target
    legacy_nested_profile: $legacy_nested_profile
    legacy_nested_target: $nested_probe.target
    resolved_profile: $resolved_profile
    element_store_paths: $element_paths
    binaries: $binary_reports
    clauses: $clauses
    pass: $pass
  }
  print ($report | to json --indent 2)
  if not $pass {
    exit 1
  }
}
