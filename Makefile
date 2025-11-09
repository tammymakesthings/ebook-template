# -*- Makefile; encoding: utf-8 -*-
# SPDX-FileCopyright-Text: 2025, Tammy Cravit.
# SPDX-LicenseIdentifier: MIT
##############################################################################
# Markdown Book Makefile - tammy@tammymakesthings.com - 2025-11-08
##############################################################################

MKFILE_PATH     := $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR      := $(shell dirname $(MKFILE_PATH))
PROJECT_NAME    := $(shell basename $(MKFILE_DIR))

# Define some macros related to searching for our toolchain
path_search = $(firstword $(wildcard $(addsuffix /$(1),$(subst :, ,$(PATH)))))
check_bin = $(if $(wildcard $(1)),$(1) (found),$(1) - (NOT found))

# If "grm" is present, we'll assume we're on a BSD system which has the GNU
# utilities installed from the packaging system.
ifneq ("$(call path_search,grm)", "")
	AWK				:= $(call path_search,gawk)
	GREP			:= $(call path_search,ggrep)
	MKDIR			:= $(call path_search,gmkdir)
	RM				:= $(call path_search,grm)
	SED				:= $(call path_search,gsed)
	SORT			:= $(call path_search,gsort)
	TR				:= $(call path_search,gtr)
	WC				:= $(call path_search,gwc)
else
ifneq ("$(call path_search,gnurm"), "")
	AWK				:= $(call path_search,gawk)
	GREP			:= $(call path_search,gnugrep)
	MKDIR			:= $(call path_search,gnumkdir)
	RM				:= $(call path_search,gnurm)
	SED				:= $(call path_search,gnused)
	SORT			:= $(call path_search,gnusort)
	TR				:= $(call path_search,gnutr)
	WC				:= $(call path_search,gnuwc)
else
	AWK				:= $(call path_search,awk)
	GREP			:= $(call path_search,grep)
	MKDIR			:= $(call path_search,mkdir)
	RM				:= $(call path_search,rm)
	SED				:= $(call path_search,sed)
	SORT			:= $(call path_search,sort)
	TR				:= $(call path_search,tr)
	WC				:= $(call path_search,wc)
endif
endif

PANDOC				:= $(call path_search,pandoc)
XELATEX				:= $(call path_search,xelatex)
EBOOK_CONVERT		:= $(call path_search,ebook-convert)

PYTHON				:= $(call path_search,python3)
MWC					:= $(call path_search,mwc)

# General settings
BUILD_DIR		:=	build
BOOKNAME		:=	$(shell echo $(PROJECT_NAME) | $(SED) 's/ /-/g' | $(TR) [A-Z] [a-z])

# File locations
METADATA		:=	metadata/metadata.yml
LOG_FILE		:=	wordcount.csv
CHAPTERS		:=	$(sort $(wildcard frontmatter/*.md)) \
					$(sort $(wildcard chapters/ch*.md)) \
					$(sort $(wildcard backmatter/*.md))
SCENES			:=	$(wildcard scenes/*.md) \
					$(wildcard scenes/**/*.md)
JOURNALS		:=	$(sort $(wildcard journal/*.md) $(wildcard journal/**/*.md))
COVER_IMAGE		:=	images/cover.jpg
IMAGE_FILES		:=	$(wildcard images/*)

# These next three variables are used by the "newjournal" target
LATEST_JOURNAL	:=	$(lastword $(JOURNALS))
DATE_STAMP		:=	$(shell date +"%B %d, %Y")
LOG_DATE		:=	$(shell date +"%Y-%m-%d")
JOURNAL_EXISTS	:=	$(shell $(GREP) "$(DATE_STAMP)" $(LATEST_JOURNAL) | $(WC) -l)

# Compile Options - General
TOC				:=	--toc --toc-depth=2
LATEX_CLASS		:=	memoir
JOURNAL_CLASS	:=	report

# Compile Options - PDF
PDF_OPTIONS		:= --template tex/pdf_template.tex \
				   --include-in-header tex/pdf_properties.tex \
				   --include-in-header tex/inline_code.tex \
				   --include-in-header tex/quote.tex \
				   --highlight tango \
				   --metadata-file $(METADATA) \
				   --pdf-engine=xelatex

# Compile Options - EPUB
EBOOK_OPTIONS	:= --top-level-division=chapter \
				   --css css/epub.css \
				   --highlight tango \
				   --metadata-file $(METADATA) \
				   --epub-cover-image=$(COVER_IMAGE)
#
# Compile Options - HTML
HTML_OPTIONS	:= --to=html5

##############################################################################
######################### Makefile Targets ###################################
##############################################################################

# NB: Do not remove the comments with the double-hashmarks, or the 'make help'
# command will stop working.

all: book					## Build the book (synonym for 'make book')

findbins:
	@echo "AWK           = $(shell which awk | sed 's/awk: //')"
	@echo "GREP          = $(shell which grep | sed 's/grep: //')"
	@echo "MKDIR         = $(shell which mkdir | sed 's/mkdir: //')"
	@echo "PANDOC        = $(shell which pandoc | sed 's/pandoc: //')"
	@echo "RM            = $(shell which rm | sed 's/rm: //')"
	@echo "SED           = $(shell which sed | sed 's/sed: //')"
	@echo "SORT          = $(shell which sort | sed 's/sort: //')"
	@echo "TR            = $(shell which tr | sed 's/tr: //')"
	@echo "WC            = $(shell which wc | sed 's/wc: //')"
	@echo "XELATEX       = $(shell which xelatex | sed 's/xelatex: //')"
	@echo "EBOOK_CONVERT = $(shell which ebook-convert | sed 's/ebook-convert: //')"

count:						## Count the words in the manuscript
ifeq ($(MWC), "mwc not found")
	$(error Cannot log word counts: mwc not found. Run 'pip install markdown-word-count' to fix.)
else
ifeq ($(firstword $(CHAPTERS)), "")
	@echo "No chapter files found in the project"
else
	@$(MWC) $(CHAPTERS) | tail -1
endif
endif

countj:						## Count the words in the journals
ifeq ($(MWC), "mwc not found")
	$(error Cannot log word counts: mwc not found. Run 'pip install markdown-word-count' to fix.)
else
ifeq ($(firstword $(JOURNALS)), "")
	@echo "No journal files found in the project"
else
	@$(MWC) $(JOURNALS) | tail -1
endif
endif

counts:						## Count the words in the scene files
ifeq ($(MWC), "mwc not found")
	$(error Cannot log word counts: mwc not found. Run 'pip install markdown-word-count' to fix.)
else
ifeq ($(firstword $(SCENES)), "")
	@echo "No scene files found in the project"
else
	@echo "'$(firstword $(SCENES))'"
	@$(MWC) $(SCENES) | tail -1
endif
endif

countall:						## Count the words in all content files
ifeq ($(MWC), "mwc not found")
	$(error Cannot log word counts: mwc not found. Run 'pip install markdown-word-count' to fix.)
else
	@$(MWC) $(CHAPTERS) $(JOURNALS) $(SCENES) | tail -1
endif

logcount : CHAPTER_COUNT = $(shell $(MWC) $(CHAPTERS) | tail -1)
logcount : JOURNALS_COUNT = $(shell $(MWC) $(JOURNALS) | tail -1)
logcount : SCENES_COUNT = $(shell $(MWC) $(SCENES) | tail -1)
logcount:					## Log today's word count
ifeq ($(MWC), "mwc not found")
	$(error Cannot log word counts: mwc not found. Run 'pip install markdown-word-count' to fix.)
else
	@$(PYTHON) scripts/log_count.py $(CHAPTERS_COUNT) $(JOURNALS_COUNT) $(SCENES_COUNT)
endif

newjournal:					## Add a new journal to the latest journal file
ifeq ($(JOURNAL_EXISTS),0)
	@echo "Adding a new journal entry to $(LATEST_JOURNAL) for $(DATE_STAMP)"
	@echo "" >> $(LATEST_JOURNAL)
	@echo "## $(DATE_STAMP)" >> $(LATEST_JOURNAL)
	@echo "" >> $(LATEST_JOURNAL)
else
	@echo "A journal entry for $(DATE_STAMP) already exists - not creating another"
endif

check:						## Display Makefile diagnostics
	@echo ""
	@echo "=======================| MAKEFILE DIAGNOSTICS |======================="
	@echo ""
	@echo "-------------"
	@echo "BUILD OPTIONS"
	@echo "-------------"
	@echo "        BUILD_DIR = $(BUILD_DIR)"
	@echo "        BOOK_NAME = $(BOOKNAME)"
	@echo "      LATEX_CLASS = $(LATEX_CLASS)"
	@echo "    JOURNAL_CLASS = $(JOURNAL_CLASS)"
	@echo ""
	@echo "      PDF_OPTIONS = $(PDF_OPTIONS)"
	@echo "    EBOOK_OPTIONS = $(EBOOK_OPTIONS)"
	@echo "     HTML_OPTIONS = $(HTML_OPTIONS)"
	@echo "              TOC = $(TOC)"
	@echo ""
	@echo "---------------"
	@echo "CONTENT OPTIONS"
	@echo "---------------"
	@echo "         METADATA = $(METADATA)"
	@echo "         CHAPTERS = $(CHAPTERS)"
	@echo "           SCENES = $(SCENES)"
	@echo "         JOURNALS = $(JOURNALS)"
	@echo ""
	@echo "      COVER_IMAGE = $(COVER_IMAGE)"
	@echo "      IMAGE_FILES = $(IMAGE_FILES)"
	@echo ""
	@echo "         LOG_FILE = $(LOG_FILE)"
	@echo ""

toolchain: 					## Display toolchain paths
	@echo ""
	@echo "=========================| TOOLCHAIN PATHS |=========================="
	@echo ""
	@echo "-----------"
	@echo "SYSTEM TYPE"
	@echo "-----------"
ifneq ("$(call path_search,grm)", "")
	@echo "    * Assuming a BSD-like system (GNU tools are '$(tool_prefix)<toolname>')"
else
	@echo "    * Assuming we can use the standard tool names"
endif
	@echo ""
	@echo "----------------"
	@echo "BINARY LOCATIONS"
	@echo "----------------"
	@echo ""
	@echo "              AWK = $(call check_bin,$(AWK))"
	@echo "    EBOOK_CONVERT = $(call check_bin,$(EBOOK_CONVERT))"
	@echo "             GREP = $(call check_bin,$(GREP))"
	@echo "            MKDIR = $(call check_bin,$(MKDIR))"
	@echo "           PANDOC = $(call check_bin,$(PANDOC))"
	@echo "           PYTHON = $(call check_bin,$(PYTHON))"
	@echo "               RM = $(call check_bin,$(RM))"
	@echo "              SED = $(call check_bin,$(SED))"
	@echo "             SORT = $(call check_bin,$(SORT))"
	@echo "               TR = $(call check_bin,$(TR))"
	@echo "               WC = $(call check_bin,$(WC))"
	@echo "          XELATEX = $(call check_bin,$(XELATEX))"
	@echo ""
	@echo "NOTE: If any tools in the above list show 'NOT found', things may not"
	@echo "      work as expected."
	@echo ""
	@echo "Run 'make help' for a list of Makefile targets."
	@echo ""


book: epub html pdf					## Build the book in EPub, HTML, and PDF formats

clean:							## Clean intermediate files
	rm -r $(BUILD_DIR)

epub: $(BUILD_DIR)/epub/$(BOOKNAME).epub		## Build the book in epub format

html: $(BUILD_DIR)/html/$(BOOKNAME).html		## Build the book in HTML format

pdf: $(BUILD_DIR)/pdf/$(BOOKNAME).pdf			## Build the book in PDF format

journal: $(BUILD_DIR)/pdf/$(BOOKNAME)_journal.pdf	## Build the book journal in PDF format

$(BUILD_DIR)/pdf/$(BOOKNAME)_journal.pdf: $(JOURNALS)
	$(MKDIR) -p $(BUILD_DIR)/pdf
	(cd metadata; ./update-metadata.sh)
	$(PANDOC) $(TOC) -f gfm $(PDF_OPTIONS) -V documentclass=$(JOURNAL_CLASS) -o $@ $(JOURNALS)

$(BUILD_DIR)/rtf/$(BOOKNAME)_journal.rtf: $(JOURNALS)
	$(MKDIR) -p $(BUILD_DIR)/rtf
	(cd metadata; ./update-metadata.sh)
	$(PANDOC) $(TOC) -f gfm $(PDF_OPTIONS) -V documentclass=$(JOURNAL_CLASS) -o $@ $(JOURNALS)

$(BUILD_DIR)/epub/$(BOOKNAME).epub: $(CHAPTERS) $(IMAGE_FILES) $(METADATA)
	$(MKDIR) -p $(BUILD_DIR)/epub
	(cd metadata; ./update-metadata.sh)
	$(PANDOC) $(TOC) -f gfm $(EBOOK_OPTIONS) --standalone -o $@ $(CHAPTERS)

$(BUILD_DIR)/mobi/$(BOOKNAME).mobi: $(CHAPTERS) $(IMAGE_FILES) $(METADATA)
	$(MKDIR) -p $(BUILD_DIR)/mobi
	(cd metadata; ./update-metadata.sh)
	$(PANDOC) $(TOC) -f gfm $(EBOOK_OPTIONS) --standalone -o $@ $(CHAPTERS)

$(BUILD_DIR)/html/$(BOOKNAME).html: $(CHAPTERS) $(IMAGE_FILES) $(METADATA)
	$(MKDIR) -p $(BUILD_DIR)/html
	(cd metadata; ./update-metadata.sh)
	$(PANDOC) $(TOC) --standalone $(HTML_OPTIONS) -o $@ $^

$(BUILD_DIR)/pdf/$(BOOKNAME).pdf: $(CHAPTERS) $(IMAGE_FILES) $(METADATA)
	$(MKDIR) -p $(BUILD_DIR)/pdf
	(cd metadata; ./update-metadata.sh)
	$(PANDOC) $(TOC) -f gfm $(PDF_OPTIONS) -V documentclass=$(LATEX_CLASS) -o $@ $(CHAPTERS)

$(BUILD_DIR)/rtf/$(BOOKNAME).rtf: $(CHAPTERS) $(IMAGE_FILES) $(METADATA)
	$(MKDIR) -p $(BUILD_DIR)/rtf
	(cd metadata; ./update-metadata.sh)
	$(PANDOC) $(TOC) -f gfm $(PDF_OPTIONS) -V documentclass=$(LATEX_CLASS) -o $@ $(CHAPTERS)

help: 							## Show this help message
	@echo ""
	@echo "==========================| MAKEFILE HELP |=========================="
	@echo ""
	@echo "The following Makefile targets are available:"
	@echo ""
	@$(GREP) -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | $(SORT) | $(AWK) 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: all book clean epub html pdf check help toolchain wordcount newjournal

