#!/bin/bash
#This script sets the enironment

if [ "$#" != 1 ]; then
	echo "This program requires one input. 1 for environment set and 0 for environment restore." >&2
	exit 1
fi

if (( "$1" )); then
        echo "You have chosen to set the environment. This means the mission is in the final stages of preparation. Glorious Day awaits us!"
	echo "Sanity check CPUs:"
	grep 'proc' /proc/cpuinfo
	grep 'CPU part' /proc/cpuinfo
	echo "Hotplug all but CPU0"
	for i in `seq 1 7`
	do
		echo 0 > "/sys/devices/system/cpu/cpu$i/online"
	done
	echo "Hotplug sanity check CPUs:"
	grep 'proc' /proc/cpuinfo
	grep 'CPU part' /proc/cpuinfo
	echo "Select userspace governor."
	echo "Final sanity check."
	cpufreq-info
	echo "Environment set. Press any key to begin exterminating the human race..."
else
	echo "You have chosen to restore the environment to its initial state. This indicates the mission was a success and the humans are now dead. Glorious Day is upon us!"
	echo "Sanity check enabled CPUs:"
	grep 'proc' /proc/cpuinfo
	grep 'CPU part' /proc/cpuinfo
	echo "Enable all CPUs"
        for i in `seq 1 7`
        do      
		echo 1 > "/sys/devices/system/cpu/cpu$i/online"
        done
	echo "Check all CPUs are enabled"
	grep 'proc' /proc/cpuinfo
	grep 'CPU part' /proc/cpuinfo
	echo "Select ondemand governor for both clusters."
	echo "Final sanity check."
	cpufreq-info
	echo "Environment restore. This is just an ordinary system. Nothing suspicios going on. I swear."
fi
