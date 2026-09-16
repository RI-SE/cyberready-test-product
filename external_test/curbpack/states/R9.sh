#!/bin/sh
# R9 — relevant application artifact missing.
# Keep the printed description in sync with curbpack
# docs/testing/procedures/0_controlled_repo_setup.md (section R9).
#
# Prepares this disposable reference-product checkout. This state owns the
# authored commit: later comparison reads Git objects, not the working tree.
# setup.sh --commit then finds a clean tree and only records HEAD.
set -eu

fail() {
	echo "R9: $*" >&2
	exit 1
}

. "$(dirname "$0")/require_product_baseline.sh"
require_product_baseline R9

CURBPACK_R_STATE=R9
export CURBPACK_R_STATE

cat <<'EOF'
R9 — relevant application artifact missing

R1 with `src/app.py` removed. The file is absent, not empty. Other R1
files remain unchanged.

Used by: CTAM
EOF

# PRECONDITION: documented R1 content
sh "$(dirname "$0")/R1.sh"

# PREPARATION
test -f src/app.py || fail "src/app.py missing before R9 mutation"
git rm -q src/app.py
git -c user.name="curbpack-fixture" -c user.email="curbpack-fixture@invalid" \
	commit -m 'curbpack fixture R9 removed src/app.py' -q

# VERIFICATION
if [ -e src/app.py ]; then
	fail "src/app.py still present (must be absent, not empty)"
fi
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
	[ -f "$f" ] || fail "other R1 file missing after R9: $f"
done
if ! git diff --quiet || ! git diff --cached --quiet \
	|| [ -n "$(git ls-files --others --exclude-standard)" ]; then
	fail "working tree must be clean after R9 commit"
fi
changed=$(git diff --name-only --diff-filter=D HEAD^ HEAD)
if [ "$changed" != "src/app.py" ]; then
	fail "unexpected deletion (want only src/app.py): $changed"
fi

echo "R9: verified. HEAD=$(git rev-parse HEAD). src/app.py absent, not empty. Other R1 files unchanged."
