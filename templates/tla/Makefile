# Each specs/X.tla is checked against specs/X.cfg, which TLC finds by name.
SPECS := $(wildcard specs/*.tla)

.PHONY: check $(SPECS)

check: $(SPECS)

$(SPECS):
	tlc -workers auto -metadir states/$(basename $(notdir $@)) $@
