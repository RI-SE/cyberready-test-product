#!/bin/sh
# R7 — wrong-author fresh/owned fixture docs.
# Keep the printed description in sync with curbpack
# docs/testing/procedures/0_controlled_repo_setup.md (section R7).
#
# Prepares this disposable reference-product checkout. This state owns the
# authored commit with the author email required by the owned check.
# setup.sh --commit then finds a clean tree and only records HEAD.
set -eu

fail() {
	echo "R7: $*" >&2
	exit 1
}

. "$(dirname "$0")/require_product_baseline.sh"
require_product_baseline R7

CURBPACK_R_STATE=R7
export CURBPACK_R_STATE

cat <<'EOF'
R7 — wrong-author fresh/owned fixture docs

R1 plus `docs/review-log.md` and `docs/owned-policy.md` committed as
`Wrong Author <wrong@example.com>` with author/committer date
`2026-09-13T12:00:00Z`.
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
GIT_AUTHOR_NAME='Wrong Author' GIT_AUTHOR_EMAIL=wrong@example.com \
GIT_COMMITTER_NAME='Wrong Author' GIT_COMMITTER_EMAIL=wrong@example.com \
GIT_AUTHOR_DATE=2026-09-13T12:00:00Z GIT_COMMITTER_DATE=2026-09-13T12:00:00Z \
git -c user.name='Wrong Author' -c user.email=wrong@example.com \
	commit -m 'curbpack fixture R7 wrong-author fresh/owned docs' -q

# VERIFICATION
[ -f docs/review-log.md ] || fail "missing docs/review-log.md"
[ -f docs/owned-policy.md ] || fail "missing docs/owned-policy.md"
grep -Fq glucose-log docs/owned-policy.md || fail "owned-policy.md must mention glucose-log"
if ! git diff --quiet || ! git diff --cached --quiet \
	|| [ -n "$(git ls-files --others --exclude-standard)" ]; then
	fail "working tree must be clean after R7 commit"
fi
author_email=$(git log -1 --format='%ae' -- docs/owned-policy.md)
author_date=$(git log -1 --format='%aI' -- docs/owned-policy.md)
[ "$author_email" = "wrong@example.com" ] || fail "owned-policy last author email is $author_email"
case $author_date in
2026-09-13T12:00:00*) ;;
*) fail "owned-policy last author date is $author_date, want 2026-09-13T12:00:00Z" ;;
esac

echo "R7: verified. HEAD=$(git rev-parse HEAD). Wrong Author commit dated 2026-09-13 on review-log and owned-policy."
