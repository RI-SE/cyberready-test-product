# Curbpack fixture for Glucose Log

Glucose Log is a living product. Packs and application files change as
Curbpack and CTAM gain capability. Named R-states are **script mutations**
of a starting product ref, not commits on `main`.

Until pack-templates exist upstream, this product carries copies of the
embedded Curbpack packs (`house-policy`, `cra-baseline`, `medtech-iec62304`)
plus a claim map for each pack. Same pack ids, so:

```bash
export CURBPACK_PACKS_DIR="$PWD/external_test/curbpack/packs"
curbpack check
```

overrides the binary's embed. `.curbpack.json` is unchanged.

## Repository states

`setup.sh` accepts only IDs in `states.list`. Suite cases such as EV-002
*use* a state; they are not script names.

Source the Curbpack verification-run configuration first. That restores
`$REFERENCE_PRODUCT_ROOT` to exactly `$REFERENCE_PRODUCT_COMMIT`. Then run
`setup.sh` from that frozen checkout. It requires a clean tree at that
commit and only applies the requested R-state. It does not reset, fetch,
or clean. The R-state scripts used are the scripts in that frozen commit.
There is no supported living harness ahead of the pin. The next
independent case sources the verification-run configuration again.

```bash
source tmp/verification-run.sh    # from the Curbpack repo; restores the tmp clone
cd "$REFERENCE_PRODUCT_ROOT/external_test/curbpack"
./setup.sh --list                 # R1 R2 R3
./setup.sh R2                     # mutate the frozen checkout (dirty)
./setup.sh R2 --commit            # same mutation, local test_* branch
# next independent case: source tmp/verification-run.sh again
git -C "$REFERENCE_PRODUCT_ROOT" branch --list 'test_*'
git -C "$REFERENCE_PRODUCT_ROOT" branch -D test_you_20260909_17500000001234
```

`setup.sh` does not take a commit argument. `--commit` creates
`test_<user>_<YYYYMMDD>_<id>` and prints the name. It is local only: do
not push it, do not merge it to `main`. Local `test_*` branches remain
until someone deletes them by hand. Use `--commit` when the case needs a
recorded commit (EC-01). Leave the tree dirty when the case is a dirty
working tree (EC-02). Do not use an uncommitted R2/R3 as a substitute for
EC-02 on R1.

Registry: `states.md` + `states.list` + `states/<ID>.sh` — change all three
together. `setup.sh` refuses unknown or duplicate R-ids.

These copies are not certification, CE marking, or a notified-body opinion.
