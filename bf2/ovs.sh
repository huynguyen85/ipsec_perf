#!/bin/bash
set -x #echo on

VXLAN_IF_NAME=vxlan_sys_4789
PF0=p0
VF0_REP=pf0hpf
REMOTE_SERVER=$1

ifconfig $VF0_REP up
ip link del vxlan_sys_4789

# adding hw-tc-offload on
#echo update hw-tc-offload to $PF0 and $VF0_REP
ethtool -K $VF0_REP hw-tc-offload on
ethtool -K $PF0 hw-tc-offload on

service openvswitch start
ovs-vsctl del-br ovs-br
ovs-vsctl add-br ovs-br
ovs-vsctl add-port ovs-br $VF0_REP
ovs-vsctl add-port ovs-br $PF0
#ovs-vsctl add-port ovs-br vxlan11 -- set interface vxlan11 type=vxlan options:local_ip=$OUTER_LOCAL_IP options:remote_ip=$OUTER_REMOTE_IP options:key=100 options:dst_port=4789

ovs-vsctl set Open_vSwitch . other_config:hw-offload=true
service openvswitch restart
ifconfig ovs-br up
ovs-vsctl show

PF0=p0
VF0_REP=pf0hpf
ssh $REMOTE_SERVER /bin/bash << EOF

ifconfig $VF0_REP up
ip link del vxlan_sys_4789

# adding hw-tc-offload on
#echo update hw-tc-offload to $PF0 and $VF0_REP
ethtool -K $VF0_REP hw-tc-offload on
ethtool -K $PF0 hw-tc-offload on

service openvswitch start
ovs-vsctl del-br ovs-br
ovs-vsctl add-br ovs-br
ovs-vsctl add-port ovs-br $VF0_REP
ovs-vsctl add-port ovs-br $PF0
#ovs-vsctl add-port ovs-br vxlan11 -- set interface vxlan11 type=vxlan options:local_ip=$OUTER_LOCAL_IP options:remote_ip=$OUTER_REMOTE_IP options:key=100 options:dst_port=4789

ovs-vsctl set Open_vSwitch . other_config:hw-offload=true
service openvswitch restart
ifconfig ovs-br up
ovs-vsctl show

EOF
