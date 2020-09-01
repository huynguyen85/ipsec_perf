#!/bin/bash
set -x #echo on

NUM_TUN=$1
REMOTE_SERVER=$2
LOCAL_NIC_PF=$3
REMOTE_NIC_PF=$4

for i in $(seq 1 $NUM_TUN)
do
LOCAL_ADDR=15.15.$i.64
REMOTE_ADDR=15.15.$i.65

ip addr add $LOCAL_ADDR/24 dev $LOCAL_NIC_PF

ssh $REMOTE_SERVER /bin/bash << EOF
	set -x #echo on
	ip addr add $REMOTE_ADDR/24 dev $REMOTE_NIC_PF
EOF
done
