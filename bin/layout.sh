#!/bin/bash

tiled="Tiled\0icon\x1f/usr/share/icons/layout_icons/tiled.png"
monocle="Monocle\0icon\x1f/usr/share/icons/layout_icons/monocle.png"
tall="Tall\0icon\x1f/usr/share/icons/layout_icons/tall.png"
rtall="rTall\0icon\x1f/usr/share/icons/layout_icons/rtall.png"
wide="Wide\0icon\x1f/usr/share/icons/layout_icons/wide.png"
rwide="rWide\0icon\x1f/usr/share/icons/layout_icons/rwide.png"
floating="Floating\0icon\x1f/usr/share/icons/layout_icons/floating.png"

options="$rwide\n$rtall\n$floating\n$tiled\n$monocle\n$tall\n$wide"

layout="$(echo -e "$options" | rofi -dmenu -selected-row 3 -theme "~/.config/rofi/layout.rasi")"

case "$layout" in
  Tiled)
    bspc node focused.local.sticky -t tiled -g sticky
    bsp-layout set titled
    echo "Cambiando layout a $layout"
  ;;

  Monocle)
    bsp-layout set monocle
    echo "Cambiando layout a $layout"
  ;;

  Tall)
    bsp-layout set tall
    echo "Cambiando layout a $layout"
  ;;

  rTall)
    bsp-layout set rtall
    echo "Cambiando layout a $layout"
  ;;

  Wide)
    bsp-layout set wide
    echo "Cambiando layout a $layout"
  ;;

  rWide)
    bsp-layout set rwide
    echo "Cambiando layout a $layout"
  ;;

  Floating)
    bspc node focused.local -t floating -g sticky

    echo "Cambiando layout a $layout"
  ;;
esac


