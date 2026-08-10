#!/bin/sh
# Re-download the public-domain source texts from Project Gutenberg.
# The raw books are not committed (several MB each); studies and designs are.
set -e
cd "$(dirname "$0")"
fetch() { [ -f "$2" ] || curl -L "https://www.gutenberg.org/cache/epub/$1/pg$1.txt" -o "$2"; }
fetch 120  treasure-island/book.txt
fetch 345  dracula/book.txt
fetch 1184 monte-cristo/book.txt
fetch 11   alice/book.txt
fetch 12   alice/looking-glass.txt
fetch 55   wizard-of-oz/book.txt
echo "all texts present"
