def expect [condition: bool, message: string] {
    if not $condition {
        print --stderr $"FAIL: ($message)"
        exit 1
    }
    print $"ok: ($message)"
}

def run [nu_bin: path, source: path, targets: list<string>] {
    do { ^$nu_bin $source ...$targets } | complete
}

const CANONICAL = "> Index stale? Run `node .gitnexus/run.cjs analyze` from the project root. No `.gitnexus/run.cjs` yet? Regenerate it with profile-owned `bunx gitnexus@latest analyze`; never use a global package-manager install."

# The line `gitnexus analyze` emits once the upstream bun lane exists. The step
# must replace it wholesale rather than patch it, so an upstream rewording of
# the same line cannot leave a half-reviewed sentence behind.
const UPSTREAM = "> Index stale? Run `node .gitnexus/run.cjs analyze` from the project root — it auto-selects an available runner. No `.gitnexus/run.cjs` yet? Bootstrap with `npx`, `bunx`, or `pnpm dlx` — e.g. `bunx gitnexus@latest analyze` (npm 11 npx crash → use bunx or pnpm dlx; #1939)."

def block-doc [stale_line: string] {
    [
        "<!-- gitnexus:start -->"
        "# GitNexus — Code Intelligence"
        ""
        "This project is indexed by GitNexus as **fixture** (1 symbols, 1 relationships, 1 execution flows)."
        ""
        $stale_line
        ""
        "## Always Do"
        ""
        "- **MUST run impact analysis before editing any symbol.**"
        "<!-- gitnexus:end -->"
        ""
    ] | str join "\n"
}

def main [workdir: path, source: path, nu_bin: path] {
    let root = ($workdir | path join "gitnexus-block-normalizer")
    mkdir $root

    # 1. An upstream-shaped block is rewritten to the reviewed lane, and every
    #    other byte of the file survives untouched.
    let doc = ($root | path join "AGENTS.md")
    block-doc $UPSTREAM | save --raw --force $doc
    let first = (run $nu_bin $source [($doc | into string)])
    expect ($first.exit_code == 0) "normalizing an upstream block exits zero"
    expect (($first.stdout | str contains "ok normalized:")) "normalizing an upstream block reports the change"
    expect ((open --raw $doc) == (block-doc $CANONICAL)) "only the stale-index line changes"

    # 2. Re-running is a no-op — `gitnexus analyze` runs often, and the step must
    #    not churn the file (or the git diff) when the lane is already reviewed.
    let second = (run $nu_bin $source [($doc | into string)])
    expect ($second.exit_code == 0) "re-normalizing exits zero"
    expect (($second.stdout | str contains "ok unchanged:")) "re-normalizing reports no change"
    expect ((open --raw $doc) == (block-doc $CANONICAL)) "re-normalizing leaves the file byte-identical"

    # 3. CRLF checkouts keep their line endings — a normalizer that silently
    #    rewrote them to LF would show the whole file as modified.
    let crlf = ($root | path join "CRLF.md")
    (block-doc $UPSTREAM | str replace --all "\n" "\r\n") | save --raw --force $crlf
    let crlf_result = (run $nu_bin $source [($crlf | into string)])
    expect ($crlf_result.exit_code == 0) "normalizing a CRLF document exits zero"
    expect (
        (open --raw $crlf) == (block-doc $CANONICAL | str replace --all "\n" "\r\n")
    ) "CRLF line endings survive normalization"

    # 4. Text outside the block is never inspected or touched, even when it
    #    names a runner this profile does not carry.
    let outside = ($root | path join "OUTSIDE.md")
    let prose = $"# Project\n\nHistorically this repo was bootstrapped with npx some-tool.\n\n(block-doc $UPSTREAM)"
    $prose | save --raw --force $outside
    let outside_result = (run $nu_bin $source [($outside | into string)])
    expect ($outside_result.exit_code == 0) "a retired lane outside the block is not an error"
    expect (
        (open --raw $outside) == $"# Project\n\nHistorically this repo was bootstrapped with npx some-tool.\n\n(block-doc $CANONICAL)"
    ) "prose outside the block survives untouched"

    # 5. A file with no gitnexus block is left alone.
    let plain = ($root | path join "PLAIN.md")
    "# Plain\n\nNo block here.\n" | save --raw --force $plain
    let plain_result = (run $nu_bin $source [($plain | into string)])
    expect ($plain_result.exit_code == 0) "a document with no block exits zero"
    expect (($plain_result.stdout | str contains "ok no-block:")) "a document with no block is reported as such"
    expect ((open --raw $plain) == "# Plain\n\nNo block here.\n") "a document with no block is untouched"

    # 6. An absent target is reported, not fatal — the default target list names
    #    both AGENTS.md and CLAUDE.md, and repos routinely carry only one.
    let absent = (run $nu_bin $source [(($root | path join "MISSING.md") | into string)])
    expect ($absent.exit_code == 0) "an absent target exits zero"
    expect (($absent.stdout | str contains "ok absent:")) "an absent target is reported"

    # 7. Drift alarm: the block still names a retired lane somewhere other than
    #    the stale-index line, so the upstream template moved and a silent
    #    success would leave an unrunnable bootstrap in place.
    let drifted = ($root | path join "DRIFT.md")
    [
        "<!-- gitnexus:start -->"
        $UPSTREAM
        ""
        "Bootstrap with pnpm dlx gitnexus@latest analyze."
        "<!-- gitnexus:end -->"
        ""
    ] | str join "\n" | save --raw --force $drifted
    let drift_result = (run $nu_bin $source [($drifted | into string)])
    expect ($drift_result.exit_code != 0) "a retired lane elsewhere in the block fails loudly"
    expect (
        ($drift_result.stderr | str contains "needs re-reviewing")
    ) "the drift failure names the cause"

    # 8. A hand-trimmed block with no stale-index line and no runner mention is
    #    a supported layout, not a failure.
    let trimmed = ($root | path join "TRIMMED.md")
    [
        "<!-- gitnexus:start -->"
        "# GitNexus — Code Intelligence"
        ""
        "Use the GitNexus MCP tools."
        "<!-- gitnexus:end -->"
        ""
    ] | str join "\n" | save --raw --force $trimmed
    let trimmed_result = (run $nu_bin $source [($trimmed | into string)])
    expect ($trimmed_result.exit_code == 0) "a trimmed block without a stale-index line exits zero"
    expect (
        ($trimmed_result.stdout | str contains "ok no-stale-index-line:")
    ) "a trimmed block is reported as such"

    # 9. An unterminated block is a malformed document, not something to guess at.
    let unclosed = ($root | path join "UNCLOSED.md")
    $"<!-- gitnexus:start -->\n($UPSTREAM)\n" | save --raw --force $unclosed
    let unclosed_result = (run $nu_bin $source [($unclosed | into string)])
    expect ($unclosed_result.exit_code != 0) "an unclosed block fails"
    expect (
        ($unclosed_result.stderr | str contains "never closed")
    ) "the unclosed-block failure names the cause"

    # 10. An inline prose mention of the marker is not a delimiter (upstream
    #     #1041) — the real CLAUDE.md quotes the marker in a pointer sentence.
    let inline = ($root | path join "INLINE.md")
    let inline_doc = $"See the `<!-- gitnexus:start -->` block in AGENTS.md.\n\n(block-doc $UPSTREAM)"
    $inline_doc | save --raw --force $inline
    let inline_result = (run $nu_bin $source [($inline | into string)])
    expect ($inline_result.exit_code == 0) "an inline marker reference exits zero"
    expect (
        (open --raw $inline) == $"See the `<!-- gitnexus:start -->` block in AGENTS.md.\n\n(block-doc $CANONICAL)"
    ) "an inline marker reference is not treated as a delimiter"

    print "ok: gitnexus block normalizer contract passed"
}
