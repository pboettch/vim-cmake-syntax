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


# textMate grammar

A TextMate grammar can be generated using the script `textmate-grammar-from-cmake-help.py`.

This grammar can be used in editors like Visual Studio Code (actually tested with vscode).

A custom cmake executable can be provided as argument as well as the output-file
(default is `CMake.tmLanguage.json`).

    python3 textmate-grammar-from-cmake-help.py \
        --cmake /path/to/cmake \
        --output /path/to/CMake.tmLanguage.json

When developing, the script can be run to put the file directly into the vscode-extension
path:

    python3 textmate-grammar-from-cmake-help.py \
        --cmake /path/to/cmake \
        --output ~/.vscode/extensions/ms-vscode.cmake-tools-<vers>/syntaxes/CMake.tmLanguage.json

Then the extension has to be disabled, restarted and enabled again to pick up the new grammar.