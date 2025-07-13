#!/usr/bin/env bash

TMP=$(mktemp)

if [ -e "$1.vim" ]; then
	vim_commands="$1.vim"
else
	vim_commands='default-commands.vim'
fi
# generate html-file(s) with local minimal .vimrc
vim -u vimrc -n -es -c "let output='$TMP'" -c "so! $vim_commands" "$1.cmake" \
    >/dev/null 2>&1

for suffix in $( find "${TMP%/*}" -name "${TMP##*/}*" | sed "s|^$TMP|-|" ); do
	[ "$suffix" != '-' ] || suffix=''
	suffix="${suffix#-}"

	# extract the body of the html-file
	body="$( sed -n -e '/<body>/,$p; /<\/body>/q' < "$TMP$suffix" )"
	echo "$body" > "$TMP$suffix"; unset body

	# diff with references
	diff -u $1.cmake.html.ref$suffix $TMP$suffix

	if [ $? -ne 0 ]; then
		echo "reference is not identical to output, produced file kept: $TMP$suffix"
		exit 1
	else
		rm $TMP$suffix
	fi
done
