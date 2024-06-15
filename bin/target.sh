#!/bin/sh

target=$(cat /usr/share/target.txt | head -1 | tr -d '\n')

if [ -n "$target" ]; then
	echo " $target"
else
	echo " No Target"
fi
