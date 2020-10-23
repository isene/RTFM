# RTFM - [Ruby|Ruddy|Rough] Terminal File Manager

## Why?
RTFM parses your LS_COLORS to ensure color consistency with the terminal experience.

The idea came to mind as I was working on [a complete
LS_COLORS setup](https://github.com/isene/LS_COLORS) with a corresponding
ranger theme. But making a separate theme for ranger to mimic a massive
LS_COLOR setup is rather stupid. File managers should parse LS_COLORS as
default rather than implement their own themes. This became an itch that
I kept scratching until I could happily replace ranger two weeks later.

## How?
RTFM is a two-pane file manager. You navigate in the left pane and the content
of the selected item (directory or file) is shown in the right pane. The right
pane is also used to show information such as the currently tagged items, your
(book)marks etc.

In order to run RTFM (without generating [a bunch of
warnings](https://github.com/isene/RTFM/issues/1)), you need to do a `gem
install curses` (gets v 1.3.2) instead of installing via `apt install
ruby-curses` (gets v. 1.2.4-1build1 on Ubuntu 20.04). 

Content of text files are handled by `cat`. Other files are shown via external
programs. It is shown if you have the program installed (Debian/Ubuntu family
of Linux distros command in parenthesis):

File type      | Requirements                     | Installation
---------------|----------------------------------|------------------------------
Syntax highlighting of text | `bat`               | `apt install bat`
Images         | `w3m` and `ImageMagick`          | `apt install w3m imagemagick`
PDFs           | `pdftotext`                      | `apt install poppler-utils`
LibreOffice    | `odt2txt`                        | `apt install odt2txt`
OOXML          | `docx2txt`                       | `apt install docx2txt`
MS doc/xls/ppt | `catdoc`, `xls2csv` and `catppt` | `apt install catdoc`

For images to be rendered in the terminal, place the file `imgw3m.sh` in your
PATH - such as in `~/bin/` and ensure it is executable.

## Screenshot

![](img/screenshot.png)

## Keys
Key    | What happens when pressed
-------|-------------------------------------------------------------
h      | Show help text in right pane
DOWN   | Go one item down in left pane (rounds to top)
UP     | Go one item up in left pane (rounds to bottom)
PgDown | Go one page down in left pane
PgUp   | Go one page up in left pane
END    | Go to last item in left pane
HOME   | Go to first item in left pane
LEFT   | Go up one directory level
RIGHT  | Enter directory or open file (using run-mailcap or xdg-open)
a      | Show all (also hidden) items
l      | Show long info per item (show item attributes)
t      | Tag item (toggles)
T      | Show currently tagged items in right pane
u      | Untag all tagged items
p      | Put (copy) tagged items here
P      | PUT (move) tagged items here
s      | Create symlink to tagged items here
d      | Delete selected item and tagged item. Press 'd' to confirm.
m      | Mark current location (permanent bookmark). Next letter entered is the name of the mark [a-zA-Z]. Press '-' and a letter to delete that mark.
M      | Show marked items in right pane
'      | Jump to mark (next letter is the name of the mark [a-zA-Z])
:      | Enter "command mode" in bottom window
ENTER  | Refresh RTFM
q      | Quit

## A convenient shell function
Add this line to your `.bashrc` or `.zshrc` to make RTFM exit to the current
directory by launching the file manager via `r` in the terminal:

`source ~/.rtfm.launch`

... and place the file `.rtfm.launch` in your home directory.

With this, you can jump around in your directory structure via RTFM, exit to
the desired directory, do work in the terminal and go back into RTFM via `r`.

## Development
I don't expect this program to be used by others. I do this for my own
enjoyment and because I want a file manager that fits my needs better than any
others I have found. If you come up with a feature request I feel is cool, I
may include it. Bug reports are always welcome.
