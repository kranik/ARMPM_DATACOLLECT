#!/bin/bash

./MC_XU3.sh -b 2000000,1900000,1800000,1700000,1600000,1500000,1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -s /home/odroid/Work/ARM_PowerModel/Results_cpustress_big -x /home/odroid/Work/ARM_PowerModel/Benchmarks/cpustress_monitor_noevents.sh -t 500000000 -n 3

sleep 1h

./MC_XU3.sh -L 1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -s /home/odroid/Work/ARM_PowerModel/Results_cpustress_LITTLE -x /home/odroid/Work/ARM_PowerModel/Benchmarks/cpustress_monitor_noevents.sh -t 500000000 -n 3

sleep 1h

./MC_XU3.sh -b 2000000,1900000,1800000,1700000,1600000,1500000,1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -s /home/odroid/Work/ARM_PowerModel/Results_cpusleep_big -x /home/odroid/Work/ARM_PowerModel/Benchmarks/cpusleep_monitor_noevents.sh -t 500000000 -n 3

./MC_XU3.sh -L 1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -s /home/odroid/Work/ARM_PowerModel/Results_cpusleep_LITTLE -x /home/odroid/Work/ARM_PowerModel/Benchmarks/cpusleep_monitor_noevents.sh -t 500000000 -n 3

#./MC_XU3.sh -b 2000000,1900000,1800000,1700000,1600000,1500000,1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -L 1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -s /home/odroid/Work/ARM_PowerModel/Results -x /home/odroid/Work/ARM_PowerModel/Benchmarks/cBench/O3/all_run__1_dataset_timestamp_noevents.sh -t 500000000 -n 3

#./MC_XU3.sh -L 1400000,200000 -s /home/odroid/Work/ARM_PowerModel/Results -x /home/odroid/Work/ARM_PowerModel/Benchmarks/cBench/O3/all_run__1_dataset_timestamp_noevents.sh -t 500000000 -n 2

#./MC_XU3.sh -b 2000000 -L 1400000 -s /home/odroid/Work/ARM_PowerModel/Results -x /home/odroid/Work/ARM_PowerModel/Benchmarks/cBench/O3/all_run__1_dataset_timestamp_noevents.sh -t 250000000 -n 2
