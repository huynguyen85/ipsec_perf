for i in $(seq 1 $1)
do
	 taskset $((1<<(($i-1)%24)))  iperf3 -s -p $((7000+$i)) &
	 taskset $((1<<(($i-1)%24)))  iperf3 -s -p $((8000+$i)) &
done

wait
