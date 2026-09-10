#!/bin/sh
# R1 — starting Glucose Log product content (no extra mutation).
# Verify the documented R1 fixture after reset. Not a general product check.
#
# Keep the printed description in sync with curbpack
# docs/testing/procedures/0_controlled_repo_setup.md (section R1).
set -eu

fail() {
	echo "R1: $*" >&2
	exit 1
}

. "$(dirname "$0")/require_product_baseline.sh"
require_product_baseline "${CURBPACK_R_STATE:-R1}"

# Print the intended state when R1 is the state being applied. R2/R3 call
# this script as a precondition and must not reprint the R1 banner.
if [ "${CURBPACK_R_STATE:-R1}" = R1 ]; then
	cat <<'EOF'
R1 — starting Glucose Log product content

The selected Glucose Log Git commit or branch without additional content
mutations.

At the audited reference-product snapshot, the following files are present:

- `SECURITY.md`;
- `.well-known/security.txt`;
- `docs/annex-vii/risk_assessment.md`;
- `docs/annex-vii/support_period.md`;
- `docs/annex-vii/user_manual_security.md`;
- `docs/incident/art14-path.md`;
- `docs/medtech/software_safety_class.md`;
- `docs/medtech/soup_list.md`;
- `docs/medtech/problem_resolution.md`; and
- `package.json`.

`docs/medtech/software_safety_class.md` contains the heading
`## Classification Rationale`. The dependency maps in `package.json` are empty
and contain no banned axios pin.
EOF
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
	[ -f "$f" ] || fail "required file missing: $f"
done

grep -Fq '## Classification Rationale' docs/medtech/software_safety_class.md \
	|| fail "missing heading ## Classification Rationale in docs/medtech/software_safety_class.md"

grep -Fq '"dependencies": {}' package.json \
	|| fail "package.json dependencies map is not empty"
grep -Fq '"devDependencies": {}' package.json \
	|| fail "package.json devDependencies map is not empty"
if grep -qi axios package.json; then
	fail "package.json contains an axios pin"
fi

if ! git diff --quiet || ! git diff --cached --quiet \
	|| [ -n "$(git ls-files --others --exclude-standard)" ]; then
	fail "working tree is not the unmodified starting content"
fi

if [ "${CURBPACK_R_STATE:-R1}" = R1 ]; then
	echo "R1: verified. HEAD=$(git rev-parse HEAD). Working tree unmodified."
fi
