#!/bin/sh
# R6 — stale fresh/owned fixture docs (old commit date).
# Keep the printed description in sync with curbpack
# docs/testing/procedures/0_controlled_repo_setup.md (section R6).
#
# Prepares this disposable reference-product checkout. This state owns the
# authored commit with the dated history required by the fresh check.
# setup.sh --commit then finds a clean tree and only records HEAD.
set -eu

fail() {
	echo "R6: $*" >&2
	exit 1
}

. "$(dirname "$0")/require_product_baseline.sh"
require_product_baseline R6

CURBPACK_R_STATE=R6
export CURBPACK_R_STATE

cat <<'EOF'
R6 — stale fresh/owned fixture docs

R1 plus `docs/review-log.md` and `docs/owned-policy.md` committed as
`Owner <owner@example.com>` with author/committer date `2022-01-01T00:00:00Z`.
EOF

# PRECONDITION: documented R1 content
sh "$(dirname "$0")/R1.sh"

# PREPARATION
mkdir -p docs
cat > docs/review-log.md <<'EOF'
# Review log

Updated with enough words to pass structural min_bytes for the glucose-log product review log fixture.
EOF
cat > docs/owned-policy.md <<'EOF'
# Owned policy for glucose-log

Product-specific draft for glucose-log owned-policy check.
EOF

git add docs/review-log.md docs/owned-policy.md
GIT_AUTHOR_NAME=Owner GIT_AUTHOR_EMAIL=owner@example.com \
GIT_COMMITTER_NAME=Owner GIT_COMMITTER_EMAIL=owner@example.com \
GIT_AUTHOR_DATE=2022-01-01T00:00:00Z GIT_COMMITTER_DATE=2022-01-01T00:00:00Z \
git -c user.name=Owner -c user.email=owner@example.com \
	commit -m 'curbpack fixture R6 stale fresh/owned docs' -q

# VERIFICATION
[ -f docs/review-log.md ] || fail "missing docs/review-log.md"
[ -f docs/owned-policy.md ] || fail "missing docs/owned-policy.md"
grep -Fq glucose-log docs/review-log.md || fail "review-log.md must mention glucose-log"
grep -Fq glucose-log docs/owned-policy.md || fail "owned-policy.md must mention glucose-log"
if ! git diff --quiet || ! git diff --cached --quiet \
	|| [ -n "$(git ls-files --others --exclude-standard)" ]; then
	fail "working tree must be clean after R6 commit"
fi
author_email=$(git log -1 --format='%ae' -- docs/review-log.md)
author_date=$(git log -1 --format='%aI' -- docs/review-log.md)
[ "$author_email" = "owner@example.com" ] || fail "review-log last author email is $author_email"
case $author_date in
2022-01-01T00:00:00*) ;;
*) fail "review-log last author date is $author_date, want 2022-01-01T00:00:00Z" ;;
esac

echo "R6: verified. HEAD=$(git rev-parse HEAD). Stale Owner commit dated 2022-01-01 on review-log and owned-policy."
