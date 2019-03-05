#!/bin/bash

#1Core LITTLE
./MC_XU3.sh -L 1 -f 1400000 -n 2 -x /home/Work/DATACOLLECT/ARMPM_datacollect/Workloads/parsec-3.0/parsec_benchlist_timestamp_cset.sh -t 500000000 -s /home/Work/DATACOLLECT/Results/XU3_1/cset_perfcpu_PARSEC_bodytrack_eMMC_c1_LITTLE_maxfreq/noevents/

#All Cores
./MC_XU3.sh -b 4 -L 4 -f 1800000,1700000,1600000,1500000,1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -q 1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -n 5 -x /home/Work/DATACOLLECT/ARMPM_datacollect/Workloads/parsec-3.0/parsec_benchlist_timestamp_cset.sh -t 500000000 -s /home/Work/DATACOLLECT/Results/XU3_1/cset_perfcpu_PARSEC_bodytrack_eMMC_c8_allfreq/noevents/
