#! /bin/sh

SCRIPT_DIR=$(dirname "$0")
FLIST='.agignore .direnvrc .gitignore_global .gvimrc .hammerspoon .screenrc .vimrc .vim .zshrc .default-npm-packages'

for file in $FLIST
do
	echo "ln -s $SCRIPT_DIR/$file" 1>&2
	ln -s $SCRIPT_DIR/$file
done

ln -s $DIR/bin/common ~/bin
