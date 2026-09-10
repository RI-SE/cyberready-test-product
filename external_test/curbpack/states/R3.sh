#!/bin/sh
# R3 — missing required section.
# Keep the printed description in sync with curbpack
# docs/testing/procedures/0_controlled_repo_setup.md (section R3).
set -eu

fail() {
	echo "R3: $*" >&2
	exit 1
}

. "$(dirname "$0")/require_product_baseline.sh"
require_product_baseline R3

CURBPACK_R_STATE=R3
export CURBPACK_R_STATE

cat <<'EOF'
R3 — missing required section

R1 with the heading `## Classification Rationale` removed from
`docs/medtech/software_safety_class.md`. The file remains present and its other
content remains unchanged.
EOF

file=docs/medtech/software_safety_class.md
heading='## Classification Rationale'

# PRECONDITION: documented R1 content
sh "$(dirname "$0")/R1.sh"

# PREPARATION
test -f "$file" || fail "$file missing before R3 mutation"
grep -Fq "$heading" "$file" || fail "heading not present before R3 mutation"
tmp=$file.tmp
sed "/^## Classification Rationale$/d" "$file" >"$tmp"
mv "$tmp" "$file"

# VERIFICATION
test -f "$file" || fail "$file missing after R3 mutation"
if grep -Fq "$heading" "$file"; then
	fail "heading still present in $file"
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
	[ -f "$f" ] || fail "other R1 file missing after R3: $f"
done
grep -Fq '"dependencies": {}' package.json \
	|| fail "R3 must not change package.json dependencies"
changed=$(git diff --name-only HEAD)
if [ "$changed" != "$file" ]; then
	fail "unexpected content mutation (want only $file): $changed"
fi

echo "R3: verified. HEAD=$(git rev-parse HEAD). Heading removed. $file present. Other R1 files unchanged."
