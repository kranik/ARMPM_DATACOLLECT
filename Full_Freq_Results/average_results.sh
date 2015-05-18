#!/bin/bash

#Programmable head line and column separator. By default I assume data start at line 3 (first line is descriptio, second is column heads and third is actual data). Columns separated by tab(s).
head_line=1
col_sep="\t"
time_convert=1000000000

echo -e "#Benchmark\tRuntime\tCPU Frequency(MHz)\tCPU Voltage(V)\tCPU Power(W)\tCPU Temperature(C)"
#\tCycles\tL1 DCache Access\tL1 ICache Access\tInstructions\tRAM Access\tCPU User(%)\tCPU Sys(%)\tCPU Idle(%)\tCPU I/O Wait(%)\tCPU IRQ(%)\tCPU Soft IQ(%)"

for line in $(awk -v START=$head_line -v SEP=$col_sep -v FREQ=0 'BEGIN{FS = SEP} {if (NR > START && FREQ != $3) {FREQ=$3; print NR}}' $1)
do
	freq=$(awk -v START=$line -v SEP=$col_sep -v FUNC=$func 'BEGIN{FS = SEP} {if (NR == START) {print $3; exit}}' $1)
	volt=$(awk -v START=$line -v SEP=$col_sep -v FUNC=$func 'BEGIN{FS = SEP} {if (NR == START) {print $4; exit}}' $1)
	
	#echo "Freq: $freq	Volt: $volt"
	
	
	for func_st in $(awk -v START=$head_line -v SEP=$col_sep -v FREQ=$freq -v FUNC=0 'BEGIN{FS = SEP} {if (NR > START && $3==FREQ && FUNC != $1) {FUNC=$1; print NR}}' $1)
   	do 
		func=$(awk -v START=$func_st -v SEP=$col_sep 'BEGIN{FS = SEP} {if (NR == START) {print $1; exit}}' $1)
		func_nd=$(awk -v START=$func_st -v SEP=$col_sep -v FUNC=$func -v FREQ=$freq 'BEGIN{FS = SEP;flag=0} {if (NR > START && ($1!=FUNC || $3!=FREQ)) {flag=1;print NR-1; exit}} END{if(!flag) print NR}' $1)
		
		power=$(awk -v FUNCST=$func_st -v FUNCND=$func_nd -v SEP=$col_sep -v COLUMN=5 'BEGIN{FS=SEP;total=0;count=0}{if(NR>=FUNCST&&NR<=FUNCND){total=total+$COLUMN;count=count+1}}END{print total/count}' $1)
        temperature=$(awk -v FUNCST=$func_st -v FUNCND=$func_nd -v SEP=$col_sep -v COLUMN=6 'BEGIN{FS=SEP;total=0;count=0}{if(NR>=FUNCST&&NR<=FUNCND){total=total+$COLUMN;count=count+1}}END{print total/count}' $1)
		runtime=$(echo "scale = 10; ($func_nd-$func_st)/$time_convert;" | bc)
		
        
:<< 'skip'
        cycles=$(awk -v FUNCST=$func_st -v FUNCND=$func_st -v SEP=$col_sep -v COLUMN=6 'BEGIN{FS=SEP;total=0;count=0}{if(NR>=FUNCST&&NR<=FUNCND){total=total+$COLUMN;count=count+1}}END{print total/count}' $1)
        l1dacc=$(awk -v FUNCST=$func_st -v FUNCND=$func_st -v SEP=$col_sep -v COLUMN=7 'BEGIN{FS=SEP;total=0;count=0}{if(NR>=FUNCST&&NR<=FUNCND){total=total+$COLUMN;count=count+1}}END{print total/count}' $1)
        l1iacc=$(awk -v FUNCST=$func_st -v FUNCND=$func_st -v SEP=$col_sep -v COLUMN=8 'BEGIN{FS=SEP;total=0;count=0}{if(NR>=FUNCST&&NR<=FUNCND){total=total+$COLUMN;count=count+1}}END{print total/count}' $1)
        instr=$(awk -v FUNCST=$func_st -v FUNCND=$func_st -v SEP=$col_sep -v COLUMN=9 'BEGIN{FS=SEP;total=0;count=0}{if(NR>=FUNCST&&NR<=FUNCND){total=total+$COLUMN;count=count+1}}END{print total/count}' $1)
        ramacc=$(awk -v FUNCST=$func_st -v FUNCND=$func_st -v SEP=$col_sep -v COLUMN=10 'BEGIN{FS=SEP;total=0;count=0}{if(NR>=FUNCST&&NR<=FUNCND){total=total+$COLUMN;count=count+1}}END{print total/count}' $1)
        cpuuser=$(awk -v FUNCST=$func_st -v FUNCND=$func_st -v SEP=$col_sep -v COLUMN=11 'BEGIN{FS=SEP;total=0;count=0}{if(NR>=FUNCST&&NR<=FUNCND){total=total+$COLUMN;count=count+1}}END{print total/count}' $1)
        cpusys=$(awk -v FUNCST=$func_st -v FUNCND=$func_st -v SEP=$col_sep -v COLUMN=12 'BEGIN{FS=SEP;total=0;count=0}{if(NR>=FUNCST&&NR<=FUNCND){total=total+$COLUMN;count=count+1}}END{print total/count}' $1)
        cpuidle=$(awk -v FUNCST=$func_st -v FUNCND=$func_st -v SEP=$col_sep -v COLUMN=13 'BEGIN{FS=SEP;total=0;count=0}{if(NR>=FUNCST&&NR<=FUNCND){total=total+$COLUMN;count=count+1}}END{print total/count}' $1)
        cpuiowait=$(awk -v FUNCST=$func_st -v FUNCND=$func_st -v SEP=$col_sep -v COLUMN=14 'BEGIN{FS=SEP;total=0;count=0}{if(NR>=FUNCST&&NR<=FUNCND){total=total+$COLUMN;count=count+1}}END{print total/count}' $1)
        cpuirq=$(awk -v FUNCST=$func_st -v FUNCND=$func_st -v SEP=$col_sep -v COLUMN=15 'BEGIN{FS=SEP;total=0;count=0}{if(NR>=FUNCST&&NR<=FUNCND){total=total+$COLUMN;count=count+1}}END{print total/count}' $1)
        cpusoftiq=$(awk -v FUNCST=$func_st -v FUNCND=$func_st -v SEP=$col_sep -v COLUMN=16 'BEGIN{FS=SEP;total=0;count=0}{if(NR>=FUNCST&&NR<=FUNCND){total=total+$COLUMN;count=count+1}}END{print total/count}' $1)	
skip
		echo -e "$func\t$runtime\t$freq\t$volt\t$power\t$temperature"
		#\t$cycles\t$l1dacc\t$l1iacc\t$instr\t$ramacc\t$cpuuser\t$cpusys\t$cpuidle\t$cpuiowait\t$cpuirq\t$cpusoftiq"
   done
done

