#!/bin/sh

project=$1
cd ~/.local/src/patches/$project
for m in $(ls ~/.local/src/patches/$project); do
	echo -e "\n" "patching" $m "\n"
	patch -p1 <~/.local/src/patches/$project/$m
done
