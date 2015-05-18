#!/bin/bash

bench_list="all_benchmarks.data"
train_benchmarks="train_benchmarks.data"
test_benchmarks="test_benchmarks.data"

#get uniques benchmark list from file

benchmarks=$(awk '
					{
						if(NR == 1){
							result = $1
						}
						else{
							result = result "\n" $1
						}						
					}
					END{
						print result
					}' $bench_list)

echo -e "All benchmarks = $benchmarks"

echo -e "===================="

benchmarks=$(echo "$(echo $benchmarks | sed 's/ /\\n/g')")
random_bench=$(echo -e $benchmarks | sort -R)
num_bench=$(echo -e "$benchmarks" | wc -l)
split=$(echo "scale = 0; $num_bench/2;" | bc )
random_bench=$(echo "$(echo $random_bench | sed 's/ /\\n/g')")
train_set=$(echo -e $random_bench | head -n $split)
test_set=$(echo -e $random_bench | tail -n $(echo "scale = 0; $num_bench-$split;" | bc ))

train_set=$(echo "$(echo $train_set | sed 's/ /\\n/g')")
test_set=$(echo "$(echo $test_set | sed 's/ /\\n/g')")

echo -e "Randomised train set = $train_set" 
echo -e $train_set > $train_benchmarks
echo -e "===================="
echo -e "Randomised test set = $test_set"
echo -e $test_set > $test_benchmarks
