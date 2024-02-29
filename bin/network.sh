#!/bin/zsh

bspc rule -a \* -o state=floating center=true rectangle=800x800+0+0 && NEWT_COLORS='root=#1f1f1f,#1f1f1f' nm-connection-editor
