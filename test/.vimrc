" we need a clean environment

" remove user's .vimrc - what else?
set runtimepath-=~/.vimrc

" add .. as vim-plugin-path (for syntax and indent)
set runtimepath^=../

" nocompat is needed for html-output
set nocompatible

source ../syntax/cmake.vim
source ../indent/cmake.vim

set expandtab
set nocopyindent
set nopreserveindent
set nosmartindent
set softtabstop=0
set shiftwidth=4
set tabstop=4

syntax on
