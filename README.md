# rfm - Ruby File Manager (a browser, really)

This is a concept project to show how one can parse LS_COLORS to a file
manager to have color consistency between the terminal ls experience and a
file manager like e.g. [ranger](https://github.com/ranger/ranger).

The idea came to mind as I was working on [a complete
LS_COLORS](https://github.com/isene/LS_COLORS) setup with a corresponding
ranger theme. But making a separate theme for ranger to mimic a massive
LS_COLOR setup is rather stupid. File managers should parse LS_COLORS as
default rather than implement their own themes.

I have included comments in the code to show how this is done.

This file viewer is working (on my setup) and is in fact usable - but nowhere
near what real file managers can offer.
