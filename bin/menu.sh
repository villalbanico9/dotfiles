#!/usr/bin/env bash

rofi                                              \
  -kb-row-tab "Control+Shift+Tab"                 \
  -file-browser-dir "~"                  \
  -file-browser-hide-hidden-symbol ""             \
  -file-browser-open-multi-key "kb-custom-9"      \
  -file-browser-toggle-hidden-key "kb-custom-1"   \
  -modi "drun,window,run:~/.config/bin/powermenu.sh" \
  -matching glob                                  \
  -disable-history -sort -drun-sort               \
  -show $1                                        \
  -icon-theme /usr/share/icons/Papirus            \
  -theme ~/.config/rofi/menu.rasi
