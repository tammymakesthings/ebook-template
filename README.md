# Pandoc Markdown ebook template

This project defines a skeleton repo for creating ebooks out of [Pandoc
Markdown](http://johnmacfarlane.net/pandoc/README.html). Pandoc is a
great tool for writing ebooks with simple to moderately complex
formatting, but I\'ve found that in practice, creating an EPUB isn\'t
*quite* as simple as just running `pandoc -o book.epub book.md`.

The author of Pandoc has written a short tutorial for [creating EPUB
files with Pandoc](http://johnmacfarlane.net/pandoc/epub.html). This
repo just expands on MacFarlane\'s tutorial a bit and wraps things up in
a Makefile.

## Installing and running

1. If you have not already done so, install:
    - [git](http://git-scm.com/)
    - [make](http://www.gnu.org/software/make/) (OS X users should
      install XCode and [download the command line
      tools](http://stackoverflow.com/questions/9329243/xcode-4-4-command-line-tools).)
    - [pandoc](http://johnmacfarlane.net/pandoc)
    - [Python](https://python.org/)
    - [LaTeX](http://www.latex-project.org/) (OS X users should probably
      install [MacTeX](http://tug.org/mactex/).)
    - **NetBSD Users**: `pkgin install gsed gsort gawk coreutils diffutils`

2. Clone this repo with **git**.

3. From the top of the project, type `make book` or simply, `make`.
   This generates three versions of the sample book in a `build/`
   directory.

## Replacing the sample material

### Book content

Edit the files in `frontmatter/`, `chapters/`, and `backmatter` as desired.
Images can be added to the `images/` directory and referenced in your book.

Scenes which have not been integrated into a chapter, but which you want to
keep, should go in the `scenes/` directory.

Research and planning materials can go in the `research/` and `planning/`
directories.

### Makefile

If you don\'t want a cover image, delete this variable and the
`--epub-cover-image` option in the EPUB target.

(Optional) Change `LATEX_CLASS`. The default of `report` handles
multi-chapter books pretty well, and uses the same template for even
and odd page numbers. However, you are free to substitute in any other
LaTeX document class. For example, `book` provides a
left-side/right-side template that is suitable for print, and
`article` is good for shorter manuscripts (short stories, technical
briefs).

`make help` will list the Makefile targets which are defined. To check
the settings of auto-detected things, use `make check`.

### metadata/metadata.xml

Replace with your actual copyright statement, language, and any other
Dublin Core metadata you wish to provide.

## Book Journal

I maintain a journal as part of my writing process. The files for this live in
the `journals/` directory, and there's a "make journal" Makefile target to
compile it to a PDF.

## Word Count Logging

If you want to track your word count, you can run the command `make logcount`
at the end of your writing session. This captures the counts of words in the
chapters, scenes, and journals into a CSV file in the project folder. The
counted words are fed to `scripts/log_count.py`, a Python script which replaces
the day's count (if it already exists) with the new counts. If your Python
intepreter isn't found in your path, you'll need to edit the script to specify
the correct Python path.

## Author

This version of the `ebook-template` repo is by [Tammy Cravit][tammyurl]. It's
forked from the project with the same name by [Florian Dahlitz][florianurl].

[tammyrepo]: https://github.com/tammymakesthings/ebook-template.git
[tammyurl]: https://github.com/tammymakesthings/
[florianurl]: https://github.com/DahlitzFlorian/ebook-template.git

