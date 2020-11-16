#!/bin/bash
set -x #echo on

UPLINK=enp8s0f0
PCI_BUS=08

echo 0 > /sys/class/net/$UPLINK/device/sriov_numvfs 
echo 1 > /sys/class/net/$UPLINK/device/sriov_numvfs
echo 0000:$PCI_BUS:00.2 > /sys/bus/pci/drivers/mlx5_core/unbind
echo dmfs > /sys/bus/pci/devices/0000\:$PCI_BUS\:00.0/net/$UPLINK/compat/devlink/steering_mode
echo full > /sys/class/net/$UPLINK/compat/devlink/ipsec_mode
devlink dev eswitch set pci/0000:$PCI_BUS:00.0 mode switchdev
echo 0000:$PCI_BUS:00.2 > /sys/bus/pci/drivers/mlx5_core/bind

ifconfig $UPLINK 192.168.1.64/24 up

REMOTE_SERVER=c-235-10-1-010

#stop openvswitch
service openvswitch stop

ssh $REMOTE_SERVER /bin/bash << EOF
	set -x #echo on

	echo 0 > /sys/class/net/$UPLINK/device/sriov_numvfs
	echo 1 > /sys/class/net/$UPLINK/device/sriov_numvfs
	echo 0000:$PCI_BUS:00.2 > /sys/bus/pci/drivers/mlx5_core/unbind
	echo dmfs > /sys/bus/pci/devices/0000\:$PCI_BUS\:00.0/net/$UPLINK/compat/devlink/steering_mode
	echo full > /sys/class/net/$UPLINK/compat/devlink/ipsec_mode
	devlink dev eswitch set pci/0000:$PCI_BUS:00.0 mode switchdev
	echo 0000:$PCI_BUS:00.2 > /sys/bus/pci/drivers/mlx5_core/bind

	#stop openvswitch
	service openvswitch stop

	ifconfig $UPLINK 192.168.1.65/24 up
EOF
