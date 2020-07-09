#!/bin/bash
set -x #echo on

REMOTE_SERVER=exprom-dell2

ifconfig enp130s0f1 15.15.1.11/24 mtu 1300 up
ifconfig enp130s0f2 15.15.2.11/24 mtu 1300 up
ifconfig enp130s0f3 15.15.3.11/24 mtu 1300 up
ifconfig enp130s0f4 15.15.4.11/24 mtu 1300 up
ifconfig enp130s0f5 15.15.5.11/24 mtu 1300 up
ifconfig enp130s0f6 15.15.6.11/24 mtu 1300 up
ifconfig enp130s0f7 15.15.7.11/24 mtu 1300 up
ifconfig enp130s1   15.15.8.11/24 mtu 1300 up

ssh $REMOTE_SERVER /bin/bash << EOF
	set -x #echo on
	ifconfig enp130s0f2 15.15.1.12/24 mtu 1300 up
	ifconfig enp130s0f3 15.15.2.12/24 mtu 1300 up
	ifconfig enp130s0f4 15.15.3.12/24 mtu 1300 up
	ifconfig enp130s0f5 15.15.4.12/24 mtu 1300 up
	ifconfig enp130s0f6 15.15.5.12/24 mtu 1300 up
	ifconfig enp130s0f7 15.15.6.12/24 mtu 1300 up
	ifconfig enp130s1   15.15.7.12/24 mtu 1300 up
	ifconfig enp130s1f1 15.15.8.12/24 mtu 1300 up
EOF
