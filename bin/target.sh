#!/bin/sh

target=$(cat ~/.config/bin/target | head -1 | tr -d '\n')

if [ -n "$target" ]; then
	echo " $target"
else
	echo " No Target"
fi
