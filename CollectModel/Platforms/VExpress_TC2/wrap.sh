#!/bin/bash
#Top level wrapper that calls MC.sh with different cofigurations
#KrNikov 2014

echo "Wrap starting: 1xA15, 1xA7"
date +"%A %H:%M:%S"
./MC_TC2.sh -b 1200000 -L 175000 -s ../../../Results/TC2/idle_energy -t ../../Benchmarks/sleep_monitor_noevents.sh -n 1
date +"%A %H:%M:%S"
echo "Wrap end!"
