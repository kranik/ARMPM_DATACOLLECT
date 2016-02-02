#!/bin/bash

./MC_XU3.sh -b 1 -f 2000000,1900000,1800000,1700000,1600000,1500000,1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -n 1 -x /home/odroid/Work/ARMPM/ARMPM_datacollect/Workloads/cBench/O3/all_run__1_dataset_timestamp_cset -e /home/odroid/Work/ARMPM/ARMPM_datacollect/ODROID_XU3/events_list_1.data -t 500000000 -s /home/odroid/Work/ARMPM/Results/XU3_1/cset_TIME_perfcpu/big/

sleep 1h

./MC_XU3.sh -L 1 -f 1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -n 1 -x /home/odroid/Work/ARMPM/ARMPM_datacollect/Workloads/cBench/O3/all_run__1_dataset_timestamp_cset -e /home/odroid/Work/ARMPM/ARMPM_datacollect/ODROID_XU3/events_list_1.data -t 500000000 -s /home/odroid/Work/ARMPM/Results/XU3_1/cset_TIME_perfcpu/LITTLE/

#sleep 1h

#./MC_XU3.sh -b 1 -f 2000000,1100000,200000 -n 5 -x /home/odroid/Work/ARMPM/ARMPM_datacollect/Workloads/cBench/O3/all_run__1_dataset_timestamp_cset -e /home/odroid/Work/ARMPM/ARMPM_datacollect/ODROID_XU3/events_list_2.data -t 500000000 -s /home/odroid/Work/ARMPM/Results/XU3_1/cset_TEST_perfcpu_eventsSelect_list2/big/

#sleep 1h

#./MC_XU3.sh -L 1 -f 1400000,800000,200000 -n 5 -x /home/odroid/Work/ARMPM/ARMPM_datacollect/Workloads/cBench/O3/all_run__1_dataset_timestamp_cset -e /home/odroid/Work/ARMPM/ARMPM_datacollect/ODROID_XU3/events_list_2.data -t 500000000 -s /home/odroid/Work/ARMPM/Results/XU3_1/cset_TEST_perfcpu_eventsSelect_list2/LITTLE/

#sleep 15m

#./MC_XU3.sh -b 1 -f 2000000,1900000,1800000,1700000,1600000,1500000,1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -n 3 -x /home/odroid/Work/ARMPM/ARMPM_datacollect/Workloads/cBench/O3/all_run__1_dataset_timestamp -e /home/odroid/Work/ARMPM/ARMPM_datacollect/ODROID_XU3/events_list_2.data -t 500000000 -s /home/odroid/Work/ARMPM/Results/XU3_2/eventsTest_minimal/eventsTest_list2/big/

#sleep 15m

#./MC_XU3.sh -L 1 -f 1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -n 3 -x /home/odroid/Work/ARMPM/ARMPM_datacollect/Workloads/cBench/O3/all_run__1_dataset_timestamp -e /home/odroid/Work/ARMPM/ARMPM_datacollect/ODROID_XU3/events_list_2.data -t 500000000 -s /home/odroid/Work/ARMPM/Results/XU3_2/eventsTest_minimal/eventsTest_list2/LITTLE/

#./MC_XU3.sh -b 1 -f 2000000,1900000,1800000,1700000,1600000,1500000,1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -n 3 -x /home/odroid/Work/ARMPM/ARMPM_datacollect/Workloads/cBench/O3/all_run__1_dataset_timestamp -e /home/odroid/Work/ARMPM/ARMPM_datacollect/ODROID_XU3/events_list_PPS.data -t 500000000 -s /home/odroid/Work/ARMPM/Results/PPS_XU3_2/big/

#sleep 1h

#./MC_XU3.sh -L 1 -f 1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -n 3 -x /home/odroid/Work/ARMPM/ARMPM_datacollect/Workloads/cBench/O3/all_run__1_dataset_timestamp -e /home/odroid/Work/ARMPM/ARMPM_datacollect/ODROID_XU3/events_list_PPS.data -t 500000000 -s /home/odroid/Work/ARMPM/Results/PPS_XU3_2/LITTLE/

#./MC_XU3.sh -L 1400000,200000 -s /home/odroid/Work/ARM_PowerModel/Results -x /home/odroid/Work/ARM_PowerModel/Benchmarks/cBench/O3/all_run__1_dataset_timestamp_noevents.sh -t 500000000 -n 2

#./MC_XU3.sh -b 2000000 -L 1400000 -s /home/odroid/Work/ARM_PowerModel/Results -x /home/odroid/Work/ARM_PowerModel/Benchmarks/cBench/O3/all_run__1_dataset_timestamp_noevents.sh -t 250000000 -n 2
