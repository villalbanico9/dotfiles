#!/usr/bin/env bash

unset target
unset TARGET

sed -i '/^$/d' /usr/share/target.txt

target=$( list | \
  rofi -dmenu \
  -theme ~/.config/rofi/target_set.rasi \
  -no-fixed-num-lines
)

if [ -n "$target" ]; then
  echo $target > /usr/share/target.txt
fi

