#!/bin/bash
set -x

IP_PREFIX="24"
## LOCAL params ##
LOCAL_NIC_REP="enp8s0f0"
LOCAL_UPLINK_VF="enp8s0f0v0"
LOCAL_UPLINK_VF_REP="enp8s0f0_0"
LOCAL_CONTAINER_VF_REP="enp8s0f0_1"
LOCAL_CONTAINER_VF="enp8s0f0v1"
LOCAL_UPLINK_VF_IP="7.7.7.7"
LOCAL_UPLINK_VF_MAC="e4:11:22:33:44:50"
LOCAL_CONTAINER_VF_IP="5.5.5.5"
LOCAL_CONTAINER_VF_MAC="e4:11:22:33:44:51"
VNI_KEY=100
VXLAN_PORT="vxlan${VNI_KEY}"
OVS_BR="ovs-br"

## REMOTE params ##
REMOTE_SETUP="10.236.149.186"
REMOTE_NIC_REP="enp8s0f0"
REMOTE_UPLINK_VF="enp8s0f0v0"
REMOTE_UPLINK_VF_REP="enp8s0f0_0"
REMOTE_CONTAINER_VF_REP="enp8s0f0_1"
REMOTE_CONTAINER_VF="enp8s0f0v1"
REMOTE_UPLINK_VF_IP="7.7.7.8"
REMOTE_UPLINK_VF_MAC="e4:11:22:33:44:52"
REMOTE_CONTAINER_VF_IP="5.5.5.9"
REMOTE_CONTAINER_VF_MAC="e4:11:22:33:44:53"
OVS_BR_EXT="ovs-ex"
OVS_BR_INT="ovs-int"
REMOTE_HW_TC_OFFLOAD="on"
REMOTE_OVS_HW_OFFLOAD="true"

## confiugre ips ##
# cleanup
ip addr flush $LOCAL_NIC_REP
ip addr flush $LOCAL_NIC_REP
ip addr flush $LOCAL_UPLINK_VF
ip addr flush $LOCAL_CONTAINER_VF
#configure ips
ip addr add $LOCAL_UPLINK_VF_IP/$IP_PREFIX dev $LOCAL_UPLINK_VF
ip addr add $LOCAL_CONTAINER_VF_IP/$IP_PREFIX dev $LOCAL_CONTAINER_VF
#set mtu to 1600 (as VXLAN is used)
ip link set $LOCAL_NIC_REP mtu 1600

## Setup OVS ##
service openvswitch start
# Cleanup
ovs-vsctl list-br | xargs -r -L 1 ovs-vsctl del-br 2>/dev/null
# Create Bridge and add ports
ovs-vsctl add-br $OVS_BR
ovs-vsctl add-port $OVS_BR $LOCAL_NIC_REP
ovs-vsctl add-port $OVS_BR $LOCAL_UPLINK_VF_REP
ovs-vsctl add-port $OVS_BR $LOCAL_CONTAINER_VF_REP
ovs-vsctl add-port $OVS_BR $VXLAN_PORT -- set interface $VXLAN_PORT type=vxlan options:local_ip=$LOCAL_UPLINK_VF_IP options:remote_ip=$REMOTE_UPLINK_VF_IP \
options:key=$VNI_KEY options:dst_port=4789

# Set hw-tc-offload
HW_TC_OFFLOAD="on"
ethtool -K $LOCAL_NIC_REP hw-tc-offload $HW_TC_OFFLOAD
ethtool -K $LOCAL_UPLINK_VF_REP hw-tc-offload $HW_TC_OFFLOAD
ethtool -K $LOCAL_CONTAINER_VF_REP hw-tc-offload $HW_TC_OFFLOAD
# Set hw-offload for OVS
OVS_HW_OFFLOAD="true"
ovs-vsctl set Open_vSwitch . other_config:hw-offload=$OVS_HW_OFFLOAD
service openvswitch restart
# Bring all up
ip link set $OVS_BR up
ip link set $LOCAL_NIC_REP up
ip link set $LOCAL_UPLINK_VF up
ip link set $LOCAL_CONTAINER_VF up
ip link set $LOCAL_UPLINK_VF_REP up
ip link set $LOCAL_CONTAINER_VF_REP up

# ARP table updates
arp -s $REMOTE_CONTAINER_VF_IP $REMOTE_CONTAINER_VF_MAC
arp -s $REMOTE_UPLINK_VF_IP $REMOTE_UPLINK_VF_MAC

ssh root@$REMOTE_SETUP /bin/bash << EOF
 #confiugre ips
 #cleanup
 ip addr flush $REMOTE_NIC_REP
 ip addr flush $REMOTE_UPLINK_VF
 ip addr flush $REMOTE_CONTAINER_VF
 #configure ips
 ip addr add $REMOTE_UPLINK_VF_IP/$IP_PREFIX dev $REMOTE_UPLINK_VF
 ip addr add $REMOTE_CONTAINER_VF_IP/$IP_PREFIX dev $REMOTE_CONTAINER_VF
 # Set mtu to 1600 (as VXLAN is used)
 ip link set $REMOTE_NIC_REP mtu 1600

 ## Setup OVS ##
 service openvswitch start
 # Cleanup
 ovs-vsctl list-br | xargs -r -L 1 ovs-vsctl del-br 2>/dev/null
 #Create Bridge and add ports
 # External OVS
 ovs-vsctl add-br $OVS_BR_EXT
 ovs-vsctl add-port $OVS_BR_EXT $LOCAL_NIC_REP
 ovs-vsctl add-port $OVS_BR_EXT $LOCAL_UPLINK_VF_REP
 # Internal OVS
 ovs-vsctl add-br $OVS_BR_INT
 ovs-vsctl add-port $OVS_BR_INT $LOCAL_CONTAINER_VF_REP
 ovs-vsctl add-port $OVS_BR_INT $VXLAN_PORT -- set interface $VXLAN_PORT type=vxlan options:local_ip=$REMOTE_UPLINK_VF_IP options:remote_ip=$LOCAL_UPLINK_VF_IP \
 options:key=$VNI_KEY options:dst_port=4789

 # Set hw-tc-offload
 ethtool -K $REMOTE_NIC_REP hw-tc-offload $REMOTE_HW_TC_OFFLOAD
 ethtool -K $REMOTE_UPLINK_VF_REP hw-tc-offload $REMOTE_HW_TC_OFFLOAD
 ethtool -K $REMOTE_CONTAINER_VF_REP hw-tc-offload $REMOTE_HW_TC_OFFLOAD
 # Set hw-offload for OVS
 ovs-vsctl set Open_vSwitch . other_config:hw-offload=$REMOTE_OVS_HW_OFFLOAD
 service openvswitch restart

 # Bring all up
 ip link set $OVS_BR_EXT up
 ip link set $OVS_BR_INT up
 ip link set $REMOTE_NIC_REP up
 ip link set $REMOTE_UPLINK_VF up
 ip link set $REMOTE_CONTAINER_VF up
 ip link set $REMOTE_UPLINK_VF_REP up
 ip link set $REMOTE_CONTAINER_VF_REP up

 # ARP table updates
 arp -s $LOCAL_CONTAINER_VF_IP $LOCAL_CONTAINER_VF_MAC
 arp -s $LOCAL_UPLINK_VF_IP $LOCAL_UPLINK_VF_MAC
 
EOF
ping $REMOTE_CONTAINER_VF_IP -c 5
