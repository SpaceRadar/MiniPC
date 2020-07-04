#!/bin/sh

modprobe r8152
modprobe sr9800
sleep 5
dhclient -v eth1
