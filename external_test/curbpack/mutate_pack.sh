#!/bin/sh
# Install one named pack input (PF-*) onto this disposable checkout.
# Usage: mutate_pack.sh <PF-id>
#
# SUT selects the fixture tree under external_test/ (curbpack default,
# or ctam). It is the product that owns the named pack input, not a CLI flag.
#
# Precondition: REFERENCE_PRODUCT_ROOT is this checkout. This script
# lives in $REFERENCE_PRODUCT_ROOT and only copies finished fixture files.
# It does not clone, select a revision, create a branch, stage, or commit.
# It does not require CURBPACK_ROOT or a Curbpack tmp/ path.
# PF-02 is reserved and is not implemented.
set -eu
here=$(cd "$(dirname "$0")" && pwd)

if [ $# -ne 1 ]; then
  echo "mutate_pack.sh: exactly one PF-id argument is required" >&2
  echo "usage: mutate_pack.sh <PF-id>" >&2
  exit 2
fi

id=$1

if [ -z "${REFERENCE_PRODUCT_ROOT:-}" ]; then
  echo "mutate_pack.sh: REFERENCE_PRODUCT_ROOT is empty; source verification-run.sh first" >&2
  exit 2
fi
if [ "$(git -C "$REFERENCE_PRODUCT_ROOT" rev-parse --is-inside-work-tree 2>/dev/null)" != "true" ]; then
  echo "mutate_pack.sh: REFERENCE_PRODUCT_ROOT is not a Git repository: $REFERENCE_PRODUCT_ROOT" >&2
  exit 2
fi
root=$(git -C "$here" rev-parse --show-toplevel)
if [ "$root" != "$REFERENCE_PRODUCT_ROOT" ]; then
  echo "mutate_pack.sh: this script is in $root, but REFERENCE_PRODUCT_ROOT is $REFERENCE_PRODUCT_ROOT" >&2
  exit 2
fi

sut=${SUT:-curbpack}
case $sut in
  curbpack|ctam) ;;
  *)
    echo "mutate_pack.sh: SUT must be curbpack or ctam (got $sut)" >&2
    exit 2
    ;;
esac
tree=$root/external_test/$sut
fixtures=$tree/pf-fixtures
packs=$tree/packs
review_in=$tree/review-pack-input

if [ "$sut" = ctam ]; then
  if [ -f "$fixtures/$id/context-pack.json" ]; then
    cp "$fixtures/$id/context-pack.json" "$tree/context-pack.json"
    echo "mutate_pack.sh: $id"
    echo "installed:"
    echo "  pf-fixtures/$id/context-pack.json -> external_test/ctam/context-pack.json"
    exit 0
  fi
  echo "mutate_pack.sh: missing fixture $fixtures/$id/context-pack.json" >&2
  exit 2
fi

require_file() {
  if [ ! -f "$1" ]; then
    echo "mutate_pack.sh: missing fixture $1" >&2
    exit 2
  fi
}

# Restore the committed reference pack set, then drop extra pack directories
# left by earlier PF selections. Destination is packs/ only.
install_baseline_packs() {
  require_file "$fixtures/PF-01/house-policy/pack.json"
  require_file "$fixtures/PF-01/house-policy/claims.md"
  require_file "$fixtures/PF-01/cra-baseline/pack.json"
  require_file "$fixtures/PF-01/cra-baseline/claims.md"
  require_file "$fixtures/PF-01/medtech-iec62304/pack.json"
  require_file "$fixtures/PF-01/medtech-iec62304/claims.md"
  require_file "$fixtures/PF-01/SOURCE.txt"
  mkdir -p "$packs/house-policy" "$packs/cra-baseline" "$packs/medtech-iec62304"
  cp "$fixtures/PF-01/house-policy/pack.json" "$packs/house-policy/pack.json"
  cp "$fixtures/PF-01/house-policy/claims.md" "$packs/house-policy/claims.md"
  cp "$fixtures/PF-01/cra-baseline/pack.json" "$packs/cra-baseline/pack.json"
  cp "$fixtures/PF-01/cra-baseline/claims.md" "$packs/cra-baseline/claims.md"
  cp "$fixtures/PF-01/medtech-iec62304/pack.json" "$packs/medtech-iec62304/pack.json"
  cp "$fixtures/PF-01/medtech-iec62304/claims.md" "$packs/medtech-iec62304/claims.md"
  cp "$fixtures/PF-01/SOURCE.txt" "$packs/SOURCE.txt"
  rm -rf \
    "$packs/unknown-check" \
    "$packs/bad-regex" \
    "$packs/path-traversal" \
    "$packs/fresh-owned-test" \
    "$packs/ev-008-rule-order-a" \
    "$packs/ev-008-rule-order-b"
}

install_review_pack() {
  pf=$1
  require_file "$fixtures/$pf/01-gate-failures.json"
  require_file "$fixtures/$pf/02-action-report.md"
  require_file "$fixtures/$pf/03-executive-summary.md"
  require_file "$fixtures/$pf/buyer-onepager.html"
  require_file "$fixtures/$pf/README.md"
  mkdir -p "$review_in"
  cp "$fixtures/$pf/01-gate-failures.json" "$review_in/01-gate-failures.json"
  cp "$fixtures/$pf/02-action-report.md" "$review_in/02-action-report.md"
  cp "$fixtures/$pf/03-executive-summary.md" "$review_in/03-executive-summary.md"
  cp "$fixtures/$pf/buyer-onepager.html" "$review_in/buyer-onepager.html"
  cp "$fixtures/$pf/README.md" "$review_in/README.md"
}

case $id in
  PF-01)
    install_baseline_packs
    echo "mutate_pack.sh: PF-01"
    echo "installed:"
    echo "  pf-fixtures/PF-01/house-policy/pack.json -> external_test/curbpack/packs/house-policy/pack.json"
    echo "  pf-fixtures/PF-01/house-policy/claims.md -> external_test/curbpack/packs/house-policy/claims.md"
    echo "  pf-fixtures/PF-01/cra-baseline/pack.json -> external_test/curbpack/packs/cra-baseline/pack.json"
    echo "  pf-fixtures/PF-01/cra-baseline/claims.md -> external_test/curbpack/packs/cra-baseline/claims.md"
    echo "  pf-fixtures/PF-01/medtech-iec62304/pack.json -> external_test/curbpack/packs/medtech-iec62304/pack.json"
    echo "  pf-fixtures/PF-01/medtech-iec62304/claims.md -> external_test/curbpack/packs/medtech-iec62304/claims.md"
    echo "  pf-fixtures/PF-01/SOURCE.txt -> external_test/curbpack/packs/SOURCE.txt"
    ;;
  PF-02)
    echo "mutate_pack.sh: PF-02 is reserved for a second product instance and is not implemented" >&2
    exit 2
    ;;
  PF-03)
    install_baseline_packs
    require_file "$fixtures/PF-03/unknown-check/pack.json"
    mkdir -p "$packs/unknown-check"
    cp "$fixtures/PF-03/unknown-check/pack.json" "$packs/unknown-check/pack.json"
    echo "mutate_pack.sh: PF-03"
    echo "installed:"
    echo "  pf-fixtures/PF-03/unknown-check/pack.json -> external_test/curbpack/packs/unknown-check/pack.json"
    ;;
  PF-04)
    install_baseline_packs
    require_file "$fixtures/PF-04/bad-regex/pack.json"
    mkdir -p "$packs/bad-regex"
    cp "$fixtures/PF-04/bad-regex/pack.json" "$packs/bad-regex/pack.json"
    echo "mutate_pack.sh: PF-04"
    echo "installed:"
    echo "  pf-fixtures/PF-04/bad-regex/pack.json -> external_test/curbpack/packs/bad-regex/pack.json"
    ;;
  PF-05)
    install_baseline_packs
    require_file "$fixtures/PF-05/path-traversal/pack.json"
    mkdir -p "$packs/path-traversal"
    cp "$fixtures/PF-05/path-traversal/pack.json" "$packs/path-traversal/pack.json"
    echo "mutate_pack.sh: PF-05"
    echo "installed:"
    echo "  pf-fixtures/PF-05/path-traversal/pack.json -> external_test/curbpack/packs/path-traversal/pack.json"
    ;;
  PF-06)
    install_baseline_packs
    require_file "$fixtures/PF-06/house-policy/pack.json"
    cp "$fixtures/PF-06/house-policy/pack.json" "$packs/house-policy/pack.json"
    echo "mutate_pack.sh: PF-06"
    echo "installed:"
    echo "  pf-fixtures/PF-06/house-policy/pack.json -> external_test/curbpack/packs/house-policy/pack.json"
    ;;
  PF-07)
    install_baseline_packs
    require_file "$fixtures/PF-07/fresh-owned-test/pack.json"
    mkdir -p "$packs/fresh-owned-test"
    cp "$fixtures/PF-07/fresh-owned-test/pack.json" "$packs/fresh-owned-test/pack.json"
    echo "mutate_pack.sh: PF-07"
    echo "installed:"
    echo "  pf-fixtures/PF-07/fresh-owned-test/pack.json -> external_test/curbpack/packs/fresh-owned-test/pack.json"
    ;;
  PF-08)
    install_baseline_packs
    require_file "$fixtures/PF-08/ev-008-rule-order-a/pack.json"
    mkdir -p "$packs/ev-008-rule-order-a"
    cp "$fixtures/PF-08/ev-008-rule-order-a/pack.json" "$packs/ev-008-rule-order-a/pack.json"
    echo "mutate_pack.sh: PF-08"
    echo "installed:"
    echo "  pf-fixtures/PF-08/ev-008-rule-order-a/pack.json -> external_test/curbpack/packs/ev-008-rule-order-a/pack.json"
    ;;
  PF-09)
    install_baseline_packs
    require_file "$fixtures/PF-09/ev-008-rule-order-b/pack.json"
    mkdir -p "$packs/ev-008-rule-order-b"
    cp "$fixtures/PF-09/ev-008-rule-order-b/pack.json" "$packs/ev-008-rule-order-b/pack.json"
    echo "mutate_pack.sh: PF-09"
    echo "installed:"
    echo "  pf-fixtures/PF-09/ev-008-rule-order-b/pack.json -> external_test/curbpack/packs/ev-008-rule-order-b/pack.json"
    ;;
  PF-10)
    install_review_pack PF-10
    echo "mutate_pack.sh: PF-10"
    echo "installed:"
    echo "  pf-fixtures/PF-10/01-gate-failures.json -> external_test/curbpack/review-pack-input/01-gate-failures.json"
    echo "  pf-fixtures/PF-10/02-action-report.md -> external_test/curbpack/review-pack-input/02-action-report.md"
    echo "  pf-fixtures/PF-10/03-executive-summary.md -> external_test/curbpack/review-pack-input/03-executive-summary.md"
    echo "  pf-fixtures/PF-10/buyer-onepager.html -> external_test/curbpack/review-pack-input/buyer-onepager.html"
    echo "  pf-fixtures/PF-10/README.md -> external_test/curbpack/review-pack-input/README.md"
    ;;
  PF-11)
    install_review_pack PF-11
    echo "mutate_pack.sh: PF-11"
    echo "installed:"
    echo "  pf-fixtures/PF-11/01-gate-failures.json -> external_test/curbpack/review-pack-input/01-gate-failures.json"
    echo "  pf-fixtures/PF-11/02-action-report.md -> external_test/curbpack/review-pack-input/02-action-report.md"
    echo "  pf-fixtures/PF-11/03-executive-summary.md -> external_test/curbpack/review-pack-input/03-executive-summary.md"
    echo "  pf-fixtures/PF-11/buyer-onepager.html -> external_test/curbpack/review-pack-input/buyer-onepager.html"
    echo "  pf-fixtures/PF-11/README.md -> external_test/curbpack/review-pack-input/README.md"
    ;;
  PF-12)
    install_review_pack PF-12
    echo "mutate_pack.sh: PF-12"
    echo "installed:"
    echo "  pf-fixtures/PF-12/01-gate-failures.json -> external_test/curbpack/review-pack-input/01-gate-failures.json"
    echo "  pf-fixtures/PF-12/02-action-report.md -> external_test/curbpack/review-pack-input/02-action-report.md"
    echo "  pf-fixtures/PF-12/03-executive-summary.md -> external_test/curbpack/review-pack-input/03-executive-summary.md"
    echo "  pf-fixtures/PF-12/buyer-onepager.html -> external_test/curbpack/review-pack-input/buyer-onepager.html"
    echo "  pf-fixtures/PF-12/README.md -> external_test/curbpack/review-pack-input/README.md"
    ;;
  PF-13)
    install_baseline_packs
    require_file "$fixtures/PF-13/house-policy/pack.json"
    cp "$fixtures/PF-13/house-policy/pack.json" "$packs/house-policy/pack.json"
    echo "mutate_pack.sh: PF-13"
    echo "installed:"
    echo "  pf-fixtures/PF-13/house-policy/pack.json -> external_test/curbpack/packs/house-policy/pack.json"
    ;;
  PF-14)
    install_baseline_packs
    require_file "$fixtures/PF-14/house-policy/pack.json"
    cp "$fixtures/PF-14/house-policy/pack.json" "$packs/house-policy/pack.json"
    echo "mutate_pack.sh: PF-14"
    echo "installed:"
    echo "  pf-fixtures/PF-14/house-policy/pack.json -> external_test/curbpack/packs/house-policy/pack.json"
    ;;
  PF-15)
    install_baseline_packs
    require_file "$fixtures/PF-15/house-policy/pack.json"
    cp "$fixtures/PF-15/house-policy/pack.json" "$packs/house-policy/pack.json"
    echo "mutate_pack.sh: PF-15"
    echo "installed:"
    echo "  pf-fixtures/PF-15/house-policy/pack.json -> external_test/curbpack/packs/house-policy/pack.json"
    ;;
  PF-16)
    install_baseline_packs
    require_file "$fixtures/PF-16/house-policy/pack.json"
    cp "$fixtures/PF-16/house-policy/pack.json" "$packs/house-policy/pack.json"
    echo "mutate_pack.sh: PF-16"
    echo "installed:"
    echo "  pf-fixtures/PF-16/house-policy/pack.json -> external_test/curbpack/packs/house-policy/pack.json"
    ;;
  PF-17)
    install_baseline_packs
    require_file "$fixtures/PF-17/house-policy/pack.json"
    cp "$fixtures/PF-17/house-policy/pack.json" "$packs/house-policy/pack.json"
    echo "mutate_pack.sh: PF-17"
    echo "installed:"
    echo "  pf-fixtures/PF-17/house-policy/pack.json -> external_test/curbpack/packs/house-policy/pack.json"
    ;;
  *)
    echo "mutate_pack.sh: missing fixture $fixtures/$id" >&2
    echo "usage: mutate_pack.sh <PF-id>" >&2
    exit 2
    ;;
esac
