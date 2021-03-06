#!/bin/bash
set -x #echo on

REMOTE_SERVER=10.9.150.39
VXLAN_IF_NAME=vxlan_sys_4789


OUTER_REMOTE_IP=192.168.1.65
OUTER_LOCAL_IP=192.168.1.64
PF0=p1
VF0_REP=pf1hpf

#configuring PF and PF representor
ip addr add dev $PF0 $OUTER_LOCAL_IP/24
ifconfig $PF0 up
ifconfig $VF0_REP up
ip link del vxlan_sys_4789

# adding hw-tc-offload on
echo update hw-tc-offload to $PF0 and $VF0_REP
ethtool -K $VF0_REP hw-tc-offload on
ethtool -K $PF0 hw-tc-offload on

service openvswitch start
ovs-vsctl del-br ovs-br
ovs-vsctl add-br ovs-br
ovs-vsctl add-port ovs-br $VF0_REP
ovs-vsctl add-port ovs-br vxlan11 -- set interface vxlan11 type=vxlan options:local_ip=$OUTER_LOCAL_IP options:remote_ip=$OUTER_REMOTE_IP options:key=100 options:dst_port=4789

ovs-vsctl set Open_vSwitch . other_config:hw-offload=true
service openvswitch restart
ifconfig ovs-br up
ovs-vsctl show

PF0=ens1f1
VF0_REP=ens1f1_0
OUTER_REMOTE_IP=192.168.1.64
OUTER_LOCAL_IP=192.168.1.65
sshpass -p 3tango ssh -o StrictHostKeyChecking=no -l root $REMOTE_SERVER /bin/bash << EOF
	#configuring PF and PF representor
	ip addr add dev $PF0 $OUTER_LOCAL_IP/24
	ifconfig $PF0 up
	ifconfig $VF0_REP up
	ip link del vxlan_sys_4789
	
	# adding hw-tc-offload on
	ethtool -K $VF0_REP hw-tc-offload on
	ethtool -K $PF0 hw-tc-offload on
	
	service openvswitch start
	ovs-vsctl del-br ovs-br
	ovs-vsctl add-br ovs-br
	ovs-vsctl add-port ovs-br $VF0_REP
	#ovs-vsctl add-port ovs-br $PF0
	ovs-vsctl add-port ovs-br vxlan11 -- set interface vxlan11 type=vxlan options:local_ip=$OUTER_LOCAL_IP options:remote_ip=$OUTER_REMOTE_IP options:key=100 options:dst_port=4789

	ovs-vsctl set Open_vSwitch . other_config:hw-offload=true
	service openvswitch restart
	ifconfig ovs-br up
	ovs-vsctl show
EOF
