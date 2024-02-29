#!/usr/bin/env bash

unset target
unset TARGET

sed -i '/^$/d' ~/.config/bin/target

targets=`cat ~/.config/bin/target`
list(){
  for t in $targets; do
    echo "$t"
  done
}

target=$( list | \
  rofi -dmenu \
  -theme ~/.config/rofi/target_set.rasi \
  -no-fixed-num-lines
)

if [ -n "$target" ]; then
  export TARGET="$target" 
  option=$(rofi -show run -modi run:~/.config/bin/target_options.sh \
    -theme ~/.config/rofi/target_set.rasi \
    -theme-str "entry {enabled: false;}" \
    -theme-str "prompt {enabled: true;}" \
    -theme-str "inputbar {children: [ "dummy", "prompt", "dummy" ];}" \
  )
fi

