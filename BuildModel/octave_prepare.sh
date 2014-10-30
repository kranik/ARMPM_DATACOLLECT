#!/bin/bash

#Programmable head line and column separator. By default I assume data start at line 3 (first line is descriptio, second is column heads and third is actual data). Columns separated by tab(s).
head_line=2
col_sep="\t"


#TC2 Configuration
((!$3)) && awk -v START=$head_line -v SEP=$col_sep 'BEGIN{FS = SEP} {if (NR > START && $1 != "consumer_mad") print $4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12 }' $1 > $2 

#ODROID Configuration
#Benchmarks
(($3 == 1)) && awk -v START=$head_line -v SEP=$col_sep 'BEGIN{FS = SEP} {if (NR > START && $1 != "consumer_mad") print $3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12 }' $1 > $2
#Sensors
(($3 == 2)) && awk -v START=$head_line -v SEP=$col_sep 'BEGIN{FS = SEP} {if (NR > START) print $1"\t"$7"\t"$8"\t"$9 }' $1 > $2

