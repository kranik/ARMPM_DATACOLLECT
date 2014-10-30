#!/bin/bash
#Top level wrapper that calls MC.sh with different cofigurations
#KrNikov 2014

echo "Wrap starting: 3xO3, 3xA7, 3xA15"
date +"%A %H:%M:%S"
./MC.sh -b 1600000,1500000,1400000,1300000,1200000,1100000,1000000,900000,800000 -L 600000,550000,500000,450000,400000,350000,300000,250000 -p -s Results/Test/O3 -t Benchmarks/cBench/O3/all_run__1_dataset_timestamp.sh -n 1
date +"%A %H:%M:%S"
./MC.sh -b 1600000,1500000,1400000,1300000,1200000,1100000,1000000,900000,800000 -L 600000,550000,500000,450000,400000,350000,300000,250000 -p -s Results/Test/A7 -t Benchmarks/cBench/A7/all_run__1_dataset_timestamp.sh -n 1
date +"%A %H:%M:%S"
./MC.sh -b 1600000,1500000,1400000,1300000,1200000,1100000,1000000,900000,800000 -L 600000,550000,500000,450000,400000,350000,300000,250000 -p -s Results/Test/A15 -t Benchmarks/cBench/A15/all_run__1_dataset_timestamp.sh -n 1
date +"%A %H:%M:%S"
echo "Wrap end!"
