#!/bin/sh
# R5 — thin rule-satisfying house-policy tree.
# Keep the printed description in sync with curbpack
# docs/testing/procedures/0_controlled_repo_setup.md (section R5).
#
# Manifestation of the Curbpack R5 definition. Target is not this
# product checkout. Uses Curbpack testdata. Does not init or commit Git
# (that is EC-01). Does not restore the reference product.
set -eu

fail() {
	echo "R5: $*" >&2
	exit 1
}

if [ -z "${CURBPACK_ROOT:-}" ]; then
	fail "CURBPACK_ROOT is empty; source tmp/verification-run.sh first"
fi
if [ -z "${REFERENCE_PRODUCT_ROOT:-}" ]; then
	fail "REFERENCE_PRODUCT_ROOT is empty; source tmp/verification-run.sh first"
fi

target=$CURBPACK_ROOT/tmp/R5
demo=$CURBPACK_ROOT/testdata/demo-app
real=$CURBPACK_ROOT/testdata/honesty-eval/real/SECURITY.md

[ -d "$demo" ] || fail "missing $demo"
[ -f "$real" ] || fail "missing $real"

rm -rf "$target"
mkdir -p "$target"

cp -R "$demo/." "$target/"
cp "$real" "$target/SECURITY.md"

cmp "$target/SECURITY.md" "$real" || fail "SECURITY.md is not byte-identical to the real fixture"
cmp "$target/package.json" "$demo/package.json" || fail "package.json is not the demo-app version"
[ -f "$target/.well-known/security.txt" ] || fail "missing .well-known/security.txt"
[ -f "$target/README.md" ] || fail "missing README.md"

cat <<EOF
R5 — thin rule-satisfying house-policy tree

demo-app content with the thin rule-satisfying honesty-eval \`SECURITY.md\`
and the original demo-app \`package.json\`. Other retained demo-app content
is as verified by this script.

Target repository: $target
EOF
