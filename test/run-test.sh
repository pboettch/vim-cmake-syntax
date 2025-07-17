#!/usr/bin/env bash

TMP=$(mktemp)

# generate html-file with local .vimrc and local syntax highlighting and only that!
vim -u .vimrc -n -es -c TOhtml -c "w! $TMP" -c 'qa!' $1.cmake >/dev/null 2>&1

# extract the body of the html-file
if [[ "$OSTYPE" =~ ^darwin ]]; then
	# macOS's builtin sed expects a suffix to create backup before in-place
	# editing. An empty suffix prevents the backup.
	sed -i "" -n -e '/<body>/,$p' $TMP
	sed -i "" '/<\/body>/q' $TMP
else
	sed -i -n -e '/<body>/,$p' $TMP
	sed -i '/<\/body>/q' $TMP
fi

# diff with references
diff -u $1.cmake.html.ref $TMP

if [ $? -ne 0 ]
then
	echo "reference is not identifcal to output, produced file kept: $TMP"
	exit 1
else
	rm $TMP
	exit 0
fi

