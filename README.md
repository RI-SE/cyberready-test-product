# test-product

A tiny fake product. Curbpack reviews this git tree. Open the files; they are the product.

`main` is complete: the document names a file that exists.

## Open these

1. `SECURITY.md` — the document Curbpack reads (house-policy surface).
2. `src/install.sh` — the file that document names in backticks.
3. `.well-known/security.txt` — the other house-policy surface.
4. `.curbpack.json` — this tree uses pack `house-policy`.

## Review this tree

Build Curbpack from the clone recorded in `curbpack-ref.txt`, then:

```bash
/path/to/curbpack review --repo /Users/DanielFl/Documents/aProjects/aslak/test-product --json > /tmp/test-product-review.json
```

Write generated JSON under `/tmp` (or another ignored path). Do not commit it.

`--edges` is optional and only valid with `--repo --json`. It reads a file `{"edges":[...]}` whose `finding_id` values must already appear in this run’s findings. This repository does not ship an edges file.

## Not a real product

Not conformity assessment. Not CE marking.
