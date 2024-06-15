#!/bin/bash

if [ $(~/.config/bin/tun0_status.sh) == "Disconnected" ]; then
  export ME=$(~/.config/bin/ethernet_status.sh) && sleep .1 && xdotool type --delay 0 $ME
else
  export ME=$(~/.config/bin/tun0_status.sh) && sleep .1 && xdotool type --delay 0 $ME
fi

