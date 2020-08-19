#!/bin/bash
set -x #echo on

echo 0 > /sys/class/net/ens1f1/device/sriov_numvfs 
echo 2 > /sys/class/net/ens1f1/device/sriov_numvfs
echo 0000:08:01.2 >  /sys/bus/pci/drivers/mlx5_core/unbind
echo 0000:08:01.3 >  /sys/bus/pci/drivers/mlx5_core/unbind
echo dmfs > /sys/bus/pci/devices/0000\:08\:00.1/net/ens1f1/compat/devlink/steering_mode
echo full > /sys/class/net/ens1f1/compat/devlink/ipsec_mode
devlink dev eswitch set pci/0000:08:00.1 mode switchdev
echo 0000:08:01.2 >  /sys/bus/pci/drivers/mlx5_core/bind
#echo 0000:08:00.3 >  /sys/bus/pci/drivers/mlx5_core/bind

REMOTE_SERVER=$1

#stop openvswitch
service openvswitch stop

ssh $REMOTE_SERVER /bin/bash << EOF
	#!/bin/bash
	set -x #echo on

	devlink dev eswitch set pci/0000:03:00.1 mode legacy
	echo none > /sys/class/net/p1/compat/devlink/ipsec_mode
	echo dmfs > /sys/bus/pci/devices/0000\:03\:00.1/net/p1/compat/devlink/steering_mode
	echo full > /sys/class/net/p1/compat/devlink/ipsec_mode
	devlink dev eswitch set pci/0000:03:00.1 mode switchdev

	service openvswitch stop
EOF
