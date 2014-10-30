#!/bin/bash
#Simple program to read information from the onboard sensors with a delay as an input.

if (( $# != 1 )); then
  echo "This program requires a wait input for the sensors in usecs." >&2
  exit 1
fi

#Check if ntered sleep time is smaller than the permitted minimum update_period of the sensors
if (( $1 < `awk '{print $1}' /sys/bus/i2c/drivers/INA231/4-0040/update_period` )); then
  echo "Minimum update time for sensors is `awk '{print $1}' /sys/bus/i2c/drivers/INA231/4-0040/update_period`. User input $1 is smaller." >&2
  exit 1
fi

#This is to convert the user input of usecs to secs, required ofr the sleep call
time_convert=1000000000

#Information header
echo -e "#Timestamp\tCPU Governor\tCPU(0) Frequency(Mhz)\tCPU(0) Temperature(C)\tA7 Voltage(V)\tA7 Power(W)\tA15 Voltage(V)\tA15 Power(W)\tRAM Voltage(V)\tRAM Power(W)\tGPU Frequency(Mhz)\tGPU Voltage(V)\tGPU Power(W)"

# Main infinite loop
while true; do

# ----------- CPU DATA ----------- #

# CPU Governor
CPU_GOVERNOR=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`

# Node Configuration for CPU Frequency
CPU0_FREQ=$((`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq`/1000))
#CPU1_FREQ=$((`cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_cur_freq`/1000))
#CPU2_FREQ=$((`cat /sys/devices/system/cpu/cpu2/cpufreq/scaling_cur_freq`/1000))
#CPU3_FREQ=$((`cat /sys/devices/system/cpu/cpu3/cpufreq/scaling_cur_freq`/1000))

# Temperature
TMU_FILE=`cat /sys/devices/platform/exynos5-tmu/temp`
CPU0_TEMP=`echo $TMU_FILE | awk '{printf $1}'`

# A7 Nodes
A7_V=`cat /sys/bus/i2c/drivers/INA231/4-0045/sensor_V`
A7_W=`cat /sys/bus/i2c/drivers/INA231/4-0045/sensor_W`

# A15 Nodes
A15_V=`cat /sys/bus/i2c/drivers/INA231/4-0040/sensor_V`
A15_W=`cat /sys/bus/i2c/drivers/INA231/4-0040/sensor_W`

# --------- MEMORY DATA ----------- # "
RAM_V=`cat /sys/bus/i2c/drivers/INA231/4-0041/sensor_V`
RAM_W=`cat /sys/bus/i2c/drivers/INA231/4-0041/sensor_W`

# ---------- GPU DATA ------------- # 
GPU_V=`cat /sys/bus/i2c/drivers/INA231/4-0044/sensor_V`
GPU_W=`cat /sys/bus/i2c/drivers/INA231/4-0044/sensor_W`
GPU_FREQ=`cat /sys/module/pvrsrvkm/parameters/sgx_gpu_clk`

# ---------- Present Results ----------- #

#echo -e "$(date +'%s%N')\t$CPU_GOVERNOR\t$CPU0_FREQ\t$CPU1_FREQ\t$CPU2_FREQ\t$CPU3_FREQ\t$A7_V\t$A7_W\t$A15_v\t$A15_W\t$RAM_V\t$RAM_W\t$GPU_FREQ\t$GPU_V\t$GPU_W"
echo -e "$(date +'%s%N')\t$CPU_GOVERNOR\t$CPU0_FREQ\t$CPU0_TEMP\t$A7_V\t$A7_W\t$A15_V\t$A15_W\t$RAM_V\t$RAM_W\t$GPU_FREQ\t$GPU_V\t$GPU_W"
#permitted sleep time is set by /sys/bus/i2c/drivers/INA231/4-004X/update_period but I allow user to input
sleep `echo "scale = 10; $1/$time_convert;" | bc`
done
