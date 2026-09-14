# medtech-iec62304 — claims on glucose-log

IEC 62304-inspired structural drafts. Not a notified-body classification
and not a claim that glucose-log is a medical device.

| Gate | Target | Claim in this product |
|---|---|---|
| MD-SW-CLASS | `docs/medtech/software_safety_class.md` | Documented example class: Class A. No diagnosis, treatment, insulin calculation, or device control. |
| MD-SOUP | `docs/medtech/soup_list.md` | SOUP is host CPython plus stdlib (`http.server`, `sqlite3`, `hashlib`, `secrets`, `html`, `json`). No pip or npm application libraries. |
| MD-PROBLEM-RESOLUTION | `docs/medtech/problem_resolution.md` | Intake via SECURITY.md; fix in `src/app.py`; verify with `make test`. Do not add insulin or treatment logic. |
| MD-ANTI-PLACEHOLDER | medtech paths | Those drafts name glucose-log and have no TODO / lorem / `[insert …]`. |
