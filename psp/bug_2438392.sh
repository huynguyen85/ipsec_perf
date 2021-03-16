#!/bin/bash

# echo > /var/log/libvirt/qemu/dev-l-vrt-127-010.log
# /images/raeds/simx/mlnx_infra/simx-qemu.cfg
# /images/raeds/simx/x86_64-softmmu/qemu-system-x86_64
# /images/raeds/simx/mellanox/libmlx.so
set -x
ip link delete vxlan11
ip addr flush enp6s0f0
ip link add vxlan11 type vxlan id 10 local 192.168.7.2 remote 192.168.7.1 dstport 4789 dev enp6s0f0
ip addr replace 1.1.1.2/24  dev vxlan11
ip addr add 192.168.7.2/24 dev enp6s0f0
ip link set vxlan11 up
ip link set enp6s0f0 up
