#!/bin/sh
# lantern: print the audit-logging setting from config/audit.json and exit.
# Audit logging is enabled.
set -e
cd "$(dirname "$0")/.."
grep '"audit_logging"' config/audit.json
