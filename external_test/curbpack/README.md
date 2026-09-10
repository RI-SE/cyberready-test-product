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

Source the Curbpack verification-run configuration first so
`REFERENCE_PRODUCT_ROOT` and `REFERENCE_PRODUCT_COMMIT` are set. Run these
scripts from this living checkout. They reset `$REFERENCE_PRODUCT_ROOT`
(typically the tmp clone). The commit object must already exist in that
clone; origin fetch does not see unpushed commits from this tree.

```bash
cd /path/to/cyberready-test-product/external_test/curbpack
./setup.sh --list                 # R1 R2 R3
./setup.sh R2                     # mutate the tmp clone (dirty)
./setup.sh R2 --commit            # same mutation, local test_* branch there
./reset.sh                        # tmp clone back to the recorded commit; test_* stay
git -C "$REFERENCE_PRODUCT_ROOT" branch --list 'test_*'
git -C "$REFERENCE_PRODUCT_ROOT" branch -D test_you_20260909_17500000001234
```

`setup.sh` resets to `$REFERENCE_PRODUCT_COMMIT`. It does not take a commit
argument. `--commit` creates `test_<user>_<YYYYMMDD>_<id>` and prints the
name. It is local only: do not push it, do not merge it to `main`.
`reset.sh` does not delete it. Use `--commit` when the case needs a recorded
commit (EC-01). Leave the tree dirty when the case is a dirty working tree
(EC-02). Do not use an uncommitted R2/R3 as a substitute for EC-02 on R1.

Registry: `states.md` + `states.list` + `states/<ID>.sh` — change all three
together. `setup.sh` refuses unknown or duplicate R-ids.

These copies are not certification, CE marking, or a notified-body opinion.
