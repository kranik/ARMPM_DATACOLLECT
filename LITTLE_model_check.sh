#!/bin/bash

freq=([1]=100000 200000 300000 400000 500000 600000 700000 800000 900000 1000000 1100000 1200000 1300000 1400000)

for i in `seq 1 13`
do

echo -e "Checking for ${freq[$i+1]}"
./freq_extract.sh Full_Freq_Results/LITTLE_full.data ${freq[$i+1]}
./split_data.sh > /dev/null
echo -e "Train"
awk -v START=1 -v SEP="\t" 'BEGIN{FS = SEP}{if (NR > START && $13!=0 ) print $13}' train_set.data
echo -e "Test"
awk -v START=1 -v SEP="\t" 'BEGIN{FS = SEP}{if (NR > START && $13!=0 ) print $13}' test_set.data
done


