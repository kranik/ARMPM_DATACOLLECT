#!/bin/bash

#Events list best PARSEC

#1 Core
#./MC_XU3.sh -b 1 -f 2000000,1900000,1800000,1700000,1600000,1500000,1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -n 5 -x /home/Work/ARMPM/ARMPM_datacollect/Workloads/mock_parsec_timestamp_cset.sh -e /home/Work/ARMPM/ARMPM_datacollect/ODROID_XU3/events_lists_all/big/events_list_big_best.data -t 500000000 -s /home/Work/ARMPM/Results/xu3_1/cset_perfcpu_PARSEC_eMMC_bestevents_c1_test/big/

#./MC_XU3.sh -L 1 -f 1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -n 2 -x /home/Work/ARMPM/ARMPM_datacollect/Workloads/mock_parsec_timestamp_cset.sh -e /home/Work/ARMPM/ARMPM_datacollect/ODROID_XU3/events_lists_all/LITTLE/events_list_LITTLE_best.data -t 500000000 -s /home/Work/ARMPM/Results/xu3_1/cset_perfcpu_PARSEC_eMMC_bestevents_c1_test/LITTLE/

./MC_XU3.sh -b 1 -f 2000000 -n 1 -x /home/Work/ARMPM/ARMPM_datacollect/Workloads/parsec-3.0/parsec_benchlist_timestamp_cset.sh -e /home/Work/ARMPM/ARMPM_datacollect/ODROID_XU3/events_lists_all/big/events_list_big_best.data -t 500000000 -s /home/Work/ARMPM/Results/xu3_1/cset_perfcpu_PARSEC_eMMC_bestevents_c1_greenbench_test/big/

./MC_XU3.sh -L 1 -f 1400000 -n 1 -x /home/Work/ARMPM/ARMPM_datacollect/Workloads/parsec-3.0/parsec_benchlist_timestamp_cset.sh -e /home/Work/ARMPM/ARMPM_datacollect/ODROID_XU3/events_lists_all/LITTLE/events_list_LITTLE_best.data -t 500000000 -s /home/Work/ARMPM/Results/xu3_1/cset_perfcpu_PARSEC_eMMC_bestevents_c1_greenbench_test/LITTLE/

#2 Cores
#./MC_XU3.sh -b 2 -f 2000000,1900000,1800000,1700000,1600000,1500000,1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -n 2 -x /home/Work/ARMPM/ARMPM_datacollect/Workloads/mock_parsec_timestamp_cset.sh -e /home/Work/ARMPM/ARMPM_datacollect/ODROID_XU3/events_lists_all/big/events_list_big_best.data -t 500000000 -s /home/Work/ARMPM/Results/xu3_1/cset_perfcpu_PARSEC_eMMC_bestevents_c2_test/big/

#./MC_XU3.sh -L 2 -f 1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -n 2 -x /home/Work/ARMPM/ARMPM_datacollect/Workloads/mock_parsec_timestamp_cset.sh -e /home/Work/ARMPM/ARMPM_datacollect/ODROID_XU3/events_lists_all/LITTLE/events_list_LITTLE_best.data -t 500000000 -s /home/Work/ARMPM/Results/xu3_1/cset_perfcpu_PARSEC_eMMC_bestevents_c2_test/LITTLE/

#3 Cores
#./MC_XU3.sh -b 3 -f 2000000,1900000,1800000,1700000,1600000,1500000,1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -n 2 -x /home/Work/ARMPM/ARMPM_datacollect/Workloads/mock_parsec_timestamp_cset.sh -e /home/Work/ARMPM/ARMPM_datacollect/ODROID_XU3/events_lists_all/big/events_list_big_best.data -t 500000000 -s /home/Work/ARMPM/Results/xu3_1/cset_perfcpu_PARSEC_eMMC_bestevents_c3_test/big/

#./MC_XU3.sh -L 3 -f 1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -n 2 -x /home/Work/ARMPM/ARMPM_datacollect/Workloads/mock_parsec_timestamp_cset.sh -e /home/Work/ARMPM/ARMPM_datacollect/ODROID_XU3/events_lists_all/LITTLE/events_list_LITTLE_best.data -t 500000000 -s /home/Work/ARMPM/Results/xu3_1/cset_perfcpu_PARSEC_eMMC_bestevents_c3_test/LITTLE/

#4 Cores
./MC_XU3.sh -b 4 -f 2000000 -n 1 -x /home/Work/ARMPM/ARMPM_datacollect/Workloads/parsec-3.0/parsec_benchlist_timestamp_cset.sh -e /home/Work/ARMPM/ARMPM_datacollect/ODROID_XU3/events_lists_all/big/events_list_big_best.data -t 500000000 -s /home/Work/ARMPM/Results/xu3_1/cset_perfcpu_PARSEC_eMMC_bestevents_c4_greenbench_test/big/

./MC_XU3.sh -L 4 -f 1400000 -n 1 -x /home/Work/ARMPM/ARMPM_datacollect/Workloads/parsec-3.0/parsec_benchlist_timestamp_cset.sh -e /home/Work/ARMPM/ARMPM_datacollect/ODROID_XU3/events_lists_all/LITTLE/events_list_LITTLE_best.data -t 500000000 -s /home/Work/ARMPM/Results/xu3_1/cset_perfcpu_PARSEC_eMMC_bestevents_c4_greenbench_test/LITTLE/

