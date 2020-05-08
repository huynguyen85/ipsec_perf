# ipsec_perf
Performance test for ipsec offload

Syntax:
To setup
[root@sw-mtx-011 ipsec_perf]# ./transport_perf.sh <number of tunnels> <iperf server system> <mode> local_netdev remote_netdev
	mode:   none: no offload on both side
		local: offload on iperf client side
		both: offload on both side
For example:
[root@sw-mtx-011 ipsec_perf]# ./transport_perf.sh 250 sw-mtx-012 none ens1f0 ens1f0
this set 250 IPsec tunnel in transport mode and offload mode on sw-mtx-011 and sw-mtx-012

To run the test
[root@sw-mtx-012 ~]# ./remote_iperf.sh 250
[root@sw-mtx-011 ipsec_perf]# ./local_iperf.sh 250 > temp.txt

To sum the bw
[root@sw-mtx-011 ipsec_perf]# grep "30.00-35.00" temp.txt > temp1.txt && python sum.py

=========== For UDP ============
Add option "-u -b 0" to the iperf command in the local_iperf.sh
Lower MTU to 300 for little bit better pps

To count the pps
[root@sw-mtx-011 ipsec_perf]# ./print_pps.sh

Dual Port test
[root@gen-l-vrt-203 ipsec_perf]# ./transport_perf_dual.sh 24 gen-l-vrt-204 both enp4s0f0np0 enp4s0f0np0 168 enp4s0f1np1 enp4s0f1np1 169

[root@gen-l-vrt-204 ipsec_perf]# ./remote_iperf_dual.sh 24
[root@gen-l-vrt-203 ipsec_perf]# grep "10.00-15.00" temp.txt > temp1.txt
[root@gen-l-vrt-203 ipsec_perf]# python sum.py
87.6776
