#!/bin/bash
set -x #echo on

echo 0 > /sys/class/net/ens1f0/device/sriov_numvfs 
echo 2 > /sys/class/net/ens1f0/device/sriov_numvfs
echo 0000:08:00.2 >  /sys/bus/pci/drivers/mlx5_core/unbind
echo 0000:08:00.3 >  /sys/bus/pci/drivers/mlx5_core/unbind
#echo dmfs > /sys/bus/pci/devices/0000\:08\:00.0/net/ens1f0/compat/devlink/steering_mode
#echo full > /sys/class/net/ens1f0/compat/devlink/ipsec_mode
devlink dev eswitch set pci/0000:08:00.0 mode switchdev
echo 0000:08:00.2 >  /sys/bus/pci/drivers/mlx5_core/bind
#echo 0000:08:00.3 >  /sys/bus/pci/drivers/mlx5_core/bind

REMOTE_SERVER=sw-mtx-012

#stop openvswitch
service openvswitch stop

ssh $REMOTE_SERVER /bin/bash << EOF
	set -x #echo on

	echo 0 > /sys/class/net/ens1f0/device/sriov_numvfs
	echo 2 > /sys/class/net/ens1f0/device/sriov_numvfs
	echo 0000:08:00.2 >  /sys/bus/pci/drivers/mlx5_core/unbind
	echo 0000:08:00.3 >  /sys/bus/pci/drivers/mlx5_core/unbind
#	echo dmfs > /sys/bus/pci/devices/0000\:08\:00.0/net/ens1f0/compat/devlink/steering_mode
#	echo full > /sys/class/net/ens1f0/compat/devlink/ipsec_mode
	devlink dev eswitch set pci/0000:08:00.0 mode switchdev
	echo 0000:08:00.2 >  /sys/bus/pci/drivers/mlx5_core/bind
#	echo 0000:08:00.3 >  /sys/bus/pci/drivers/mlx5_core/bind

	#stop openvswitch
	service openvswitch stop

#	# Add vxlan device by ip link command
#	echo "adding vxlan device"
#	echo "VXLAN_IF_NAME=$VXLAN_IF_NAME"
#	ip link add $VXLAN_IF_NAME type vxlan external dstport 4789
#	ifconfig $VXLAN_IF_NAME up
EOF
