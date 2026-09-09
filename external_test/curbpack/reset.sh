#!/bin/sh
# Hard-reset this Glucose Log checkout to the starting commit, then leave
# test_* fixture branches alone (delete those by hand).
#
# A branch name (default main) is rewound to origin/<name> after fetch, so
# local commits on that branch do not survive the next setup. A commit SHA
# checks out that commit.
set -eu
root=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
cd "$root"
fixture_dir=$root/.git/curbpack-fixture

if [ $# -gt 1 ]; then
  echo "usage: reset.sh [commit-or-branch]" >&2
  exit 2
fi

if [ $# -eq 1 ]; then
  start=$1
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
  exit 2
fi
git clean -fd --quiet

rm -rf "$fixture_dir"
