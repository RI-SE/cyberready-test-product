# External test surfaces

Not product behaviour. Not a Curbpack or CTAM verdict.

The **curbpack** tree is the base: frozen pack copies, claim maps, named
repository states R1–R7, and the shared `setup.sh` / `mutate_pack.sh`
drivers. The **ctam** tree builds on that base. CTAM reuses Curbpack R/P
ids and adds states Curbpack does not own (R8, R9, PF-18). `SUT=curbpack`
is the default. `SUT=ctam` selects the ctam tree. Ids are unique across
both trees.

```text
external_test/
  curbpack/
    packs/              # CURBPACK_PACKS_DIR — id/pack.json
    states.md           # live Curbpack R-state registry
    states/             # one script per Curbpack R-id
    pf-fixtures/        # PF-01 … PF-17
    setup.sh            # setup.sh <R-id> [--commit]; SUT selects the tree
    mutate_pack.sh
    reset.sh
  ctam/
    states.md           # live CTAM script registry
    states/             # R8.sh R9.sh (compose Curbpack R1)
    pf-fixtures/        # PF-18
    packs/              # empty; live Curbpack packs stay under curbpack/
```

A verification case sources the verification-run environment, then invokes
`setup.sh` with an R-id (optionally `--commit`). Suite cases (EV-002, …)
live in the Curbpack procedures document and *use* the curbpack states.
CTAM cases set `SUT=ctam` for CTAM-owned ids.
