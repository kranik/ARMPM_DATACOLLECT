#!/bin/bash


if [[ "$#" -eq 0 ]]; then
  echo "This program requires inputs. Type -h for help." >&2
  exit 1
fi

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
while getopts ":r:f:b:s:m:hac" opt;
do
    case $opt in
        h)
        echo "Available flags and options:" >&1
        echo "-r [FILEPATH] -> Specify the concatednated results file to be analyzed." >&1
        echo "-f [FREQENCY LIST][MHz] -> Specify the frequencies to be analyzed, separated by commas." >&1
        echo "-b [FILEPATH] -> Specify the benchmark split file for the analyzed results. Can also use an unused filename to generate new split."
        echo "-s [FILEPATH] -> Specify the save file for the analyzed results." >&1
        echo "-c -> Replace dots with commas for upload into google docs." >&1
        echo "-a -> Use flag to specify all frequencies model instead of per frequency one." >&1
        echo "-m -> Mode of operation: 1 for benchmark set overview; 2 for event correlation coefficients; 3 for model performance; 4 for quick model performance metrics; 5 for model coefficients; 6 for avg. power run difference." >&1
        echo "Mandatory options are: -r"
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

        	spaced_OPTARG="${OPTARG//,/ }"

        	#Go throught the selected frequecnies and make sure they are not out of bounds
    		#Also make sure they are present in the frequency table located at /sys/devices/system/cpu/cpufreq/iks-cpufreq/freq_table because the kernel rounds up
        	#Specifying a higher/lower frequency or an odd frequency is now wrong, jsut the kernel handles it in the background and might lead to collection of unwanted resutls
        	
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
            	#wait on user input here (Y/N)
            	#if user says Y set writing directory to that
            	#if no then exit and ask for better input parameters
            	echo "-b $OPTARG does not exist. Do you want to create a new benchmark split and save in file? (Y/N)" >&1
            	read USER_INPUT
            	while true;
            	do
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
            	read USER_INPUT
            	while true;
            	do
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
        	else
        		MODE="$OPTARG"
        	fi      	
        	;;
        c)
        	if [[ -n $COMMAS_NOT_DOTS ]]; then
            	echo "Invalid input: option -c has already been used!" >&2
            	exit 1                
        	else
            	COMMAS_NOT_DOTS=1
        	fi
            ;;

        a)
        	if [[ -n $ALL_FREQUENCY ]]; then
            	echo "Invalid input: option -a has already been used!" >&2
            	exit 1                
        	else
            	ALL_FREQUENCY=1
        	fi
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

echo -e "===================="

if [[ -z $RESULTS_FILE ]]; then
    	echo "Nothing to run! Expected -r flag." >&2
    	echo -e "===================="
    	exit 1
fi

if [[ -z $MODE ]]; then
    	echo "No mode specified! Expected -m flag." >&2
    	echo -e "===================="
    	exit 1
fi

if [[ $MODE != "1" ]] && [[ $MODE != "2" ]] && [[ $MODE != "3" ]] && [[ $MODE != "4" ]] && [[ $MODE != "5" ]] && [[ $MODE != "6" ]]; then 
		echo "Invalid operarion: -m $MODE! Options are: 1 -> benchmark set overview; 2 -> event correlation coefficients; 3 -> model performance; 4 -> simplified model performance; 5 -> model coefficients; 6 -> avg. power run difference." >&2
    	echo -e "===================="
    	exit 1
fi		

#Frequency list sanity checks
if [[ -z $USER_FREQ_LIST ]]; then
    	echo "No user specified frequency list! Using default frequency list in results file." >&1
    	echo $RESULTS_FREQ_LIST
    	IFS="," read -a FREQ_LIST <<< "$RESULTS_FREQ_LIST"
else
		echo "Using user specified frequency list." >&1
    	echo $USER_FREQ_LIST
    	IFS="," read -a FREQ_LIST <<< "$USER_FREQ_LIST"		
fi

echo -e "===================="

if [[ -z $SAVE_FILE ]]; then 
	echo "No save file specified! Output to terminal." >&1
	echo -e "===================="
fi

if [[ -z $BENCH_FILE ]]; then
	echo "No benchmark file specified! Please use flag with existing file or an empty file to gererate random benchmark split." >&2
	echo -e "===================="
	exit 1
fi

#Benchmark sets and sanity cheks

echo -e "Train Set:"
echo -e "===================="

echo "${TRAIN_SET[*]}"

echo -e "===================="

echo -e "Test Set:"
echo -e "===================="

echo "${TEST_SET[*]}"

echo -e "===================="

#Issue warning if train sets are different sizes
if [[ ${#TRAIN_SET[@]} != ${#TEST_SET[@]} ]]; then 
	echo "Warning! Benchmark sets are different sizes [${#TRAIN_SET[@]};${#TEST_SET[@]}]" >&1
	echo -e "===================="
fi

#Check for dupicates in benchmark sets
for i in `seq 0 $((${#TEST_SET[@]}-1))`
do
	if [[ " ${TRAIN_SET[@]} " =~ " ${TEST_SET[$i]} " ]]; then
		echo -e "Warning! Benchmark sets share benchmark \"${TEST_SET[$i]}\"" >&1
		echo -e "===================="
	fi
done

#Create auxiliary files
touch "temp.data" "train_set.data" "test_set.data"

for i in `seq 0 $((${#FREQ_LIST[@]}-1))`
do
	#I tried storing the results from extracting frequencies in a string, but it proved way to painful to manipulate (new lines get omitted when saving) so im resorting to using a file again
	#I have optimised all other cases though
	
	if [[ $ALL_FREQUENCY == "1" ]]; then 
		awk -v START=$RESULTS_START_LINE -v SEP='\t' -v FREQ=${FREQ_LIST[$i]} 'BEGIN{FS = SEP}{if (NR > START && $4 == FREQ){print $0}}' $RESULTS_FILE >> "temp.data" 
	else 
		awk -v START=$RESULTS_START_LINE -v SEP='\t' -v FREQ=${FREQ_LIST[$i]} 'BEGIN{FS = SEP}{if (NR > START && $4 == FREQ){print $0}}' $RESULTS_FILE > "temp.data"
	fi
	
	#Uses temporary file generated from extracting freqeuncies. Array indexing starts at 1 in awk apparently.
	#I also use test and train set files to pass arguments in octave since I found that to be the easiest way and quickest for bug checking
	if [[ $ALL_FREQUENCY == "1" ]]; then 
		awk -v SEP='\t' -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}' "temp.data" >> "train_set.data" 
	else
		awk -v SEP='\t' -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}' "temp.data" > "train_set.data"
	fi
	
	if [[ $ALL_FREQUENCY == "1" ]]; then
		awk -v SEP='\t' -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY, / /)}{for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}' "temp.data" >> "test_set.data"
	else
		awk -v SEP='\t' -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY, / /)}{for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}' "temp.data" > "test_set.data"
	fi
	
	#If first mode just use the full of test data to collect benchmark overview.
	[[ $MODE == "1" ]] && cp "temp.data" "test_set.data"
		
	[[ $ALL_FREQUENCY != "1" ]] && octave_output+="$(octave --silent --eval "load_build_model( ${FREQ_LIST[$i]},$((${FREQ_LIST[$i+1]} - 100)) )" 2> /dev/null) "
	
	
done

#If all freqeuncy model then use all freqeuncies in octave
[[ $ALL_FREQUENCY == "1" ]] && octave_output="$(octave --silent --eval "load_build_model( ${FREQ_LIST[0]},$(( ${FREQ_LIST[$((${#FREQ_LIST[@]}-1))]} - 100 )) )" 2> /dev/null) "

#Cleanup files
rm "temp.data" "train_set.data" "test_set.data"

#Extract relevant informaton from octave
#Generic information
#Avg. Runtime
IFS=";" read -a avg_run <<< "$((echo "$octave_output" | awk -v SEP=' ' '{if ($1=="Avg." && $3=="Runtime"){ print $5 }}' ) | tr "\n" ";" | head -c -1)"
#Avg. Temp
IFS=";" read -a avg_t <<< "$((echo "$octave_output" |awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Avg." && $2=="Temperature"){ print $4 }}' ) | tr "\n" ";" | head -c -1)" 
#Avg. Curr.
IFS=";" read -a avg_c <<< "$((echo "$octave_output" |awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Avg." && $2=="Current"){ print $4 }}' ) | tr "\n" ";" | head -c -1)" 
#Avg. Volt.
IFS=";" read -a avg_v <<< "$((echo "$octave_output" |awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Avg." && $2=="Voltage"){ print $4 }}' ) | tr "\n" ";" | head -c -1)" 
#Avg. Power
IFS=";" read -a avg_pow <<< "$((echo "$octave_output" |awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Avg." && $2=="Power"){ print $4 }}' ) | tr "\n" ";" | head -c -1)" 
#Power Diff.
IFS=";" read -a pow_diff <<< "$((echo "$octave_output" | awk -v SEP=' ' '{if ($1=="Power" && $2=="Diff."){ print substr($0, index($0,$4)) }}' ) | tr "\n" ";" | head -c -1)"  
#Measured Power Range
IFS=";" read -a pow_range <<< "$((echo "$octave_output" |awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Measured" && $2=="Power"){ print $5 }}' ) | tr "\n" ";" | head -c -1)"


#Benchmark overview mode 1
#Avg. Totall Ev1.
IFS=";" read -a avg_ev1 <<< "$((echo "$octave_output" |awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Avg." && $3=="Ev1"){ print $5 }}' ) | tr "\n" ";" | head -c -1)" 
#Avg. Totall Ev2.
IFS=";" read -a avg_ev2 <<< "$((echo "$octave_output" |awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Avg." && $3=="Ev2"){ print $5 }}' ) | tr "\n" ";" | head -c -1)" 
#Avg. Totall Ev3.
IFS=";" read -a avg_ev3 <<< "$((echo "$octave_output" |awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Avg." && $3=="Ev3"){ print $5 }}' ) | tr "\n" ";" | head -c -1)" 
#Avg. Totall Ev4.
IFS=";" read -a avg_ev4 <<< "$((echo "$octave_output" |awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Avg." && $3=="Ev4"){ print $5 }}' ) | tr "\n" ";" | head -c -1)" 
#Avg. Totall Ev5.
IFS=";" read -a avg_ev5 <<< "$((echo "$octave_output" |awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Avg." && $3=="Ev5"){ print $5 }}' ) | tr "\n" ";" | head -c -1)" 

#Events correlation mode 2
#[1;2]
IFS=";" read -a corr_1_2 <<< "$((echo "$octave_output" | awk -v SEP=' ' '{if ($2=="correlation" && $6=="[2" && $7=="3]"){ print $9 }}' ) | tr "\n" ";" | head -c -1)" 
#[1;3]
IFS=";" read -a corr_1_3 <<< "$((echo "$octave_output" | awk -v SEP=' ' '{if ($2=="correlation" && $6=="[2" && $7=="4]"){ print $9 }}' ) | tr "\n" ";" | head -c -1)" 
#[1;4]
IFS=";" read -a corr_1_4 <<< "$((echo "$octave_output" | awk -v SEP=' ' '{if ($2=="correlation" && $6=="[2" && $7=="5]"){ print $9 }}' ) | tr "\n" ";" | head -c -1)" 
#[1;5]
IFS=";" read -a corr_1_5 <<< "$((echo "$octave_output" | awk -v SEP=' ' '{if ($2=="correlation" && $6=="[2" && $7=="6]"){ print $9 }}' ) | tr "\n" ";" | head -c -1)" 
#[2;3]
IFS=";" read -a corr_2_3 <<< "$((echo "$octave_output" | awk -v SEP=' ' '{if ($2=="correlation" && $6=="[3" && $7=="4]"){ print $9 }}' ) | tr "\n" ";" | head -c -1)" 
#[2;4]
IFS=";" read -a corr_2_4 <<< "$((echo "$octave_output" | awk -v SEP=' ' '{if ($2=="correlation" && $6=="[3" && $7=="5]"){ print $9 }}' ) | tr "\n" ";" | head -c -1)" 
#[2;5]
IFS=";" read -a corr_2_5 <<< "$((echo "$octave_output" | awk -v SEP=' ' '{if ($2=="correlation" && $6=="[3" && $7=="6]"){ print $9 }}' ) | tr "\n" ";" | head -c -1)" 
#[3;4]
IFS=";" read -a corr_3_4 <<< "$((echo "$octave_output" | awk -v SEP=' ' '{if ($2=="correlation" && $6=="[4" && $7=="5]"){ print $9 }}' ) | tr "\n" ";" | head -c -1)" 
#[3;5]
IFS=";" read -a corr_3_5 <<< "$((echo "$octave_output" | awk -v SEP=' ' '{if ($2=="correlation" && $6=="[4" && $7=="6]"){ print $9 }}' ) | tr "\n" ";" | head -c -1)" 
#[4;5]
IFS=";" read -a corr_4_5 <<< "$((echo "$octave_output" | awk -v SEP=' ' '{if ($2=="correlation" && $6=="[5" && $7=="6]"){ print $9 }}' ) | tr "\n" ";" | head -c -1)" 

#Model performance mode 3
#Average Pred. Power
IFS=";" read -a avg_pred_pow <<< "$((echo "$octave_output" | awk -v SEP=' ' '{if ($1=="Avg." && $2=="Pred." && $3=="Power"){ print $5 }}' ) | tr "\n" ";" | head -c -1)" 
#Pred. Power Range
IFS=";" read -a pred_pow_range <<< "$((echo "$octave_output" | awk -v SEP=' ' '{if ($1=="Pred." && $2=="Power" && $3=="Range"){ print $5 }}' ) | tr "\n" ";" | head -c -1)" 
#Avg. Error
IFS=";" read -a avg_err <<< "$((echo "$octave_output" | awk -v SEP=' ' '{if ($1=="Avg." && $2=="Error"){ print $4 }}' ) | tr "\n" ";" | head -c -1)" 
#Std. Dev. Error
IFS=";" read -a std_dev_err <<< "$((echo "$octave_output" | awk -v SEP=' ' '{if ($1=="Std." && $2=="Dev."){ print $5 }}' ) | tr "\n" ";" | head -c -1)" 
#Norm. RMS Error
IFS=";" read -a norm_rms_err <<< "$((echo "$octave_output" | awk -v SEP=' ' '{if ($1=="Norm." && $2=="RMS"){ print $5 }}' ) | tr "\n" ";" | head -c -1)"

#Model coefficients mode 5
IFS=";" read -a model_coeff <<< "$((echo "$octave_output" | awk -v SEP=' ' '{if ($1=="Model" && $2=="coefficients:"){ print substr($0, index($0,$3)) }}' ) | tr "\n" ";" | head -c -1)" 

#Modify freqeuncy list first element to list "all"
[[ $ALL_FREQUENCY == "1" ]] && FREQ_LIST[0]=$(echo "all")
	
#Adjust output depending on mode  	
#I store the varaible references as specail characters in the DATA string then eval to evoke subsittution. Eliminates repetitive code.
case $MODE in
	1)
		HEADER="Freq.\tAvg. Tot. Runtime\tAvg. Temp.\tAvg. Curr.\tAvg. Volt.\tAvg. Power\tMeas. Pow. Range\tAvg. Tot. Ev1\tAvg. Tot. Ev2\tAvg. Tot. Ev3\tAvg. Tot. Ev4\tAvg. Tot. Ev5"
		DATA="\${FREQ_LIST[\$i]}\t\${avg_run[\$i]}\t\${avg_t[\$i]}\t\${avg_c[\$i]}\t\${avg_v[\$i]}\t\${avg_pow[\$i]}\t\${pow_range[\$i]}\t\${avg_ev1[\$i]}\t\${avg_ev2[\$i]}\t\${avg_ev3[\$i]}\t\${avg_ev4[\$i]}\t\${avg_ev5[\$i]}"
		;;
	2)
		HEADER="Freq.\tCorr.[1;2]\tCorr.[1;3]\tCorr.[1;4]\tCorr.[1;5]\tCorr.[2;3]\tCorr.[2;4]\tCorr.[2;5]\tCorr.[3;4]\tCorr.[3;5]\tCorr.[4;5]"
		DATA="\${FREQ_LIST[\$i]}\t\${corr_1_2[\$i]}\t\${corr_1_3[\$i]}\t\${corr_1_4[\$i]}\t\${corr_1_5[\$i]}\t\${corr_2_3[\$i]}\t\${corr_2_4[\$i]}\t\${corr_2_5[\$i]}\t\${corr_3_4[\$i]}\t\${corr_3_5[\$i]}\t\${corr_4_5[\$i]}"
		;;
	3)
		HEADER="Freq.\tAvg. Total Runtime\tAvg. Power\tMeasured Power Range\tAvg. Pred. Power\tPred. Power Range\tAvg. Error\tStd. Dev. Error\tNorm. RMS Error"
		DATA="\${FREQ_LIST[\$i]}\t\${avg_run[\$i]}\t\${avg_pow[\$i]}\t\${pow_range[\$i]}\t\${avg_pred_pow[\$i]}\t\${pred_pow_range[\$i]}\t\${avg_err[\$i]}\t\${std_dev_err[\$i]}\t\${norm_rms_err[\$i]}"
		;;
	4)
		HEADER="Avg. Pred. Power\tPred. Power Range\tAvg. Error\tStd. Dev. Error\tNorm. RMS Error"
		DATA="\${avg_pred_pow[\$i]}\t\${pred_pow_range[\$i]}\t\${avg_err[\$i]}\t\${std_dev_err[\$i]}\t\${norm_rms_err[\$i]}"
		;;
	5)
		HEADER="Model coefficients:"
		DATA="\${model_coeff[\$i]}"
		;;
	6)
		HEADER="Power difference:"
		DATA="\${pow_diff[\$i]}" 
		;;	
esac  

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
		if [[ $COMMAS_NOT_DOTS ]]; then
			#The tabs all get removed after eval with spaces for some obscure reason so I have to resort to double echo (othersie i get just the "t" character and substituting spaes for tabs
			echo -e $(eval echo `echo -e "$DATA"`) | tr "." "," | tr " " "\t"
		else
			echo -e $(eval echo `echo -e "$DATA"`) | tr " " "\t"
		fi
	else
		if [[ $COMMAS_NOT_DOTS ]]; then
			echo -e $(eval echo `echo -e "$DATA"`) | tr "." "," | tr " " "\t" >> $SAVE_FILE
		else
			echo -e $(eval echo `echo -e "$DATA"`) >> $SAVE_FILE
		fi
	fi
	
	#If all freqeuncy model, there is just one line that needs to be printed
	[[ $ALL_FREQUENCY == "1" ]] && break;
	
done

echo "Done!"

