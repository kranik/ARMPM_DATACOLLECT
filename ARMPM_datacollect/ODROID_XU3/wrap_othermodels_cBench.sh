#!/bin/bash

#Pricopi

./MC_XU3.sh -b 1 -f 2000000,1900000,1800000,1700000,1600000,1500000,1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -n 2 -x /home/Work/ARMPM/ARMPM_datacollect/Workloads/cBench/O3/all_run__1_dataset_timestamp_cset -e /home/Work/ARMPM/ARMPM_datacollect/ODROID_XU3/events_lists_all/big/events_list_big_pricopi.data -t 500000000 -s /home/Work/ARMPM/Results/XU3_1/cset_perfcpu_cBench_eMMC_pricopi/big/

#Rodrigues

./MC_XU3.sh -b 1 -f 2000000,1900000,1800000,1700000,1600000,1500000,1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -n 2 -x /home/Work/ARMPM/ARMPM_datacollect/Workloads/cBench/O3/all_run__1_dataset_timestamp_cset -e /home/Work/ARMPM/ARMPM_datacollect/ODROID_XU3/events_lists_all/big/events_list_big_rodrigues.data -t 500000000 -s /home/Work/ARMPM/Results/XU3_1/cset_perfcpu_cBench_eMMC_rodrigues/big/

#Walker

./MC_XU3.sh -b 1 -f 2000000,1900000,1800000,1700000,1600000,1500000,1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -n 2 -x /home/Work/ARMPM/ARMPM_datacollect/Workloads/cBench/O3/all_run__1_dataset_timestamp_cset -e /home/Work/ARMPM/ARMPM_datacollect/ODROID_XU3/events_lists_all/big/events_list_big_walker.data -t 500000000 -s /home/Work/ARMPM/Results/XU3_1/cset_perfcpu_cBench_eMMC_walker/big/

#Nikov

./MC_XU3.sh -b 1 -f 2000000,1900000,1800000,1700000,1600000,1500000,1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -n 2 -x /home/Work/ARMPM/ARMPM_datacollect/Workloads/cBench/O3/all_run__1_dataset_timestamp_cset -e /home/Work/ARMPM/ARMPM_datacollect/ODROID_XU3/events_lists_all/big/events_list_big_nikov.data -t 500000000 -s /home/Work/ARMPM/Results/XU3_1/cset_perfcpu_cBench_eMMC_nikov/big/

./MC_XU3.sh -L 1 -f 1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -n 2 -x /home/Work/ARMPM/ARMPM_datacollect/Workloads/cBench/O3/all_run__1_dataset_timestamp_cset -e /home/Work/ARMPM/ARMPM_datacollect/ODROID_XU3/events_lists_all/LITTLE/events_list_LITTLE_nikov.data -t 500000000 -s /home/Work/ARMPM/Results/XU3_1/cset_perfcpu_cBench_eMMC_nikov/LITTLE/
