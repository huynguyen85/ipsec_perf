#!/bin/bash
set -x #echo on

devlink dev eswitch set pci/0000:03:00.1 mode legacy
echo none > /sys/class/net/p1/compat/devlink/ipsec_mode
echo dmfs > /sys/bus/pci/devices/0000\:03\:00.1/net/p1/compat/devlink/steering_mode
echo full > /sys/class/net/p1/compat/devlink/ipsec_mode
devlink dev eswitch set pci/0000:03:00.1 mode switchdev
ifconfig p1 192.168.1.64/24 up

REMOTE_SERVER=10.9.150.39

#stop openvswitch
service openvswitch stop

sshpass -p 3tango ssh -o StrictHostKeyChecking=no -l root $REMOTE_SERVER /bin/bash << EOF
#ssh $REMOTE_SERVER /bin/bash << EOF
	#!/bin/bash
	set -x #echo on

	echo 0 > /sys/class/net/ens1f1/device/sriov_numvfs 
	echo 1 > /sys/class/net/ens1f1/device/sriov_numvfs
	echo 0000:08:01.2 >  /sys/bus/pci/drivers/mlx5_core/unbind
	echo none > /sys/class/net/ens1f1/compat/devlink/ipsec_mode
	echo dmfs > /sys/bus/pci/devices/0000\:08\:00.1/net/ens1f1/compat/devlink/steering_mode
	echo full > /sys/class/net/ens1f1/compat/devlink/ipsec_mode
	devlink dev eswitch set pci/0000:08:00.1 mode switchdev
	echo 0000:08:01.2 >  /sys/bus/pci/drivers/mlx5_core/bind

	ifconfig ens1f1 192.168.1.65/24 up

	service openvswitch stop
EOF
