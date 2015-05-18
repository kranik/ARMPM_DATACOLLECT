#!/bin/bash

#Programmable head line and column separator. By default I assume data start at line 3 (first line is descriptio, second is column heads and third is actual data). Columns separated by tab(s).
head_line=1
col_sep="\t"

echo -e "#Benchmark	CPU Power(W)	CPU Voltage(V)	CPU Frequency(MHz)	CPU Temperature(C)	Cycles	L1 DCache Access	L1 ICache Access	Instructions	RAM Access	CPU User(%)	CPU Sys(%)	CPU Idle(%)	CPU I/O Wait(%)	CPU IRQ(%)	CPU Soft IQ(%)"

freq=([1]=1400000 1300000 1200000 1100000 1000000 900000 800000 700000 600000 500000 400000 300000 200000 100000)

for i in `seq 1 13`
do
	freq_st_1=$(awk -v START=$head_line -v SEP=$col_sep -v FREQ=${freq[$i]} 'BEGIN{FS = SEP} {if (NR > START && $4==FREQ){print NR;exit}}' $1)
	freq_st_2=$(awk -v START=$head_line -v SEP=$col_sep -v FREQ=${freq[$i]} 'BEGIN{FS = SEP} {if (NR > START && $4==FREQ){print NR;exit}}' $2)
	
	for func_st in $(awk -v START=$head_line -v SEP=$col_sep -v FREQ=${freq[$i]} -v FUNC=0 -v FREQST=$freq_st_1 'BEGIN{FS = SEP} {if (NR > START && $4==FREQ && FUNC != $1) {FUNC=$1;print NR-FREQST}}' $1)
	do
		
		func=$(awk -v FREQST=$freq_st_1 -v FUNCST=$func_st -v SEP=$col_sep -v COLUMN=1 'BEGIN{FS=SEP;total=0;count=0}{if(NR==FREQST+FUNCST){print $COLUMN;exit}}' $1)
		power=$(awk -v FREQST=$freq_st_1 -v FUNCST=$func_st -v SEP=$col_sep -v COLUMN=2 'BEGIN{FS=SEP;total=0;count=0}{if(NR==FREQST+FUNCST){print $COLUMN;exit}}' $1)
		voltage=$(awk -v FREQST=$freq_st_2 -v FUNCST=$func_st -v SEP=$col_sep -v COLUMN=3 'BEGIN{FS=SEP;total=0;count=0}{if(NR==FREQST+FUNCST){print $COLUMN;exit}}' $2)
        temperature=$(awk -v FREQST=$freq_st_2 -v FUNCST=$func_st -v SEP=$col_sep -v COLUMN=5 'BEGIN{FS=SEP;total=0;count=0}{if(NR==FREQST+FUNCST){print $COLUMN;exit}}' $2)
        cycles=$(awk -v FREQST=$freq_st_2 -v FUNCST=$func_st -v SEP=$col_sep -v COLUMN=6 'BEGIN{FS=SEP;total=0;count=0}{if(NR==FREQST+FUNCST){print $COLUMN;exit}}' $2)
        l1dacc=$(awk -v FREQST=$freq_st_2 -v FUNCST=$func_st -v SEP=$col_sep -v COLUMN=7 'BEGIN{FS=SEP;total=0;count=0}{if(NR==FREQST+FUNCST){print $COLUMN;exit}}' $2)
        l1iacc=$(awk -v FREQST=$freq_st_2 -v FUNCST=$func_st -v SEP=$col_sep -v COLUMN=8 'BEGIN{FS=SEP;total=0;count=0}{if(NR==FREQST+FUNCST){print $COLUMN;exit}}' $2)
        instr=$(awk -v FREQST=$freq_st_2 -v FUNCST=$func_st -v SEP=$col_sep -v COLUMN=9 'BEGIN{FS=SEP;total=0;count=0}{if(NR==FREQST+FUNCST){print $COLUMN;exit}}' $2)
        ramacc=$(awk -v FREQST=$freq_st_2 -v FUNCST=$func_st -v SEP=$col_sep -v COLUMN=10 'BEGIN{FS=SEP;total=0;count=0}{if(NR==FREQST+FUNCST){print $COLUMN;exit}}' $2)
        cpuuser=$(awk -v FREQST=$freq_st_2 -v FUNCST=$func_st -v SEP=$col_sep -v COLUMN=11 'BEGIN{FS=SEP;total=0;count=0}{if(NR==FREQST+FUNCST){print $COLUMN;exit}}' $2)
        cpusys=$(awk -v FREQST=$freq_st_2 -v FUNCST=$func_st -v SEP=$col_sep -v COLUMN=12 'BEGIN{FS=SEP;total=0;count=0}{if(NR==FREQST+FUNCST){print $COLUMN;exit}}' $2)
        cpuidle=$(awk -v FREQST=$freq_st_2 -v FUNCST=$func_st -v SEP=$col_sep -v COLUMN=13 'BEGIN{FS=SEP;total=0;count=0}{if(NR==FREQST+FUNCST){print $COLUMN;exit}}' $2)
        cpuiowait=$(awk -v FREQST=$freq_st_2 -v FUNCST=$func_st -v SEP=$col_sep -v COLUMN=14 'BEGIN{FS=SEP;total=0;count=0}{if(NR==FREQST+FUNCST){print $COLUMN;exit}}' $2)
        cpuirq=$(awk -v FREQST=$freq_st_2 -v FUNCST=$func_st -v SEP=$col_sep -v COLUMN=15 'BEGIN{FS=SEP;total=0;count=0}{if(NR==FREQST+FUNCST){print $COLUMN;exit}}' $2)
        cpusoftiq=$(awk -v FREQST=$freq_st_2 -v FUNCST=$func_st -v SEP=$col_sep -v COLUMN=16 'BEGIN{FS=SEP;total=0;count=0}{if(NR==FREQST+FUNCST){print $COLUMN;exit}}' $2)
		
		echo -e "$func\t$power\t$voltage\t${freq[$i]}\t$temperature\t$cycles\t$l1dacc\t$l1iacc\t$instr\t$ramacc\t$cpuuser\t$cpusys\t$cpuidle\t$cpuiowait\t$cpuirq\t$cpusoftiq"    
    done
done

