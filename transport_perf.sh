#!/bin/bash
set -x #echo on

LOCAL_SPI_RX=(400 16 10 9 1 4 2000 100000 2001 2002 6 3 11 8 401 402)
REMOTE_SPI_RX=(500 26 20 10 2 5 3000 200000 3001 3002 7 399 12 1099 501 502)
REMOTE_SERVER=$2
NUM_TUN=$1
OPTION=$3
NIC_PF=ens1f0

pkill irqbalance
pkill tuned
systemctl stop NetworkManager
systemctl stop firewalld
ip xfrm s f
ip xfrm p f
ip addr flush dev $NIC_PF
set_irq_affinity.sh $NIC_PF
ip link set $NIC_PF up

ssh sw-mtx-012 /bin/bash << EOF
	set -x #echo on
	pkill irqbalance
	pkill tuned
	systemctl stop NetworkManager
	systemctl stop firewalld
	ip xfrm s f
	ip xfrm p f
	ip addr flush dev $NIC_PF
	set_irq_affinity.sh $NIC_PF
	ip link set $NIC_PF up

	ip link set $NIC_PF up
EOF

for i in $(seq 1 $NUM_TUN)
do
LOCAL_ADDR=192.168.$i.64
REMOTE_ADDR=192.168.$i.65

ip addr add $LOCAL_ADDR/24 dev $NIC_PF

ssh sw-mtx-012 /bin/bash << EOF
	set -x #echo on
	ip addr add $REMOTE_ADDR/24 dev $NIC_PF
EOF
./setup_xfrm.sh -$OPTION -id ${REMOTE_SPI_RX[$(($i-1))]} ${LOCAL_SPI_RX[$(($i-1))]} -a -256 -v $LOCAL_ADDR/24 ens1f0 $REMOTE_ADDR/24 ens1f0 10.9.150.39 $LOCAL_ADDR $REMOTE_ADDR
done

