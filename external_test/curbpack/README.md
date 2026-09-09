# Curbpack fixture for Glucose Log

Until pack-templates exist upstream, this product carries copies of the
embedded Curbpack packs (`house-policy`, `cra-baseline`, `medtech-iec62304`)
plus a claim map for each pack. Same pack ids, so:

```bash
export CURBPACK_PACKS_DIR="$PWD/external_test/curbpack/packs"
curbpack check
```

overrides the binary's embed. `.curbpack.json` is unchanged.

Reset, setup and `fault_injection/*.sh` live here so you can run them in
this repository and watch the tree change:

```bash
cd external_test/curbpack
make setup CASE=EV-002          # reset to main, then rm SECURITY.md
# inspect the repo; run curbpack check if you want
make reset                      # back to main
```

`reset.sh` / `setup.sh` take an optional ref (default `main`). Curbpack
tests only call these scripts; they pass their frozen product pin as the ref.
`reset.sh` discards uncommitted work in this checkout.

These copies are not certification, CE marking, or a notified-body opinion.
