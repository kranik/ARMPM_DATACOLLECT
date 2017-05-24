#!/bin/bash

#Set manual mode for fan
echo 0 > "/sys/devices/odroid_fan.14/fan_mode"

#Start with the low rpm fan
echo 100 > "/sys/devices/odroid_fan.14/pwm_duty"

./MC_XU3.sh -b 1 -f 2000000 -n 5 -x /home/odroid/Work/ARMPM/ARMPM_datacollect/Workloads/cBench/O3/all_run__1_dataset_timestamp_cset -e /home/odroid/Work/ARMPM/ARMPM_datacollect/ODROID_XU3/events_list_best_big.data -t 500000000 -s /home/odroid/Work/ARMPM/Results/xu3_1/cset_perfcpu_cBench_eMMC_thermalprobe/low_rpm/big/
sleep 1h
./MC_XU3.sh -L 1 -f 1400000 -n 5 -x /home/odroid/Work/ARMPM/ARMPM_datacollect/Workloads/cBench/O3/all_run__1_dataset_timestamp_cset -e /home/odroid/Work/ARMPM/ARMPM_datacollect/ODROID_XU3/events_list_best_LITTLE.data -t 500000000 -s /home/odroid/Work/ARMPM/Results/xu3_1/cset_perfcpu_cBench_eMMC_thermalprobe/low_rpm/LITTLE/

#Continue with the medium rpm fan
echo 180 > "/sys/devices/odroid_fan.14/pwm_duty"

./MC_XU3.sh -b 1 -f 2000000 -n 5 -x /home/odroid/Work/ARMPM/ARMPM_datacollect/Workloads/cBench/O3/all_run__1_dataset_timestamp_cset -e /home/odroid/Work/ARMPM/ARMPM_datacollect/ODROID_XU3/events_list_best_big.data -t 500000000 -s /home/odroid/Work/ARMPM/Results/xu3_1/cset_perfcpu_cBench_eMMC_thermalprobe/med_rpm/big/
sleep 1h
./MC_XU3.sh -L 1 -f 1400000 -n 5 -x /home/odroid/Work/ARMPM/ARMPM_datacollect/Workloads/cBench/O3/all_run__1_dataset_timestamp_cset -e /home/odroid/Work/ARMPM/ARMPM_datacollect/ODROID_XU3/events_list_best_LITTLE.data -t 500000000 -s /home/odroid/Work/ARMPM/Results/xu3_1/cset_perfcpu_cBench_eMMC_thermalprobe/med_rpm/LITTLE/


#End with the highest rpm fan
echo 255 > "/sys/devices/odroid_fan.14/pwm_duty"

./MC_XU3.sh -b 1 -f 2000000 -n 5 -x /home/odroid/Work/ARMPM/ARMPM_datacollect/Workloads/cBench/O3/all_run__1_dataset_timestamp_cset -e /home/odroid/Work/ARMPM/ARMPM_datacollect/ODROID_XU3/events_list_best_big.data -t 500000000 -s /home/odroid/Work/ARMPM/Results/xu3_1/cset_perfcpu_cBench_eMMC_thermalprobe/high_rpm/big/
sleep 1h
./MC_XU3.sh -L 1 -f 1400000 -n 5 -x /home/odroid/Work/ARMPM/ARMPM_datacollect/Workloads/cBench/O3/all_run__1_dataset_timestamp_cset -e /home/odroid/Work/ARMPM/ARMPM_datacollect/ODROID_XU3/events_list_best_LITTLE.data -t 500000000 -s /home/odroid/Work/ARMPM/Results/xu3_1/cset_perfcpu_cBench_eMMC_thermalprobe/high_rpm/LITTLE/

#Return to auto mode for fan
echo 1 > "/sys/devices/odroid_fan.14/fan_mode"
