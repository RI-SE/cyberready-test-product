# CTAM repository states (R8, R9) and pack inputs (PF-18)

This file is the live registry of **scripts** that implement CTAM-owned
states. Meaning lives in CTAM
[docs/testing/procedures.md](https://github.com/RI-SE/ctam/blob/main/docs/testing/procedures.md).
Do not change a state's meaning here.

Apply them with the shared Curbpack drivers and `SUT=ctam`:

```bash
SUT=ctam ./external_test/curbpack/setup.sh R8 --commit
SUT=ctam ./external_test/curbpack/mutate_pack.sh PF-18
```

R8 and R9 compose Curbpack R1 (`external_test/curbpack/states/R1.sh`).
They do not copy R1. R-ids are unique across both trees.

| ID | Repository state | Seeded condition | Expected structural result | Used by |
|---|---|---|---|---|
| R8 | R1 with reviewed `src/app.py` insulin-disclaimer bytes changed; path remains | `src/app.py` committed with the disclaimer line edited once | Git artifact bytes differ; path still present | CTAM |
| R9 | R1 with `src/app.py` removed (absent, not empty); other R1 content unchanged | `src/app.py` removed | Git path/span absent at the comparison commit | CTAM |
| PF-18 | Context-pack `pack_versions` different from PF-01 / current Glucose Log provenance | `pf-fixtures/PF-18/context-pack.json` → `external_test/ctam/context-pack.json` | `review_freshness` stale; Git unchanged | CTAM |
