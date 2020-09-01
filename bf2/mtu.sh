set -x #echo on

PF0=p0
VF0_REP=pf0hpf
REMOTE_SERVER=$1

ifconfig $PF0 mtu 7000 up
ifconfig $VF0_REP mtu 5000 up
ifconfig ovs-br mtu 6000 up

ssh $REMOTE_SERVER /bin/bash << EOF
ifconfig $PF0 mtu 7000 up
ifconfig $VF0_REP mtu 5000 up
ifconfig ovs-br mtu 6000 up
EOF
