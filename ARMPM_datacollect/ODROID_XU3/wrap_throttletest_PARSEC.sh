#!/bin/bash

#1Core

#Overhead

./MC_XU3.sh -b 1 -f 2000000 -n 2 -x /home/Work/DATACOLLECT/ARMPM_datacollect/Workloads/parsec-3.0/parsec_benchlist_timestamp_cset.sh -t 500000000 -s /home/Work/DATACOLLECT/Results/XU3_1/cset_perfcpu_PARSEC_green_mSD_c1_maxfreq_big/noevents/

#4Core

#Overhead

./MC_XU3.sh -b 4 -f 2000000 -n 2 -x /home/Work/DATACOLLECT/ARMPM_datacollect/Workloads/parsec-3.0/parsec_benchlist_timestamp_cset.sh -t 500000000 -s /home/Work/DATACOLLECT/Results/XU3_1/cset_perfcpu_PARSEC_green_mSD_c4_maxfreq_big/noevents/
