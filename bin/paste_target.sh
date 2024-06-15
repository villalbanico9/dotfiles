#!/bin/bash
export TARGET=$(~/.config/bin/target.sh | awk '{$1=$1;print}') && sleep .1 && xdotool type --delay 0 $TARGET
