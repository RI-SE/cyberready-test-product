#!/usr/bin/env python3
"""Behaviour tests for the glucose-log reference app."""

import http.client
import os
import sqlite3
import sys
import tempfile
import threading
import unittest
from http.server import ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlencode, urlparse

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))

import app  # noqa: E402


class HttpClient:
    def __init__(self, host, port):
        self.host = host
        self.port = port
        self.cookie = None

    def request(self, method, path, body=None, follow=True):
        headers = {}
        encoded = None
        if body is not None:
            encoded = urlencode(body).encode("utf-8")
            headers["Content-Type"] = "application/x-www-form-urlencoded"
            headers["Content-Length"] = str(len(encoded))
        if self.cookie:
            headers["Cookie"] = self.cookie
        conn = http.client.HTTPConnection(self.host, self.port, timeout=5)
        conn.request(method, path, encoded, headers)
        resp = conn.getresponse()
        data = resp.read()
        set_cookie = resp.getheader("Set-Cookie")
        if set_cookie:
            self.cookie = set_cookie.split(";", 1)[0]
        location = resp.getheader("Location")
        status = resp.status
        conn.close()
        if follow and status in (301, 302, 303, 307, 308) and location:
            next_path = urlparse(location).path or "/"
            return self.request("GET", next_path, follow=True)
        return status, data.decode("utf-8", errors="replace"), location


class GlucoseAppTest(unittest.TestCase):
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

    def test_home_and_login_show_demo_credentials(self):
        status, home, _ = self.client.request("GET", "/")
        self.assertEqual(status, 200)
        self.assertIn("username: demo", home.lower())
        self.assertIn("password: demo", home.lower())
        status, login, _ = self.client.request("GET", "/login")
        self.assertEqual(status, 200)
        self.assertIn("username: demo", login.lower())
        self.assertIn("password: demo", login.lower())

    def test_unauthenticated_user_cannot_save_a_measurement(self):
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

    def test_valid_login_succeeds(self):
        status, body, _ = self.login()
        self.assertEqual(status, 200)
        self.assertIn("glucose", body.lower())
        self.assertIn("demo", body.lower())

    def test_invalid_login_fails(self):
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

    def test_invalid_measurement_is_rejected(self):
        self.login()
        for raw in ("", "abc", "-1", "999", "NaN"):
            status, body, _ = self.client.request(
                "POST", "/measurements", {"glucose_value": raw}
            )
            self.assertEqual(self.count_measurements(), 0, "accepted %r" % raw)
            self.assertEqual(status, 200)
            self.assertIn("must", body.lower())

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


if __name__ == "__main__":
    unittest.main()
