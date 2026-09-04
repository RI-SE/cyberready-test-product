PYTHON ?= python3
HOST ?= 127.0.0.1
PORT ?= 8080
URL := http://$(HOST):$(PORT)
PIDFILE := var/app.pid
LOGFILE := var/server.log

.PHONY: help start stop test test-unit test-functional test-integration

help:
	@echo "Glucose Log"
	@echo
	@echo "  make start              Start the server at $(URL) and open it in a browser"
	@echo "  make stop               Stop the server"
	@echo "  make test               Run the whole suite"
	@echo "  make test-unit          Run unit tests only"
	@echo "  make test-functional    Run functional tests only"
	@echo "  make test-integration   Run integration tests only"

start: var
	@command -v $(PYTHON) >/dev/null || { echo "make start: python3 is required"; exit 1; }
	@$(PYTHON) -c "import hashlib, http.server, secrets, sqlite3"
	@if [ -f $(PIDFILE) ] && kill -0 $$(cat $(PIDFILE)) 2>/dev/null; then \
		echo "Glucose Log is already running at $(URL)"; \
	else \
		rm -f $(PIDFILE); \
		$(PYTHON) -c 'import subprocess, sys; log = open("$(LOGFILE)", "a"); p = subprocess.Popen([sys.executable, "src/app.py"], stdout=log, stderr=subprocess.STDOUT, start_new_session=True); open("$(PIDFILE)", "w").write("%s\n" % p.pid)'; \
		i=0; \
		until $(PYTHON) -c "import urllib.request; urllib.request.urlopen('$(URL)', timeout=0.3)" 2>/dev/null; do \
			if [ -f $(PIDFILE) ] && ! kill -0 $$(cat $(PIDFILE)) 2>/dev/null; then \
				echo "make start: server exited. See $(LOGFILE)"; \
				rm -f $(PIDFILE); \
				exit 1; \
			fi; \
			i=$$((i+1)); \
			if [ $$i -gt 50 ]; then \
				echo "make start: timed out waiting for $(URL)"; \
				exit 1; \
			fi; \
			sleep 0.1; \
		done; \
		echo "Glucose Log is running at $(URL)"; \
	fi
	@if command -v open >/dev/null 2>&1; then \
		open "$(URL)"; \
	elif command -v xdg-open >/dev/null 2>&1; then \
		xdg-open "$(URL)"; \
	else \
		echo "make start: could not open a browser; visit $(URL)"; \
		exit 1; \
	fi

stop:
	@if [ -f $(PIDFILE) ]; then \
		pid=$$(cat $(PIDFILE)); \
		if kill -0 $$pid 2>/dev/null; then \
			kill $$pid; \
			i=0; \
			while kill -0 $$pid 2>/dev/null; do \
				i=$$((i+1)); \
				if [ $$i -gt 30 ]; then kill -9 $$pid; break; fi; \
				sleep 0.1; \
			done; \
			echo "Stopped Glucose Log"; \
		else \
			echo "Glucose Log was not running"; \
		fi; \
		rm -f $(PIDFILE); \
	else \
		echo "Glucose Log is not running"; \
	fi

test:
	@command -v $(PYTHON) >/dev/null || { echo "make test: python3 is required"; exit 1; }
	@$(PYTHON) tests/run.py

test-unit:
	@command -v $(PYTHON) >/dev/null || { echo "make test-unit: python3 is required"; exit 1; }
	@$(PYTHON) tests/run.py unit

test-functional:
	@command -v $(PYTHON) >/dev/null || { echo "make test-functional: python3 is required"; exit 1; }
	@$(PYTHON) tests/run.py functional

test-integration:
	@command -v $(PYTHON) >/dev/null || { echo "make test-integration: python3 is required"; exit 1; }
	@$(PYTHON) tests/run.py integration

var:
	@mkdir -p var
