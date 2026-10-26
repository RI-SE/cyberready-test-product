# Repository states (R1…R7) for Curbpack Studio

This file is the registry of **scripts** under `states/` for the Studio
fixture. Curbpack defines what each R-id means. These scripts are the
executable manifestation and stay byte-identical to
`external_test/curbpack/states/R1.sh` through `R7.sh`.

`setup.sh` applies `$tree/states/<ID>.sh` under `external_test/$SUT`.
For this tree set `SUT=curbpack-studio`. A missing script is an error.

Prepare the product, then run curbcheck:

```bash
SUT=curbpack-studio ./setup.sh R1 --commit
# write curbpack.json and copy the seven carried claim files into claims/
python3 -m checks --repo <product-root> \
  --packs <product-root>/external_test/curbpack-studio/packs \
  --out <product-root>/run-result.json
```

Do not export `CURBPACK_PACKS_DIR`. Do not run `curbpack check`. Do not
use `.curbpack.json` as the Pack selection file. Use `curbpack.json`.

| ID | Repository state | Used by |
|---|---|---|
| R1 | Starting Glucose Log product content — no extra mutation | Studio carried suite (PF-01) |
| R2 | R1 with `SECURITY.md` removed (absent, not empty) | Studio / Curbpack |
| R3 | R1 with heading `## Classification Rationale` removed | Studio / Curbpack |
| R4 | demo-app content with token-only honesty-eval `SECURITY.md` | Studio / Curbpack |
| R5 | demo-app content with thin rule-satisfying honesty-eval `SECURITY.md` | Studio / Curbpack |
| R6 | R1 plus stale Owner-dated review/owned docs | Studio / Curbpack |
| R7 | R1 plus Wrong Author-dated review/owned docs | Studio / Curbpack |
