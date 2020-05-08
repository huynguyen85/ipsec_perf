set -x #echo on

PORT1_OCTET=$2
PORT2_OCTET=$3

for i in $(seq 1 $1)
do
	taskset $((1<<(($i-1)%24))) iperf3 -B "192.$PORT1_OCTET.$i.64" -c "192.$PORT1_OCTET.$i.65" -t 300 -P1 -p $((7000+$i)) -f M -i 5  &
	taskset $((1<<(($i-1)%24))) iperf3 -B "192.$PORT2_OCTET.$i.64" -c "192.$PORT2_OCTET.$i.65" -t 300 -P1 -p $((8000+$i)) -f M -i 5  &
done

wait
