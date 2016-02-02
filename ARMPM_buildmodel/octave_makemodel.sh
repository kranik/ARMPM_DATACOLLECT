#!/bin/bash

freq=([1]=2000000 1900000 1800000 1700000 1600000 1500000 1400000 1300000 1200000 1100000 1000000 900000 800000 700000 600000 500000 400000 300000 200000 100000)
#freq=([1]=100000 200000 300000 400000 500000 600000 700000 800000 900000 1000000 1100000 1200000 1300000 1400000 1500000 1600000 1700000 1800000 1900000 2000000)
#freq=([1]=1400000 1300000 1200000 1100000 1000000 900000 800000 700000 600000 500000 400000 300000 200000 100000)
#freq=([1]=100000 200000 300000 400000 500000 600000 700000 800000 900000 1000000 1100000 1200000 1300000 1400000)

#freq=([1]=2000000 1900000 1100000 1000000 200000 100000)
#freq=([1]=1400000 1300000 800000 700000 200000 100000)

#cp Full_Freq_Results/LITTLE_full.data "model_input.data"
#./split_data.sh
#mv "train_set.data" "train_set_full.data"
#cp Full_Freq_Results/big_full.data "model_input.data"
#./split_data.sh

#mv "train_set_full.data" "train_set.data"

#./freq_extract.sh Full_Freq_Results/LITTLE_full.data	1400000
#./split_data.sh 
#mv "train_set.data" "train_set_full.data"
#./freq_extract.sh Full_Freq_Results/big_full.data 2000000
#./split_data.sh
#mv "train_set_full.data" "train_set.data"

#octave --silent --eval "load_build_model(2000000,100000)" 2> /dev/null 1>> "octave_model.temp"
count=0 
#: <<'SKIP1'
#for i in `seq 1 2 5` #19`
#for i in `seq 1 13`
for i in `seq 1 19`
do
	echo $((${freq[$i]}/1000))
	./freq_extract.sh $1	$((${freq[$i]}/1000))
	cp "model_input.data" "test_set.data"
	count=$(($count+1))
#	mv "train_set.data" "train_set_full.data"
#	./freq_extract.sh Full_Freq_Results/LITTLE_power_big_events_averaged.data ${freq[$i]}
#	./split_data.sh
#	mv "train_set_full.data" "train_set.data"

	octave --silent --eval "load_build_model($((${freq[$i]}/1000)),$((${freq[$i+1]}/1000)))" 2> /dev/null 1>> "octave_model.temp"
done
#SKIP1

#Replace dots with commas for GOGOLE docs

#sed 's/\./,/g' "octave_model.temp" > "model_replaced.temp"
cp "octave_model.temp" "model_replaced.temp"

#: <<'SKIP2'
echo -e "===================="
echo -e "Avg. Totall Runtime"
IFS="," read -a avg_run <<< "$((awk '{if ($1=="Avg." && $3=="Runtime"){ print $5 }}' "model_replaced.temp") | tr "\n" "," | head -c -1)" 
echo -e "===================="
echo -e "Measured Power Range"
IFS="," read -a pow_range <<< "$((awk '{if ($1=="Measured" && $2=="Power"){ print $5 }}' "model_replaced.temp") | tr "\n" "," | head -c -1)" 
echo -e "===================="
echo -e "Avg. Power"
IFS="," read -a avg_pow <<< "$((awk '{if ($1=="Avg." && $2=="Power"){ print $4 }}' "model_replaced.temp") | tr "\n" "," | head -c -1)" 
echo -e "===================="
echo -e "Avg. Temp"
IFS="," read -a avg_t <<< "$((awk '{if ($1=="Avg." && $2=="Temperature"){ print $4 }}' "model_replaced.temp") | tr "\n" "," | head -c -1)" 
echo -e "===================="
echo -e "Avg. Curr."
IFS="," read -a avg_c <<< "$((awk '{if ($1=="Avg." && $2=="Current"){ print $4 }}' "model_replaced.temp") | tr "\n" "," | head -c -1)" 
echo -e "===================="
echo -e "Avg. Volt."
IFS="," read -a avg_v <<< "$((awk '{if ($1=="Avg." && $2=="Voltage"){ print $4 }}' "model_replaced.temp") | tr "\n" "," | head -c -1)" 
echo -e "===================="
echo -e "Avg. Totall Ev1."
IFS="," read -a avg_ev1 <<< "$((awk '{if ($1=="Avg." && $3=="Ev1"){ print $5 }}' "model_replaced.temp") | tr "\n" "," | head -c -1)" 
echo -e "===================="
echo -e "Avg. Totall Ev2."
IFS="," read -a avg_ev2 <<< "$((awk '{if ($1=="Avg." && $3=="Ev2"){ print $5 }}' "model_replaced.temp") | tr "\n" "," | head -c -1)" 
echo -e "===================="
echo -e "Avg. Totall Ev3."
IFS="," read -a avg_ev3 <<< "$((awk '{if ($1=="Avg." && $3=="Ev3"){ print $5 }}' "model_replaced.temp") | tr "\n" "," | head -c -1)" 
echo -e "===================="
echo -e "Avg. Totall Ev4."
IFS="," read -a avg_ev4 <<< "$((awk '{if ($1=="Avg." && $3=="Ev4"){ print $5 }}' "model_replaced.temp") | tr "\n" "," | head -c -1)" 
echo -e "===================="
echo -e "Avg. Totall Ev5."
IFS="," read -a avg_ev5 <<< "$((awk '{if ($1=="Avg." && $3=="Ev5"){ print $5 }}' "model_replaced.temp") | tr "\n" "," | head -c -1)" 
echo -e "===================="
:<<'skiperr'
echo -e "===================="
echo -e "Avg. Error"	
awk '{
		if ($1=="Avg." && $2=="Error"){ 
		print $4 }
	}' "model_replaced.temp"
echo -e "===================="
echo -e "Std.Dev. Error"
awk '{
		if ($1=="Standart" && $2=="Deviation"){ 
		print $5 }
	}' "model_replaced.temp"
echo -e "===================="
echo -e "Norm. RMS Error"
awk '{
		if ($1=="Normalised"){ 
		print $5 }
	}' "model_replaced.temp"

skiperr

#SKIP2

: <<'SKIP3'
#SKIP3

echo -e "===================="
awk 'BEGIN{
		time = 0;		
	}{
		if ($1=="Frequency:"){ 
		print time;
		time = time + 0.5; 
		}
	}' "model_replaced.temp"

echo -e "===================="


awk '{
		if ($1=="Measured:"){ 
		print $2 }
	}' "model_replaced.temp"

#SKIP3
	
echo -e "===================="
awk '{
		if ($1=="Predicted:"){ 
		print $2 }
	}' "model_replaced.temp"

SKIP3
echo -e "===================="
echo -e "Avg. Totall Runtime\tMeasured Power Range\tAvg. Power\tAvg. Temp.\tAvg. Curr.\tAvg. Volt.\tAvg. Totall Ev1\tAvg. Totall Ev2\tAvg. Totall Ev3\tAvg. Totall Ev4\tAvg. Totall Ev5"
echo -e "===================="
for i in `seq 0 $(($count-1))`
do
echo -e "${avg_run[$i]}\t${pow_range[$i]}\t${avg_pow[$i]}\t${avg_t[$i]}\t${avg_c[$i]}\t${avg_v[$i]}\t${avg_ev1[$i]}\t${avg_ev2[$i]}\t${avg_ev3[$i]}\t${avg_ev4[$i]}\t${avg_ev5[$i]}"
done	
rm "octave_model.temp" "model_replaced.temp"

