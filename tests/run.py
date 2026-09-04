#!/usr/bin/env python3
"""Compact test runner for Glucose Log.

unittest is the engine. This script presents each result as
`ID  diagnosis ................................. [PASS]` grouped by level.
"""

from __future__ import annotations

import os
import sys
import unittest
from pathlib import Path

TESTS = Path(__file__).resolve().parent
ROOT = TESTS.parent

sys.path.insert(0, str(TESTS))

from harness import LEVELS, WIDTH, case_line, colour_enabled, metadata  # noqa: E402

USAGE = "usage: tests/run.py [unit|functional|integration]"


def die(message):
    sys.stderr.write("test: %s\n" % message)
    raise SystemExit(2)


def rule():
    return "-" * WIDTH


def iter_tests(suite):
    for item in suite:
        if isinstance(item, unittest.TestSuite):
            yield from iter_tests(item)
        else:
            yield item


def load_cases(levels):
    loader = unittest.TestLoader()
    suite = loader.discover(start_dir=str(TESTS), pattern="test_*.py", top_level_dir=str(TESTS))
    cases = []
    missing = []
    seen = {}
    for test in iter_tests(suite):
        case_id, label, level = metadata(test)
        if not case_id or not label or not level:
            missing.append("%s.%s" % (type(test).__name__, test._testMethodName))
            continue
        if case_id in seen:
            die("duplicate case id %s (%s and %s)" % (case_id, seen[case_id], test._testMethodName))
        seen[case_id] = test._testMethodName
        if level not in levels:
            continue
        cases.append((level, case_id, label, test))
    if missing:
        die("tests without @case: %s" % ", ".join(missing))
    cases.sort(key=lambda row: (LEVELS.index(row[0]), row[1]))
    return cases


class CompactResult(unittest.TestResult):
    def __init__(self, stream):
        super().__init__()
        self.stream = stream
        self.buffer = True

    def addSuccess(self, test):
        super().addSuccess(test)
        self._emit(test, "PASS")

    def addSkip(self, test, reason):
        super().addSkip(test, reason)
        self._emit(test, "SKIP")
        self.stream.write("    skipped: %s\n" % (reason or "no reason given"))
        self.stream.flush()

    def addFailure(self, test, err):
        super().addFailure(test, err)
        self._emit(test, "FAIL")

    def addError(self, test, err):
        super().addError(test, err)
        self._emit(test, "FAIL")

    def addUnexpectedSuccess(self, test):
        super().addUnexpectedSuccess(test)
        self._emit(test, "FAIL")

    def _emit(self, test, status):
        case_id, label, _ = metadata(test)
        self.stream.write(case_line(case_id, label, status) + "\n")
        self.stream.flush()

    def print_failures(self):
        if self.wasSuccessful():
            return
        heading = "FAILED"
        if colour_enabled():
            heading = "\033[1;31mFAILED\033[0m"
        self.stream.write("\n%s\n" % heading)
        self.stream.write(rule() + "\n")
        for test, tb in self.failures + self.errors:
            case_id, label, _ = metadata(test)
            self.stream.write("    %s  %s\n" % (case_id, label))
            for line in tb.rstrip().splitlines():
                self.stream.write("      %s\n" % line)
        self.stream.write("\n")
        self.stream.flush()


def present(cases, levels):
    result = CompactResult(sys.stdout)
    for level in levels:
        group = [row for row in cases if row[0] == level]
        if not group:
            continue
        print(level.upper())
        print(rule())
        for _, _, _, test in group:
            test(result)
        print()
    result.print_failures()
    return result


def main(argv):
    os.chdir(str(ROOT))
    args = argv[1:]
    if not args:
        levels = LEVELS
    elif len(args) == 1 and args[0] in ("help", "-h", "--help"):
        print(USAGE)
        return 0
    elif len(args) == 1 and args[0] in LEVELS:
        levels = (args[0],)
    else:
        die(USAGE)
    cases = load_cases(levels)
    result = present(cases, levels)
    return 0 if result.wasSuccessful() else 1


if __name__ == "__main__":
    try:
        raise SystemExit(main(sys.argv))
    except KeyboardInterrupt:
        raise SystemExit(130)
