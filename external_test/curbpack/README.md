# Curbpack Studio fixture for Glucose Log

This tree is the Studio external-test fixture. Packs under `packs/` are
Packs v2 copies of the three test packs from Curbpack Studio
`docs/reference/test-packs/`. Claim files live in `claims/`, not inside
`packs/<id>/`.

Run curbcheck from a Studio checkout (or any environment where
`python3 -m checks` is available):

```bash
# In the product repository root, after the R-state is prepared:
printf '%s\n' '{"packs":["cra-baseline","house-policy","medtech-iec62304"]}' > curbpack.json
mkdir -p claims
cp external_test/curbpack-studio/claims/CRA-ANNEX-VII-MANUAL.json \
   external_test/curbpack-studio/claims/CRA-ANNEX-VII-RISK.json \
   external_test/curbpack-studio/claims/CRA-ANNEX-VII-SUPPORT.json \
   external_test/curbpack-studio/claims/CRA-ART14-PATH.json \
   external_test/curbpack-studio/claims/HOUSE-ANTI-PLACEHOLDER.json \
   external_test/curbpack-studio/claims/HOUSE-SECURITY-MD.json \
   external_test/curbpack-studio/claims/HOUSE-SECURITY-TXT.json \
   claims/
python3 -m checks \
  --repo "$PWD" \
  --packs "$PWD/external_test/curbpack-studio/packs" \
  --out "$PWD/run-result.json"
```

Do not export `CURBPACK_PACKS_DIR`. Do not run `curbpack check`. Do not
select this SUT with `.curbpack.json`. The product selection file is
`curbpack.json`.

## Repository states

`setup.sh` runs `external_test/$SUT/states/<ID>.sh`. For this fixture set
`SUT=curbpack-studio` (or run `./setup.sh` from this directory after
exporting that value). `SUT` defaults in the script to `curbpack` when
unset; use this tree explicitly for Studio.

```bash
export REFERENCE_PRODUCT_ROOT=/path/to/cyberready-test-product
export REFERENCE_PRODUCT_COMMIT=<pin>
# tree must be clean at that commit before setup.sh
cd "$REFERENCE_PRODUCT_ROOT/external_test/curbpack-studio"
SUT=curbpack-studio ./setup.sh R1 --commit
```

Named pack inputs (`PF-*`) are finished files under `pf-fixtures/`.
`mutate_pack.sh` selects a PF-id and copies those files onto this
checkout. It does not clone, commit, or export variables. PF-01 is the
committed `packs/` set above.

`states/R1.sh` through `states/R7.sh` match the curbpack fixture scripts.
Do not edit them to obtain a pass.

Evidence of the carried Studio suite on this fixture is in `RUN.txt`.
