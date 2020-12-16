#!/bin/bash
set -x #echo on

VXLAN_IF_NAME=vxlan_sys_4789
PF0=ens1f0
VF0_REP=eth0
OUTER_REMOTE_IP=2001::192:168:210:12
OUTER_LOCAL_IP=2001::192:168:210:11
#OUTER_REMOTE_IP=192.168.1.65
#OUTER_LOCAL_IP=192.168.1.64

REMOTE_SERVER=sw-mtx-012

#configuring PF and PF representor
ip addr add $OUTER_LOCAL_IP/112 dev $PF0
ifconfig $PF0 up
ifconfig $VF0_REP up
ip link del vxlan_sys_4789

# adding hw-tc-offload on
#echo update hw-tc-offload to $PF0 and $VF0_REP
ethtool -K $VF0_REP hw-tc-offload off
ethtool -K $PF0 hw-tc-offload off

service openvswitch start
ovs-vsctl del-br ovs-br
ovs-vsctl add-br ovs-br
ovs-vsctl add-port ovs-br $VF0_REP
#ovs-vsctl add-port ovs-br $PF0
ovs-vsctl add-port ovs-br gre0 -- set interface gre0 type=gre options:local_ip=$OUTER_LOCAL_IP options:remote_ip=$OUTER_REMOTE_IP options:key=10

ovs-vsctl set Open_vSwitch . other_config:hw-offload=false
service openvswitch restart
ifconfig ovs-br up
ovs-vsctl show

OUTER_REMOTE_IP=2001::192:168:210:11
OUTER_LOCAL_IP=2001::192:168:210:12
#OUTER_REMOTE_IP=192.168.1.64
#OUTER_LOCAL_IP=192.168.1.65

PF0=ens1f0
VF0_REP=eth0
ssh $REMOTE_SERVER /bin/bash << EOF
	#configuring PF and PF representor
	ip addr add $OUTER_LOCAL_IP/112 dev $PF0
	ifconfig $PF0 up
	ifconfig $VF0_REP up
	ip link del vxlan_sys_4789

	# adding hw-tc-offload on
	echo update hw-tc-offload to $PF0 and $VF0_REP
	ethtool -K $VF0_REP hw-tc-offload off
	ethtool -K $PF0 hw-tc-offload off
	
	service openvswitch start
	ovs-vsctl del-br ovs-br
	ovs-vsctl add-br ovs-br
	ovs-vsctl add-port ovs-br $VF0_REP
#	ovs-vsctl add-port ovs-br $PF0
	ovs-vsctl add-port ovs-br gre0 -- set interface gre0 type=gre options:local_ip=$OUTER_LOCAL_IP options:remote_ip=$OUTER_REMOTE_IP options:key=10
	
	ovs-vsctl set Open_vSwitch . other_config:hw-offload=false
	service openvswitch restart
	ifconfig ovs-br up
	ovs-vsctl show
EOF
