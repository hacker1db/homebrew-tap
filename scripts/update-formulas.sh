#!/usr/bin/env bash
# Reads and rewrites the ai-usage release that Formula/ai-usage.rb and
# Formula/foundry-entra-proxy.rb build from. Used by .github/workflows/bump.yml.
#
#   update-formulas.sh current             print the tag both formulas use (fails if they differ)
#   update-formulas.sh newer TAG           exit 0 if TAG is newer than current, 1 if not, 2 on error
#   update-formulas.sh apply TAG SHA256    point both formulas at TAG's source tarball
#
# FORMULA_DIR overrides the Formula directory (for tests).
set -euo pipefail

dir="${FORMULA_DIR:-$(cd "$(dirname "$0")/.." && pwd)/Formula}"
formulas=("$dir/ai-usage.rb" "$dir/foundry-entra-proxy.rb")
base="https://github.com/hacker1db/ai-usage/archive/refs/tags"
tag_re='^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$'

die() { echo "update-formulas: $*" >&2; exit 2; }

valid_tag() { [[ "$1" =~ $tag_re ]]; }

# tag_of FILE prints the tag in FILE's single release url line.
tag_of() {
  local lines
  lines="$(grep -E "^  url \"$base/v[^\"]+\.tar\.gz\"$" "$1" || true)"
  [[ -n "$lines" && "$(printf '%s\n' "$lines" | wc -l | tr -d ' ')" == 1 ]] ||
    die "$1: expected exactly one release url line"
  lines="${lines#*/tags/}"
  lines="${lines%.tar.gz\"}"
  valid_tag "$lines" || die "$1: url tag $lines is not vMAJOR.MINOR.PATCH"
  printf '%s\n' "$lines"
}

current() {
  local a b
  a="$(tag_of "${formulas[0]}")"
  b="$(tag_of "${formulas[1]}")"
  [[ "$a" == "$b" ]] || die "formulas disagree: ai-usage $a, foundry-entra-proxy $b"
  printf '%s\n' "$a"
}

# newer A B: exit 0 if version A > version B.
newer_than() {
  local -a x y
  IFS=. read -r -a x <<<"${1#v}"
  IFS=. read -r -a y <<<"${2#v}"
  for i in 0 1 2; do
    ((10#${x[i]} > 10#${y[i]})) && return 0
    ((10#${x[i]} < 10#${y[i]})) && return 1
  done
  return 1
}

apply() {
  local tag="$1" sha="$2" f tmp
  valid_tag "$tag" || die "tag $tag is not vMAJOR.MINOR.PATCH"
  [[ "$sha" =~ ^[0-9a-f]{64}$ ]] || die "sha256 $sha is not 64 lowercase hex digits"
  for f in "${formulas[@]}"; do
    tag_of "$f" >/dev/null
    [[ "$(grep -cE '^  sha256 "[0-9a-f]{64}"$' "$f")" == 1 ]] || die "$f: expected exactly one sha256 line"
  done
  for f in "${formulas[@]}"; do
    tmp="$(mktemp)"
    sed -E \
      -e "s|^  url \"$base/v[^\"]+\.tar\.gz\"$|  url \"$base/$tag.tar.gz\"|" \
      -e "s|^  sha256 \"[0-9a-f]{64}\"$|  sha256 \"$sha\"|" "$f" >"$tmp"
    if ! grep -qxF "  url \"$base/$tag.tar.gz\"" "$tmp" || ! grep -qxF "  sha256 \"$sha\"" "$tmp"; then
      rm -f "$tmp"
      die "$f: rewrite did not take"
    fi
    cat "$tmp" >"$f"
    rm -f "$tmp"
  done
}

case "${1:-}" in
  current) current ;;
  newer)
    [[ $# == 2 ]] || die "usage: newer TAG"
    valid_tag "$2" || die "tag $2 is not vMAJOR.MINOR.PATCH"
    cur="$(current)"
    if newer_than "$2" "$cur"; then exit 0; fi
    echo "formulas are at $cur; $2 is not newer" >&2
    exit 1
    ;;
  apply)
    [[ $# == 3 ]] || die "usage: apply TAG SHA256"
    apply "$2" "$3"
    ;;
  *) die "usage: $0 current | newer TAG | apply TAG SHA256" ;;
esac
