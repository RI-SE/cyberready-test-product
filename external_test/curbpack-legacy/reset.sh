#!/bin/sh
# Hard-reset the reference-product checkout to the starting commit, then
# leave test_* fixture branches alone (delete those by hand).
#
# Prefer $REFERENCE_PRODUCT_ROOT from a sourced verification-run.sh so this
# script can live in a different checkout than the tmp clone it resets.
# A branch name (default main) is rewound to origin/<name> after fetch, so
# local commits on that branch do not survive the next setup. A commit SHA
# checks out that commit. Origin fetch does not see unpushed commits from
# another checkout; the object must already exist in the target clone.
set -eu

if [ -n "${REFERENCE_PRODUCT_ROOT:-}" ]; then
	root=$REFERENCE_PRODUCT_ROOT
else
	root=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
fi

if [ "$(git -C "$root" rev-parse --is-inside-work-tree 2>/dev/null)" != "true" ]; then
	echo "reset.sh: not a Git repository: $root" >&2
	exit 2
fi

cd "$root"
fixture_dir=$root/.git/curbpack-fixture

if [ $# -gt 1 ]; then
	echo "usage: reset.sh [commit-or-branch]" >&2
	exit 2
fi

if [ $# -eq 1 ]; then
	start=$1
elif [ -n "${REFERENCE_PRODUCT_COMMIT:-}" ]; then
	start=$REFERENCE_PRODUCT_COMMIT
elif [ -f "$fixture_dir/origin" ]; then
	start=$(cat "$fixture_dir/origin")
else
	start=main
fi

git fetch --quiet 2>/dev/null || true

if git rev-parse --verify --quiet "refs/remotes/origin/$start^{commit}"; then
	target=$(git rev-parse "refs/remotes/origin/$start^{commit}")
	git checkout --quiet --force -B "$start" "$target"
	git reset --hard "$target"
elif git rev-parse --verify --quiet "$start^{commit}"; then
	git checkout --force --quiet "$(git rev-parse "$start^{commit}")"
else
	echo "reset.sh: unknown commit or branch $start" >&2
	echo "reset.sh: this clone must already contain that object; origin fetch does not see unpushed commits from another checkout" >&2
	exit 2
fi
git clean -fd --quiet

rm -rf "$fixture_dir"
