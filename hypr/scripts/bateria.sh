#!/usr/bin/env bash
b=/sys/class/power_supply/BAT0
[ -r $b/capacity ] || exit 0
st=$(cat $b/status)
case $st in Charging) s=" · carregando";; Full|"Not charging") s=" · tomada";; *) s="";; esac
echo "bateria $(cat $b/capacity)%$s"
