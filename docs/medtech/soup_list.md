# SOUP List

Software of unknown provenance used by glucose-log. There are no pip packages and no Node runtime dependencies. `package.json` exists so Curbpack can evaluate manifest dependency bans; it names the product `glucose-log` and lists empty dependency maps.

## Items

| Component | Version | Manufacturer | Residual Risk |
|-----------|---------|--------------|---------------|
| CPython | 3.9+ (host interpreter; documented `python3`) | Python Software Foundation | Interpreter bugs could affect the local process. Mitigate by using a current Python 3 from the OS/vendor. |
| Python stdlib `http.server` | ships with the interpreter | Python Software Foundation | Development HTTP server. glucose-log binds 127.0.0.1 only. |
| Python stdlib `sqlite3` | ships with the interpreter | Python Software Foundation / SQLite | Local file corruption or disk full. Data is disposable reference data in the gitignored var directory. |
| Python stdlib `hashlib`, `secrets`, `html`, `json`, `http.cookies` | ships with the interpreter | Python Software Foundation | Used for hashing, session tokens, escaping, and audit lines. No extra network clients. |

No axios, no npm lockfile, no third-party application libraries.
