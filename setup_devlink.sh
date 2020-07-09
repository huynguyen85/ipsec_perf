#!/bin/bash
set -x #echo on
IPSEC_MODE=$1
NUM_VF=$2
echo 0 > /sys/class/net/enp130s0/device/sriov_numvfs 
echo $NUM_VF > /sys/class/net/enp130s0/device/sriov_numvfs
echo none > /sys/class/net/enp130s0/compat/devlink/ipsec_mode

DEVICE=0
for ((i = 1 ; i <= $NUM_VF ; i++));
do
	FUNC=$(( $i % 8 ))
	if [ $FUNC -eq 0 ]
	then
		DEVICE=$(( $DEVICE + 1 ))
	fi
	echo 0000:82:0$DEVICE.$FUNC >  /sys/bus/pci/drivers/mlx5_core/unbind
done

echo $IPSEC_MODE > /sys/class/net/enp130s0/compat/devlink/ipsec_mode
devlink dev eswitch set pci/0000:82:00.0 mode switchdev

DEVICE=0
for ((i = 1 ; i <= $NUM_VF ; i++));
do
	FUNC=$(( $i % 8 ))
	if [ $FUNC -eq 0 ]
	then
		DEVICE=$(( $DEVICE + 1 ))
	fi
	echo 0000:82:0$DEVICE.$FUNC >  /sys/bus/pci/drivers/mlx5_core/bind
done

#stop openvswitch
service openvswitch stop

REMOTE_SERVER=exprom-dell2
ssh $REMOTE_SERVER /bin/bash << EOF
	#!/bin/bash
	set -x #echo on

	echo 0 > /sys/class/net/enp130s0f0/device/sriov_numvfs
	echo $NUM_VF > /sys/class/net/enp130s0f0/device/sriov_numvfs
EOF

DEVICE=0
for ((i = 2 ; i <= $NUM_VF+1 ; i++));
do
	FUNC=$(( $i % 8 ))
	if [ $FUNC -eq 0 ]
	then
		DEVICE=$(( $DEVICE + 1 ))
	fi
ssh $REMOTE_SERVER /bin/bash << EOF
	set -x #echo on
	echo 0000:82:0$DEVICE.$FUNC >  /sys/bus/pci/drivers/mlx5_core/unbind
EOF
done

ssh $REMOTE_SERVER /bin/bash << EOF
	echo $IPSEC_MODE > /sys/class/net/enp130s0f0/compat/devlink/ipsec_mode
	devlink dev eswitch set pci/0000:82:00.0 mode switchdev
EOF

DEVICE=0
for ((i = 2 ; i <= $NUM_VF+1 ; i++));
do
	FUNC=$(( $i % 8 ))
	if [ $FUNC -eq 0 ]
	then
		DEVICE=$(( $DEVICE + 1 ))
	fi
ssh $REMOTE_SERVER /bin/bash << EOF
	set -x #echo on
	echo 0000:82:0$DEVICE.$FUNC >  /sys/bus/pci/drivers/mlx5_core/bind
EOF
done

ssh $REMOTE_SERVER /bin/bash << EOF
	set -x #echo on
	#stop openvswitch
	service openvswitch stop
EOF

