#!/bin/sh
# R4 — token-only house-policy tree.
# Keep the printed description in sync with curbpack
# docs/testing/procedures/0_controlled_repo_setup.md (section R4).
#
# Prepares this disposable reference-product checkout. Git recording is
# setup.sh --commit. Does not create tmp/R4. Does not select a revision.
set -eu

fail() {
	echo "R4: $*" >&2
	exit 1
}

. "$(dirname "$0")/require_product_baseline.sh"
require_product_baseline R4

if [ -z "${CURBPACK_ROOT:-}" ]; then
	fail "CURBPACK_ROOT is empty; source tmp/verification-run.sh first"
fi

CURBPACK_R_STATE=R4
export CURBPACK_R_STATE

demo=$CURBPACK_ROOT/testdata/demo-app
token=$CURBPACK_ROOT/testdata/honesty-eval/token-only/SECURITY.md
[ -d "$demo" ] || fail "missing $demo"
[ -f "$token" ] || fail "missing $token"
[ -f "$demo/package.json" ] || fail "missing $demo/package.json"
[ -f "$demo/.well-known/security.txt" ] || fail "missing $demo/.well-known/security.txt"
[ -f "$demo/README.md" ] || fail "missing $demo/README.md"

cat <<'EOF'
R4 — token-only house-policy tree

demo-app content with the token-only honesty-eval `SECURITY.md` and
`package.json` identifying `acme-widget`. Other retained demo-app content
is as verified by this script.
EOF

# PREPARATION — replace this checkout with demo-app files, then overlay
# the token-only SECURITY.md and the acme-widget package name.
staged=$(mktemp -d)
cp -R "$demo/." "$staged/"
cp "$token" "$staged/SECURITY.md"
pkg_tmp=$(mktemp)
sed 's/"name": "demo-app"/"name": "acme-widget"/' "$staged/package.json" >"$pkg_tmp"
mv "$pkg_tmp" "$staged/package.json"
grep -Fq '"name": "acme-widget"' "$staged/package.json" \
	|| fail "failed to set package.json name to acme-widget"

find . -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
cp -R "$staged/." .
rm -rf "$staged"

# VERIFICATION
cmp SECURITY.md "$token" || fail "SECURITY.md is not byte-identical to the token-only fixture"
grep -Fq '"name": "acme-widget"' package.json || fail "package.json name is not acme-widget"
grep -Fq '"version": "1.0.0"' package.json || fail "package.json version is not the demo-app version"
[ -f .well-known/security.txt ] || fail "missing .well-known/security.txt"
[ -f README.md ] || fail "missing README.md"
cmp .well-known/security.txt "$demo/.well-known/security.txt" \
	|| fail ".well-known/security.txt is not the demo-app file"
cmp README.md "$demo/README.md" || fail "README.md is not the demo-app file"
if [ -e src/app.py ] || [ -e docs/medtech/software_safety_class.md ]; then
	fail "Glucose Log product files remain after R4"
fi

echo "R4: verified. HEAD=$(git rev-parse HEAD). Token-only SECURITY.md. package.json name acme-widget. Demo-app files only."
