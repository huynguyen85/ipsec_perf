#!/bin/bash
set -x #echo on

LOCAL_NIC="enp6s0f0"
LOCAL_PCI="0000:06:00.0"
LOCAL_PCI_VF1="0000:06:00.1"
LOCAL_MAC_VF1="e4:11:22:33:44:50"
LOCAL_PCI_VF2="0000:06:00.2"
LOCAL_MAC_VF2="e4:11:22:33:44:51"
LOCAL_NUM_VFS=2

echo 0 > /sys/class/net/$LOCAL_NIC/device/sriov_numvfs                                                                                                           
echo dmfs >  /sys/class/net/$LOCAL_NIC/compat/devlink/steering_mode
echo full >  /sys/class/net/$LOCAL_NIC/compat/devlink/ipsec_mode # none
echo $LOCAL_NUM_VFS > /sys/class/net/$LOCAL_NIC/device/sriov_numvfs
ip link set $LOCAL_NIC vf 0 mac $LOCAL_MAC_VF1
ip link set $LOCAL_NIC vf 1 mac $LOCAL_MAC_VF2
echo $LOCAL_PCI_VF1 > /sys/bus/pci/drivers/mlx5_core/unbind
echo $LOCAL_PCI_VF2 > /sys/bus/pci/drivers/mlx5_core/unbind
devlink dev eswitch set pci/$LOCAL_PCI mode switchdev
echo $LOCAL_PCI_VF1 > /sys/bus/pci/drivers/mlx5_core/bind
echo $LOCAL_PCI_VF2 > /sys/bus/pci/drivers/mlx5_core/bind


REMOTE_SETUP="exprom-dell2"
REMOTE_NIC="enp130s0f0"
REMOTE_PCI="0000:82:00.0"
REMOTE_PCI_VF1="0000:82:00.2"
REMOTE_MAC_VF1="e4:11:22:33:44:52"
REMOTE_PCI_VF2="0000:82:00.3"
REMOTE_MAC_VF2="e4:11:22:33:44:53"
REMOTE_NUM_VFS=2

ssh root@$REMOTE_SETUP /bin/bash << EOF
 echo 0 > /sys/class/net/$REMOTE_NIC/device/sriov_numvfs                                                                                                           
 echo dmfs >  /sys/class/net/$REMOTE_NIC/compat/devlink/steering_mode
 echo full >  /sys/class/net/$REMOTE_NIC/compat/devlink/ipsec_mode # none
 echo $REMOTE_NUM_VFS > /sys/class/net/$REMOTE_NIC/device/sriov_numvfs
 ip link set $REMOTE_NIC vf 0 mac $REMOTE_MAC_VF1
 ip link set $REMOTE_NIC vf 1 mac $REMOTE_MAC_VF2
 echo $REMOTE_PCI_VF1 > /sys/bus/pci/drivers/mlx5_core/unbind
 echo $REMOTE_PCI_VF2 > /sys/bus/pci/drivers/mlx5_core/unbind
 devlink dev eswitch set pci/$REMOTE_PCI mode switchdev
 echo $REMOTE_PCI_VF1 > /sys/bus/pci/drivers/mlx5_core/bind
 echo $REMOTE_PCI_VF2 > /sys/bus/pci/drivers/mlx5_core/bind
EOF

