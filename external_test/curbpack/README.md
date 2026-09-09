# Curbpack fixture for Glucose Log

Until pack-templates exist upstream, this product carries copies of the
embedded Curbpack packs (`house-policy`, `cra-baseline`, `medtech-iec62304`)
plus a claim map for each pack. Same pack ids, so:

```bash
export CURBPACK_PACKS_DIR="$PWD/external_test/curbpack/packs"
curbpack check
```

overrides the binary's embed. `.curbpack.json` is unchanged.

Named repository states **R1…Rn** are the setup interface (Test Procedures
§3.1). Suite cases such as EV-002 *use* a state; they are not script names.

```bash
cd external_test/curbpack
make list                       # R1 R2 R3
make setup STATE=R2             # reset to main, then missing SECURITY.md
# inspect the repo; run curbpack check if you want
make reset                      # back to main
```

Registry: `states.md` + `states.list` + `states/<ID>.sh` — change all three
together. `setup.sh` refuses unknown or duplicate R-ids.

`reset.sh` / `setup.sh` take an optional ref (default `main`). Curbpack
tests only call these scripts; they pass their frozen product pin as the ref.
`reset.sh` discards uncommitted work in this checkout.

These copies are not certification, CE marking, or a notified-body opinion.
