# YZXCONV-003 — explicit-profile closure contract tests.
#
# Exercises packaging/single_profile_check.nu and packaging/profile_migration.nu
# against hermetic fixtures. No live profile is read or mutated.

def expect [cond: bool, msg: string] {
  if not $cond {
    print -e $"FAIL: ($msg)"
    exit 1
  }
  print $"ok: ($msg)"
}

def link-present [path: string] {
  let probe = (do { ^readlink $path } | complete)
  $probe.exit_code == 0 or ($path | path exists)
}

def resolve [path: string] {
  let probe = (do { ^readlink -f $path } | complete)
  if $probe.exit_code == 0 { $probe.stdout | str trim } else { "" }
}

def make-exec [path: string] {
  mkdir ($path | path dirname)
  let nu_bin = (which nu | get path.0)
  [$"#!($nu_bin)" "exit 0" ""] | str join "\n" | save --force $path
  ^chmod +x $path
}

def make-foundation [store: string, name: string] {
  let foundation = ($store | path join $name)
  for b in [
    yzx codex claude rtk rtk_nu br bv bun bunx ccboard codedb git-kb icm nix
    nu_plugin_codedb nvim
  ] {
    make-exec ($foundation | path join "bin" | path join $b)
  }
  make-exec ($foundation | path join "toolbin" | path join "nu")
  $foundation
}

def make-profile-dir [store: string, name: string, foundation: string] {
  let profile_dir = ($store | path join $name)
  mkdir $profile_dir
  ^ln -s ($foundation | path join "bin") ($profile_dir | path join "bin")
  ^ln -s ($foundation | path join "toolbin") ($profile_dir | path join "toolbin")
  {
    version: 3
    elements: {
      lifeos_foundation_yzx: {
        active: true
        attrPath: "packages.x86_64-linux.lifeos_foundation_yzx"
        originalUrl: "path:."
        outputs: null
        priority: 5
        storePaths: [$foundation]
        url: "path:."
      }
    }
  } | to json | save --force ($profile_dir | path join "manifest.json")
  $profile_dir
}

# Explicit fixture:
#   home/.nix-profile        -> .nix-profile-1-link
#   home/.nix-profile-1-link -> profile output
#   state/nix/               contains no active selector
#
# Legacy fixture:
#   home/.nix-profile        -> state/nix/profile
#   state/nix/profile        -> profile-1-link
#   state/nix/profile-1-link -> profile-1-link-1-link
#   state/nix/profile-1-link-1-link -> profile output
#   state/nix/profiles/profile has an equivalent independent generation chain
def make-fixture [--legacy] {
  let root = (^mktemp -d | str trim)
  let store = ($root | path join "store")
  let foundation = (make-foundation $store "aaaa-lifeos-foundation-yzx")
  let profile_dir = (make-profile-dir $store "bbbb-profile" $foundation)
  let state = ($root | path join "state" | path join "nix")
  let nested_profile = ($state | path join "profiles" | path join "profile")
  let home = ($root | path join "home")
  mkdir $state $home
  if $legacy {
    ^ln -s $profile_dir ($state | path join "profile-1-link-1-link")
    ^ln -s "profile-1-link-1-link" ($state | path join "profile-1-link")
    ^ln -s "profile-1-link" ($state | path join "profile")
    mkdir ($nested_profile | path dirname)
    ^ln -s $profile_dir ($nested_profile | path dirname | path join "profile-1-link-1-link")
    ^ln -s "profile-1-link-1-link" ($nested_profile | path dirname | path join "profile-1-link")
    ^ln -s "profile-1-link" $nested_profile
    ^ln -s ($state | path join "profile") ($home | path join ".nix-profile")
  } else {
    ^ln -s $profile_dir ($home | path join ".nix-profile-1-link")
    ^ln -s ".nix-profile-1-link" ($home | path join ".nix-profile")
  }
  {
    root: $root
    store: $store
    foundation: $foundation
    profile_dir: $profile_dir
    state: $state
    home: $home
    profile_link: ($home | path join ".nix-profile")
    legacy_profile: ($state | path join "profile")
    nested_profile: $nested_profile
  }
}

def fixture-env [fx: record] {
  {
    YZX_PROFILE_LINK: $fx.profile_link
    YZX_LEGACY_XDG_PROFILE: $fx.legacy_profile
    YZX_LEGACY_NESTED_PROFILE: $fx.nested_profile
    YZX_STORE_PREFIX: $fx.store
  }
}

def run-check [check_script: string, fx: record, extra: record] {
  let nu_bin = (which nu | get path.0)
  with-env ((fixture-env $fx) | merge $extra) {
    do { ^$nu_bin $check_script } | complete
  }
}

def run-migrate [migrate_script: string, check_script: string, fx: record, extra: record, args: list<string>] {
  let base = ((fixture-env $fx) | merge {YZX_CHECK_SCRIPT: $check_script})
  with-env ($base | merge $extra) {
    do { ^nu $migrate_script ...$args } | complete
  }
}

def read-receipt [receipt_dir: string] {
  let files = (ls $receipt_dir | where name =~ "single-profile-migration.receipt" | get name)
  expect (($files | length) == 1) $"exactly one receipt written in ($receipt_dir)"
  open --raw ($files | first) | from json
}

def make-installer-stub [path: string] {
  let nu_bin = (which nu | get path.0)
  [
    $"#!($nu_bin)"
    "mkdir ($env.STUB_PROFILE | path dirname)"
    "^ln -s $env.STUB_PROFILE_DIR $env.STUB_GENERATION"
    "^ln -s ($env.STUB_GENERATION | path basename) $env.STUB_PROFILE"
    "exit 0"
    ""
  ] | str join "\n" | save --force $path
  ^chmod +x $path
}

def make-nix-store-stub [path: string] {
  let nu_bin = (which nu | get path.0)
  [
    $"#!($nu_bin)"
    "def link-present [path: string] {"
    "  let probe = (do { ^readlink $path } | complete)"
    "  $probe.exit_code == 0 or ($path | path exists)"
    "}"
    "def --wrapped main [...args: string] {"
    "  if '--add-root' in $args {"
    "    let index = ($args | enumerate | where item == '--add-root' | first | get index)"
    "    let root = ($args | get ($index + 1))"
    "    let target = ($args | last)"
    "    mkdir ($root | path dirname)"
    "    ^ln -s $target $root"
    "    $root | save --append $env.STUB_GC_REGISTRY"
    "    print $root"
    "    return"
    "  }"
    "  if ($args | first 2) == ['--query' '--roots'] {"
    "    let target = ($args | last)"
    "    if ($env.STUB_GC_REGISTRY | path exists) {"
    "      open --raw $env.STUB_GC_REGISTRY | lines | where {|root| $root | is-not-empty} | each {|root|"
    "        let probe = (do { ^readlink -f $root } | complete)"
    "        let sticky = ($env.STUB_GC_QUERY_STICKY? | default '0') == '1'"
    "        if $sticky or ($probe.exit_code == 0 and ($probe.stdout | str trim) == $target) {"
    "          print $'($root) -> ($target)'"
    "        }"
    "      }"
    "    }"
    "    return"
    "  }"
    "  exit 64"
    "}"
    ""
  ] | str join "\n" | save --force $path
  ^chmod +x $path
}

def main [packaging_dir: string] {
  let pdir = ($packaging_dir | path expand)
  let check = ($pdir | path join "single_profile_check.nu")
  let migrate = ($pdir | path join "profile_migration.nu")
  expect ($check | path exists) $"check script exists: ($check)"
  expect ($migrate | path exists) $"migration script exists: ($migrate)"

  # 1. A direct ~/.nix-profile selector passes every mandatory clause.
  let fx1 = (make-fixture)
  let r1 = (run-check $check $fx1 {})
  if $r1.exit_code != 0 { print -e $r1.stdout; print -e $r1.stderr }
  expect ($r1.exit_code == 0) "direct fixture: exit 0"
  let j1 = ($r1.stdout | from json)
  expect ($j1.schema == "yazelix.single-profile-check.v2") "direct fixture: v2 schema"
  expect ($j1.pass == true) "direct fixture: pass true"
  expect ($j1.clauses.direct_profile_selector == true) "direct fixture: explicit selector"
  expect ($j1.clauses.selector_resolves == true) "direct fixture: selector resolves"
  expect ($j1.clauses.single_foundation_element == true) "direct fixture: one element"
  expect ($j1.clauses.legacy_xdg_inactive == true) "direct fixture: legacy XDG inactive"
  expect ($j1.clauses.legacy_nested_inactive == true) "direct fixture: nested XDG inactive"
  expect ($j1.clauses.foundation_binaries_resolve == true) "direct fixture: binaries resolve"

  # A direct store-path install uses the package pname instead of the flake
  # attribute as its element key. Element identity comes from the store path.
  let fx1b = (make-fixture)
  let mpath1b = ($fx1b.profile_dir | path join "manifest.json")
  open --raw $mpath1b
  | str replace '"lifeos_foundation_yzx"' '"lifeos-foundation-yzx"'
  | save --force $mpath1b
  let r1b = (run-check $check $fx1b {})
  expect ($r1b.exit_code == 0) "store-path manifest key: exit 0"
  expect (($r1b.stdout | from json).clauses.single_foundation_element == true) "store-path manifest key: foundation identity"

  # 2. A convergent XDG alias is still a forbidden active ownership layer.
  let fx2 = (make-fixture --legacy)
  let r2 = (run-check $check $fx2 {})
  expect ($r2.exit_code != 0) "legacy alias: nonzero exit"
  let j2 = ($r2.stdout | from json)
  expect ($j2.clauses.direct_profile_selector == false) "legacy alias: direct selector false"
  expect ($j2.clauses.legacy_xdg_inactive == false) "legacy alias: XDG inactive false"
  expect ($j2.clauses.legacy_nested_inactive == false) "legacy alias: nested XDG inactive false"

  # 3. An absolute link to an otherwise valid home generation is not explicit.
  let fx3 = (make-fixture)
  ^rm $fx3.profile_link
  ^ln -s ($fx3.home | path join ".nix-profile-1-link") $fx3.profile_link
  let r3 = (run-check $check $fx3 {})
  expect ($r3.exit_code != 0) "absolute selector alias: nonzero exit"
  let j3 = ($r3.stdout | from json)
  expect ($j3.clauses.direct_profile_selector == false) "absolute selector alias: clause false"

  # A chained selector name is not a Nix-owned direct generation.
  let fx3b = (make-fixture)
  ^rm $fx3b.profile_link
  let chained3b = ($fx3b.home | path join ".nix-profile-1-link-2-link")
  ^ln -s $fx3b.profile_dir $chained3b
  ^ln -s ($chained3b | path basename) $fx3b.profile_link
  let r3b = (run-check $check $fx3b {})
  expect ($r3b.exit_code != 0) "chained selector alias: nonzero exit"
  expect (($r3b.stdout | from json).clauses.direct_profile_selector == false) "chained selector alias: clause false"

  # A valid selector name whose selected generation chains through another
  # relative generation is not a direct Nix store selector.
  let fx3c = (make-fixture)
  let generation3c = ($fx3c.home | path join ".nix-profile-1-link")
  ^rm $generation3c
  let chained3c = ($fx3c.home | path join ".nix-profile-1-link-2-link")
  ^ln -s $fx3c.profile_dir $chained3c
  ^ln -s ($chained3c | path basename) $generation3c
  let r3c = (run-check $check $fx3c {})
  expect ($r3c.exit_code != 0) "intermediate generation chain: nonzero exit"
  expect (($r3c.stdout | from json).clauses.direct_profile_selector == false) "intermediate generation chain: clause false"

  # 4. A broken legacy symlink is still an active stale shadow.
  let fx4 = (make-fixture)
  ^ln -s "missing-generation" $fx4.legacy_profile
  let r4 = (run-check $check $fx4 {})
  expect ($r4.exit_code != 0) "broken legacy selector: nonzero exit"
  let j4 = ($r4.stdout | from json)
  expect ($j4.clauses.legacy_xdg_inactive == false) "broken legacy selector: clause false"

  # Broken links in the nested XDG profile namespace are active shadows too.
  let fx4b = (make-fixture)
  mkdir ($fx4b.nested_profile | path dirname)
  ^ln -s "missing-generation" $fx4b.nested_profile
  let r4b = (run-check $check $fx4b {})
  expect ($r4b.exit_code != 0) "broken nested selector: nonzero exit"
  expect (($r4b.stdout | from json).clauses.legacy_nested_inactive == false) "broken nested selector: clause false"

  # 5. Two manifest elements violate the single-element contract.
  let fx5 = (make-fixture)
  let mpath5 = ($fx5.profile_dir | path join "manifest.json")
  let m5 = (open --raw $mpath5 | from json)
  $m5
  | update elements ($m5.elements | insert second_element {storePaths: [$fx5.foundation]})
  | to json | save --force $mpath5
  let r5 = (run-check $check $fx5 {})
  expect ($r5.exit_code != 0) "two manifest elements: nonzero exit"
  let j5 = ($r5.stdout | from json)
  expect ($j5.clauses.single_foundation_element == false) "two manifest elements: clause false"

  # 6. Missing foundation binaries fail closed.
  let fx6 = (make-fixture)
  let claude6 = ($fx6.foundation | path join "bin" | path join "claude")
  ^mv $claude6 $"($claude6).disabled"
  let r6 = (run-check $check $fx6 {})
  expect ($r6.exit_code != 0) "missing claude binary: nonzero exit"
  let j6 = ($r6.stdout | from json)
  expect ($j6.clauses.foundation_binaries_resolve == false) "missing claude binary: clause false"

  # 7. Expected-closure mismatch fails; an exact match passes.
  let fx7 = (make-fixture)
  let other7 = (make-foundation $fx7.store "dddd-lifeos-foundation-yzx")
  let mismatch7 = (run-check $check $fx7 {YZX_EXPECTED_CLOSURE: $other7})
  expect ($mismatch7.exit_code != 0) "expected-closure mismatch: nonzero exit"
  expect (($mismatch7.stdout | from json).clauses.closure_matches_expected == false) "expected-closure mismatch: clause false"
  let match7 = (run-check $check $fx7 {YZX_EXPECTED_CLOSURE: $fx7.foundation})
  expect ($match7.exit_code == 0) "expected-closure match: exit 0"
  expect (($match7.stdout | from json).clauses.closure_matches_expected == true) "expected-closure match: clause true"

  # 7b. The profile Nix must win PATH precedence, while the system daemon Nix
  # may remain later in PATH. Other managed frontdoors remain strict.
  let fx7b = (make-fixture)
  let system_bin7b = ($fx7b.root | path join "system-bin")
  make-exec ($system_bin7b | path join "nix")
  let coreutils7b = (which readlink | get path.0 | path dirname)
  let path7b = [
    ($fx7b.profile_dir | path join "bin")
    ($fx7b.profile_dir | path join "toolbin")
    $system_bin7b
    $coreutils7b
  ] | str join (char esep)
  let allowed7b = (run-check $check $fx7b {YZX_CHECK_PATH: "1", PATH: $path7b})
  expect ($allowed7b.exit_code == 0) "secondary system Nix: profile-first pass"
  expect (($allowed7b.stdout | from json).clauses.path_single_owner == true) "secondary system Nix: PATH clause true"
  make-exec ($system_bin7b | path join "rtk")
  let strict7b = (run-check $check $fx7b {YZX_CHECK_PATH: "1", PATH: $path7b})
  expect ($strict7b.exit_code != 0) "secondary managed RTK: strict failure"
  expect (($strict7b.stdout | from json).clauses.path_single_owner == false) "secondary managed RTK: PATH clause false"

  # 8. Dry-run records every alias/generation and mutates nothing.
  let fx8 = (make-fixture --legacy)
  let newf8 = (make-foundation $fx8.store "dddd-lifeos-foundation-yzx")
  let unrelated8 = ($fx8.state | path join "profile-backup-link")
  ^ln -s $fx8.profile_dir $unrelated8
  let rdir8 = ($fx8.root | path join "receipts")
  let adir8 = ($fx8.root | path join "archive")
  let r8 = (run-migrate $migrate $check $fx8 {} [--closure $newf8 --archive-dir $adir8 --receipt-dir $rdir8])
  if $r8.exit_code != 0 { print -e $r8.stdout; print -e $r8.stderr }
  expect ($r8.exit_code == 0) "dry-run migration: exit 0"
  expect ((^readlink $fx8.profile_link | str trim) == $fx8.legacy_profile) "dry-run: profile alias unchanged"
  expect ((^readlink $fx8.legacy_profile | str trim) == "profile-1-link") "dry-run: legacy selector unchanged"
  expect (link-present $unrelated8) "dry-run: similarly named unrelated link untouched"
  let rec8 = (read-receipt $rdir8)
  expect ($rec8.schema == "yazelix.single-profile-migration.receipt.v2") "dry-run receipt: v2 schema"
  expect ($rec8.mode == "dry-run") "dry-run receipt: mode"
  expect (($rec8.archive_entries | length) == 7) "dry-run receipt: alias and both complete legacy generation chains"
  expect (($rec8.gc_roots | length) == 1 and ($rec8.gc_roots | first).verified == null) "dry-run receipt: prior GC root plan"
  expect ($rec8.prior_manifest_sha256 != "") "dry-run receipt: prior manifest hash"
  expect ($rec8.install_command | str contains "profile add") "dry-run receipt: explicit add command"
  expect ($rec8.verified == null and $rec8.rollback_performed == false) "dry-run receipt: no execution"
  expect (not ($adir8 | path exists)) "dry-run: archive tree absent"

  # 9. --execute without --closure is refused before mutation.
  let fx9 = (make-fixture --legacy)
  let r9 = (run-migrate $migrate $check $fx9 {} [--execute --receipt-dir ($fx9.root | path join "receipts")])
  expect ($r9.exit_code != 0) "--execute without --closure: refused"

  # 10. Execute rehearsal creates an explicit selector and archives all shadows.
  let fx10 = (make-fixture --legacy)
  let newf10 = (make-foundation $fx10.store "dddd-lifeos-foundation-yzx")
  let newprof10 = (make-profile-dir $fx10.store "eeee-profile-next" $newf10)
  let stub10 = ($fx10.root | path join "stub-nix")
  let store_stub10 = ($fx10.root | path join "stub-nix-store")
  make-installer-stub $stub10
  make-nix-store-stub $store_stub10
  let generation10 = ($fx10.home | path join ".nix-profile-1-link")
  let rdir10 = ($fx10.root | path join "receipts")
  let adir10 = ($fx10.root | path join "archive")
  let env10 = {
    YZX_NIX_BIN: $stub10
    YZX_NIX_STORE_BIN: $store_stub10
    STUB_GC_REGISTRY: ($fx10.root | path join "gc-roots.txt")
    STUB_PROFILE: $fx10.profile_link
    STUB_GENERATION: $generation10
    STUB_PROFILE_DIR: $newprof10
  }
  let r10 = (run-migrate $migrate $check $fx10 $env10 [--closure $newf10 --archive-dir $adir10 --receipt-dir $rdir10 --execute])
  if $r10.exit_code != 0 { print -e $r10.stdout; print -e $r10.stderr }
  expect ($r10.exit_code == 0) "execute rehearsal: exit 0"
  expect ((^readlink $fx10.profile_link | str trim) == ".nix-profile-1-link") "execute rehearsal: explicit selector"
  expect (not (link-present $fx10.legacy_profile)) "execute rehearsal: legacy selector inactive"
  expect (not (link-present $fx10.nested_profile)) "execute rehearsal: nested selector inactive"
  let rec10 = (read-receipt $rdir10)
  expect ($rec10.mode == "execute" and $rec10.verified == true) "execute receipt: verified"
  expect ($rec10.install_exit_code == 0 and $rec10.verification_exit_code == 0) "execute receipt: commands exited zero"
  expect ($rec10.verification_stdout_sha256 != "") "execute receipt: verification log hash"
  expect ($rec10.rollback_performed == false) "execute receipt: no rollback"
  expect ($rec10.new_manifest_sha256 != "") "execute receipt: new manifest hash"
  expect (($rec10.gc_roots | length) == 1 and ($rec10.gc_roots | first).verified == true and ($rec10.gc_roots | first).retained == true) "execute receipt: prior GC root retained"
  expect ((resolve (($rec10.gc_roots | first).root)) == ($fx10.profile_dir | path expand)) "execute archive: GC root preserves prior profile"
  for entry in [[namespace name];
    ["profile" ".nix-profile"]
    ["legacy-xdg" "profile"]
    ["legacy-xdg" "profile-1-link"]
    ["legacy-xdg" "profile-1-link-1-link"]
    ["legacy-nested" "profile"]
    ["legacy-nested" "profile-1-link"]
    ["legacy-nested" "profile-1-link-1-link"]
  ] {
    let archived = ($rec10.archive_path | path join "prior" | path join $entry.namespace | path join $entry.name)
    expect (($archived | path type) == "symlink") $"execute archive contains ($entry.namespace)/($entry.name)"
  }
  expect ((resolve ($rec10.archive_path | path join "prior/legacy-xdg/profile")) == ($fx10.profile_dir | path expand)) "execute archive: legacy XDG generation graph resolves"
  expect ((resolve ($rec10.archive_path | path join "prior/legacy-nested/profile")) == ($fx10.profile_dir | path expand)) "execute archive: nested XDG generation graph resolves"

  # 11. A failed candidate is archived and the complete legacy state restored.
  let fx11 = (make-fixture --legacy)
  let newf11 = (make-foundation $fx11.store "dddd-lifeos-foundation-yzx")
  let broken11 = ($fx11.store | path join "ffff-broken-profile")
  mkdir $broken11
  let stub11 = ($fx11.root | path join "stub-nix")
  let store_stub11 = ($fx11.root | path join "stub-nix-store")
  make-installer-stub $stub11
  make-nix-store-stub $store_stub11
  let generation11 = ($fx11.home | path join ".nix-profile-1-link")
  let rdir11 = ($fx11.root | path join "receipts")
  let adir11 = ($fx11.root | path join "archive")
  let env11 = {
    YZX_NIX_BIN: $stub11
    YZX_NIX_STORE_BIN: $store_stub11
    STUB_GC_REGISTRY: ($fx11.root | path join "gc-roots.txt")
    STUB_PROFILE: $fx11.profile_link
    STUB_GENERATION: $generation11
    STUB_PROFILE_DIR: $broken11
  }
  let r11 = (run-migrate $migrate $check $fx11 $env11 [--closure $newf11 --archive-dir $adir11 --receipt-dir $rdir11 --execute])
  expect ($r11.exit_code != 0) "failed cutover: nonzero exit"
  expect ((^readlink $fx11.profile_link | str trim) == $fx11.legacy_profile) "failed cutover: profile alias restored"
  expect ((^readlink $fx11.legacy_profile | str trim) == "profile-1-link") "failed cutover: legacy selector restored"
  expect ((^readlink $fx11.nested_profile | str trim) == "profile-1-link") "failed cutover: nested selector restored"
  expect ((^readlink ($fx11.state | path join "profile-1-link") | str trim) == "profile-1-link-1-link") "failed cutover: chained generation restored"
  expect ((resolve $fx11.profile_link) == ($fx11.profile_dir | path expand)) "failed cutover: original closure restored"
  let rec11 = (read-receipt $rdir11)
  expect ($rec11.verified == false and $rec11.rollback_performed == true) "failed receipt: rollback recorded"
  expect ($rec11.install_exit_code == 0 and $rec11.verification_exit_code != 0) "failed receipt: exact failing gate"
  expect (($rec11.errors | first) | str contains "profile verification exited") "failed receipt: nonempty error"
  expect (($rec11.gc_roots | first).retained == false and not (link-present (($rec11.gc_roots | first).root))) "failed receipt: temporary archive GC root released"
  expect (($rec11.failed_candidate_archive | path join ".nix-profile" | path type) == "symlink") "failed candidate selector archived"
  expect (($rec11.failed_candidate_archive | path join ".nix-profile-1-link" | path type) == "symlink") "failed candidate generation archived"

  # 12. A cleanup query that still reports a root must remain truthful in the
  # receipt and cannot be reported as a completed rollback.
  let fx12 = (make-fixture --legacy)
  let newf12 = (make-foundation $fx12.store "dddd-lifeos-foundation-yzx")
  let broken12 = ($fx12.store | path join "ffff-broken-profile")
  mkdir $broken12
  let stub12 = ($fx12.root | path join "stub-nix")
  let store_stub12 = ($fx12.root | path join "stub-nix-store")
  make-installer-stub $stub12
  make-nix-store-stub $store_stub12
  let rdir12 = ($fx12.root | path join "receipts")
  let env12 = {
    YZX_NIX_BIN: $stub12
    YZX_NIX_STORE_BIN: $store_stub12
    STUB_GC_REGISTRY: ($fx12.root | path join "gc-roots.txt")
    STUB_GC_QUERY_STICKY: "1"
    STUB_PROFILE: $fx12.profile_link
    STUB_GENERATION: ($fx12.home | path join ".nix-profile-1-link")
    STUB_PROFILE_DIR: $broken12
  }
  let r12 = (run-migrate $migrate $check $fx12 $env12 [--closure $newf12 --archive-dir ($fx12.root | path join "archive") --receipt-dir $rdir12 --execute])
  expect ($r12.exit_code != 0) "retained cleanup root: nonzero exit"
  let rec12 = (read-receipt $rdir12)
  expect ($rec12.rollback_performed == false) "retained cleanup root: rollback remains incomplete"
  expect (($rec12.gc_roots | first).retained == true) "retained cleanup root: receipt remains truthful"
  expect (($rec12.gc_roots | first).error | str contains "failed to release GC root") "retained cleanup root: per-root error recorded"
  expect ($rec12.gc_root_cleanup.ok == false) "retained cleanup root: aggregate cleanup failure recorded"

  print "ok: all explicit-profile contract tests passed"
}
