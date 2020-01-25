# ipsec_perf
Performance test for ipsec offload

Syntax:
SETUP
[root@local_machine]# ./transport_perf.sh <num of IPsec tunnel> <remote machine> <IPsec option>
  IPsec option:
    none: no IPsec offload on both sides
    local: IPsec inline offload on local
    both: IPsec inline offload on both side

RUN IPERF TEST
./remote_iperf.sh <num of IPsec tunnel>
./local_iperf.sh <num of IPsec tunnel>
 
Check CPU usage during htop. Offload should not occupy much CPU power.

Example:
[root@sw-mtx-011 ipsec3]# ./transport_perf.sh 10 sw-mtx-012 both
This command runs on local machine sw-mtx-012 and creates 10 IPsec tunnel in transport mode with its remote machine is sw-mtx-011 and both sides have IPsec offload.

[root@sw-mtx-012 ipsec3]# ./remote_iperf.sh 10
[root@sw-mtx-011 ipsec3]# ./local_iperf.sh 10
