#!/bin/sh

if /usr/sbin/ifconfig | grep -A 7 "ens33" | grep "inet " > /dev/null ;then
  echo " $(/usr/sbin/ifconfig ens33 | grep "inet " | awk '{print $2}')%{u-}"
else
  echo " Disconnected"
fi
