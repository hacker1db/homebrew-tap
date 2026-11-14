#!/usr/bin/env bash
# check() evals its condition later, so single-quoted expansions are intended.
# shellcheck disable=SC2016
# Tests for update-formulas.sh against copies of the real formulas. Run: scripts/test-update-formulas.sh
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
script="$here/update-formulas.sh"
fails=0
sha_a="$(printf 'a%.0s' {1..64})"
sha_b="$(printf 'b%.0s' {1..64})"

setup() {
  work="$(mktemp -d)"
  cp "$here/../Formula/ai-usage.rb" "$here/../Formula/foundry-entra-proxy.rb" "$work/"
  export FORMULA_DIR="$work"
  bash "$script" apply v0.2.0 "$sha_a" || { echo "setup failed"; exit 1; }
}

# expect CODE DESCRIPTION -- COMMAND...
expect() {
  local want="$1" desc="$2"; shift 3
  "$@" >/dev/null 2>&1
  local got=$?
  if [[ "$got" == "$want" ]]; then echo "ok   $desc"; else echo "FAIL $desc (exit $got, want $want)"; fails=$((fails + 1)); fi
}

check() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; fails=$((fails + 1)); fi; }

setup
check "current reads the tag" '[[ "$(bash "$script" current)" == v0.2.0 ]]'
expect 0 "patch is newer" -- bash "$script" newer v0.2.1
expect 0 "minor is newer" -- bash "$script" newer v0.3.0
expect 0 "numeric, not lexical, compare" -- bash "$script" newer v0.10.0
expect 1 "same version is not newer (no-op)" -- bash "$script" newer v0.2.0
expect 1 "older version is not newer (no downgrade)" -- bash "$script" newer v0.1.9
expect 2 "malformed tag rejected" -- bash "$script" newer 0.3.0
expect 2 "pre-release tag rejected" -- bash "$script" newer v0.3.0-rc.1
expect 2 "leading zero rejected" -- bash "$script" newer v0.03.0
expect 2 "apply rejects short sha" -- bash "$script" apply v0.3.0 abc
expect 2 "apply rejects uppercase sha" -- bash "$script" apply v0.3.0 "$(printf 'A%.0s' {1..64})"
expect 2 "apply rejects bad tag" -- bash "$script" apply 'v0.3.0"; system("x' "$sha_b"
check "rejected applies left files untouched" '[[ "$(bash "$script" current)" == v0.2.0 ]] && grep -qF "$sha_a" "$work/ai-usage.rb"'

expect 0 "apply updates" -- bash "$script" apply v0.3.0 "$sha_b"
for f in ai-usage.rb foundry-entra-proxy.rb; do
  check "$f url updated" 'grep -qxF "  url \"https://github.com/hacker1db/ai-usage/archive/refs/tags/v0.3.0.tar.gz\"" "$work/$f"'
  check "$f sha updated" 'grep -qxF "  sha256 \"$sha_b\"" "$work/$f"'
  check "$f head url untouched" 'grep -qF "head \"https://github.com/hacker1db/ai-usage.git\", branch: \"main\"" "$work/$f"'
done
check "only url and sha lines changed" '[[ "$(diff "$here/../Formula/ai-usage.rb" "$work/ai-usage.rb" | grep -c "^[<>]")" -le 4 ]]'
expect 1 "re-running with the same tag is a no-op" -- bash "$script" newer v0.3.0
expect 0 "re-applying the same tag is harmless" -- bash "$script" apply v0.3.0 "$sha_b"

setup
sed -E 's|tags/v0\.2\.0|tags/v0.1.0|' "$work/foundry-entra-proxy.rb" >"$work/t" && mv "$work/t" "$work/foundry-entra-proxy.rb"
expect 2 "formulas that disagree are refused" -- bash "$script" newer v0.3.0

setup
printf '  url "https://github.com/hacker1db/ai-usage/archive/refs/tags/v0.2.0.tar.gz"\n' >>"$work/ai-usage.rb"
expect 2 "duplicate url line refused" -- bash "$script" apply v0.3.0 "$sha_b"
check "refused apply wrote nothing to the other formula" 'grep -qF "tags/v0.2.0" "$work/foundry-entra-proxy.rb"'

setup
sed -E 's|^  sha256 .*|  sha256 "deadbeef"|' "$work/ai-usage.rb" >"$work/t" && mv "$work/t" "$work/ai-usage.rb"
expect 2 "unrecognised sha256 line refused" -- bash "$script" apply v0.3.0 "$sha_b"

setup
sed -E 's|^  url .*|  url "https://example.com/ai-usage-v0.2.0.tar.gz"|' "$work/ai-usage.rb" >"$work/t" && mv "$work/t" "$work/ai-usage.rb"
expect 2 "foreign url refused" -- bash "$script" current

expect 2 "unknown command" -- bash "$script" frobnicate

if ((fails)); then echo "$fails test(s) failed"; exit 1; fi
echo "all tests passed"
