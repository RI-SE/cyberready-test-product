# Curbpack Studio fixture for Glucose Log

This tree is the Studio external-test fixture. Packs under `packs/` are
Packs v2 copies of the three test packs from Curbpack Studio
`docs/reference/test-packs/`. Claim files live in `claims/`, not inside
`packs/<id>/`.

The product selection file is `curbpack.json` at the repository root. Its path fields point here:

- `packs_dir` is `external_test/curbpack/packs`
- `claims_dir` is `external_test/curbpack/claims`
- `results_dir` is `external_test/curbpack`
- `reports_dir` is `external_test/curbpack/reports`

Packs are `packs/<pack-id>/pack.json`. Claims are `claims/<claim-id>.json`. From the product root, with `curbcheck` on `PATH`:

```bash
curbcheck
```

That loads this directory's packs and claims and writes `run-result_<UTC>.json` here. `--packs` replaces the `packs/` directory. `--out` replaces that run-result file. `--repo` is required when the current directory has no `curbpack.json`.

Do not export `CURBPACK_PACKS_DIR`. Do not run `curbpack check`. Do not
select this SUT with `.curbpack.json`.

## Repository states

`setup.sh` runs `external_test/$SUT/states/<ID>.sh`. For this fixture set
`SUT=curbpack` (or run `./setup.sh` from this directory after exporting
that value). The script's own default is `curbpack-studio`, which is not
this directory, so set `SUT=curbpack`.

```bash
export REFERENCE_PRODUCT_ROOT=/path/to/cyberready-test-product
export REFERENCE_PRODUCT_COMMIT=<pin>
# tree must be clean at that commit before setup.sh
cd "$REFERENCE_PRODUCT_ROOT/external_test/curbpack"
SUT=curbpack ./setup.sh R1 --commit
```

Named pack inputs (`PF-*`) are finished files under `pf-fixtures/`.
`mutate_pack.sh` selects a PF-id and copies those files onto this
checkout. It does not clone, commit, or export variables. PF-01 is the
committed `packs/` set above.

`states/R1.sh` through `states/R7.sh` match the curbpack fixture scripts.
Do not edit them to obtain a pass.

Evidence of the carried Studio suite on this fixture is in `RUN.txt`.
