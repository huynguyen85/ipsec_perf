for i in $(seq 1 $1)
do
	taskset $i iperf -B "192.168.$i.64" -c "192.168.$i.65" -t 30 -P1 -p $((5000+$i)) &
done

wait
