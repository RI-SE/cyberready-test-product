# External test surfaces

Not product behaviour. Not a Curbpack or CTAM verdict.

This tree is what Curbpack and (later) CTAM drive against Glucose Log:
frozen pack copies, claim maps, and fault-injection scripts.

```text
external_test/
  curbpack/
    packs/              # CURBPACK_PACKS_DIR — id/pack.json
    fault_injection/    # one .sh per mutation, run from a Curbpack work clone
  ctam/                 # later
```

Curbpack owns setup / test / teardown and the product pin.
Scripts here only mutate. They do not call `curbpack` and do not declare pass/fail.
