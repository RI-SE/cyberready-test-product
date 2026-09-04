#!/usr/bin/env python3
"""Unit tests: isolated rules, no HTTP server."""

import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))
sys.path.insert(0, str(Path(__file__).resolve().parent))

import app  # noqa: E402
from harness import case  # noqa: E402


class GlucoseRuleTest(unittest.TestCase):
    @case("U-001", "Rejects a glucose value below 0.1", "unit")
    def test_rejects_glucose_below_min(self):
        value, error = app.parse_glucose("0.09")
        self.assertIsNone(value)
        self.assertIn("must", error.lower())

    @case("U-003", "Rejects a glucose value above 50.0", "unit")
    def test_rejects_glucose_above_max(self):
        value, error = app.parse_glucose("50.1")
        self.assertIsNone(value)
        self.assertIn("must", error.lower())

    @case("U-004", "Rejects a non-numeric glucose value", "unit")
    def test_rejects_non_numeric_glucose(self):
        value, error = app.parse_glucose("abc")
        self.assertIsNone(value)
        self.assertIn("must", error.lower())

    @case("U-005", "Accepts a glucose value in the valid range", "unit")
    def test_accepts_glucose_in_range(self):
        value, error = app.parse_glucose("6.5")
        self.assertEqual(value, 6.5)
        self.assertIsNone(error)

    @case("U-008", "Rejects NaN as a glucose value", "unit")
    def test_rejects_nan_glucose(self):
        value, error = app.parse_glucose("NaN")
        self.assertIsNone(value)
        self.assertIn("must", error.lower())

    @case("U-009", "Rejects an empty glucose value", "unit")
    def test_rejects_empty_glucose(self):
        value, error = app.parse_glucose("")
        self.assertIsNone(value)
        self.assertIn("must", error.lower())


class PasswordHashTest(unittest.TestCase):
    @case("U-002", "Stores the demo password as PBKDF2, not plaintext", "unit")
    def test_demo_password_is_pbkdf2(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        app.configure(tmp.name)
        conn = app.connect()
        try:
            row = conn.execute(
                "SELECT password_hash FROM users WHERE username = ?",
                (app.DEMO_USERNAME,),
            ).fetchone()
        finally:
            conn.close()
        self.assertIsNotNone(row)
        stored = row[0]
        self.assertNotIn(app.DEMO_PASSWORD, stored)
        self.assertIn("$", stored)

    @case("U-006", "Verifies a correct password against its PBKDF2 hash", "unit")
    def test_verify_password_accepts_match(self):
        stored = app.hash_password("secret")
        self.assertTrue(app.verify_password("secret", stored))

    @case("U-007", "Rejects a password that does not match the stored hash", "unit")
    def test_verify_password_rejects_mismatch(self):
        stored = app.hash_password("secret")
        self.assertFalse(app.verify_password("wrong", stored))
