MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

SRC_DIR=$(MAKEFILE_DIR)
MD=$(SRC_DIR)/RESUME.md
TEMPLATE=$(SRC_DIR)/template.latex
FILTER=$(SRC_DIR)/filter.lua

OUT_DIR=$(MAKEFILE_DIR)/build
NAME=Dimitar_Banev_Resume
TEX=$(OUT_DIR)/$(NAME).tex
PDF=$(OUT_DIR)/$(NAME).pdf

.PHONY: all clean

all: $(PDF)

$(TEX): $(MD) $(TEMPLATE) $(FILTER) | $(OUT_DIR)
	pandoc $(MD) --from markdown --to latex --template=$(TEMPLATE) --lua-filter=$(FILTER) -o $(TEX)

$(PDF): $(TEX)
	latexmk -pdf -interaction=nonstopmode -halt-on-error -output-directory=$(OUT_DIR) $(TEX)

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

save:
	cp -iv $(PDF) $(MAKEFILE_DIR)

open:
	open $(PDF)

clean:
	rm -rf $(OUT_DIR)
