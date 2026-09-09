# Run from this directory. Mutates the Glucose Log checkout.
#   make setup CASE=EV-002
#   make reset
# Optional REF=main|<commit>. Curbpack/CTAM tests pass their pin as REF.

.PHONY: reset setup

CASE ?= EV-002
REF ?= main

reset:
	./reset.sh $(REF)

setup:
	./setup.sh $(CASE) $(REF)
