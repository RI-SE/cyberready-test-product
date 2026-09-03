# test-product

Läs det här om du inte har en aning om vad vi gör.

Det här git-repot **är produkten**. En fejk-grej som heter Lantern. Ett litet skalskript, en config, en docs-fil. Inte en riktig tjänst. Inte certifiering. Inte CE-märkning.

**Curbpack** är ett annat program. Det läser dokument i *den här* mappen och kollar om sökvägar som står där faktiskt finns i git.

**CTAM** är ett tredje program. Det kan läsa Curbpacks JSON. Vi kör det sist, kort. Första testet är Curbpack.

När du är klar ska du kunna peka på tre filer på disk och samma tre namn i en JSON-fil. Då fattar du grejen.

---

## 0. Vad du behöver

- `git`
- `go` (testat med `go version` → `go1.27.0` här; nyare 1.2x går bra)

Kolla:

```bash
git --version
go version
```

---

## 1. Tre mappar bredvid varandra

Du sitter redan i `test-product`. Gå upp en nivå. Där ska det ligga tre kataloger:

```text
någon-mapp/
  test-product/     ← du är här (produkten)
  curbpack/         ← verktyget som läser dokument
  ctam/             ← verktyget som läser Curbpacks JSON
```

Om `curbpack` och `ctam` saknas, hämta dem **bredvid** `test-product` (inte inuti den):

```bash
cd ..
git clone https://github.com/RI-SE/curbpack.git
git clone https://github.com/RI-SE/ctam.git
ls
# du ska se: test-product  curbpack  ctam
```

Gå tillbaka:

```bash
cd test-product
```

---

## 2. Titta på produkten (gör det före du kör något)

Öppna tre filer. Läs dem. De är korta.

1. `docs/overview.md` — vad Lantern påstår (audit logging på, config-sökväg, startskript)
2. `config/audit.json` — inställningen `audit_logging: true`
3. `src/lantern.sh` — koden; den läser config-filen

Kör produkten en gång, så du ser att den är dum med flit:

```bash
./src/lantern.sh
```

Du ska få en rad i stil med:

```text
  "audit_logging": true,
```

Curbpack har **inte** kört än. Du har bara tittat på produkten.

---

## 3. Bygg Curbpack

```bash
cd ../curbpack
go build -o /tmp/curbpack ./cmd/curbpack
cd ../test-product
```

Om `go build` skäller: du är i fel mapp, eller `go` saknas.

---

## 4. Första testet: Curbpack läser den här produkten

Kolla först att `main` är rent (produktfilerna ska redan vara inne i git, inte bara ligga lösa):

```bash
git status
```

Du ska se `nothing to commit, working tree clean` (eller motsvarande). Annars är du mitt i en halv redigering — då är inte det här “första testet”.

Kör **alltid om** review. Spara inte en gammal JSON från i går. Curbpack skriver in *vilken git-commit* den tittade på.

```bash
/tmp/curbpack review --repo . --json > /tmp/test-product-review.json
```

Du kör kommandot **inne i `test-product`**. `--repo .` betyder “det här git-repot”.

**Exitkod 0 är OK.** (Ibland kan Curbpack avsluta med 1 och JSON:en är ändå giltig. Öppna filen.)

På skärmen (stderr, inte JSON-filen) kommer ungefär:

```text
Offline in-repo document triage — not a product verdict.
Scope-limited: only 2 governed surface(s) from packs house-policy ...
```

Det betyder:

- Det här är **inte** ett omdöme om att produkten är säker eller laglig.
- House-policy tittar bara på **två dokument**: `SECURITY.md` och `.well-known/security.txt`. Inte på hela `docs/`. Det är meningen.

JSON:en ligger i `/tmp/test-product-review.json`. Checka inte in den.

---

## 5. Vad i helvete hände?

Curbpack öppnade `SECURITY.md`. Där står tre sökvägar i bakåtick (`src/lantern.sh`, `config/audit.json`, `docs/overview.md`). Sen kollade den om de filerna finns i **det här** git-trädet.

Titta själv:

```bash
python3 -c 'import json; d=json.load(open("/tmp/test-product-review.json")); print("commit", d.get("subject_commit"));
[print(f["id"], f["state"], "from", f.get("source")) for f in d.get("findings") or []]'
```

Du ska se **tre** rader, alla `confirmed`, alla `from SECURITY.md`:

```text
reference:path:config/audit.json confirmed from SECURITY.md
reference:path:docs/overview.md confirmed from SECURITY.md
reference:path:src/lantern.sh confirmed from SECURITY.md
```

`subject_commit` ska vara **samma** som:

```bash
git rev-parse HEAD
```

**confirmed** betyder: sökvägen står i dokumentet **och** filen finns. Det betyder **inte** “audit logging funkar i produktion” och **inte** “kravet är uppfyllt”.

`reference:path:src/lantern.sh` är ett **id**. Öppna `src/lantern.sh` i editorn. Samma fil.

Om någon sökväg vore `unconfirmed` skulle filen saknas eller inte gå att hitta i git. Då har du brutit `main`: dokumentet ljuger.

---

## 6. CTAM, trettio sekunder

Samma JSON, andra programmet. Inget godkännande. Ingen magi.

```bash
cd ../ctam
go run ./ctam read /tmp/test-product-review.json
```

Du ska se samma tre `finding id=...` och samma `subject_commit`.

Då har du sett kedjan: **produktfiler → Curbpack läser dokumentet → JSON → CTAM läser JSON**.

Gå tillbaka:

```bash
cd ../test-product
```

---

## Om något kraschar

| Symptom | Vanlig orsak |
|---|---|
| `go: cannot find main module` | Du körde `go build` i `test-product`. Bygg i `curbpack`. |
| `review --repo: no governed documentation surfaces` | `SECURITY.md` eller `.well-known/security.txt` saknas. |
| `confirmed` saknas för `src/lantern.sh` | Filen finns inte, eller den är inte committad, eller du tittar på en gammal JSON. Kör steg 4 igen. |
| CTAM `subject_commit` stämmer inte med `git rev-parse HEAD` | Gammal JSON. Steg 4 igen. |

Pack-reglerna (`house-policy`) ligger **i Curbpack**, inte här. Här står bara namnet, i `.curbpack.json`. Kopiera inte in pack-filerna.

---

Inte en riktig produkt. Inte conformity assessment. Inte CE-märkning.
