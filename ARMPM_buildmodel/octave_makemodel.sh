#!/bin/bash

if [[ "$#" -eq 0 ]]; then
	echo "This program requires inputs. Type -h for help." >&2
	exit 1
fi

#Internal variable for quickly setting maximum number of modes and model types
NUM_MODES=3
NUM_TYPES=2

#Extract unique benchmark split from results file
benchmarkSplit () {
	#Read and randomise benchmarks, assumes column 2 is benchmarks.
	#I can automate this by searching the header and extracting column number if I need to, but this is very rarely used.
	local RANDOM_BENCHMARK_LIST=$(echo $(awk -v SEP='\t' -v START=$RESULTS_START_LINE -v BENCH=0 'BEGIN{FS=SEP}{ if(NR > START && $2 != BENCH){print ($2);BENCH=$2} }' < $RESULTS_FILE | sort -u | sort -R ) | sed 's/ /\\n/g' )
	local NUM_BENCH=$(echo -e "$RANDOM_BENCHMARK_LIST" | wc -l)
	#Get midpoint to split the randomised list
	local MIDPOINT=$(echo "scale = 0; $NUM_BENCH/2;" | bc )
	#I need to use this temp to extract the string
	#Bash gets confused with too many variable substitutions, that why I need the temp
	local temp=$(echo $(echo -e $RANDOM_BENCHMARK_LIST | head -n $MIDPOINT | sort -d ) | sed 's/ /,/g')
	IFS="," read -a TRAIN_SET <<< "$temp"
	local temp=$(echo $(echo -e $RANDOM_BENCHMARK_LIST | tail -n $(echo "scale = 0; $NUM_BENCH-$MIDPOINT;" | bc ) | sort -d ) | sed 's/ /,/g')
	IFS="," read -a TEST_SET <<< "$temp"
}

#Simple script to get the mean of an array
#Need to pass the name of the array as first argument and then the element count as second argument
#Then use BC to compute mean since bash has just integer logic and we are almost surely dealing with fractions for the mean
getMean () {
	local total=0
	local -n array=$1
	for i in `seq 0 $(($2-1))`
	do
		total=$(echo "scale = 2; $total+${array[$i]};" | bc )
	done
	echo $(echo "scale=2; $total/$2;" | bc )
}

#requires getops, but this should not be an issue since ints built in bash
while getopts ":r:f:b:s:m:t:c:e:n:hac" opt;
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
			echo "-t [NUMBER: 1:$NUM_TYPES]-> Type of model: 1 -> Minimal absolute error; 2 -> Minimal absolute error standart deviation;" >&1
			echo "Mandatory options are: -r, -b, -c, -e, -m, -t"
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
		t)
			if [[ -n $MODEL_TYPE ]]; then
		    		echo "Invalid input: option -t has already been used!" >&2
		    		exit 1                
			fi
			if [[ $OPTARG != "1" && $OPTARG != "2" ]]; then 
				echo "Invalid operarion: -t $MODEL_TYPE! Options are: [1:$NUM_TYPES]." >&2
				echo "Use -h flag for more information on the available modes." >&2
			    	echo -e "===================="
			    	exit 1
			fi		
			MODEL_TYPE="$OPTARG"      	
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
			EVENTS_LIST_SIZE=$(echo $EVENTS_LIST | tr "," "\n" | wc -l)
			#Check if number is within bounds, which is total number of events - 1 (regressand)
			if [[ "$OPTARG" -gt $EVENTS_LIST_SIZE || "$OPTARG" -le 0 ]]; then 
				echo "Selected number of events -n $EVENTS_LIST_SIZE is out of bounds/invalid. Needs to be an integer value betweeen [1:$EVENTS_LIST_SIZE]." >&2
				exit 1
			fi
			#Initiate variables and unset events_list (since we use events_pool for the automatic list)
	    		NUM_MODEL_EVENTS="$OPTARG"
			EVENTS_POOL=$EVENTS_LIST
			unset EVENTS_LIST
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
if [[ -z $MODEL_TYPE ]]; then
    	echo "No model type specified! Expected -t flag." >&2
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
if [[ -z $EVENTS_LIST && -z $EVENTS_POOL ]]; then
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
if [[ -z $ALL_FREQUENCY ]]; then
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
#Model type sanity checks
echo "Specified model type:" >&1
case $MODEL_TYPE in
	1)
		echo "$MODEL_TYPE -> Minimize model absolute error." >&1
		;;
	2) 
		echo "$MODEL_TYPE -> Minimize model absolute error standart deviation." >&1
		;;
esac
echo -e "--------------------" >&1
#Events sanity checks
echo -e "Regressand Column:" >&1
echo "$REGRESSAND_COL -> $REGRESSAND_LABEL" >&1
echo -e "--------------------" >&1
if [[ -z $NUM_MODEL_EVENTS ]]; then
	EVENTS_LIST_LABELS=$((awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) -v COLUMNS="$EVENTS_LIST" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < $RESULTS_FILE) | tr "\n" "," | head -c -1)
    	echo "No maximum number of event specified (for automatic generation). Using full user specified list." >&1
	echo -e "--------------------" >&1
	echo -e "Events list:" >&1
	echo "$EVENTS_LIST -> $EVENTS_LIST_LABELS" >&1
	NUM_MODEL_EVENTS=0
else
	EVENTS_POOL_LABELS=$((awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) -v COLUMNS="$EVENTS_POOL" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < $RESULTS_FILE) | tr "\n" "," | head -c -1)
	echo "Using user specified maximum number of events for automatic generation -> $NUM_MODEL_EVENTS" >&1
	echo -e "--------------------" >&1
	echo -e "Events pool:" >&1
	echo "$EVENTS_POOL -> $EVENTS_POOL_LABELS" >&1
fi
echo -e "--------------------" >&1
#Save file sanity check
if [[ -z $SAVE_FILE ]]; then 
	echo "No save file specified! Output to terminal." >&1
else
	echo "Using user specified output save file -> $SAVE_FILE" >&1
fi
echo -e "--------------------" >&1
#Automatic model generation.
#It will keep going as long as we have not saturated the model (no further events contribute) or we reach max number of model events as specified by user
#If we dont want automatic we just initialise NUM_MODEL_EVENTS to 0 and skip this loop. EZPZ
echo -e "====================" >&1
while [[ $NUM_MODEL_EVENTS -gt 0 ]]
do
	spaced_POOL="${EVENTS_POOL//,/ }"
	echo -e "--------------------" >&1
	if [[ $EVENTS_POOL != "\n" ]]; then
		echo -e "Current events pool:" >&1
		echo "$EVENTS_POOL -> $EVENTS_POOL_LABELS" >&1
	else
		echo "Current events pool -> (empty)" >&1
	fi
	echo -e "--------------------" >&1
	for EV_TEMP in $spaced_POOL
	do
		#Initiate temp event list to collect results for
		[[ -n $EVENTS_LIST ]] && EVENTS_LIST_TEMP="$EVENTS_LIST,$EV_TEMP" || EVENTS_LIST_TEMP="$EV_TEMP"
		echo -e "********************" >&1
		EV_TEMP_LABEL=$(awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) -v COL=$EV_TEMP 'BEGIN{FS=SEP}{if(NR==START){ print $COL; exit } }' < $RESULTS_FILE)
		EVENTS_LIST_TEMP_LABELS=$((awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) -v COLUMNS="$EVENTS_LIST_TEMP" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < $RESULTS_FILE) | tr "\n" "," | head -c -1)
		echo "Checking event:" >&1
		echo -e "$EV_TEMP -> $EV_TEMP_LABEL" >&1
		echo "Temporaty events list:"
		echo -e "$EVENTS_LIST_TEMP -> $EVENTS_LIST_TEMP_LABELS" >&1
		#Uses temporary files generated for extracting the train and test set. Array indexing starts at 1 in awk.
		#Also uses the extracted benchmark set files to pass arguments in octave since I found that to be the easiest way and quickest for bug checking.
		if [[ -n $ALL_FREQUENCY ]]; then
			#If all freqeuncy model then use all freqeuncies in octave, as in use the fully populated train and test set files
			#Split data and collect output, then cleanup
			touch "train_set.data" "test_set.data"
			awk -v START=$RESULTS_START_LINE -v SEP='\t' -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "train_set.data" 
			awk -v START=$RESULTS_START_LINE -v SEP='\t' -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "test_set.data" 	
			octave_output=$(octave --silent --eval "load_build_model('train_set.data','test_set.data',0,$(($EVENTS_COL_START-1)),$REGRESSAND_COL,'$EVENTS_LIST_TEMP')" 2> /dev/null)
			rm "train_set.data" "test_set.data"
		else
			#If per-frequency models, split benchmarks for each freqeuncy (with cleanup so we get fresh split every frequency)
			#Then pass onto octave and store results in a concatenating string
			#Sometimes octave bugs out and does not accept input correctly resulting in missing frequencies.
			#I overcome that with a while loop which checks if we have collected data for all frequencies, if not repeat
			#This bug is totally random and the only way to overcome it is to check and repeat (1 in every 5-6 times is faulty)	
			unset -v data_count
			while [[ $data_count -ne ${#FREQ_LIST[@]} ]]
			do
				unset -v octave_output				
				for count in `seq 0 $((${#FREQ_LIST[@]}-1))`
				do
					touch "train_set.data" "test_set.data"
					awk -v START=$RESULTS_START_LINE -v SEP='\t' -v FREQ=${FREQ_LIST[$count]} -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $4 == FREQ){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "train_set.data" 
					awk -v START=$RESULTS_START_LINE -v SEP='\t' -v FREQ=${FREQ_LIST[$count]} -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $4 == FREQ){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "test_set.data"
					octave_output+=$(octave --silent --eval "load_build_model('train_set.data','test_set.data',0,$(($EVENTS_COL_START-1)),$REGRESSAND_COL,'$EVENTS_LIST_TEMP')" 2> /dev/null)
					rm "train_set.data" "test_set.data"
				done
				data_count=$(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Power"){ count++ }}END{print count}' )
			done	
		fi
		#Analyse collected results
		#Avg. Rel. Error
		IFS=";" read -a rel_avg_abs_err <<< $((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Relative" && $3=="Error"){ print $5 }}' ) | tr "\n" ";" | head -c -1)
		#Rel. Err. Std. Dev
		IFS=";" read -a rel_avg_abs_err_std_dev <<< $((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Relative" && $2=="Error" && $3=="Standart" && $4=="Deviation"){ print $6 }}' ) | tr "\n" ";" | head -c -1)
		#Check for bad events
		if [[ " ${rel_avg_abs_err[@]} " =~ " Inf " ]]; then
			#If relative error contains infinity then event is bad for linear regression as is removed from list
			EVENTS_POOL=$(echo $EVENTS_POOL | sed "s/^$EV_TEMP,//g;s/,$EV_TEMP,/,/g;s/,$EV_TEMP$//g;s/^$EV_TEMP$//g")
			echo "Bad Event (constant)!" >&1
			echo "Removed from events pool." >&1
		else
			#Get the means for both relative error and standart deviation and output
			#Depending oon type though we use a different value for EVENTS_LIST_NEW to try and minmise
			MEAN_REL_AVG_ABS_ERR=$(getMean rel_avg_abs_err ${#rel_avg_abs_err[@]} )
			MEAN_REL_AVG_ABS_ERR_STD_DEV=$(getMean rel_avg_abs_err_std_dev ${#rel_avg_abs_err_std_dev[@]} )
			echo "Mean model relative error -> $MEAN_REL_AVG_ABS_ERR" >&1
			echo "Mean model relative error stdandart deviation -> $MEAN_REL_AVG_ABS_ERR_STD_DEV" >&1
			case $MODEL_TYPE in
			1)
				EVENTS_LIST_NEW=$MEAN_REL_AVG_ABS_ERR
				;;
			2)
				EVENTS_LIST_NEW=$MEAN_REL_AVG_ABS_ERR_STD_DEV
				;;
			esac
			if [[ -n $EVENTS_LIST_MIN ]]; then
				#If events list exits then compare new value and if smaller then store else just move along the events list 
				if [[ $(echo "$EVENTS_LIST_NEW < $EVENTS_LIST_MIN" | bc -l) -eq 1 ]]; then
					#Update events list error and EV
					echo "Good event (improves minimum temporary model)! Using as new minimum!"
					EV_ADD=$EV_TEMP
					EVENTS_LIST_MIN=$EVENTS_LIST_NEW
					EVENTS_LIST_MEAN_REL_AVG_ABS_ERR=$MEAN_REL_AVG_ABS_ERR
					EVENTS_LIST_MEAN_REL_AVG_ABS_ERR_STD_DEV=$MEAN_REL_AVG_ABS_ERR_STD_DEV
				else
					echo "Bad event (does not improve minimum temporary model)!" >&1
				fi
			else
				#If no event list temp error present this means its the first event to check. Just add it as a new minimum
				EVENTS_LIST_MIN=$EVENTS_LIST_NEW
				EVENTS_LIST_MEAN_REL_AVG_ABS_ERR=$MEAN_REL_AVG_ABS_ERR
				EVENTS_LIST_MEAN_REL_AVG_ABS_ERR_STD_DEV=$MEAN_REL_AVG_ABS_ERR_STD_DEV
				EV_ADD=$EV_TEMP
				echo "Good event (first event in model)!" >&1
			fi
		fi 
	done
	echo -e "********************" >&1
	echo "All events checked!" >&1
	echo -e "********************" >&1
	#Once going through all events see if we can populate events list
	if [[ -n $EV_ADD ]]; then
		#We found an new event to add to list
		[[ -n $EVENTS_LIST ]] && EVENTS_LIST="$EVENTS_LIST,$EV_ADD" || EVENTS_LIST="$EV_ADD"
		EV_ADD_LABEL=$(awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) -v COL=$EV_ADD 'BEGIN{FS=SEP}{if(NR==START){ print $COL; exit } }' < $RESULTS_FILE)
		EVENTS_LIST_LABELS=$((awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) -v COLUMNS="$EVENTS_LIST" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < $RESULTS_FILE) | tr "\n" "," | head -c -1)
		EVENTS_POOL=$(echo $EVENTS_POOL | sed "s/^$EV_ADD,//g;s/,$EV_ADD,/,/g;s/,$EV_ADD$//g;s/^$EV_ADD$//g")
		EVENTS_POOL_LABELS=$((awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) -v COLUMNS="$EVENTS_POOL" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < $RESULTS_FILE) | tr "\n" "," | head -c -1)
		#Remove from events pool
		echo -e "--------------------" >&1
		echo -e "********************" >&1
		echo "Add best event to final list and remove from pool:"
		echo "$EV_ADD -> $EV_ADD_LABEL" >&1
		echo -e "********************" >&1
		echo -e "New events list:" >&1
		echo "$EVENTS_LIST -> $EVENTS_LIST_LABELS" >&1
		echo -e "New mean model relative error -> $EVENTS_LIST_MEAN_REL_AVG_ABS_ERR" >&1
		echo -e "New mean model relative error stdandart deviation -> $EVENTS_LIST_MEAN_REL_AVG_ABS_ERR_STD_DEV" >&1
		echo -e "********************" >&1
		if [[ $EVENTS_POOL !=  "\n" ]]; then
			echo "New events pool:" >&1
			echo "$EVENTS_POOL -> $EVENTS_POOL_LABELS" >&1
		else
			echo "New events pool -> (empty)" >&1
		fi
		echo -e "********************" >&1
		#reset EV_ADD too see if we can find another one and decrement counter
		unset -v EV_ADD
		((NUM_MODEL_EVENTS--))
	else
		EVENTS_LIST_SIZE=$(echo $EVENTS_LIST | tr "," "\n" | wc -l)
		#We did not find a new event to add to list. Just output and break loop (list saturated)		
		echo -e "--------------------" >&1
		echo "No new improving event found. Events list minimised at $EVENTS_LIST_SIZE events." >&1
		echo -e "--------------------" >&1
		echo -e "====================" >&1
		echo -e "Optimal events list found:" >&1
		echo "$EVENTS_LIST -> $EVENTS_LIST_LABELS" >&1
		echo -e "Events list mean model relative error -> $EVENTS_LIST_MEAN_REL_AVG_ABS_ERR" >&1
		echo -e "Events list mean model relative error stdandart deviation -> $EVENTS_LIST_MEAN_REL_AVG_ABS_ERR_STD_DEV" >&1
		echo -e "Using final list in full model analysis." >&1
		echo -e "====================" >&1
		break
	fi
done

echo -e "====================" >&1
echo -e "Using events list:" >&1
echo "$EVENTS_LIST -> $EVENTS_LIST_LABELS" >&1
echo -e "====================" >&1

#This part is for outputing a specified events list or just using the automatically generated one and passing it onto octave
#Anyhow its mandatory to extract results so its always executed even if we skip automatic generation
#Its the same as the automatic generation collection logic, except for the all the automatic iteration, we just use one events list with octave
if [[ -n $ALL_FREQUENCY ]]; then
	touch "train_set.data" "test_set.data"
	awk -v START=$RESULTS_START_LINE -v SEP='\t' -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "train_set.data" 
	awk -v START=$RESULTS_START_LINE -v SEP='\t' -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "test_set.data" 	
	octave_output=$(octave --silent --eval "load_build_model('train_set.data','test_set.data',0,$(($EVENTS_COL_START-1)),$REGRESSAND_COL,'$EVENTS_LIST')" 2> /dev/null)
	rm "train_set.data" "test_set.data"
else
	unset -v data_count	
	while [[ $data_count -ne ${#FREQ_LIST[@]} ]]
	do
		unset -v octave_output				
		for count in `seq 0 $((${#FREQ_LIST[@]}-1))`
		do
			touch "train_set.data" "test_set.data"
			awk -v START=$RESULTS_START_LINE -v SEP='\t' -v FREQ=${FREQ_LIST[$count]} -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $4 == FREQ){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "train_set.data" 
			awk -v START=$RESULTS_START_LINE -v SEP='\t' -v FREQ=${FREQ_LIST[$count]} -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $4 == FREQ){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "test_set.data"
			octave_output+=$(octave --silent --eval "load_build_model('train_set.data','test_set.data',0,$(($EVENTS_COL_START-1)),$REGRESSAND_COL,'$EVENTS_LIST')" 2> /dev/null)
			rm "train_set.data" "test_set.data"
		done
		data_count=$(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Power"){ count++ }}END{print count}' )
	done	
fi
#Extract relevant informaton from octave
#Avg. Power
IFS=";" read -a avg_pow <<< $((echo "$octave_output" |awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Power"){ print $4 }}' ) | tr "\n" ";" | head -c -1)
#Measured Power Range
IFS=";" read -a pow_range <<< $((echo "$octave_output" |awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Measured" && $2=="Power" && $3=="Range"){ print $5 }}' ) | tr "\n" ";" | head -c -1)
#Average Pred. Power
IFS=";" read -a avg_pred_pow <<< $((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Predicted" && $3=="Power"){ print $5 }}' ) | tr "\n" ";" | head -c -1)
#Pred. Power Range
IFS=";" read -a pred_pow_range <<< $((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Predicted" && $2=="Power" && $3=="Range"){ print $5 }}' ) | tr "\n" ";" | head -c -1)
#Avg. Abs. Error
IFS=";" read -a avg_abs_err <<< $((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Absolute" && $3=="Error"){ print $5 }}' ) | tr "\n" ";" | head -c -1)
#Abs. Err. Std. Dev.
IFS=";" read -a std_dev_err <<< $((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Absolute" && $2=="Error" && $3=="Standart" && $4=="Deviation"){ print $6 }}' ) | tr "\n" ";" | head -c -1)
#Avg. Rel. Error
IFS=";" read -a rel_avg_abs_err <<< $((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Relative" && $3=="Error"){ print $5 }}' ) | tr "\n" ";" | head -c -1)
#Rel. Err. Std. Dev
IFS=";" read -a rel_avg_abs_err_std_dev <<< $((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Relative" && $2=="Error" && $3=="Standart" && $4=="Deviation"){ print $6 }}' ) | tr "\n" ";" | head -c -1)
#Model coefficients
IFS=";" read -a model_coeff <<< $((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Model" && $2=="coefficients:"){ print substr($0, index($0,$3)) }}' ) | tr "\n" ";" | head -c -1)

#Modify freqeuncy list first element to list "all"
[[ -n $ALL_FREQUENCY ]] && FREQ_LIST[0]=$(echo "all")
#Adjust output depending on mode  	
#I store the varaible references as special characters in the DATA string then eval to evoke subsittution. Eliminates repetitive code.
case $MODE in
	1)
		HEADER="CPU Frequency\tAverage Power [W]\tMeasured Power Range [%]\tAverage Predicted Power [W]\tPredicted Power Range [%]\tAverage Absolute Error [W]\tAbsolute Error Stdandart Deviation [W]\tAverage Relative Error [%]\tRelative Error Standart Deviation [%]\tModel coefficients"
		DATA="\${FREQ_LIST[\$i]}\t\${avg_pow[\$i]}\t\${pow_range[\$i]}\t\${avg_pred_pow[\$i]}\t\${pred_pow_range[\$i]}\t\${avg_abs_err[\$i]}\t\${std_dev_err[\$i]}\t\${rel_avg_abs_err[\$i]}\t\${rel_avg_abs_err_std_dev[\$i]}\t\${model_coeff[\$i]}"
		;;
	2)
		HEADER="CPU Frequency\tAverage Power [W]\tMeasured Power Range [%]\tAverage Predicted Power [W]\tPredicted Power Range [%]\tAverage Absolute Error [W]\tAbsolute Error Stdandart Deviation [W]\tAverage Relative Error [%]\tRelative Error Standart Deviation [%]"
		DATA="\${FREQ_LIST[\$i]}\t\${avg_pow[\$i]}\t\${pow_range[\$i]}\t\${avg_pred_pow[\$i]}\t\${pred_pow_range[\$i]}\t\${avg_abs_err[\$i]}\t\${std_dev_err[\$i]}\t\${rel_avg_abs_err[\$i]}\t\${rel_avg_abs_err_std_dev[\$i]}"
		;;
	3)
		HEADER="Average Predicted Power [W]\tPredicted Power Range [%]\tAverage Absolute Error [W]\tAbsolute Error Stdandart Deviation [W]\tAverage Relative Error [%]\tRelative Error Standart Deviation [%]"
		DATA="\${avg_pred_pow[\$i]}\t\${pred_pow_range[\$i]}\t\${avg_abs_err[\$i]}\t\${std_dev_err[\$i]}\t\${rel_avg_abs_err[\$i]}\t\${rel_avg_abs_err_std_dev[\$i]}"
		;;
esac  

#Output to file or terminal. First header, then data depending on model
#If per-frequency models, iterate frequencies then print
#If full frequency just print the one model
if [[ -z $SAVE_FILE ]]; then
	echo -e "--------------------" >&1
	echo -e $HEADER
	echo -e "--------------------" >&1
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
echo -e "--------------------" >&1
echo -e "====================" >&1
echo "Script Done!" >&1
echo -e "====================" >&1

