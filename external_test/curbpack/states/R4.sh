#!/bin/sh
# R4 — token-only house-policy tree.
# Keep the printed description in sync with curbpack
# docs/testing/procedures/0_controlled_repo_setup.md (section R4).
#
# Manifestation of the Curbpack R4 definition. Target is not this
# product checkout. Uses Curbpack testdata. Does not init or commit Git
# (that is EC-01). Does not restore the reference product.
set -eu

fail() {
	echo "R4: $*" >&2
	exit 1
}

if [ -z "${CURBPACK_ROOT:-}" ]; then
	fail "CURBPACK_ROOT is empty; source tmp/verification-run.sh first"
fi
if [ -z "${REFERENCE_PRODUCT_ROOT:-}" ]; then
	fail "REFERENCE_PRODUCT_ROOT is empty; source tmp/verification-run.sh first"
fi

target=$CURBPACK_ROOT/tmp/R4
demo=$CURBPACK_ROOT/testdata/demo-app
token=$CURBPACK_ROOT/testdata/honesty-eval/token-only/SECURITY.md

[ -d "$demo" ] || fail "missing $demo"
[ -f "$token" ] || fail "missing $token"

rm -rf "$target"
mkdir -p "$target"

cp -R "$demo/." "$target/"
cp "$token" "$target/SECURITY.md"
printf '%s\n' '{"name":"acme-widget","version":"1.0.0","dependencies":{}}' >"$target/package.json"

cmp "$target/SECURITY.md" "$token" || fail "SECURITY.md is not byte-identical to the token-only fixture"
printf '%s\n' '{"name":"acme-widget","version":"1.0.0","dependencies":{}}' | cmp - "$target/package.json" || fail "package.json is not the acme-widget content"
[ -f "$target/.well-known/security.txt" ] || fail "missing .well-known/security.txt"
[ -f "$target/README.md" ] || fail "missing README.md"

cat <<EOF
R4 — token-only house-policy tree

demo-app content with the token-only honesty-eval \`SECURITY.md\` and
\`package.json\` identifying \`acme-widget\`. Other retained demo-app content
is as verified by this script.

Target repository: $target
EOF
