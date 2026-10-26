#!/bin/sh
# R2 — missing required file.
# Keep the printed description in sync with curbpack
# docs/testing/procedures/0_controlled_repo_setup.md (section R2).
set -eu

fail() {
	echo "R2: $*" >&2
	exit 1
}

. "$(dirname "$0")/require_product_baseline.sh"
require_product_baseline R2

CURBPACK_R_STATE=R2
export CURBPACK_R_STATE

cat <<'EOF'
R2 — missing required file

R1 with `SECURITY.md` removed. The file is absent, not empty. Other R1 files
remain unchanged.
EOF

# PRECONDITION: documented R1 content
sh "$(dirname "$0")/R1.sh"

# PREPARATION
test -f SECURITY.md || fail "SECURITY.md missing before R2 mutation"
rm SECURITY.md

# VERIFICATION
if [ -e SECURITY.md ]; then
	fail "SECURITY.md still present (must be absent, not empty)"
fi
for f in \
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
	[ -f "$f" ] || fail "other R1 file missing after R2: $f"
done
grep -Fq '## Classification Rationale' docs/medtech/software_safety_class.md \
	|| fail "R2 must not remove ## Classification Rationale"
grep -Fq '"dependencies": {}' package.json \
	|| fail "R2 must not change package.json dependencies"
grep -Fq '"devDependencies": {}' package.json \
	|| fail "R2 must not change package.json devDependencies"
changed=$(git diff --name-only HEAD)
if [ "$changed" != "SECURITY.md" ]; then
	fail "unexpected content mutation (want only SECURITY.md): $changed"
fi

echo "R2: verified. HEAD=$(git rev-parse HEAD). SECURITY.md absent, not empty. Other R1 files unchanged."
