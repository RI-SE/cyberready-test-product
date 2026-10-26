#!/bin/sh
# R5 — thin rule-satisfying house-policy tree.
# Keep the printed description in sync with curbpack
# docs/testing/procedures/0_controlled_repo_setup.md (section R5).
#
# Prepares this disposable reference-product checkout. Git recording is
# setup.sh --commit. Does not create tmp/R5. Does not select a revision.
set -eu

fail() {
	echo "R5: $*" >&2
	exit 1
}

. "$(dirname "$0")/require_product_baseline.sh"
require_product_baseline R5

if [ -z "${CURBPACK_ROOT:-}" ]; then
	fail "CURBPACK_ROOT is empty; source tmp/verification-run.sh first"
fi

CURBPACK_R_STATE=R5
export CURBPACK_R_STATE

demo=$CURBPACK_ROOT/testdata/demo-app
real=$CURBPACK_ROOT/testdata/honesty-eval/real/SECURITY.md
[ -d "$demo" ] || fail "missing $demo"
[ -f "$real" ] || fail "missing $real"
[ -f "$demo/package.json" ] || fail "missing $demo/package.json"
[ -f "$demo/.well-known/security.txt" ] || fail "missing $demo/.well-known/security.txt"
[ -f "$demo/README.md" ] || fail "missing $demo/README.md"

cat <<'EOF'
R5 — thin rule-satisfying house-policy tree

demo-app content with the thin rule-satisfying honesty-eval `SECURITY.md`
and the original demo-app `package.json`. Other retained demo-app content
is as verified by this script.
EOF

# PREPARATION — replace this checkout with demo-app files, then overlay
# the thin rule-satisfying SECURITY.md. Keep the demo-app package.json.
staged=$(mktemp -d)
cp -R "$demo/." "$staged/"
cp "$real" "$staged/SECURITY.md"
cmp "$staged/package.json" "$demo/package.json" \
	|| fail "staged package.json is not the demo-app version"

find . -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
cp -R "$staged/." .
rm -rf "$staged"

# VERIFICATION
cmp SECURITY.md "$real" || fail "SECURITY.md is not byte-identical to the real fixture"
cmp package.json "$demo/package.json" || fail "package.json is not the demo-app version"
grep -Fq '"name": "demo-app"' package.json || fail "package.json name is not demo-app"
[ -f .well-known/security.txt ] || fail "missing .well-known/security.txt"
[ -f README.md ] || fail "missing README.md"
cmp .well-known/security.txt "$demo/.well-known/security.txt" \
	|| fail ".well-known/security.txt is not the demo-app file"
cmp README.md "$demo/README.md" || fail "README.md is not the demo-app file"
if [ -e src/app.py ] || [ -e docs/medtech/software_safety_class.md ]; then
	fail "Glucose Log product files remain after R5"
fi

echo "R5: verified. HEAD=$(git rev-parse HEAD). Thin real SECURITY.md. Original demo-app package.json. Demo-app files only."
