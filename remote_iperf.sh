for i in $(seq 1 $1)
do
	 taskset $((1<<(($i-1)%24)))  iperf3 -s -p $((5000+$i)) &
done

wait
