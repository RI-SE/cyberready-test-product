#!/usr/bin/env python3
"""Integration tests: a real src/app.py process, not an in-process handler."""

import os
import signal
import socket
import subprocess
import sys
import tempfile
import time
import unittest
from pathlib import Path
from urllib.error import URLError
from urllib.request import urlopen

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(Path(__file__).resolve().parent))

from harness import HttpClient, case  # noqa: E402


def free_port():
    sock = socket.socket()
    sock.bind(("127.0.0.1", 0))
    port = sock.getsockname()[1]
    sock.close()
    return port


class ProcessBoundaryTest(unittest.TestCase):
    def setUp(self):
        self.tmpdir = tempfile.TemporaryDirectory()
        self.port = free_port()
        env = os.environ.copy()
        env["GLUCOSE_LOG_DATA_DIR"] = self.tmpdir.name
        env["GLUCOSE_LOG_HOST"] = "127.0.0.1"
        env["GLUCOSE_LOG_PORT"] = str(self.port)
        self.proc = subprocess.Popen(
            [sys.executable, str(ROOT / "src" / "app.py")],
            cwd=str(ROOT),
            env=env,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.PIPE,
            start_new_session=True,
        )
        url = "http://127.0.0.1:%d/login" % self.port
        for _ in range(50):
            if self.proc.poll() is not None:
                err = self.proc.stderr.read().decode("utf-8", errors="replace")
                self.fail("src/app.py exited before serving: %s" % err)
            try:
                urlopen(url, timeout=0.3)
                break
            except (URLError, OSError):
                time.sleep(0.1)
        else:
            self.fail("timed out waiting for src/app.py on port %d" % self.port)

    def tearDown(self):
        if self.proc.poll() is None:
            os.killpg(self.proc.pid, signal.SIGTERM)
            try:
                self.proc.wait(timeout=3)
            except subprocess.TimeoutExpired:
                os.killpg(self.proc.pid, signal.SIGKILL)
                self.proc.wait(timeout=3)
        self.tmpdir.cleanup()

    @case("INT-001", "Process serves the login page", "integration")
    def test_process_serves_the_login_page(self):
        client = HttpClient("127.0.0.1", self.port)
        status, body, _ = client.request("GET", "/login")
        self.assertEqual(status, 200)
        self.assertIn("username: demo", body.lower())
        self.assertIn("password: demo", body.lower())
