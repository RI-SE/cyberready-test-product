# Run from this directory. Mutates the Glucose Log checkout.
#   make setup STATE=R2
#   make reset
# Optional REF=main|<commit>. Curbpack/CTAM tests pass their pin as REF.

.PHONY: reset setup list

STATE ?= R1
REF ?= main

list:
	./setup.sh --list

reset:
	./reset.sh $(REF)

setup:
	./setup.sh $(STATE) $(REF)
