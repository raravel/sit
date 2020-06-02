#!/bin/sh

if [ ! -d "$HOME/.svn" ]; then
	mkdir $HOME/.svn
fi

SVN=$(which svn)

IS_SVN_PROJ=$(svn info > /dev/null; echo $?)
if [ $IS_SVN_PROJ -ne 0 ]; then
	exit 1;
fi

PROJ_DIR=$(svn info | head -n 2 | tail -n 1 | awk -F': ' '{print $2}')
PROJ=$(basename "$PROJ_DIR")
P_FILE="$HOME/.svn/"$PROJ

function print_p_file {
	echo "$P_FILE 에 추가한 파일 정보:"
	echo ""
	files=$(cat $P_FILE)
	if [ ! "$files" = "" ]; then
		svn st -q $files
	else
		echo "항목 없음"
	fi
}

if [ ! -f "$P_FILE" ]; then
	touch $P_FILE
fi

if [ "$1" = "add" ]; then
	for arg in $@
	do
		if [ "$arg" = "add" ]; then
			continue
		fi

		dir=$(dirname $arg)
		base=$(basename $arg)

		if [ "$dir" = "." ]; then
			dir=""
		fi

		search_files=$(find "$PWD/$dir" -name $base)
		files=$(svn st -q $search_files | awk -F' ' '{print $2}')

		for f in $files
		do
			check=$(cat $P_FILE | grep $f)
			if [ "$check" = "" ]; then
				echo $f >> $P_FILE
				echo $f
			fi
		done
	done
elif [ "$1" = "show" ]; then
	print_p_file
elif [ "$1" = "diff" ]; then
	files=$(cat $P_FILE)
	svn diff $files | colordiff | less -R
elif [ "$1" = "clear" ]; then
	echo $(cat $P_FILE | grep -v "$2") > $P_FILE
	print_p_file
elif [ "$1" = "push" ]; then
	cd $PROJ_DIR
	svn commit $(cat $P_FILE)
else
	echo "sit: Invalid Arguments. run svn"
	echo "svn $@"
	echo ""

	svn $@
fi
