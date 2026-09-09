# Curbpack fixture for Glucose Log

Until pack-templates exist upstream, this product carries copies of the
embedded Curbpack packs (`house-policy`, `cra-baseline`, `medtech-iec62304`)
plus a claim map for each pack. Same pack ids, so:

```bash
export CURBPACK_PACKS_DIR="$PWD/external_test/curbpack/packs"
curbpack check
```

overrides the binary's embed. `.curbpack.json` is unchanged.

`fault_injection/*.sh` are RF-02 mutations. Curbpack reset/setup runs them
inside a work clone checked out at its pin. Do not run them on a checkout
you are developing in.

These copies are not certification, CE marking, or a notified-body opinion.
