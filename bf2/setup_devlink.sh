#!/bin/bash
set -x #echo on
#IPSEC_MODE=$1
#NUM_VF=$2

#devlink dev eswitch set pci/0000:03:00.0 mode legacy
#echo none > /sys/class/net/p0/compat/devlink/ipsec_mode
echo dmfs > /sys/bus/pci/devices/0000\:03\:00.0/net/p0/compat/devlink/steering_mode
#echo full > /sys/class/net/p0/compat/devlink/ipsec_mode
devlink dev eswitch set pci/0000:03:00.0 mode switchdev

#stop openvswitch
service openvswitch stop

REMOTE_SERVER=bu-lab33v-bf2
ssh $REMOTE_SERVER /bin/bash << EOF
	#!/bin/bash
	set -x #echo on

	#devlink dev eswitch set pci/0000:03:00.0 mode legacy
	#echo none > /sys/class/net/p0/compat/devlink/ipsec_mode
	echo dmfs > /sys/bus/pci/devices/0000\:03\:00.0/net/p0/compat/devlink/steering_mode
	#echo full > /sys/class/net/p0/compat/devlink/ipsec_mode
	devlink dev eswitch set pci/0000:03:00.0 mode switchdev

	service openvswitch stop
EOF
