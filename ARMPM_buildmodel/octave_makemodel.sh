#!/bin/bash

if [[ "$#" -eq 0 ]]; then
	echo "This program requires inputs. Type -h for help." >&2
	exit 1
fi

NUM_MODES=3

benchmarkSplit () {
	#extract uniques benchmark list from file
	local RANDOM_BENCHMARK_LIST=$(echo $(awk -v SEP='\t' -v START=$RESULTS_START_LINE -v BENCH=0 'BEGIN{FS=SEP}{ if(NR > START && $2 != BENCH){print ($2);BENCH=$2} }' < $RESULTS_FILE | sort -u | sort -R ) | sed 's/ /\\n/g' )
	local NUM_BENCH=$(echo -e "$RANDOM_BENCHMARK_LIST" | wc -l)
	local MIDPOINT=$(echo "scale = 0; $NUM_BENCH/2;" | bc )
	
	#I need to use this temp to extract the string I have no ida why just plain substitution in the IFT line does not work
	local temp=$(echo $(echo -e $RANDOM_BENCHMARK_LIST | head -n $MIDPOINT | sort -d ) | sed 's/ /,/g')
	IFS="," read -a TRAIN_SET <<< "$temp"
	local temp=$(echo $(echo -e $RANDOM_BENCHMARK_LIST | tail -n $(echo "scale = 0; $NUM_BENCH-$MIDPOINT;" | bc ) | sort -d ) | sed 's/ /,/g')
	IFS="," read -a TEST_SET <<< "$temp"
}

#requires getops, but this should not be an issue since ints built in bash
while getopts ":r:f:b:s:m:c:e:n:hac" opt;
do
	case $opt in
		h)
			echo "Available flags and options:" >&1
			echo "-r [FILEPATH] -> Specify the concatednated results file to be analyzed." >&1
			echo "-f [FREQENCY LIST][MHz] -> Specify the frequencies to be analyzed, separated by commas." >&1
			echo "-b [FILEPATH] -> Specify the benchmark split file for the analyzed results. Can also use an unused filename to generate new split."
			echo "-s [FILEPATH] -> Specify the save file for the analyzed results." >&1
			echo "-c [NUMBER] -> Specify regressand column." >&1
			echo "-e [NUMBER LIST] -> Specify events list." >&1
			echo "-n [NUMBER] -> Specify max number of events to include in automatic model generation." >&1
			echo "-a -> Use flag to specify all frequencies model instead of per frequency one." >&1
			echo "-m [NUMBER: 1:$NUM_MODES]-> Mode of operation: 1 -> Measured physical data, full model performance and model coefficients; 2 -> Measured physical data and model performance; 3 -> Model performance;" >&1
			echo "Mandatory options are: -r, -b, -c, -e, -m"
			exit 0 
			;;

		#Specify the save directory, if no save directory is chosen the results are saved in the $PWD
		r)
			if [[ -n $RESULTS_FILE ]]; then
				echo "Invalid input: option -r has already been used!" >&2
				exit 1                
			fi
			#Make sure the benchmark directory selected exists
			if [[ ! -e "$OPTARG" ]]; then
				echo "-r $OPTARG does not exist. Please enter the results file to be analyzed!" >&2 
				exit 1
		    	else
				RESULTS_FILE="$OPTARG"
				RESULTS_START_LINE=$(awk -v SEP='\t' 'BEGIN{FS=SEP}{ if($1 !~ /#/){print (NR);exit} }' < $RESULTS_FILE)
				#Check if results file contains data
			    	if [[ -z $RESULTS_START_LINE ]]; then 
					echo "Results file contains no data!" >&2
					exit 1
				fi  
				RESULTS_FREQ_LIST=$(echo $(awk -v SEP='\t' -v START=$RESULTS_START_LINE -v FREQ=0 'BEGIN{FS=SEP}{ if(NR >= START && $4 != FREQ){print ($4);FREQ=$4} }' < $RESULTS_FILE | sort -u | sort -gr ) | tr " " ",")
				#Check if we have successfully extracted freqeuncies
				if [[ -z $RESULTS_FREQ_LIST ]]; then
					echo "Unable to extract freqeuncies from results file!" >&2
					exit 1
				fi  
		    	fi
		    	;;
		f)
		    	if [[ -n $CORE_FREQ ]]; then
			    	echo "Invalid input: option -f has already been used!" >&2
		            	exit 1
		    	fi
			if [[ -z $RESULTS_FILE ]]; then
				echo "Please specify results file before selecting frequency list!" >&2
				exit 1
			fi

			#Go throught the selected frequecnies and make sure they are not out of bounds
	    		#Also make sure they are present in the frequency table located at /sys/devices/system/cpu/cpufreq/iks-cpufreq/freq_table because the kernel rounds up
			#Specifying a higher/lower frequency or an odd frequency is now wrong, jsut the kernel handles it in the background and might lead to collection of unwanted resutls
			spaced_OPTARG="${OPTARG//,/ }"
			IFS="," read -a FREQ_LIST <<< "$RESULTS_FREQ_LIST"
			for FREQ_SELECT in $spaced_OPTARG
			do
				#containsElement "$FREQ_SELECT" "${FREQ_LIST[@]}"
				if [[ " ${FREQ_LIST[@]} " =~ " $FREQ_SELECT " ]]; then
					[[ -z "$USER_FREQ_LIST" ]] && USER_FREQ_LIST="$FREQ_SELECT" || USER_FREQ_LIST+=",$FREQ_SELECT"	
				else
					echo "selected frequency $FREQ_SELECT for -$opt is not present in concatenated results file."
			       	 	exit 1
				fi
			done
			;;
		#Specify the benchmarks split file, if no benchmarks are chosen the program can be used to make a new randomised benchmark split
		b)
			if [[ -n $BENCH_FILE ]]; then
		    		echo "Invalid input: option -b has already been used!" >&2
		    		exit 1                
			fi
			if [[ -z $RESULTS_FILE ]]; then
				echo "Please specify results file before selecting benchmark split!" >&2
				exit 1
			fi
			if [[ ! -e "$OPTARG" ]]; then
			    	echo "-b $OPTARG does not exist. Do you want to create a new benchmark split and save in file? (Y/N)" >&1
			    	#wait on user input here (Y/N)
			    	#if user says Y set writing directory to that
			    	#if no then exit and ask for better input parameters
			    	while true;
			    	do
					read USER_INPUT
					if [[ "$USER_INPUT" == Y || "$USER_INPUT" == y ]]; then
				    		echo "Creating new benchmark split file $OPTARG" >&1
		    				BENCH_FILE="$OPTARG"
		    				#Perform randomised split and 
		    				benchmarkSplit
		    				#Store benchmarks
		    				echo -e "#Train Set\tTest Set" > $BENCH_FILE
					 	for i in `seq 0 $((${#TEST_SET[@]}-1))`
						do
							echo -e "${TRAIN_SET[$i]}\t${TEST_SET[$i]}" >> $BENCH_FILE 
						done
						break
					elif [[ "$USER_INPUT" == N || "$USER_INPUT" == n ]]; then
				    		echo "Cancelled creating benchmark split file $OPTARG Program exiting." >&1
				    		exit 0                            
					else
				    		echo "Invalid input: $USER_INPUT !(Expected Y/N)" >&2
						echo "Please enter correct input: " >&2
					fi
			    	done
			else
			    	#Extract benchmark split information.
			    	BENCH_FILE="$OPTARG"
			    	BENCH_START_LINE=$(awk -v SEP='\t' 'BEGIN{FS=SEP}{ if($1 !~ /#/){print (NR);exit} }' < $BENCH_FILE)
				#Check if bench file contains data
				if [[ -z $BENCH_START_LINE ]]; then
					echo "Benchmarks split file contains no data!" >&2
					exit 1
				fi
				IFS=";" read -a TRAIN_SET <<< "$( echo $(awk -v SEP='\t' -v START=$BENCH_START_LINE 'BEGIN{FS=SEP}{if (NR >= START){ print $1 }}' $BENCH_FILE | sort -d ) | tr "\n" ";" | head -c -1 )"
				IFS=";" read -a TEST_SET <<< "$( echo $(awk -v SEP='\t' -v START=$BENCH_START_LINE 'BEGIN{FS=SEP}{if (NR >= START){ print $2 }}' $BENCH_FILE | sort -d) | tr "\n" ";" |  head -c -1 )"
				#Check if we have successfully extracted benchmark sets 
				if [[ ${#TRAIN_SET[@]} == 0 || ${#TEST_SET[@]} == 0 ]]; then
					echo "Unable to extract train or test set from benchmarks file!" >&2
					exit 1
				fi 	            	
			fi
		    	;;
		#Specify the save file, if no save directory is chosen the results are printed on terminal
		s)
			if [[ -n $SAVE_FILE ]]; then
			    	echo "Invalid input: option -s has already been used!" >&2
			    	exit 1                
			fi

			if [[ -e "$OPTARG" ]]; then
			    	#wait on user input here (Y/N)
			    	#if user says Y set writing directory to that
			    	#if no then exit and ask for better input parameters
			    	echo "-s $OPTARG already exists. Continue writing in file? (Y/N)" >&1
			    	while true;
			    	do
					read USER_INPUT
					if [[ "$USER_INPUT" == Y || "$USER_INPUT" == y ]]; then
				    		echo "Using existing file $OPTARG" >&1
				    		break
					elif [[ "$USER_INPUT" == N || "$USER_INPUT" == n ]]; then
				    		echo "Cancelled using save file $OPTARG Program exiting." >&1
				    		exit 0                            
					else
				    		echo "Invalid input: $USER_INPUT !(Expected Y/N)" >&2
						echo "Please enter correct input: " >&2
					fi
			    	done
			    	SAVE_FILE="$OPTARG"
			else
		    		#file does not exist, set mkdir flag.
		    		SAVE_FILE="$OPTARG"
			fi
			;;
		m)
			if [[ -n $MODE ]]; then
		    		echo "Invalid input: option -m has already been used!" >&2
		    		exit 1                
			fi
			if [[ $OPTARG != "1" && $OPTARG != "2" && $OPTARG != "3" ]]; then 
				echo "Invalid operarion: -m $MODE! Options are: [1:$NUM_MODES]." >&2
				echo "Use -h flag for more information on the available modes." >&2
			    	echo -e "===================="
			    	exit 1
			fi		
			MODE="$OPTARG"      	
			;;
		c)
			if [[ -n  $REGRESSAND_COL ]]; then
		    		echo "Invalid input: option -c has already been used!" >&2
		    		exit 1                
			fi
			if [[ -z $RESULTS_FILE ]]; then
				echo "Please specify results file before selecting regressand column!" >&2
				exit 1
			fi
			#Extract events columns from results file
			EVENTS_COL_START=$(awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Run/) { print i+1; exit} } } }' < $RESULTS_FILE)
			EVENTS_COL_END=$(awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ print NF; exit } }' < $RESULTS_FILE)
			
			#Check if regressand is within bounds
			if [[ "$OPTARG" -gt $EVENTS_COL_END || "$OPTARG" -lt $EVENTS_COL_START ]]; then 
				echo "Selected regressand -c $OPTARG is out of bounds/invalid. Needs to be an integer value betweeen [$EVENTS_COL_START:$EVENTS_COL_END]." >&2
				exit 1
			fi
	    		REGRESSAND_COL="$OPTARG"
			REGRESSAND_LABEL=$(awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) -v COL=$REGRESSAND_COL 'BEGIN{FS=SEP}{if(NR==START){ print $COL; exit } }' < $RESULTS_FILE)
		    	;;
		e)
			if [[ -n  $EVENTS_LIST ]]; then
		    		echo "Invalid input: option -e has already been used!" >&2
		    		exit 1
                	fi
			if [[ -z $REGRESSAND_COL ]]; then
				echo "Please specify regressand column before selecting events list!" >&2
				exit 1
			fi
			spaced_OPTARG="${OPTARG//,/ }"
			for EVENT in $spaced_OPTARG
			do
				#Check if events list is in bounds
				if [[ "$EVENT" -gt $EVENTS_COL_END || "$EVENT" -lt $EVENTS_COL_START ]]; then 
					echo "Selected event -e $EVENT is out of bounds/invalid. Needs to be an integer value betweeen [$EVENTS_COL_START:$EVENTS_COL_END]." >&2
					exit 1
				fi
				#Check if it contains regressand
				if [[ "$EVENT" == $REGRESSAND_COL ]]; then 
					echo "Selected event -e $EVENT is the same as the regressand $REGRESSAND_COL -> $REGRESSAND_LABEL." >&2
					exit 1
				fi
			done
			#Checkif events string contains duplicates
			if [[ $(echo $OPTARG | tr "," "\n" | wc -l) -gt $(echo $OPTARG | tr "," "\n" | sort | uniq | wc -l) ]]; then
				echo "Selected event list -e $OPTARG contains duplicates." >&2
				exit 1
			fi
			EVENTS_LIST="$OPTARG"
			EVENTS_LIST_LABELS=$((awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) -v COLUMNS="$EVENTS_LIST" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < $RESULTS_FILE) | tr "\n" "," | head -c -1)
		    	;;
		n)
			if [[ -n  $NUM_MODEL_EVENTS ]]; then
		    		echo "Invalid input: option -n has already been used!" >&2
		    		exit 1                
			fi
			if [[ -z $EVENTS_LIST ]]; then
				echo "Please specify events list file before selecting number of events in model(automatic)!" >&2
				exit 1
			fi
			#Check if number is within bounds, which is total number of events - 1 (regressand)
			if [[ "$OPTARG" -gt $(( $EVENTS_COL_END - $EVENTS_COL_START )) || "$OPTARG" -le 0 ]]; then 
				echo "Selected event -e $EVENT is out of bounds/invalid. Needs to be an integer value betweeen [1:`$EVENTS_COL_END-$EVENTS_COL_START`]." >&2
				exit 1
			fi
	    		NUM_MODEL_EVENTS="$OPTARG"
		    	;;
		a)
			if [[ -n  $ALL_FREQUENCY ]]; then
		    		echo "Invalid input: option -a has already been used!" >&2
		    		exit 1                
			fi
		    	ALL_FREQUENCY=1
		    	;;           
		:)
		    	echo "Option: -$OPTARG requires an argument" >&2
		    	exit 1
		    	;;
		\?)
		    	echo "Invalid option: -$OPTARG" >&2
		    	exit 1
		    	;;
	esac
done

#Critical sanity checks
echo -e "===================="
if [[ -z $RESULTS_FILE ]]; then
    	echo "Nothing to run! Expected -r flag." >&2
    	echo -e "====================" >&1
    	exit 1
fi
if [[ -z $MODE ]]; then
    	echo "No mode specified! Expected -m flag." >&2
    	echo -e "====================" >&1
    	exit 1
fi
if [[ -z $BENCH_FILE ]]; then
	echo "No benchmark file specified! Please use flag with existing file or an empty file to gererate random benchmark split." >&2
	echo -e "====================" >&1
	exit 1
fi
if [[ -z $REGRESSAND_COL ]]; then
    	echo "No regressand! Expected -c flag." >&2
    	echo -e "====================" >&1
    	exit 1
fi
if [[ -z $EVENTS_LIST ]]; then
    	echo "No event list specified! Expected -e flag." >&2
    	echo -e "====================" >&1
    	exit 1
fi
echo -e "Critical checks passed!"  >&1

#Regular sanity checks
echo -e "====================" >&1
echo -e "--------------------" >&1
echo -e "Train Set:" >&1
echo "${TRAIN_SET[*]}" >&1
echo -e "--------------------" >&1
echo -e "Test Set:" >&1
echo "${TEST_SET[*]}" >&1
echo -e "--------------------" >&1
#Check for dupicates in benchmark sets
for i in `seq 0 $((${#TEST_SET[@]}-1))`
do
	if [[ " ${TRAIN_SET[@]} " =~ " ${TEST_SET[$i]} " ]]; then
		echo -e "Warning! Benchmark sets share benchmark \"${TEST_SET[$i]}\"" >&1
	fi
done
#Issue warning if train sets are different sizes
if [[ ${#TRAIN_SET[@]} != ${#TEST_SET[@]} ]]; then 
	echo "Warning! Benchmark sets are different sizes [${#TRAIN_SET[@]};${#TEST_SET[@]}]" >&1
	echo -e "--------------------" >&1
fi
#Output freqeuncy list
if [[ -z $USER_FREQ_LIST ]]; then
    	echo "No user specified frequency list! Using default frequency list in results file:" >&1
    	echo $RESULTS_FREQ_LIST >&1
    	IFS="," read -a FREQ_LIST <<< "$RESULTS_FREQ_LIST"
else
	echo "Using user specified frequency list:" >&1
    	echo $USER_FREQ_LIST >&1
    	IFS="," read -a FREQ_LIST <<< "$USER_FREQ_LIST"		
fi
echo -e "--------------------" >&1
#Model type check
if [[ -z ALL_FREQUENCY ]]; then
    	echo "Computing per-frequency models!" >&1
else
    	echo "Computing full frequency model!" >&1
fi
echo -e "--------------------" >&1
#Mode sanity checks
echo "Specified program mode:" >&1
case $MODE in
	1) 
		echo "$MODE -> Measured physical characteristics, full model performance and model coefficients." >&1
		;;
	2) 
		echo "$MODE -> Measured physical characteristics and full model performance." >&1
		;;
	3) 
		echo "$MODE -> Full model performance." >&1
		;;
esac
echo -e "--------------------" >&1
#Events sanity checks
echo -e "Regressand Column:" >&1
echo "$REGRESSAND_COL -> $REGRESSAND_LABEL" >&1
echo -e "--------------------" >&1
echo -e "Events list:" >&1
echo "$EVENTS_LIST -> $EVENTS_LIST_LABELS" >&1
echo -e "--------------------" >&1
if [[ -z $NUM_MODEL_EVENTS ]]; then
    	echo "No maximum number of event specified (for automatic generation). Using full user specified list." >&1
else
	echo "Using user specified maximum number of events for automatic generation -> $NUM_MODEL_EVENTS" >&1
fi
echo -e "--------------------" >&1
#Save file sanity check
if [[ -z $SAVE_FILE ]]; then 
	echo "No save file specified! Output to terminal." >&1
else
	echo "Using user specified output save file -> $SAVE_FILE" >&1
fi
echo -e "--------------------" >&1

#Uses temporary files generated for extracting the train and test set. Array indexing starts at 1 in awk.
#Also uses the extracted benchmark set files to pass arguments in octave since I found that to be the easiest way and quickest for bug checking.
if [[ -n $ALL_FREQUENCY ]]; then
	#If all freqeuncy model then use all freqeuncies in octave, as in use the fully populated train and test set files
	#Split data and collect output, then cleanup
	touch "train_set.data" "test_set.data"
	awk -v START=$RESULTS_START_LINE -v SEP='\t' -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "train_set.data" 
	awk -v START=$RESULTS_START_LINE -v SEP='\t' -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "test_set.data" 	
	octave_output="$(octave --silent --eval "load_build_model('train_set.data','test_set.data',0,$(($EVENTS_COL_START-1)),$REGRESSAND_COL,'$EVENTS_LIST')" 2> /dev/null)"
	rm "train_set.data" "test_set.data"
else
	#If per-frequency models, split benchmarks for each freqeuncy (with cleanup so we get fresh split every frequency)
	#Then pass onto octave and store results in a concatenating string
	octave_ouput=""
	for i in `seq 0 $((${#FREQ_LIST[@]}-1))`
	do
		touch "train_set.data" "test_set.data"
		awk -v START=$RESULTS_START_LINE -v SEP='\t' -v FREQ=${FREQ_LIST[$i]} -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $4 == FREQ){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "train_set.data" 
		awk -v START=$RESULTS_START_LINE -v SEP='\t' -v FREQ=${FREQ_LIST[$i]} -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $4 == FREQ){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "test_set.data" 
		octave_output+="$(octave --silent --eval "load_build_model('train_set.data','test_set.data',0,$(($EVENTS_COL_START-1)),$REGRESSAND_COL,'$EVENTS_LIST')" 2> /dev/null)"
		rm "train_set.data" "test_set.data"
	done	
fi

#Extract relevant informaton from octave
#Avg. Power
IFS=";" read -a avg_pow <<< "$((echo "$octave_output" |awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Power"){ print $4 }}' ) | tr "\n" ";" | head -c -1)" 
#Measured Power Range
IFS=";" read -a pow_range <<< "$((echo "$octave_output" |awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Measured" && $2=="Power" && $3=="Range"){ print $5 }}' ) | tr "\n" ";" | head -c -1)"
#Average Pred. Power
IFS=";" read -a avg_pred_pow <<< "$((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Predicted" && $3=="Power"){ print $5 }}' ) | tr "\n" ";" | head -c -1)" 
#Pred. Power Range
IFS=";" read -a pred_pow_range <<< "$((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Predicted" && $2=="Power" && $3=="Range"){ print $5 }}' ) | tr "\n" ";" | head -c -1)" 
#Avg. Abs. Error
IFS=";" read -a avg_abs_err <<< "$((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Absolute" && $3=="Error:"){ print $4 }}' ) | tr "\n" ";" | head -c -1)" 
#Abs. Err. Std. Dev. Error
IFS=";" read -a std_dev_err <<< "$((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Absolute" && $2=="Error" && $3=="Standart" && $4=="Deviation:"){ print $5 }}' ) | tr "\n" ";" | head -c -1)" 
#Norm. Avg. Abs. Error
IFS=";" read -a norm_avg_abs_err <<< "$((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Normalised" && $2=="Average" && $3=="Absolute" && $4=="Error"){ print $6 }}' ) | tr "\n" ";" | head -c -1)"
#Rel. Std. Dev
IFS=";" read -a rel_std_dev <<< "$((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Relative" && $2=="Standart" && $3=="Deviation"){ print $5 }}' ) | tr "\n" ";" | head -c -1)"
#Model coefficients
IFS=";" read -a model_coeff <<< "$((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Model" && $2=="coefficients:"){ print substr($0, index($0,$3)) }}' ) | tr "\n" ";" | head -c -1)" 

#Modify freqeuncy list first element to list "all"
[[ -n $ALL_FREQUENCY ]] && FREQ_LIST[0]=$(echo "all")
	
#Adjust output depending on mode  	
#I store the varaible references as special characters in the DATA string then eval to evoke subsittution. Eliminates repetitive code.
case $MODE in
	1)
		HEADER="CPU Frequency\tAverage Power [W]\tMeasured Power Range [%]\tAverage Predicted Power [W]\tPredicted Power Range [%]\tAverage Absolute Error\tAbsolute Error Stdandart Deviation\tNormalised Average Absolute Error [%]\tRelative Standart Deviation [%]\tModel coefficients"
		DATA="\${FREQ_LIST[\$i]}\t\${avg_pow[\$i]}\t\${pow_range[\$i]}\t\${avg_pred_pow[\$i]}\t\${pred_pow_range[\$i]}\t\${avg_abs_err[\$i]}\t\${std_dev_err[\$i]}\t\${norm_avg_abs_err[\$i]}\t\${rel_std_dev[\$i]}\t\${model_coeff[\$i]}"
		;;
	2)
		HEADER="CPU Frequency\tAverage Power [W]\tMeasured Power Range [%]\tAverage Predicted Power [W]\tPredicted Power Range [%]\tAverage Absolute Error\tAbsolute Error Stdandart Deviation\tNormalised Average Absolute Error [%]\tRelative Standart Deviation [%]"
		DATA="\${FREQ_LIST[\$i]}\t\${avg_pow[\$i]}\t\${pow_range[\$i]}\t\${avg_pred_pow[\$i]}\t\${pred_pow_range[\$i]}\t\${avg_abs_err[\$i]}\t\${std_dev_err[\$i]}\t\${norm_avg_abs_err[\$i]}\t\${rel_std_dev[\$i]}"
		;;
	3)
		HEADER="Average Predicted Power [W]\tPredicted Power Range [%]\tAverage Absolute Error\tAbsolute Error Stdandart Deviation\tNormalised Average Absolute Error [%]\tRelative Standart Deviation [%]"
		DATA="\${avg_pred_pow[\$i]}\t\${pred_pow_range[\$i]}\t\${avg_abs_err[\$i]}\t\${std_dev_err[\$i]}\t\${norm_avg_abs_err[\$i]}\t\${rel_std_dev[\$i]}"
		;;
esac  

#Output to file or terminal. First header, then data depending on model
#If per-frequency models, iterate frequencies then print
#If full frequency just print the one model
if [[ -z $SAVE_FILE ]]; then
	echo -e "===================="
	echo -e $HEADER
	echo -e "===================="
else
	echo -e $HEADER > $SAVE_FILE
fi
for i in `seq 0 $((${#FREQ_LIST[@]}-1))`
do
	if [[ -z $SAVE_FILE ]]; then 
		echo -e $(eval echo `echo -e "$DATA"`) | tr " " "\t"
	else
		echo -e $(eval echo `echo -e "$DATA"`) >> $SAVE_FILE
	fi
	#If all freqeuncy model, there is just one line that needs to be printed
	[[ -n $ALL_FREQUENCY ]] && break;
done
echo -e "====================" >&1
echo "Script Done!" >&1

