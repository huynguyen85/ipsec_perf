#!/bin/bash
set -x #echo on

REMOTE_SERVER=$1
LOCAL_DEV=$2
REMOTE_DEV=$3

for i in {1..24}
do
	ip addr add dev $LOCAL_DEV 15.15.$i.11/24
done

for i in {1..24}; do
ssh $REMOTE_SERVER /bin/bash << EOF
	set -x #echo on
	ip addr add dev $REMOTE_DEV 15.15.$i.12/24
EOF
done
