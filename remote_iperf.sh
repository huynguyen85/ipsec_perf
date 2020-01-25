for i in $(seq 1 $1)
do
	taskset $i iperf -s -p $((5000+$i)) &
done

wait
