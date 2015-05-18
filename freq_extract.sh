#!/bin/bash

if [ "$#" -eq 0 ]; then
  echo "This program requires input all frequencies file and the freqeuncy extracted" >&2
  exit 1
fi


full_data="model_input.data"
head_line=1
col_sep="\t"

header=$(awk -v START=$head_line -v SEP=$col_sep '
											BEGIN{
												FS = SEP
											}{
												if (NR == START){
													print $0
													exit
												}
											}' $1)

echo -e $header > $full_data

awk -v START=$head_line -v SEP=$col_sep -v FREQ=$2 '
											BEGIN{
												FS = SEP
											}{
												if (NR > START && $4 == FREQ){
                            						print $0
		                        				}
											}' $1 >> $full_data
