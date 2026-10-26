# Product-side verification-run variables. Sourced by R1–R3 and R8–R9
# (mutations of this checkout). R4 and R5 do not source this file: they
# build disposable trees under $CURBPACK_ROOT/tmp from Curbpack testdata.
#
# Required: REFERENCE_PRODUCT_ROOT, REFERENCE_PRODUCT_COMMIT.
# Not required here: CURBPACK_COMMIT, CURBPACK_ROOT, AS_OF_DATE,
# CURBPACK_PACKS_DIR (Curbpack-side / pack / as-of; not an R1–R3 input).
#
# The commit object must already exist in this clone. Setup does not fetch
# or insert it.

require_product_baseline() {
	prefix=$1
	if [ -z "${REFERENCE_PRODUCT_ROOT:-}" ]; then
		echo "$prefix: REFERENCE_PRODUCT_ROOT is empty; source verification-run.sh first" >&2
		exit 1
	fi
	if [ -z "${REFERENCE_PRODUCT_COMMIT:-}" ]; then
		echo "$prefix: REFERENCE_PRODUCT_COMMIT is empty; source verification-run.sh first" >&2
		exit 1
	fi
	root=$(git rev-parse --show-toplevel)
	if [ "$root" != "$REFERENCE_PRODUCT_ROOT" ]; then
		echo "$prefix: this checkout is at $root, but REFERENCE_PRODUCT_ROOT is $REFERENCE_PRODUCT_ROOT" >&2
		exit 1
	fi
	if ! expected=$(git rev-parse --verify "${REFERENCE_PRODUCT_COMMIT}^{commit}" 2>/dev/null); then
		echo "$prefix: REFERENCE_PRODUCT_COMMIT is not a commit in this clone: $REFERENCE_PRODUCT_COMMIT" >&2
		echo "$prefix: the frozen commit must already exist in this clone" >&2
		exit 1
	fi
	head=$(git rev-parse HEAD)
	if [ "$head" != "$expected" ]; then
		echo "$prefix: HEAD is $head, but REFERENCE_PRODUCT_COMMIT is $expected" >&2
		exit 1
	fi
}
