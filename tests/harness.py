"""Shared test helpers. Not a test module — unittest does not discover this file."""

from __future__ import annotations

import http.client
import os
import sys
from urllib.parse import urlencode, urlparse

LEVELS = ("unit", "functional", "integration")
WIDTH = 100

_COLOURS = {"PASS": "\033[1;32m", "FAIL": "\033[1;31m", "SKIP": "\033[1;33m"}


def case(case_id, label, level):
    """Attach a stable ID, diagnosis label, and level to a test method."""
    if level not in LEVELS:
        raise ValueError("level must be one of %s, not %r" % (LEVELS, level))

    def decorator(fn):
        fn.case_id = case_id
        fn.case_label = label
        fn.case_level = level
        return fn

    return decorator


def colour_enabled():
    if os.environ.get("NO_COLOR") or os.environ.get("TERM") == "dumb":
        return False
    if os.environ.get("FORCE_COLOR"):
        return True
    # unittest buffers sys.stdout during each test; the real terminal is __stdout__.
    out = getattr(sys, "__stdout__", sys.stdout)
    return hasattr(out, "isatty") and out.isatty()


def colour_tag(status):
    tag = "[%s]" % status
    if not colour_enabled():
        return tag
    return "%s%s\033[0m" % (_COLOURS.get(status, ""), tag)


def case_line(case_id, label, status):
    left = "%-7s  %s " % (case_id, label)
    fill = WIDTH - len(left) - len(" [XXXX]")
    return "%s%s %s" % (left, "." * fill if fill >= 2 else " ", colour_tag(status))


def metadata(test):
    method = getattr(test, test._testMethodName, None)
    return (
        getattr(method, "case_id", None),
        getattr(method, "case_label", None),
        getattr(method, "case_level", None),
    )


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
