#!/usr/bin/env python3
"""Glucose Log: store blood-glucose values entered by a user.

CyberReady reference/test product. Not a medical device.
Does not calculate insulin, recommend treatment, or make clinical decisions.
"""

import hashlib
import html
import json
import os
import secrets
import sqlite3
import sys
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse

HOST = "127.0.0.1"
PORT = 8080
DEMO_USERNAME = "demo"
DEMO_PASSWORD = "demo"
PBKDF2_ITERATIONS = 120000
GLUCOSE_MIN = 0.1
GLUCOSE_MAX = 50.0
COOKIE_NAME = "session"

DATA_DIR = None
SESSIONS = {}

DISCLAIMER = (
    "This is a CyberReady reference/test product. "
    "It is not a medical device and does not calculate insulin, "
    "recommend treatment, or make clinical decisions. "
    "It only stores values you enter."
)


def repo_root():
    return os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def default_data_dir():
    return os.path.join(repo_root(), "var")


def db_path():
    return os.path.join(DATA_DIR, "glucose.db")


def audit_path():
    return os.path.join(DATA_DIR, "audit.log")


def now_utc():
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def configure(data_dir, host="127.0.0.1", port=8080):
    global DATA_DIR, HOST, PORT, SESSIONS
    DATA_DIR = data_dir
    HOST = host
    PORT = port
    SESSIONS = {}
    os.makedirs(DATA_DIR, exist_ok=True)
    init_db()


def connect():
    conn = sqlite3.connect(db_path())
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    return conn


def hash_password(password, salt=None):
    if salt is None:
        salt = secrets.token_bytes(16)
    digest = hashlib.pbkdf2_hmac(
        "sha256", password.encode("utf-8"), salt, PBKDF2_ITERATIONS
    )
    return "%s$%s" % (salt.hex(), digest.hex())


def verify_password(password, stored):
    try:
        salt_hex, digest_hex = stored.split("$", 1)
        salt = bytes.fromhex(salt_hex)
    except (ValueError, AttributeError):
        return False
    candidate = hashlib.pbkdf2_hmac(
        "sha256", password.encode("utf-8"), salt, PBKDF2_ITERATIONS
    )
    return secrets.compare_digest(candidate.hex(), digest_hex)


def init_db():
    os.makedirs(DATA_DIR, exist_ok=True)
    conn = connect()
    try:
        conn.execute(
            """
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY,
                username TEXT NOT NULL UNIQUE,
                password_hash TEXT NOT NULL
            )
            """
        )
        conn.execute(
            """
            CREATE TABLE IF NOT EXISTS measurements (
                id INTEGER PRIMARY KEY,
                user_id INTEGER NOT NULL,
                measured_at TEXT NOT NULL,
                glucose_value REAL NOT NULL,
                created_at TEXT NOT NULL,
                FOREIGN KEY (user_id) REFERENCES users(id)
            )
            """
        )
        row = conn.execute(
            "SELECT id FROM users WHERE username = ?", (DEMO_USERNAME,)
        ).fetchone()
        if row is None:
            conn.execute(
                "INSERT INTO users (username, password_hash) VALUES (?, ?)",
                (DEMO_USERNAME, hash_password(DEMO_PASSWORD)),
            )
        conn.commit()
    finally:
        conn.close()


def audit(event, username="", detail=""):
    os.makedirs(DATA_DIR, exist_ok=True)
    record = {
        "ts": now_utc(),
        "event": event,
        "username": username,
        "detail": detail,
    }
    with open(audit_path(), "a", encoding="utf-8") as handle:
        handle.write(json.dumps(record) + "\n")


def parse_glucose(raw):
    if raw is None or str(raw).strip() == "":
        return None, "Glucose value must be a number between 0.1 and 50.0."
    try:
        value = float(str(raw).strip())
    except ValueError:
        return None, "Glucose value must be a number between 0.1 and 50.0."
    if value != value or not (GLUCOSE_MIN <= value <= GLUCOSE_MAX):
        return None, "Glucose value must be a number between 0.1 and 50.0."
    return value, None


def page(title, body, status_note=None):
    note = ""
    if status_note:
        note = '<p class="note">%s</p>' % html.escape(status_note)
    return """<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>%s — Glucose Log</title>
  <style>
    body { font-family: sans-serif; max-width: 40rem; margin: 2rem auto; padding: 0 1rem; }
    .disclaimer { background: #f4f4f4; padding: 0.75rem 1rem; }
    .note { color: #8a1f1f; }
    label, input { display: block; margin: 0.4rem 0; }
    table { border-collapse: collapse; width: 100%%; }
    th, td { border-bottom: 1px solid #ddd; text-align: left; padding: 0.4rem 0; }
    nav a { margin-right: 1rem; }
  </style>
</head>
<body>
  <h1>Glucose Log</h1>
  <p class="disclaimer">%s</p>
  %s
  %s
</body>
</html>
""" % (
        html.escape(title),
        html.escape(DISCLAIMER),
        note,
        body,
    )


class Handler(BaseHTTPRequestHandler):
    server_version = "GlucoseLog/0.1"

    def log_message(self, fmt, *args):
        sys.stderr.write("%s - %s\n" % (self.address_string(), fmt % args))

    def current_user(self):
        header = self.headers.get("Cookie", "")
        token = None
        for part in header.split(";"):
            part = part.strip()
            if part.startswith(COOKIE_NAME + "="):
                token = part.split("=", 1)[1]
                break
        if not token:
            return None
        return SESSIONS.get(token)

    def read_form(self):
        length = int(self.headers.get("Content-Length", "0") or "0")
        raw = self.rfile.read(length).decode("utf-8") if length else ""
        parsed = parse_qs(raw, keep_blank_values=True)
        return {key: values[0] if values else "" for key, values in parsed.items()}

    def send_html(self, content, status=200, headers=None):
        payload = content.encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(payload)))
        self.send_header("Cache-Control", "no-store")
        extra = headers or {}
        for key, value in extra.items():
            self.send_header(key, value)
        self.end_headers()
        self.wfile.write(payload)

    def redirect(self, location, extra_headers=None, status=303):
        self.send_response(status)
        self.send_header("Location", location)
        self.send_header("Content-Length", "0")
        extra = extra_headers or {}
        for key, value in extra.items():
            self.send_header(key, value)
        self.end_headers()

    def session_header(self, token):
        return {
            "Set-Cookie": "%s=%s; Path=/; HttpOnly; SameSite=Lax" % (COOKIE_NAME, token)
        }

    def clear_session_header(self):
        return {
            "Set-Cookie": "%s=; Path=/; HttpOnly; SameSite=Lax; Max-Age=0" % COOKIE_NAME
        }

    def do_GET(self):
        path = urlparse(self.path).path
        if path == "/":
            self.handle_home()
        elif path == "/login":
            self.handle_login_form()
        elif path == "/measurements":
            self.handle_measurements()
        elif path == "/logout":
            self.handle_logout()
        else:
            self.send_html(page("Not found", "<p>Not found.</p>"), status=404)

    def do_POST(self):
        path = urlparse(self.path).path
        if path == "/login":
            self.handle_login_post()
        elif path == "/measurements":
            self.handle_measurement_post()
        else:
            self.send_html(page("Not found", "<p>Not found.</p>"), status=404)

    def handle_home(self):
        user = self.current_user()
        if user:
            body = (
                "<nav><a href=\"/measurements\">Measurements</a>"
                "<a href=\"/logout\">Log out</a></nav>"
                "<p>Signed in as %s.</p>"
            ) % html.escape(user["username"])
        else:
            body = (
                "<nav><a href=\"/login\">Log in</a></nav>"
                "<p>Log in to store a blood-glucose measurement.</p>"
            )
        self.send_html(page("Home", body))

    def handle_login_form(self, note=None, status=200):
        if self.current_user() and note is None:
            self.redirect("/measurements")
            return
        body = """
<nav><a href="/">Home</a></nav>
<form method="post" action="/login">
  <label>Username <input name="username" autocomplete="username"></label>
  <label>Password <input type="password" name="password" autocomplete="current-password"></label>
  <button type="submit">Log in</button>
</form>
<p>Local demo account: demo / demo</p>
"""
        self.send_html(page("Login", body, note), status=status)

    def handle_login_post(self):
        form = self.read_form()
        username = (form.get("username") or "").strip()
        password = form.get("password") or ""
        conn = connect()
        try:
            row = conn.execute(
                "SELECT id, username, password_hash FROM users WHERE username = ?",
                (username,),
            ).fetchone()
        finally:
            conn.close()
        if row is None or not verify_password(password, row["password_hash"]):
            audit("login_failure", username)
            self.handle_login_form(note="Invalid username or password.", status=401)
            return
        token = secrets.token_urlsafe(32)
        SESSIONS[token] = {"id": row["id"], "username": row["username"]}
        audit("login_success", row["username"])
        self.redirect("/measurements", extra_headers=self.session_header(token))

    def handle_measurements(self, note=None):
        user = self.current_user()
        if user is None:
            audit("unauthorized", detail="GET /measurements")
            self.redirect("/login")
            return
        conn = connect()
        try:
            rows = conn.execute(
                """
                SELECT measured_at, glucose_value, created_at
                FROM measurements
                WHERE user_id = ?
                ORDER BY id DESC
                """,
                (user["id"],),
            ).fetchall()
        finally:
            conn.close()
        items = []
        for row in rows:
            items.append(
                "<tr><td>%s</td><td>%s</td></tr>"
                % (
                    html.escape(str(row["measured_at"])),
                    html.escape(str(row["glucose_value"])),
                )
            )
        table = "".join(items) or "<tr><td colspan=\"2\">No measurements yet.</td></tr>"
        body = """
<nav><a href="/">Home</a><a href="/logout">Log out</a></nav>
<p>Signed in as %s.</p>
<form method="post" action="/measurements">
  <label>Blood glucose (mmol/L, stored as entered)
    <input name="glucose_value" inputmode="decimal">
  </label>
  <button type="submit">Save</button>
</form>
<h2>Stored measurements</h2>
<table>
  <thead><tr><th>Measured at (UTC)</th><th>Value</th></tr></thead>
  <tbody>%s</tbody>
</table>
""" % (
            html.escape(user["username"]),
            table,
        )
        self.send_html(page("Measurements", body, note))

    def handle_measurement_post(self):
        user = self.current_user()
        if user is None:
            audit("unauthorized", detail="POST /measurements")
            self.redirect("/login")
            return
        form = self.read_form()
        value, error = parse_glucose(form.get("glucose_value"))
        if error:
            self.handle_measurements(note=error)
            return
        stamp = now_utc()
        conn = connect()
        try:
            conn.execute(
                """
                INSERT INTO measurements (user_id, measured_at, glucose_value, created_at)
                VALUES (?, ?, ?, ?)
                """,
                (user["id"], stamp, value, stamp),
            )
            conn.commit()
        finally:
            conn.close()
        audit("measurement_saved", user["username"], detail=str(value))
        self.redirect("/measurements")

    def handle_logout(self):
        user = self.current_user()
        header = self.headers.get("Cookie", "")
        for part in header.split(";"):
            part = part.strip()
            if part.startswith(COOKIE_NAME + "="):
                token = part.split("=", 1)[1]
                SESSIONS.pop(token, None)
                break
        if user:
            audit("logout", user["username"])
        self.redirect("/", extra_headers=self.clear_session_header())


def serve():
    httpd = ThreadingHTTPServer((HOST, PORT), Handler)
    sys.stderr.write(
        "Glucose Log listening on http://%s:%s\n"
        "Not a medical device. Local demo user: %s / %s\n"
        % (HOST, PORT, DEMO_USERNAME, DEMO_PASSWORD)
    )
    sys.stderr.flush()
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        sys.stderr.write("\nStopping\n")
    finally:
        httpd.server_close()


if __name__ == "__main__":
    configure(default_data_dir())
    serve()
