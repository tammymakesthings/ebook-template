# -*- Makefile; encoding: utf-8 -*-
##############################################################################
##############################################################################

MKFILE_PATH     := $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR      := $(shell dirname $(MKFILE_PATH))
PROJECT_NAME    := $(shell basename $(MKFILE_DIR))

BSD_PACKAGE_PATH	:= /usr/pkg
MACOS_PACKAGE_PATH	:= /opt/homebrew

ifneq ("$(wildcard $(BSD_PACKAGE_PATH))", "")
	AWK		:= $(BSD_PACKAGE_PATH)/bin/gawk
	GREP		:= $(BSD_PACKAGE_PATH)/bin/ggrep
	MKDIR		:= $(BSD_PACKAGE_PATH)/bin/gmkdir
	PANDOC		:= $(BSD_PACKAGE_PATH)/bin/pandoc
	RM		:= $(BSD_PACKAGE_PATH)/bin/grm
	SED		:= $(BSD_PACKAGE_PATH)/bin/gsed
	SORT		:= $(BSD_PACKAGE_PATH)/bin/gsort
	TR		:= $(BSD_PACKAGE_PATH)/bin/gtr
	XELATEX		:= $(BSD_PACKAGE_PATH)/bin/xelatex
	EBOOK_CONVERT	:= $(BSD_PACKAGE_PATH)/bin/ebook-convert
	PACKAGE_LOC	:= bsd
else
ifneq ("$(wildcard $(MACOS_PACKAGE_PATH))", "")
	AWK		:= $(MACOS_PACKAGE_PATH)/bin/awk
	GREP		:= $(MACOS_PACKAGE_PATH)/bin/grep
	MKDIR		:= $(MACOS_PACKAGE_PATH)/bin/mkdir
	PANDOC		:= $(MACOS_PACKAGE_PATH)/bin/pandoc
	RM		:= $(MACOS_PACKAGE_PATH)/bin/rm
	SED		:= $(MACOS_PACKAGE_PATH)/bin/sed
	SORT		:= $(MACOS_PACKAGE_PATH)/bin/sort
	TR		:= $(MACOS_PACKAGE_PATH)/bin/tr
	XELATEX		:= $(MACOS_PACKAGE_PATH)/bin/xelatex
	EBOOK_CONVERT	:= $(MACOS_PACKAGE_PATH)/bin/ebook-convert
	PACKAGE_LOC	:= homebrew
else
	AWK		:= awk
	GREP		:= grep
	MKDIR		:= mkdir
	PANDOC		:= pandoc
	RM		:= rm
	SED		:= sed
	SORT		:= sort
	TR		:= tr
	XELATEX		:= xelatex
	EBOOK_CONVERT	:= ebook-convert
	PACKAGE_LOC	:= sh-path
endif
endif

BUILD_DIR	:= build
BOOKNAME	:= $(shell echo $(PROJECT_NAME) | $(SED) 's/ /-/g' | $(TR) [A-Z] [a-z])
METADATA	:= metadata/metadata.yml
CHAPTERS	:= $(wildcard frontmatter/*.md) \
		   $(wildcard chapters/ch*.md) \
		   $(wildcard backmatter/*.md)
JOURNALS	:= $(wildcard journal/*.md)

COVER_IMAGE	:= images/cover.jpg
IMAGE_FILES	:= $(wildcard images/*)

TOC		:= --toc --toc-depth=2
LATEX_CLASS	:= book
JOURNAL_CLASS	:= report

PDF_OPTIONS	:= --template tex/pdf_template.tex \
		   --include-in-header tex/pdf_properties.tex \
		   --include-in-header tex/inline_code.tex \
		   --include-in-header tex/quote.tex \
		   --highlight tango \
		   --metadata-file $(METADATA) \
		   --pdf-engine=xelatex
EBOOK_OPTIONS	:= --top-level-division=chapter \
		   --css css/epub.css \
		   --highlight tango \
		   --metadata-file $(METADATA) \
		   --epub-cover-image=$(COVER_IMAGE)
HTML_OPTIONS	:= --to=html5

all: book					## Build the book (synonym for 'make book')

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
	@echo ""
	@echo "---------------"
	@echo "CONTENT OPTIONS"
	@echo "---------------"
	@echo "         METADATA = $(METADATA)"
	@echo "         CHAPTERS = $(CHAPTERS)"
	@echo "         JOURNALS = $(JOURNALS)"
	@echo "              TOC = $(TOC)"
	@echo "      COVER_IMAGE = $(COVER_IMAGE)"
	@echo "      IMAGE_FILES = $(IMAGE_FILES)"
	@echo ""
	@echo "---------------"
	@echo "TOOLCHAIN PATHS"
	@echo "---------------"
	@echo "      PACKAGE_LOC = $(PACKAGE_LOC)"
	@echo "              AWK = $(AWK)"
	@echo "    EBOOK_CONVERT = $(EBOOK_CONVERT)"
	@echo "             GREP = $(GREP)"
	@echo "            MKDIR = $(MKDIR)"
	@echo "           PANDOC = $(PANDOC)"
	@echo "               RM = $(RM)"
	@echo "              SED = $(SED)"
	@echo "             SORT = $(SORT)"
	@echo "               TR = $(TR)"
	@echo "          XELATEX = $(XELATEX)"
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
	$(PANDOC) $(TOC) -f gfm $(PDF_OPTIONS) -V documentclass=$(JOURNAL_CLASS) -o $@ $(JOURNALS)

$(BUILD_DIR)/rtf/$(BOOKNAME)_journal.rtf: $(JOURNALS)
	$(MKDIR) -p $(BUILD_DIR)/rtf
	$(PANDOC) $(TOC) -f gfm $(PDF_OPTIONS) -V documentclass=$(JOURNAL_CLASS) -o $@ $(JOURNALS)

$(BUILD_DIR)/epub/$(BOOKNAME).epub: $(CHAPTERS) $(IMAGE_FILES) $(METADATA)
	$(MKDIR) -p $(BUILD_DIR)/epub
	$(PANDOC) $(TOC) -f gfm $(EBOOK_OPTIONS) --standalone -o $@ $(CHAPTERS)

$(BUILD_DIR)/mobi/$(BOOKNAME).mobi: $(CHAPTERS) $(IMAGE_FILES) $(METADATA)
	$(MKDIR) -p $(BUILD_DIR)/mobi
	$(PANDOC) $(TOC) -f gfm $(EBOOK_OPTIONS) --standalone -o $@ $(CHAPTERS)

$(BUILD_DIR)/html/$(BOOKNAME).html: $(CHAPTERS) $(IMAGE_FILES) $(METADATA)
	$(MKDIR) -p $(BUILD_DIR)/html
	$(PANDOC) $(TOC) --standalone $(HTML_OPTIONS) -o $@ $^

$(BUILD_DIR)/pdf/$(BOOKNAME).pdf: $(CHAPTERS) $(IMAGE_FILES) $(METADATA)
	$(MKDIR) -p $(BUILD_DIR)/pdf
	$(PANDOC) $(TOC) -f gfm $(PDF_OPTIONS) -V documentclass=$(LATEX_CLASS) -o $@ $(CHAPTERS)

$(BUILD_DIR)/rtf/$(BOOKNAME).rtf: $(CHAPTERS) $(IMAGE_FILES) $(METADATA)
	$(MKDIR) -p $(BUILD_DIR)/rtf
	$(PANDOC) $(TOC) -f gfm $(PDF_OPTIONS) -V documentclass=$(LATEX_CLASS) -o $@ $(CHAPTERS)

help: 							## Show this help message
	@echo ""
	@echo "==========================| MAKEFILE HELP |=========================="
	@echo ""
	@echo "The following Makefile targets are available:"
	@echo ""
	@$(GREP) -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | $(SORT) | $(AWK) 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: all book clean epub html pdf check help
