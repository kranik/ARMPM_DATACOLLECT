#!/bin/bash

train_benchmarks="train_benchmarks.data"
test_benchmarks="test_benchmarks.data"
full_data="model_input.data"
train_data="train_set.data"
test_data="test_set.data"
head_line=1
col_sep="\t"

train_set=$(awk '
					{
						if(NR == 1){
							result = $1
						}
						else{
							result = result "," $1
						}						
					}
					END{
						print result
					}' $train_benchmarks)
					
test_set=$(awk '
					{
						if(NR == 1){
							result = $1
						}
						else{
							result = result "," $1
						}						
					}
					END{
						print result
					}' $test_benchmarks)

echo -e "Randomised train set = $train_set\n"
echo -e "Randomised test set = $test_set"

echo -e "===================="

header=$(awk -v START=$head_line -v SEP=$col_sep '
											BEGIN{
												FS = SEP
											}{
												if (NR == START){
													print $0
													exit
												}
											}' $full_data)

echo -e $header > $train_data

awk -v START=$head_line -v SEP=$col_sep -v BENCH_SET=$train_set '
											BEGIN{
												FS = SEP
												len=split(BENCH_SET,BENCH,",")
											}{
												if (NR > START){
													for (i = 1; i <= len; i++){
                                    				if ($1 == BENCH[i]){
                                    						print $0
                                    						next
                                    					}
                                					}
												}
											}' $full_data >> $train_data

echo -e $header > $test_data
											
awk -v START=$head_line -v SEP=$col_sep -v BENCH_SET=$test_set '
											BEGIN{
												FS = SEP
												len=split(BENCH_SET,BENCH,",")
											}{
												if (NR > START){
													for (i = 1; i <= len; i++){
                                    				if ($1 == BENCH[i]){
                                    						print $0
                                    						next
                                    					}
                                					}
												}
											}' $full_data >> $test_data

											

