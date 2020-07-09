#!/bin/bash
set -x #echo on

VXLAN_IF_NAME=vxlan_sys_4789
PF0=enp130s0
VF0_REP=enp130s0_0
OUTER_REMOTE_IP=192.168.1.64
OUTER_LOCAL_IP=192.168.1.65
REMOTE_SERVER=exprom-dell2

#configuring PF and PF representor
ifconfig $PF0 $OUTER_LOCAL_IP/24 up
ifconfig $PF0 up
#ifconfig $VF0 $INNER_LOCAL_IP/24 up
ifconfig $VF0_REP up
ifconfig enp130s0_1 up
ifconfig enp130s0_2 up
ifconfig enp130s0_3 up
ifconfig enp130s0_4 up
ifconfig enp130s0_5 up
ifconfig enp130s0_6 up
ifconfig enp130s0_7 up

ip link del vxlan_sys_4789
#ip link add vxlan_sys_4789 type vxlan id 100 dev ens1f0 dstport 4789

# adding hw-tc-offload on
#echo update hw-tc-offload to $PF0 and $VF0_REP
ethtool -K $VF0_REP hw-tc-offload on
ethtool -K enp130s0_1 hw-tc-offload on
ethtool -K enp130s0_2 hw-tc-offload on
ethtool -K enp130s0_3 hw-tc-offload on
ethtool -K enp130s0_4 hw-tc-offload on
ethtool -K enp130s0_5 hw-tc-offload on
ethtool -K enp130s0_6 hw-tc-offload on
ethtool -K enp130s0_7 hw-tc-offload on

ethtool -K $PF0 hw-tc-offload on

service openvswitch start
ovs-vsctl del-br ovs-br
ovs-vsctl add-br ovs-br
ovs-vsctl add-port ovs-br $VF0_REP
ovs-vsctl add-port ovs-br enp130s0_1
ovs-vsctl add-port ovs-br enp130s0_2
ovs-vsctl add-port ovs-br enp130s0_3
ovs-vsctl add-port ovs-br enp130s0_4
ovs-vsctl add-port ovs-br enp130s0_5
ovs-vsctl add-port ovs-br enp130s0_6
ovs-vsctl add-port ovs-br enp130s0_7

ovs-vsctl add-port ovs-br $PF0
#ovs-vsctl add-port ovs-br vxlan11 -- set interface vxlan11 type=vxlan options:local_ip=$OUTER_LOCAL_IP options:remote_ip=$OUTER_REMOTE_IP options:key=100 options:dst_port=4789

ovs-vsctl set Open_vSwitch . other_config:hw-offload=true
service openvswitch restart
ifconfig ovs-br up
ovs-vsctl show

OUTER_REMOTE_IP=192.168.1.65
OUTER_LOCAL_IP=192.168.1.64
PF0=enp130s0f0
VF0_REP=enp130s0f0_0
ssh $REMOTE_SERVER /bin/bash << EOF
	#configuring PF and PF representor
	ifconfig $PF0 $OUTER_LOCAL_IP/24 up
	ifconfig $PF0 up
	ifconfig $VF0_REP up
	ifconfig enp130s0f0_1 up
	ifconfig enp130s0f0_2 up
	ifconfig enp130s0f0_3 up
	ifconfig enp130s0f0_4 up
	ifconfig enp130s0f0_5 up
	ifconfig enp130s0f0_6 up
	ifconfig enp130s0f0_7 up
	ip link del vxlan_sys_4789

	# adding hw-tc-offload on
	echo update hw-tc-offload to $PF0 and $VF0_REP
	ethtool -K $VF0_REP hw-tc-offload on
	ethtool -K enp130s0f0_1 hw-tc-offload on
	ethtool -K enp130s0f0_2 hw-tc-offload on
	ethtool -K enp130s0f0_3 hw-tc-offload on
	ethtool -K enp130s0f0_4 hw-tc-offload on
	ethtool -K enp130s0f0_5 hw-tc-offload on
	ethtool -K enp130s0f0_6 hw-tc-offload on
	ethtool -K enp130s0f0_7 hw-tc-offload on

	ethtool -K $PF0 hw-tc-offload on

	service openvswitch start
	ovs-vsctl del-br ovs-br
	ovs-vsctl add-br ovs-br
	ovs-vsctl add-port ovs-br $VF0_REP
	ovs-vsctl add-port ovs-br enp130s0f0_1
	ovs-vsctl add-port ovs-br enp130s0f0_2
	ovs-vsctl add-port ovs-br enp130s0f0_3
	ovs-vsctl add-port ovs-br enp130s0f0_4
	ovs-vsctl add-port ovs-br enp130s0f0_5
	ovs-vsctl add-port ovs-br enp130s0f0_6
	ovs-vsctl add-port ovs-br enp130s0f0_7

#	ovs-vsctl add-port ovs-br vxlan11 -- set interface vxlan11 type=vxlan options:local_ip=$OUTER_LOCAL_IP options:remote_ip=$OUTER_REMOTE_IP options:key=100 options:dst_port=4789
	ovs-vsctl add-port ovs-br $PF0

	ovs-vsctl set Open_vSwitch . other_config:hw-offload=true
	service openvswitch restart
	ifconfig ovs-br up
	ovs-vsctl show
EOF
