#!/usr/bin/env python3
"""Functional tests: observable HTTP behaviour against an in-process handler."""

import sqlite3
import sys
import tempfile
import threading
import unittest
from http.server import ThreadingHTTPServer
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))
sys.path.insert(0, str(Path(__file__).resolve().parent))

import app  # noqa: E402
from harness import HttpClient, case  # noqa: E402


class GlucoseAppFunctionalTest(unittest.TestCase):
    def setUp(self):
        self.tmpdir = tempfile.TemporaryDirectory()
        app.configure(self.tmpdir.name, host="127.0.0.1", port=0)
        self.httpd = ThreadingHTTPServer((app.HOST, 0), app.Handler)
        self.thread = threading.Thread(target=self.httpd.serve_forever, daemon=True)
        self.thread.start()
        host, port = self.httpd.server_address[:2]
        self.client = HttpClient(host, port)

    def tearDown(self):
        self.httpd.shutdown()
        self.httpd.server_close()
        self.tmpdir.cleanup()

    def login(self, username="demo", password="demo"):
        return self.client.request(
            "POST", "/login", {"username": username, "password": password}
        )

    def count_measurements(self):
        conn = sqlite3.connect(app.db_path())
        try:
            row = conn.execute("SELECT COUNT(*) FROM measurements").fetchone()
            return row[0]
        finally:
            conn.close()

    @case("F-001", "Valid login reaches measurements", "functional")
    def test_valid_login_reaches_measurements(self):
        status, body, _ = self.login()
        self.assertEqual(status, 200)
        self.assertIn("glucose", body.lower())
        self.assertIn("demo", body.lower())

    @case("F-002", "Unauthenticated save is refused and audited", "functional")
    def test_unauthenticated_save_is_refused_and_audited(self):
        status, _, location = self.client.request(
            "POST",
            "/measurements",
            {"glucose_value": "6.5"},
            follow=False,
        )
        self.assertIn(status, (302, 303, 401, 403))
        if location:
            self.assertIn("/login", location)
        self.assertEqual(self.count_measurements(), 0)
        text = Path(app.audit_path()).read_text(encoding="utf-8")
        self.assertIn("unauthorized", text)

    @case("F-003", "Home and login show demo credentials", "functional")
    def test_home_and_login_show_demo_credentials(self):
        status, home, _ = self.client.request("GET", "/")
        self.assertEqual(status, 200)
        self.assertIn("username: demo", home.lower())
        self.assertIn("password: demo", home.lower())
        status, login, _ = self.client.request("GET", "/login")
        self.assertEqual(status, 200)
        self.assertIn("username: demo", login.lower())
        self.assertIn("password: demo", login.lower())

    @case("F-004", "Invalid login fails without a session", "functional")
    def test_invalid_login_fails_without_a_session(self):
        status, body, location = self.client.request(
            "POST",
            "/login",
            {"username": "demo", "password": "wrong"},
            follow=False,
        )
        self.assertNotEqual(status, 200)
        if location:
            self.assertIn("/login", location)
        else:
            self.assertIn("login", body.lower())
        self.assertIsNone(self.client.cookie)

    @case("F-005", "Valid measurement can be saved", "functional")
    def test_valid_measurement_can_be_saved(self):
        self.login()
        status, _, location = self.client.request(
            "POST",
            "/measurements",
            {"glucose_value": "6.5"},
            follow=False,
        )
        self.assertIn(status, (302, 303))
        self.assertIn("/measurements", location)
        self.assertEqual(self.count_measurements(), 1)

    @case("F-006", "Saved measurement can be read back", "functional")
    def test_saved_measurement_can_be_read_back(self):
        self.login()
        self.client.request("POST", "/measurements", {"glucose_value": "7.2"})
        status, body, _ = self.client.request("GET", "/measurements")
        self.assertEqual(status, 200)
        self.assertIn("7.2", body)
        conn = sqlite3.connect(app.db_path())
        try:
            row = conn.execute(
                "SELECT glucose_value FROM measurements WHERE user_id = 1"
            ).fetchone()
        finally:
            conn.close()
        self.assertAlmostEqual(row[0], 7.2)

    @case("F-007", "Invalid measurement is rejected over HTTP", "functional")
    def test_invalid_measurement_is_rejected_over_http(self):
        self.login()
        for raw in ("", "abc", "-1", "999", "NaN"):
            status, body, _ = self.client.request(
                "POST", "/measurements", {"glucose_value": raw}
            )
            self.assertEqual(self.count_measurements(), 0, "accepted %r" % raw)
            self.assertEqual(status, 200)
            self.assertIn("must", body.lower())

    @case("F-008", "SQL injection payload is data or rejected", "functional")
    def test_sql_injection_payload_is_data_or_rejected(self):
        payload = "1; DROP TABLE measurements;--"
        self.login()
        self.client.request("POST", "/measurements", {"glucose_value": payload})
        self.assertEqual(self.count_measurements(), 0)

        attacker = HttpClient(self.client.host, self.client.port)
        status, body, _ = attacker.request(
            "POST",
            "/login",
            {"username": "' OR 1=1 --", "password": "x"},
        )
        self.assertTrue(
            status != 200 or "invalid" in body.lower() or "login" in body.lower()
        )
        self.assertIsNone(attacker.cookie)

        status, body, _ = self.login()
        self.assertEqual(status, 200)
        self.client.request("POST", "/measurements", {"glucose_value": "5.4"})
        self.assertEqual(self.count_measurements(), 1)
        conn = sqlite3.connect(app.db_path())
        try:
            tables = {
                row[0]
                for row in conn.execute(
                    "SELECT name FROM sqlite_master WHERE type='table'"
                )
            }
        finally:
            conn.close()
        self.assertIn("measurements", tables)
        self.assertIn("users", tables)

    @case("F-009", "Login appends an audit event", "functional")
    def test_login_appends_an_audit_event(self):
        self.login()
        text = Path(app.audit_path()).read_text(encoding="utf-8")
        self.assertIn("login_success", text)
        self.assertIn("demo", text)
