#!/bin/bash

# eni-config.sh
# Copyright (c) 2014 Mark Raymond
# Released under the MIT license

i=1
ifconfig -a | sed -n 's/^\([^ ]\+\)\s\+.*HWaddr \([a-f0-9:]*\).*/\1 \2/p' | while read line; do
  iface=${line% *}
  mac=${line#* }
  ips=($(wget -qO- http://169.254.169.254/latest/meta-data/network/interfaces/macs/$mac/local-ipv4s))
  ifconfig $iface up
  for ip in ${ips[@]}; do
    ip addr add dev $iface $ip/24
    ip rule add from $ip table $i
  done
  ip route add default via ${ips[0]%.*}.1 dev $iface table $i
  i=$((i+1))
done
