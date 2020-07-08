#!/bin/bash
set -x #echo on

echo 0 > /sys/class/net/enp130s0/device/sriov_numvfs 
echo 1 > /sys/class/net/enp130s0/device/sriov_numvfs
echo none > /sys/class/net/enp130s0/compat/devlink/ipsec_mode
echo 0000:82:00.1 >  /sys/bus/pci/drivers/mlx5_core/unbind
echo $1 > /sys/class/net/enp130s0/compat/devlink/ipsec_mode
devlink dev eswitch set pci/0000:82:00.0 mode switchdev
echo 0000:82:00.1 >  /sys/bus/pci/drivers/mlx5_core/bind

REMOTE_SERVER=exprom-dell2

#stop openvswitch
service openvswitch stop

ssh $REMOTE_SERVER /bin/bash << EOF
	set -x #echo on

	echo 0 > /sys/class/net/enp130s0f0/device/sriov_numvfs
	echo 1 > /sys/class/net/enp130s0f0/device/sriov_numvfs
	echo 0000:82:00.2 >  /sys/bus/pci/drivers/mlx5_core/unbind
	echo full > /sys/class/net/enp130s0f0/compat/devlink/ipsec_mode
	devlink dev eswitch set pci/0000:82:00.0 mode switchdev
	echo 0000:82:00.2 >  /sys/bus/pci/drivers/mlx5_core/bind

	#stop openvswitch
	service openvswitch stop

#	# Add vxlan device by ip link command
#	echo "adding vxlan device"
#	echo "VXLAN_IF_NAME=$VXLAN_IF_NAME"
#	ip link add $VXLAN_IF_NAME type vxlan external dstport 4789
#	ifconfig $VXLAN_IF_NAME up
EOF
