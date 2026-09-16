#!/bin/sh
# R8 — relevant application artifact changed.
# Keep the printed description in sync with curbpack
# docs/testing/procedures/0_controlled_repo_setup.md (section R8).
#
# Prepares this disposable reference-product checkout. This state owns the
# authored commit: later comparison reads Git objects, not the working tree.
# setup.sh --commit then finds a clean tree and only records HEAD.
set -eu

fail() {
	echo "R8: $*" >&2
	exit 1
}

. "$(dirname "$0")/require_product_baseline.sh"
require_product_baseline R8

CURBPACK_R_STATE=R8
export CURBPACK_R_STATE

cat <<'EOF'
R8 — relevant application artifact changed

R1 with `src/app.py` still present and the reviewed insulin-disclaimer
bytes changed. The path exists. The reviewed claim string
`does not calculate insulin` is replaced once with
`does not calculate insulin (edited)`. Other R1 files remain unchanged.

Used by: CTAM
EOF

# PRECONDITION: documented R1 content
sh "$(dirname "$0")/R1.sh"

# PREPARATION
test -f src/app.py || fail "src/app.py missing before R8 mutation"
grep -Fq 'does not calculate insulin' src/app.py \
	|| fail "src/app.py missing claim string before R8 mutation"
if grep -Fq 'does not calculate insulin (edited)' src/app.py; then
	fail "src/app.py already edited"
fi
awk '
	!done && /does not calculate insulin/ {
		sub(/does not calculate insulin/, "does not calculate insulin (edited)")
		done = 1
	}
	{ print }
' src/app.py >src/app.py.tmp
mv src/app.py.tmp src/app.py

git add src/app.py
git -c user.name="curbpack-fixture" -c user.email="curbpack-fixture@invalid" \
	commit -m 'curbpack fixture R8 edited src/app.py' -q

# VERIFICATION
test -f src/app.py || fail "src/app.py missing after R8 mutation"
grep -Fq 'does not calculate insulin (edited)' src/app.py \
	|| fail "src/app.py missing edited claim string"
for f in \
	SECURITY.md \
	.well-known/security.txt \
	docs/annex-vii/risk_assessment.md \
	docs/annex-vii/support_period.md \
	docs/annex-vii/user_manual_security.md \
	docs/incident/art14-path.md \
	docs/medtech/software_safety_class.md \
	docs/medtech/soup_list.md \
	docs/medtech/problem_resolution.md \
	package.json
do
	[ -f "$f" ] || fail "other R1 file missing after R8: $f"
done
if ! git diff --quiet || ! git diff --cached --quiet \
	|| [ -n "$(git ls-files --others --exclude-standard)" ]; then
	fail "working tree must be clean after R8 commit"
fi
changed=$(git diff --name-only HEAD^ HEAD)
if [ "$changed" != "src/app.py" ]; then
	fail "unexpected content mutation (want only src/app.py): $changed"
fi

echo "R8: verified. HEAD=$(git rev-parse HEAD). src/app.py present with edited insulin-disclaimer bytes. Other R1 files unchanged."
