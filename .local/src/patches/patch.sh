#!/bin/sh

project=$1
cd ~/.local/src/$project
for m in $(ls ~/.local/src/patches/$project); do
	echo $m
	if [[ $m == *"#"* ]]
	then
		echo -e "\n" "ommited custom patch" "\n"
		continue
	else
		echo -e "\n" "patching" $m "\n"
		patch -p1 <~/.local/src/patches/$project/$m
	fi
done
