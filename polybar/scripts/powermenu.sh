#!/usr/bin/env bash

dir="~/.config/polybar/scripts/rofi"
uptime=$(uptime -p | sed -e 's/up //g')

rofi_command="rofi -no-config -theme $dir/powermenu.rasi"

# Options
shutdown="Shutdown\0icon\x1f<span color='#fcfcfc'>⏻</span>"
reboot="Restart\0icon\x1f<span color='#fcfcfc'></span>"
lock="Lock\0icon\x1f<span color='#fcfcfc'>󰍁</span>"
logout="Logout\0icon\x1f<span color='#fcfcfc'>󰍂</span>"

# Variable passed to rofi
options="$shutdown\n$reboot\n$lock\n$logout"

chosen="$(echo -e "$options" | $rofi_command -p "Uptime: $uptime" -dmenu -selected-row 0)"

echo $chosen

case $chosen in
    Shutdown)
      systemctl poweroff
      ;;
    Restart)
      systemctl reboot
      ;;
    Lock)
      dm-tool lock
      ;;
    Logout)
      bspc quit
      ;;
esac



