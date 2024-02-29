#!/usr/bin/env bash

list=$(ls /usr/share/vpn/)

list () {
  for i in $list; do
    if [ ! -z $( ps faux | grep "sudo openvpn /usr/share/vpn/$i" | grep "root" | head -1 ) ]; then
      echo "󰖟  $i"
    else
      echo "󰪎  $i"
    fi
  done
}

vpn=$( list | rofi -dmenu \
  -theme ~/.config/rofi/vpn.rasi \
  -no-fixed-num-lines
)

vpn=$( echo $vpn | awk {'print $2'} )

if [ ! -z $( ps faux | grep "sudo openvpn /usr/share/vpn/$vpn" | grep "root" | head -1 ) ]; then
  ps faux | grep "sudo openvpn /usr/share/vpn/$vpn" | grep "root" | head -1 | awk {'print $2'} | xargs sudo kill -9
else
  sudo openvpn /usr/share/vpn/$vpn &
fi
