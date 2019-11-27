#!/bin/sh
mkdir -p /tmp/debugfs
mount none -t debugfs /tmp/debugfs
echo 'file axi-pcie.c +p' > /tmp/debugfs/dynamic_debug/control
rmmod adcvolt
rmmod ldpc
rmmod mdltr
rmmod gctl
rmmod axi_pcie
modprobe axi-pcie dyndbg
modprobe gctl dyndbg
modprobe mdltr dyndbg
modprobe ldpc dyndbg
modprobe adcvolt dyndbg
cat /tmp/debugfs/dynamic_debug/control | grep axi-pcie 
dmesg | tail
