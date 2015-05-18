#!/bin/bash

#freq=([1]=2000000 1900000 1800000 1700000 1600000 1500000 1400000 1300000 1200000 1100000 1000000 900000 800000 700000 600000 500000 400000 300000 200000 100000)
#freq=([1]=100000 200000 300000 400000 500000 600000 700000 800000 900000 1000000 1100000 1200000 1300000 1400000 1500000 1600000 1700000 1800000 1900000 2000000)
freq=([1]=1400000 1300000 1200000 1100000 1000000 900000 800000 700000 600000 500000 400000 300000 200000 100000)
#freq=([1]=100000 200000 300000 400000 500000 600000 700000 800000 900000 1000000 1100000 1200000 1300000 1400000)

#cp Full_Freq_Results/big_cpustress_full.data "power_high.data"
#cp Full_Freq_Results/big_cpusleep_full.data "power_low.data"
 
cp Full_Freq_Results/LITTLE_cpustress_full.data "power_high.data"
cp Full_Freq_Results/LITTLE_cpusleep_full.data "power_low.data"

#: <<'SKIP1'
#for i in `seq 1 19`
for i in `seq 1 13`
do
	echo -e "$i"
	octave --silent --eval "full_power_range(${freq[$i]},${freq[$i+1]})" 2> /dev/null 1>> "octave_model.temp"
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
	
rm "octave_model.temp" "model_replaced.temp"

