#!/bin/bash

#Taskset seq part big core
./MC_XU3.sh -b 4 -L 4 -m 4 -f 1000000,900000,800000,700000,600000,500000,400000,300000,200000 -q 700000,600000,500000,400000 -n 1 -x /home/Work/DATACOLLECT/ARMPM_datacollect/Workloads/parsec-3.0/parsec_benchlist_timestamp_cset.sh -t 500000000 -s /home/Work/DATACOLLECT/Results/XU3_1/cset_perfcpu_PARSEC_green_mSD_c8_multicluster_bigseq/noevents/

#Taskset seq part LITTLE core
./MC_XU3.sh -b 4 -L 4 -m 0 -f 1000000,900000,800000,700000,600000,500000,400000,300000,200000 -q 700000,600000,500000,400000 -n 1 -x /home/Work/DATACOLLECT/ARMPM_datacollect/Workloads/parsec-3.0/parsec_benchlist_timestamp_cset.sh -t 500000000 -s /home/Work/DATACOLLECT/Results/XU3_1/cset_perfcpu_PARSEC_green_mSD_c8_multicluster_LITTLEseq/noevents/
