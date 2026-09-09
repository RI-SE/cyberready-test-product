# External test surfaces

Not product behaviour. Not a Curbpack or CTAM verdict.

This tree is what Curbpack and (later) CTAM drive against Glucose Log:
frozen pack copies, claim maps, and fault-injection scripts.

```text
external_test/
  curbpack/
    packs/              # CURBPACK_PACKS_DIR — id/pack.json
    reset.sh setup.sh   # reset this checkout; apply one injection
    fault_injection/    # one .sh per mutation
  ctam/                 # later
```

Curbpack tests only invoke `reset.sh` / `setup.sh`. The scripts do not call
`curbpack` and do not declare pass/fail.
