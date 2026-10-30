# Curbpack fixture for Glucose Log

Glucose Log is a living product. Packs and application files change as
Curbpack and CTAM gain capability. Named R-states are the executable
manifestation of the states Curbpack defines. R1–R3 are **script
mutations** of a starting product ref. R4–R5 build disposable trees from
Curbpack testdata. CTAM-owned states (R8, R9, PF-18) live under
`external_test/ctam/` and are applied with `SUT=ctam` through this
directory's `setup.sh` / `mutate_pack.sh`.

Until pack-templates exist upstream, this product carries copies of the
embedded Curbpack packs (`house-policy`, `cra-baseline`, `medtech-iec62304`)
plus a claim map for each pack. Same pack ids, so:

```bash
curbcheck --repo "$PWD"
```

`curbpack.json` at the product root selects the packs and points `packs_dir`, `claims_dir`, `results_dir`, and `reports_dir` at `external_test/curbpack`. `.curbpack.json` is not the selection file.

Named pack inputs (`PF-*`) are finished files under `pf-fixtures/`. After
the R-state, select one with `mutate_pack.sh`. The only argument is the
PF-id. The script copies those files onto this checkout (`packs/` or
`review-pack-input/`). It does not clone, commit, or export variables.

```bash
./setup.sh R1 --commit
./mutate_pack.sh PF-03
```

PF-01 is the committed `packs/` set. PF-02 is reserved for a second
product instance and is not implemented. The PF registry lives in Curbpack
`docs/testing/procedures/1_pack_template_instantiation.md`.

## Repository states

`setup.sh` runs `external_test/$SUT/states/<ID>.sh`. `SUT` defaults to
`curbpack`. A missing script is an error. Suite cases such as EV-002
*use* a state; they are not script names.

Source the Curbpack verification-run configuration first. That restores
`$REFERENCE_PRODUCT_ROOT` to exactly `$REFERENCE_PRODUCT_COMMIT`. Then
prepare the named R-state. The R-state scripts used are the scripts in
that frozen commit. There is no supported living harness ahead of the
pin. The next independent case sources the verification-run configuration
again.

R1–R3: run `setup.sh` from that frozen checkout. It requires a clean tree
at that commit and only applies the requested R-state. It does not reset,
fetch, or clean.

R4–R5: run `states/R4.sh` or `states/R5.sh`. They read Curbpack testdata
and write `$CURBPACK_ROOT/tmp/R4` or `tmp/R5`. They do not mutate this
checkout. Do not use `--commit` for those states; the case records Git.

```bash
source tmp/verification-run.sh    # from the Curbpack repo; restores the tmp clone
cd "$REFERENCE_PRODUCT_ROOT/external_test/curbpack"
./setup.sh --list                 # R1 … R7 in this tree
./setup.sh R2                     # mutate the frozen checkout (dirty)
./setup.sh R2 --commit            # same mutation, local test_* branch
./states/R4.sh                    # recreate $CURBPACK_ROOT/tmp/R4 only
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

Registry: `states.md` + `states/<ID>.sh`. `setup.sh` fails if the script
file is missing.

These copies are not certification, CE marking, or a notified-body opinion.
