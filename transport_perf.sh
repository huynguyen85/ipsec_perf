#!/bin/bash
set -x #echo on

#LOCAL_SPI_RX=(400 16 10 9 1 4 2000 100000 2001 2002 6 3 11 8 401 402)
#REMOTE_SPI_RX=(500 26 20 10 2 5 3000 200000 3001 3002 7 399 12 1099 501 502)
REMOTE_SERVER=$2
NUM_TUN=$1
#$3 is the both/local/none
OPTION=$4
LOCAL_NIC_PF=$5
REMOTE_NIC_PF=$6
FULL=$3
SOFT=$7
HARD=$8

pkill irqbalance
pkill tuned
systemctl stop NetworkManager
systemctl stop firewalld
ip xfrm s f
ip xfrm p f
set_irq_affinity.sh $LOCAL_NIC_PF
ip link set $LOCAL_NIC_PF up

sshpass -p 3tango ssh -o StrictHostKeyChecking=no -l root $REMOTE_SERVER /bin/bash << EOF
	set -x #echo on
	pkill irqbalance
	pkill tuned
	systemctl stop NetworkManager
	systemctl stop firewalld
	ip xfrm s f
	ip xfrm p f
	set_irq_affinity.sh $REMOTE_NIC_PF
	ip link set $REMOTE_NIC_PF up
EOF

for i in $(seq 1 $NUM_TUN)
do
LOCAL_ADDR=192.168.$i.64
REMOTE_ADDR=192.168.$i.65
#LOCAL_ADDR=15.15.15.11
#REMOTE_ADDR=15.15.15.12

#./setup_xfrm.sh -$OPTION -id ${REMOTE_SPI_RX[$(($i-1))]} ${LOCAL_SPI_RX[$(($i-1))]} -a -256 -v $LOCAL_ADDR/24 $LOCAL_NIC_PF $REMOTE_ADDR/24 $REMOTE_NIC_PF $REMOTE_SERVER $LOCAL_ADDR $REMOTE_ADDR
./setup_xfrm.sh -$FULL -$OPTION -a -256 -v $LOCAL_ADDR/24 $LOCAL_NIC_PF $REMOTE_ADDR/24 $REMOTE_NIC_PF $REMOTE_SERVER $LOCAL_ADDR $REMOTE_ADDR $SOFT $HARD
done

