#!/bin/bash

for i in `seq 1 5`;
do
	./octave_prepare.sh "TC2/big/Run_$i/benchmarks_data_big.dat" "TC2/big/Run_$i/TC2_big_octave_$i.dat" 0
	./octave_prepare.sh "TC2/LITTLE/Run_$i/benchmarks_data_LITTLE.dat" "TC2/LITTLE/Run_$i/TC2_LITTLE_octave_$i.dat" 0
	
	./octave_prepare.sh "ODROID/Eric/Run_$i/benchmarks_data_big.dat" "ODROID/Eric/Run_$i/ODROID_big_octave_$i.dat" 1
	./octave_prepare.sh "ODROID/Eric/Run_$i/sensors_data_big.dat" "ODROID/Eric/Run_$i/ODROID_big_octave_sensors_$i.dat" 2
	
	./octave_prepare.sh "ODROID/Eric/Run_$i/benchmarks_data_LITTLE.dat" "ODROID/Eric/Run_$i/ODROID_LITTLE_octave_$i.dat" 1
	./octave_prepare.sh "ODROID/Eric/Run_$i/sensors_data_LITTLE.dat" "ODROID/Eric/Run_$i/ODROID_LITTLE_octave_sensors_$i.dat" 2
	
done

