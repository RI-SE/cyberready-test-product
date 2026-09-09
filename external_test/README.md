# External test surfaces

Not product behaviour. Not a Curbpack or CTAM verdict.

This tree is what Curbpack and (later) CTAM drive against Glucose Log:
frozen pack copies, claim maps, and named repository states R1…Rn.

```text
external_test/
  curbpack/
    packs/              # CURBPACK_PACKS_DIR — id/pack.json
    states.md           # live R-state registry (procedures §3.1)
    states/             # one script per R-id
    reset.sh setup.sh   # setup.sh <R-id> [ref]
  ctam/                 # later
```

Curbpack tests only invoke `reset.sh` / `setup.sh` with an R-id.
Suite cases (EV-002, …) live in the procedures document and *use* these states.
