#! /bin/sh

SCRIPT_DIR=$(dirname "$0")
FLIST='.agignore .direnvrc .git .gitignore .gitignore_global .gvimrc .hammerspoon .screenrc .vimium .vimrc .zshrc'


for file in $FLIST
do
	echo "ln -s $SCRIPT_DIR/$file" 1>&2
	ln -s $SCRIPT_DIR/$file
done
