#!/bin/bash
set -x #echo on

PF_NETDEV=ens1f0

echo 0 > /sys/class/net/$PF_NETDEV/device/sriov_numvfs 
echo 1 > /sys/class/net/$PF_NETDEV/device/sriov_numvfs
ifconfig $PF_NETDEV up
echo 0000:08:00.2 >  /sys/bus/pci/drivers/mlx5_core/unbind
devlink dev eswitch set pci/0000:08:00.0 mode legacy
#echo dmfs > /sys/bus/pci/devices/0000\:08\:00.0/net/ens1f0/compat/devlink/steering_mode
#echo full > /sys/class/net/ens1f0/compat/devlink/ipsec_mode
devlink dev eswitch set pci/0000:08:00.0 ipsec-mode full
devlink dev eswitch set pci/0000:08:00.0 mode switchdev
echo 0000:08:00.2 >  /sys/bus/pci/drivers/mlx5_core/bind
ifconfig $PF_NETDEV 192.168.1.64/24 up

REMOTE_SERVER=sw-mtx-012

#stop openvswitch
service openvswitch stop

ssh $REMOTE_SERVER /bin/bash << EOF
	set -x #echo on

	echo 0 > /sys/class/net/ens1f0/device/sriov_numvfs
	echo 1 > /sys/class/net/ens1f0/device/sriov_numvfs
	echo 0000:08:00.2 >  /sys/bus/pci/drivers/mlx5_core/unbind
	echo dmfs > /sys/bus/pci/devices/0000\:08\:00.0/net/ens1f0/compat/devlink/steering_mode
	echo full > /sys/class/net/ens1f0/compat/devlink/ipsec_mode
	devlink dev eswitch set pci/0000:08:00.0 mode legacy
	devlink dev eswitch set pci/0000:08:00.0 mode switchdev
	echo 0000:08:00.2 >  /sys/bus/pci/drivers/mlx5_core/bind

	ifconfig $PF_NETDEV 192.168.1.65/24 up

	#stop openvswitch
	service openvswitch stop

EOF
