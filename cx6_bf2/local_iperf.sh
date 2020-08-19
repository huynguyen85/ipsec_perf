set -x #echo on

for i in $(seq 1 $1)
do
	taskset $((1<<(($i-1)%24))) iperf3 -B "15.15.$i.11" -c "15.15.$i.12" -t 300 -P1 -p $((5000+$i)) -f M -i 5  &
done

wait
