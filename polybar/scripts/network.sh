#!/bin/zsh

bspc rule -a \* -o state=floating center=true rectangle=800x800+0+0 && NEWT_COLORS='root=black,black' kitty nmtui
#kitty bspc rule -a \* -o state=floating && kitty
