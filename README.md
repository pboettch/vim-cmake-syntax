# vim-cmake-syntax

Vim syntax highlighting rules for modern CMakeLists.txt.

Original code from KitWare.
First hosted on Github by Nicholas Hutchinson.
Extended and modified by Patrick Boettcher and contributors

The code of this repository is integrated in and released with CMake and is pulled
into the official cmake-distribution "from time to time".

## Installation

With Pathogen

    cd ~/.vim/bundle
    git clone git://github.com/pboettch/vim-cmake-syntax.git

With Vundle

    " inside .vimrc
    Plugin 'pboettch/vim-cmake-syntax'

## Updating

Updating with new keywords and commands needs to be done for new releases of
CMake. Simply ensure your cmake is newer than the previous version and run:

    ./extract-upper-case.pl

Please file a pull-request if the diff seems reasonable.

## Test

There is a ever growing test-suite based on ctest located in test/

    cd <build-dir-where-ever-located>
    cmake path/to/this/repo/test
    ctest
