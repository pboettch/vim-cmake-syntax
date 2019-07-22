# vim-cmake-syntax

Vim syntax highlighting rules for modern CMakeLists.txt.

Original code from KitWare.
First hosted on Github by Nicholas Hutchinson.
Extended and modified by Patrick Boettcher and contributors

Keyword update - refer to syntax/cmake.vim-header.

The code of this repository is integrated in and released with CMake and is pulled
into the official cmake-distribution "from time to time".

## Installation

With Pathogen

    cd ~/.vim/bundle
    git clone git://github.com/pboettch/vim-cmake-syntax.git

With Vundle

    " inside .vimrc
    Plugin 'pboettch/vim-cmake-syntax'

## Indentation

There is also an indent file which can do some intelligent alignment.

### Control-statements

For control-keywords (`if`, `while`, `foreach`, `macro`, etc) it automatically adds a
`shiftwidth()` (and substracts it for a `end`-keyword).

### Command arguments

For commands (so everything which has arguments between parenthesis `(...)`) is tries to do the following:

Either it aligns all arguments on a new line in the same column as the opening parenthesis if the first argument is on the
same line as the command:

```cmake
add_custom_target(TARGET name
                  DEPENDS target
                  WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
```

or it indents it with one additional `shiftwidth()` if the first argument is on a new line

```cmake
add_custom_target(
    TARGET name
    DEPENDS target
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
```

This is achieved by letting `g:cmake_indent_align_command_arguments` to be 1.

By setting it to 0 (the default) in your vimrc-file the standard behavior is achieved.

```cmake
add_custom_target(TARGET name
    DEPENDS target
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
```

### Comments

By setting `g:cmake_indent_align_comments_to_first_column` to 1 (default: 0) comment will always be aligned to the
zero column - otherwise they will aligned as normal line with a statement.

## Test

There is a ever growing test-suite based on ctest located in test/

    cd <build-dir-where-ever-located>
    cmake path/to/this/repo/test
    ctest
