#!/bin/bash

#freq=([1]=2000000 1900000 1800000 1700000 1600000 1500000 1400000 1300000 1200000 1100000 1000000 900000 800000 700000 600000 500000 400000 300000 200000 100000)
#freq=([1]=100000 200000 300000 400000 500000 600000 700000 800000 900000 1000000 1100000 1200000 1300000 1400000 1500000 1600000 1700000 1800000 1900000 2000000)
freq=([1]=1400000 1300000 1200000 1100000 1000000 900000 800000 700000 600000 500000 400000 300000 200000 100000)
#freq=([1]=100000 200000 300000 400000 500000 600000 700000 800000 900000 1000000 1100000 1200000 1300000 1400000)

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
 
#: <<'SKIP1'
#for i in `seq 1 19`
for i in `seq 1 13`
do

	./freq_extract.sh Full_Freq_Results/LITTLE_power_big_events_averaged.data	${freq[$i]}
	./split_data.sh 
	echo ${freq[$i]}
	mv "train_set.data" "train_set_full.data"
	./freq_extract.sh Full_Freq_Results/LITTLE_power_big_events_averaged.data ${freq[$i]}
	./split_data.sh
	mv "train_set_full.data" "train_set.data"

	octave --silent --eval "load_build_model(${freq[$i]},${freq[$i+1]})" 2> /dev/null 1>> "octave_model.temp"
done
#SKIP1

#Replace dots with commas for GOGOLE docs

sed 's/\./,/g' "octave_model.temp" > "model_replaced.temp"

#: <<'SKIP2'

echo -e "===================="
echo -e "Measured Power Range"
awk '{
		if ($1=="Measured" && $2=="Power"){ 
		print $5 }
	}' "model_replaced.temp"
echo -e "===================="
echo -e "Predicted Power Range"
awk '{
		if ($1=="Predicted" && $2=="Power"){ 
		print $5 }
	}' "model_replaced.temp"
	
echo -e "===================="	
echo -e "===================="
echo -e "Average Power"
awk '{
		if ($1=="Average" && $2=="Power"){ 
		print $4 }
	}' "model_replaced.temp"	
echo -e "===================="
echo -e "Average Temp."
awk '{
		if ($1=="Average" && $2=="Temperature"){ 
		print $4 }
	}' "model_replaced.temp"	
echo -e "===================="
echo -e "===================="
echo -e "Average Error"	
awk '{
		if ($1=="Average" && $2=="Error"){ 
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

	
rm "octave_model.temp" "model_replaced.temp"

