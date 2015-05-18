
#!/bin/bash

#freq=([1]=2000000 1900000 1800000 1700000 1600000 1500000 1400000 1300000 1200000 1100000 1000000 900000 800000 700000 600000 500000 400000 300000 200000 100000)
freq=([1]=1400000 1300000 1200000 1100000 1000000 900000 800000 700000 600000 500000 400000 300000 200000 100000)

echo -e "===================="
echo -e "Coefficients"

#for i in `seq 1 19`
for i in `seq 1 13`
do

	./freq_extract.sh Full_Freq_Results/LITTLE_full.data	${freq[$i]}
	./split_data.sh > /dev/null

	octave --silent --eval "load_build_model(${freq[$i]},${freq[$i+1]})" 2> /dev/null 1> "octave_model.temp"
	
	awk -v FREQ=${freq[$i]} '{
		if ($1=="Coeff:"){ 
		print FREQ"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$14"\t"$15"\t"$16}
	}' "octave_model.temp" | sed 's/\./,/g'

done 

echo -e "===================="

rm "octave_model.temp"


