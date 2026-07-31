# Restore the profile-owned GitNexus invocation lane in generated agent docs.
#
# `gitnexus analyze` rewrites the whole `<!-- gitnexus:start -->` …
# `<!-- gitnexus:end -->` block from its own template on every run, so the
# reviewed bootstrap line is replaced by whatever the upstream template names.
# This step puts the reviewed line back and touches nothing else: only the
# stale-index line inside the block is rewritten, and only when it differs.
#
# Ownership stays here rather than upstream, so a `gitnexus@latest` bump cannot
# silently reintroduce a package-manager bootstrap this profile does not have.

const BLOCK_START = "<!-- gitnexus:start -->"
const BLOCK_END = "<!-- gitnexus:end -->"
const STALE_INDEX_PREFIX = "> Index stale?"
const CANONICAL_STALE_INDEX = "> Index stale? Run `node .gitnexus/run.cjs analyze` from the project root. No `.gitnexus/run.cjs` yet? Regenerate it with profile-owned `bunx gitnexus@latest analyze`; never use a global package-manager install."
const DEFAULT_TARGETS = ["AGENTS.md" "CLAUDE.md"]

# Runner spellings the profile does not carry. Their presence anywhere in the
# block after normalization means the upstream template grew a second bootstrap
# mention, which this step would otherwise leave in place unnoticed.
const RETIRED_LANES = ["npx " "pnpm dlx" "pnpm add -g" "npm i -g" "npm install -g"]

def fail [message: string] {
    print --stderr $"gitnexus block normalizer: ($message)"
    exit 1
}

# Markers only count when they occupy their own line, so an inline prose
# reference to the marker text is never treated as a delimiter.
def marker-line [line: string, marker: string] {
    ($line | str replace --all "\r" "" | str trim) == $marker
}

def strip-cr [line: string] {
    $line | str replace --all "\r" ""
}

def publish [content: string, target: path] {
    let directory = ($target | path dirname | path expand)
    let stage = ($directory | path join $".($target | path basename).yazelix-stage-(random uuid)")
    try {
        $content | save --raw --force $stage
        ^chmod 644 $stage
        mv --force $stage $target
        do { ^sync -f $directory } | complete | ignore
    } catch {|err|
        if ($stage | path exists) { rm --force $stage }
        fail ($err.msg? | default ($err | to json --raw))
    }
}

def normalize-file [target: path] {
    if not ($target | path exists) {
        return {path: $target, status: "absent"}
    }
    if (($target | path expand --strict | path type) != "file") {
        fail $"target is not a file: ($target)"
    }

    # `open --raw` yields a byte stream, and splitting it drops the empty element
    # a trailing newline would produce — so the final newline is carried
    # separately and restored below rather than inferred from the split.
    let content = (open --raw $target | into string)
    let trailing_newline = ($content | str ends-with "\n")
    let lines = ($content | split row "\n")
    let starts = ($lines | enumerate | where {|row| marker-line $row.item $BLOCK_START })
    if ($starts | is-empty) {
        return {path: $target, status: "no-block"}
    }
    let start = $starts.0.index
    let ends = (
        $lines
        | enumerate
        | where {|row| ($row.index > $start) and (marker-line $row.item $BLOCK_END) }
    )
    if ($ends | is-empty) {
        fail $"($target) opens a gitnexus block that is never closed"
    }
    let end = $ends.0.index

    let block_rows = (
        $lines
        | enumerate
        | where {|row| ($row.index >= $start) and ($row.index <= $end) }
    )
    let stale_rows = (
        $block_rows
        | where {|row| (strip-cr $row.item) | str starts-with $STALE_INDEX_PREFIX }
    )

    if ($stale_rows | is-empty) {
        # A block trimmed by hand (upstream's `gitnexus:keep`) legitimately has
        # no stale-index line. A block that dropped the line but still names a
        # runner means the template moved and this step must be re-reviewed.
        let stray = (
            $block_rows
            | where {|row| $RETIRED_LANES | any {|lane| (strip-cr $row.item) | str contains $lane } }
        )
        if not ($stray | is-empty) {
            fail $"($target) has no stale-index line but its gitnexus block still names a retired runner lane; the upstream template moved and this step needs re-reviewing"
        }
        return {path: $target, status: "no-stale-index-line"}
    }

    let row = $stale_rows.0
    let had_cr = ($row.item | str ends-with "\r")
    let replacement = (if $had_cr { $"($CANONICAL_STALE_INDEX)\r" } else { $CANONICAL_STALE_INDEX })

    let residue = (
        $block_rows
        | where {|item| $item.index != $row.index }
        | where {|item| $RETIRED_LANES | any {|lane| (strip-cr $item.item) | str contains $lane } }
    )
    if not ($residue | is-empty) {
        fail $"($target) names a retired runner lane outside the stale-index line; the upstream template moved and this step needs re-reviewing"
    }

    if $row.item == $replacement {
        return {path: $target, status: "unchanged"}
    }

    let updated = ($lines | enumerate | each {|item|
        if $item.index == $row.index { $replacement } else { $item.item }
    })
    let rebuilt = ($updated | str join "\n")
    let restored = (
        if $trailing_newline and (not ($rebuilt | str ends-with "\n")) {
            $"($rebuilt)\n"
        } else {
            $rebuilt
        }
    )
    publish $restored $target
    {path: $target, status: "normalized"}
}

def main [...targets: path] {
    let requested = (if ($targets | is-empty) { $DEFAULT_TARGETS } else { $targets })
    let results = ($requested | each {|target| normalize-file $target })

    for result in $results {
        print $"ok ($result.status): ($result.path)"
    }

    let normalized = ($results | where status == "normalized" | length)
    let unchanged = ($results | where status == "unchanged" | length)
    print $"ok gitnexus block normalizer: ($normalized) normalized, ($unchanged) already reviewed"
}
