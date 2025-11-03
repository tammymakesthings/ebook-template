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

1.  If you have not already done so, install:
    - [git](http://git-scm.com/)
    - [make](http://www.gnu.org/software/make/) (OS X users should
      install XCode and [download the command line
      tools](http://stackoverflow.com/questions/9329243/xcode-4-4-command-line-tools).)
    - [pandoc](http://johnmacfarlane.net/pandoc)
    - [latex](http://www.latex-project.org/) (OS X users should probably
      install [MacTex](http://tug.org/mactex/).)
    - **NetBSD Users**: `pkgin install gsed gsort gawk coreutils diffutils`

2.  Clone this repo with **git**.

3.  From the top of the project, type `make book` or simply, `make`.
    This generates three versions of the sample book in a `build/`
    directory.

## Replacing the sample material

### Book content

Edit the files in `frontmatter/`, `chapters/`, and `backmatter` as desired.
Images can be added to the `images/` directory and referenced in your book.

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

### The 'research' and 'planning' folders

These folders exist for your own organization and use. They're not used in any
Makefile targets, and you can put whatever you want in them.

## Book Journal

I maintain a journal as part of my writing process. The files for this live in
the `journals/` directory, and there's a "make journal" Makefile target to
compile it to a PDF.

