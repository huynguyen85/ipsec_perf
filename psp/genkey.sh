#!/bin/bash
#set -x
var=$(cat /sys/kernel/debug/mlx5/0000\:06\:00.0/psp/gen_key)
echo "${var// /}" | cut -d":" -f2
