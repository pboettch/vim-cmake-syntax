" Vim indent file
" Language:     CMake (ft=cmake)
" Author:       Andy Cedilnik <andy.cedilnik@kitware.com>
" Maintainer:   Dimitri Merejkowsky <d.merej@gmail.com>
" Former Maintainer: Karthik Krishnan <karthik.krishnan@kitware.com>
" Last Change:  2017 Sep 24
"
" Licence:      The CMake license applies to this file. See
"               https://cmake.org/licensing
"               This implies that distribution with Vim is allowed

if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal indentexpr=CMakeGetIndent(v:lnum)
setlocal indentkeys+==ENDIF(,ENDFOREACH(,ENDMACRO(,ELSE(,ELSEIF(,ENDWHILE(

" Only define the function once.
if exists("*CMakeGetIndent")
  finish
endif

let s:keepcpo= &cpo
set cpo&vim

let s:or = '\|'
" Regular expressions used by line indentation function.
let s:cmake_regex_comment = '#.*'
let s:cmake_regex_identifier = '[A-Za-z][A-Za-z0-9_]*'
let s:cmake_regex_quoted = '"\([^"\\]\|\\.\)*"'
let s:cmake_regex_arguments = '\(' . s:cmake_regex_quoted .
                  \       s:or . '\$(' . s:cmake_regex_identifier . ')' .
                  \       s:or . '[^()\\#"]' . s:or . '\\.' . '\)*'

let s:cmake_indent_comment_line = '^\s*' . s:cmake_regex_comment
let s:cmake_indent_open_regex = '^\s*' . s:cmake_regex_identifier .
                  \           '\s*(' . s:cmake_regex_arguments .
                  \           '\(' . s:cmake_regex_comment . '\)\?$'

let s:cmake_indent_close_regex = '^' . s:cmake_regex_arguments .
                  \            '\zs)\s*' .
                  \            '\(' . s:cmake_regex_comment . '\)\?$'

let s:cmake_indent_begin_regex = '^\s*\(IF\|MACRO\|FOREACH\|ELSE\|ELSEIF\|WHILE\|FUNCTION\)\s*('
let s:cmake_indent_end_regex = '^\s*\(ENDIF\|ENDFOREACH\|ENDMACRO\|ELSE\|ELSEIF\|ENDWHILE\|ENDFUNCTION\)\s*('

if !exists('g:cmake_indent_align_command_arguments')
  let g:cmake_indent_align_command_arguments = 0
endif

if !exists('g:cmake_indent_align_comments_to_first_column')
  let g:cmake_indent_align_comments_to_first_column = 0
endif

fun! CMakeGetIndent(lnum)
  let this_line = getline(a:lnum)

  let lnum = a:lnum - 1

  " Find a non-blank/non-comment line above the current line.
  while lnum > 0
	let lnum = prevnonblank(lnum)
	let previous_line = getline(lnum)

	" ignore comments (# only, lua-like comment TODO)
	if previous_line !~? s:cmake_indent_comment_line
	  break
	endif

	let lnum -= 1
  endwhile

  " Hit the start of the file, use zero indent.
  if lnum == 0
    return 0
  endif

  let ind = indent(lnum)

  if previous_line =~? s:cmake_indent_open_regex " open parenthesis
	if previous_line !~? s:cmake_indent_close_regex " closing parenthesis is not on the same line
	  call cursor(lnum, 1)
	  let s = searchpos('(\s*$') " find '(' with nothing or only spaces until the end of the line
	  if s[0] == lnum
		let ind += shiftwidth()
	  else " an argument after the keyword
		call cursor(lnum, 1)
		let s = searchpos('(') " find position of first '('
		if g:cmake_indent_align_command_arguments == 0 " old behavior
		  let ind += shiftwidth()
		else
		  let ind = s[1]
		endif
	  endif
	endif
  elseif previous_line =~? s:cmake_indent_close_regex " close parenthesis
    call cursor(lnum, strlen(previous_line))
	let pairpos = searchpos(s:cmake_indent_open_regex, 'nbz') " find corresponding open paren
	if pairpos[0] != 0
	  let ind = indent(pairpos[0])
	endif
  endif

  if previous_line =~? s:cmake_indent_begin_regex " control begin block
	let ind = ind + shiftwidth()
  endif

  if this_line =~? s:cmake_indent_end_regex  " control end block
	let ind = ind - shiftwidth()
  elseif this_line =~? s:cmake_indent_comment_line
	if g:cmake_indent_align_comments_to_first_column == 1
	  let ind = 0
	endif
  endif

  return ind
endfun

let &cpo = s:keepcpo
unlet s:keepcpo
