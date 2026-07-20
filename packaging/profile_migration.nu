# YZXCONV-003 — explicit ~/.nix-profile cutover (dry-run by default).
#
# Converges the LifeOS foundation onto ~/.nix-profile as the sole selector:
#   * archives the prior ~/.nix-profile alias or generation selector,
#   * protects every prior profile closure with an archive-owned indirect GC root,
#   * archives both legacy XDG profile selectors and their generations,
#   * creates a fresh explicit ~/.nix-profile with `nix profile add`,
#   * verifies the expected closure with single_profile_check.nu,
#   * archives a failed candidate and restores every prior selector link, and
#   * writes a hash-bearing migration receipt for dry-run and execute modes.
#
# WITHOUT --execute this performs NO selector mutation: it records the plan.
#
#   nu packaging/profile_migration.nu --closure /nix/store/...-lifeos-foundation-yzx \
#     [--flake-ref path:/home/flexnetos/meta/src/yazelix] \
#     [--archive-dir /home/flexnetos/.local/state/meta/archives/yazelix-nix-profile] \
#     [--receipt-dir DIR] [--execute]
#
# Environment overrides (fixtures/staging): YZX_PROFILE_LINK,
# YZX_LEGACY_XDG_PROFILE, YZX_LEGACY_NESTED_PROFILE, YZX_STORE_PREFIX,
# YZX_NIX_BIN, YZX_NIX_STORE_BIN, YZX_NU_BIN, YZX_CHECK_SCRIPT.

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

def entry-present [path: string] {
  let probe = (read-link $path)
  $probe.ok or ($path | path exists)
}

def file-sha256 [path: string] {
  if ($path | path exists) {
    open --raw $path | hash sha256
  } else {
    ""
  }
}

def generation-links [selector: string] {
  let directory = ($selector | path dirname)
  let selector_name = ($selector | path basename)
  let prefix = $"($selector_name)-"
  if not ($directory | path exists) { return [] }
  ls -a $directory
  | where type == symlink
  | where {|entry|
      let name = ($entry.name | path basename)
      let body = ($name | str replace $prefix "")
      ($name | str starts-with $prefix) and ($body =~ '^[0-9]+-link(-[0-9]+-link)*$')
    }
  | get name
}

def archive-records [paths: list<string>, archive_path: string, namespace: string] {
  $paths | each {|source|
    let probe = (read-link $source)
    {
      source: $source
      archived: ($archive_path | path join "prior" | path join $namespace | path join ($source | path basename))
      target: $probe.target
      resolved: (resolve $source)
    }
  }
}

def create-gc-roots [nix_store_bin: string, plans: list<record>] {
  $plans | each {|plan|
    mkdir ($plan.root | path dirname)
    let add = (do {
      ^$nix_store_bin --add-root $plan.root --indirect --realise $plan.target
    } | complete)
    let query = if $add.exit_code == 0 {
      do { ^$nix_store_bin --query --roots $plan.target } | complete
    } else {
      {exit_code: null, stdout: "", stderr: ""}
    }
    let expected = $"($plan.root) -> ($plan.target)"
    let verified = (
      $add.exit_code == 0
      and $query.exit_code == 0
      and ($query.stdout | lines | any {|line| ($line | str trim) == $expected })
    )
    {
      root: $plan.root
      target: $plan.target
      add_exit_code: $add.exit_code
      add_stdout_sha256: ($add.stdout | hash sha256)
      query_exit_code: $query.exit_code
      query_stdout_sha256: ($query.stdout | hash sha256)
      verified: $verified
      retained: $verified
      error: (if $verified { null } else {
        let stderr = ([$add.stderr $query.stderr] | str join " " | str trim)
        if $stderr == "" { $"GC root verification failed: ($expected)" } else { $stderr }
      })
    }
  }
}

def release-gc-roots [nix_store_bin: string, roots: list<record>] {
  let updated = ($roots | each {|root|
    let remove = if (entry-present $root.root) {
      do { ^rm -f $root.root } | complete
    } else {
      {exit_code: null, stdout: "", stderr: ""}
    }
    let query = (do { ^$nix_store_bin --query --roots $root.target } | complete)
    let observed_retained = (
      $query.stdout | lines | any {|line| $line | str contains $root.root }
    )
    let remove_ok = ($remove.exit_code == null or $remove.exit_code == 0)
    let cleanup_ok = ($remove_ok and $query.exit_code == 0 and not $observed_retained)
    let retained = if $cleanup_ok {
      false
    } else if $query.exit_code == 0 {
      $observed_retained
    } else {
      $root.retained
    }
    let error = if $cleanup_ok { null } else {
      $"failed to release GC root ($root.root) for ($root.target): remove_exit=($remove.exit_code), query_exit=($query.exit_code), retained=($retained)"
    }
    $root
    | upsert release_remove_exit_code $remove.exit_code
    | upsert release_query_exit_code $query.exit_code
    | upsert release_query_stdout_sha256 ($query.stdout | hash sha256)
    | upsert retained $retained
    | upsert error $error
  })
  let errors = ($updated | where error != null | get error)
  {ok: (($errors | is-empty)), errors: $errors, roots: $updated}
}

def refuse [msg: string] {
  print -e $"refusing: ($msg)"
  exit 2
}

def archive-entries [entries: list<record>] {
  for entry in $entries {
    if (entry-present $entry.source) {
      mkdir ($entry.archived | path dirname)
      ^mv -T $entry.source $entry.archived
    }
  }
}

def restore-entries [entries: list<record>] {
  for entry in ($entries | reverse) {
    if (entry-present $entry.archived) {
      if (entry-present $entry.source) {
        error make {msg: $"rollback destination is occupied: ($entry.source)"}
      }
      mkdir ($entry.source | path dirname)
      ^mv -T $entry.archived $entry.source
    }
  }
}

def archive-candidate [profile_link: string, destination: string] {
  let paths = ((generation-links $profile_link) | append $profile_link | uniq)
  for source in $paths {
    if (entry-present $source) {
      mkdir $destination
      ^mv -T $source ($destination | path join ($source | path basename))
    }
  }
}

def main [
  --closure: string = ""     # freshly built lifeos-foundation-yzx store path (required)
  --flake-ref: string = "path:/home/flexnetos/meta/src/yazelix"  # install source
  --archive-dir: string = "/home/flexnetos/.local/state/meta/archives/yazelix-nix-profile"
  --receipt-dir: string = "."  # where the migration receipt is written
  --execute                    # actually mutate; default is a read-only dry-run
] {
  let profile_link = ($env.YZX_PROFILE_LINK? | default "/home/flexnetos/.nix-profile")
  let legacy_xdg_profile = (
    $env.YZX_LEGACY_XDG_PROFILE? | default "/home/flexnetos/.local/state/nix/profile"
  )
  let legacy_nested_profile = (
    $env.YZX_LEGACY_NESTED_PROFILE? | default "/home/flexnetos/.local/state/nix/profiles/profile"
  )
  let store_prefix = ($env.YZX_STORE_PREFIX? | default "/nix/store")
  let nix_bin = ($env.YZX_NIX_BIN? | default "nix")
  let nix_store_bin = ($env.YZX_NIX_STORE_BIN? | default "nix-store")
  let nu_bin = ($env.YZX_NU_BIN? | default "nu")
  let check_script = ($env.YZX_CHECK_SCRIPT? | default ($env.FILE_PWD | path join "single_profile_check.nu"))

  if $closure == "" { refuse "--closure <store path of lifeos-foundation-yzx> is required" }
  if not ($closure | str starts-with $store_prefix) { refuse $"closure ($closure) is not under ($store_prefix)" }
  if not (($closure | path type) == "dir") { refuse $"closure ($closure) is not a directory" }
  if not ($check_script | path exists) { refuse $"check script not found at ($check_script)" }
  if not (entry-present $profile_link) { refuse $"active profile selector is absent: ($profile_link)" }

  let prior_profile_target = (read-link $profile_link | get target)
  let prior_profile_resolved = (resolve $profile_link)
  if $prior_profile_resolved == "" { refuse $"active profile does not resolve: ($profile_link)" }
  let prior_manifest = ($prior_profile_resolved | path join "manifest.json")
  if not ($prior_manifest | path exists) { refuse $"active profile manifest is absent: ($prior_manifest)" }

  let stamp = (^date -u +%Y%m%dT%H%M%S%NZ | str trim)
  let archive_path = ($archive_dir | path join $stamp)
  let profile_paths = ((generation-links $profile_link) | append $profile_link)
  let legacy_paths = if (entry-present $legacy_xdg_profile) {
    (generation-links $legacy_xdg_profile) | append $legacy_xdg_profile
  } else { [] }
  let nested_paths = if (entry-present $legacy_nested_profile) {
    (generation-links $legacy_nested_profile) | append $legacy_nested_profile
  } else { [] }
  let prior_entries = (
    (archive-records $profile_paths $archive_path "profile")
    | append (archive-records $legacy_paths $archive_path "legacy-xdg")
    | append (archive-records $nested_paths $archive_path "legacy-nested")
  )
  let gc_root_plans = (
    $prior_entries
    | get resolved
    | where {|target| $target | str starts-with $"($store_prefix)/" }
    | uniq
    | enumerate
    | each {|item|
        {
          root: ($archive_path | path join "gcroots" | path join $"prior-profile-($item.index)")
          target: $item.item
          add_exit_code: null
          add_stdout_sha256: null
          query_exit_code: null
          query_stdout_sha256: null
          verified: null
          retained: null
          error: null
        }
      }
  )

  let install_command = $"($nix_bin) profile add --profile '($profile_link)' '($flake_ref)#lifeos_foundation_yzx'"
  let mode = if $execute { "execute" } else { "dry-run" }
  mut receipt = {
    schema: "yazelix.single-profile-migration.receipt.v2"
    task: "YZXCONV-003"
    observed_at: (^date -u +%Y-%m-%dT%H:%M:%SZ | str trim)
    mode: $mode
    profile_link: $profile_link
    legacy_xdg_profile: $legacy_xdg_profile
    legacy_nested_profile: $legacy_nested_profile
    prior_profile_target: $prior_profile_target
    prior_profile_resolved: $prior_profile_resolved
    prior_manifest_sha256: (file-sha256 $prior_manifest)
    new_closure_path: $closure
    flake_ref: $flake_ref
    archive_path: $archive_path
    archive_entries: $prior_entries
    gc_roots: $gc_root_plans
    gc_root_cleanup: null
    install_command: $install_command
    install_exit_code: null
    rollback_actions: ($prior_entries | reverse | each {|entry| {from: $entry.archived, to: $entry.source}})
    new_profile_resolved: null
    new_manifest_sha256: null
    verification_exit_code: null
    verification_stdout_sha256: null
    verified: null
    rollback_performed: false
    failed_candidate_archive: null
    failure_stage: null
    errors: []
  }

  mut failed = false
  if $execute {
    let protect_result = (try {
      mkdir $archive_path
      let roots = (create-gc-roots $nix_store_bin $gc_root_plans)
      let ok = ($roots | all {|root| $root.verified })
      let errors = ($roots | where verified == false | get error)
      {ok: $ok, roots: $roots, error: (if $ok { null } else { $errors | str join "; " })}
    } catch {|err|
      {
        ok: false
        roots: $gc_root_plans
        error: ($err.msg? | default ($err | to json --raw))
      }
    })
    $receipt.gc_roots = $protect_result.roots

    if not $protect_result.ok {
      $receipt.failure_stage = "protect-prior"
      $receipt.errors = ($receipt.errors | append $protect_result.error)
      let cleanup = (release-gc-roots $nix_store_bin $protect_result.roots)
      $receipt.gc_root_cleanup = $cleanup
      $receipt.gc_roots = $cleanup.roots
      if not $cleanup.ok {
        $receipt.errors = ($receipt.errors | append $cleanup.errors)
      }
      $receipt.verified = false
      $failed = true
    } else {
      let archive_result = (try {
        archive-entries $prior_entries
        {ok: true, error: null}
      } catch {|err|
        {ok: false, error: ($err.msg? | default ($err | to json --raw))}
      })

      if not $archive_result.ok {
        $receipt.failure_stage = "archive-prior"
        $receipt.errors = ($receipt.errors | append $archive_result.error)
        let restore_result = (try {
          restore-entries $prior_entries
          {ok: true, error: null}
        } catch {|err|
          {ok: false, error: ($err.msg? | default ($err | to json --raw))}
        })
        let cleanup = (release-gc-roots $nix_store_bin $protect_result.roots)
        $receipt.gc_root_cleanup = $cleanup
        $receipt.gc_roots = $cleanup.roots
        $receipt.rollback_performed = ($restore_result.ok and $cleanup.ok)
        if not $restore_result.ok {
          $receipt.errors = ($receipt.errors | append $restore_result.error)
        }
        if not $cleanup.ok {
          $receipt.errors = ($receipt.errors | append $cleanup.errors)
        }
        $receipt.verified = false
        $failed = true
      } else {
        let install = (do {
          ^$nix_bin profile add --profile $profile_link $"($flake_ref)#lifeos_foundation_yzx"
        } | complete)
        $receipt.install_exit_code = $install.exit_code
        if $install.exit_code != 0 {
          print -e $install.stderr
          $receipt.failure_stage = "install-profile"
          let install_error = ($install.stderr | str trim)
          $receipt.errors = ($receipt.errors | append (
            if $install_error == "" { $"profile install exited ($install.exit_code)" } else { $install_error }
          ))
        }

        let verified = if $install.exit_code != 0 {
          false
        } else {
          let verify = (with-env {
            YZX_PROFILE_LINK: $profile_link
            YZX_LEGACY_XDG_PROFILE: $legacy_xdg_profile
            YZX_LEGACY_NESTED_PROFILE: $legacy_nested_profile
            YZX_STORE_PREFIX: $store_prefix
            YZX_EXPECTED_CLOSURE: $closure
          } {
            do { ^$nu_bin $check_script } | complete
          })
          $receipt.verification_exit_code = $verify.exit_code
          $receipt.verification_stdout_sha256 = ($verify.stdout | hash sha256)
          print $verify.stdout
          if $verify.exit_code != 0 {
            print -e $verify.stderr
            $receipt.failure_stage = "verify-profile"
            let verify_error = ($verify.stderr | str trim)
            $receipt.errors = ($receipt.errors | append (
              if $verify_error == "" { $"profile verification exited ($verify.exit_code)" } else { $verify_error }
            ))
          }
          $verify.exit_code == 0
        }
        $receipt.verified = $verified

        if $verified {
          let new_profile = (resolve $profile_link)
          $receipt.new_profile_resolved = $new_profile
          $receipt.new_manifest_sha256 = (file-sha256 ($new_profile | path join "manifest.json"))
        } else {
          let failed_archive = ($archive_path | path join "failed-candidate")
          let candidate_result = (try {
            archive-candidate $profile_link $failed_archive
            {ok: true, error: null}
          } catch {|err|
            {ok: false, error: ($err.msg? | default ($err | to json --raw))}
          })
          if not $candidate_result.ok {
            $receipt.errors = ($receipt.errors | append $candidate_result.error)
          }
          let restore_result = (try {
            restore-entries $prior_entries
            {ok: true, error: null}
          } catch {|err|
            {ok: false, error: ($err.msg? | default ($err | to json --raw))}
          })
          let cleanup = (release-gc-roots $nix_store_bin $protect_result.roots)
          $receipt.gc_root_cleanup = $cleanup
          $receipt.gc_roots = $cleanup.roots
          if not $restore_result.ok {
            $receipt.errors = ($receipt.errors | append $restore_result.error)
          }
          if not $cleanup.ok {
            $receipt.errors = ($receipt.errors | append $cleanup.errors)
          }
          $receipt.rollback_performed = ($restore_result.ok and $cleanup.ok)
          $receipt.failed_candidate_archive = $failed_archive
          $failed = true
        }
      }
    }
  }

  mkdir $receipt_dir
  let receipt_path = ($receipt_dir | path join $"single-profile-migration.receipt.($stamp).json")
  $receipt | to json --indent 2 | save --force $receipt_path
  print $"receipt: ($receipt_path)"
  print ($receipt | to json --indent 2)
  if $failed {
    if $receipt.failure_stage == "protect-prior" {
      print -e "cutover refused before selector mutation; prior state is unchanged"
    } else if $receipt.rollback_performed {
      print -e "cutover failed; every prior selector link was restored"
    } else {
      print -e $"cutover failed and automatic recovery was incomplete; follow receipt rollback_actions: ($receipt_path)"
    }
    exit 1
  }
}
