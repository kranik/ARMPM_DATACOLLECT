#!/bin/bash
#This is my main script to run benchmarks in parallel with sensor collection
#KrNikov 2014

#Global params for ODROID-XU3
BIG_MAX_CORE=7
BIG_MIN_CORE=4
BIG_MAX_F=2000000
BIG_MIN_F=200000

LITTLE_MAX_CORE=3
LITTLE_MIN_CORE=0
LITTLE_MAX_F=1400000
LITTLE_MIN_F=200000

            
if [[ "$#" -eq 0 ]]; then
  echo "This program requires inputs. Type -h for help." >&2
  exit 1
fi

#main loop b=big L=LITTLE s=save directory n=specify number of runs -t=benchmark directory -h=help
#requires getops, but this should not be an issue since ints built in bash
while getopts ":b:L:m:f:q:s:x:t:n:e:h" opt;
do
    case $opt in
        h)
            echo "Available flags and options:" >&2
            echo "-b [NUMBER] -> Turn on collection for big cores [benchmarks and monitors]. Specify number of cores to involve."
            echo "-L [NUMBER] -> Turn on collection for LITTLE cores [benchmarks and monitors]. Specify number of cores to involve."
            echo "-f [FREQEUNCIES] -> Specify frequencies in Hz, separated by commas. Range is determined by core type. First core type."
		echo "-q [FREQEUNCIES] -> Specify frequencies in Hz, separated by commas. Range is determined by core type. Second core (if selected)."
            echo "-s [DIRECTORY] -> Specify a save directory for the results of the different runs. If flag is not specified program uses current directory"
            echo "-x [DIRECTORY] -> Specify the benchmark executable to be run. If multiple benchmarks are to be ran, put them all in a script and set that."
            echo "-e [DIRECTORY] -> Specify the events to be collected. Event labels must be on line 1, separated by commas. Event RAW identifiers must be sepcified on line 2, separated by commas."
            echo "-t [NUMBER] -> Specify the sensor sampling time. It needs to be a positive integer."
            echo "-n [NUMBER] -> specify number of runs. Results from different runs are saved in subdirectories."
            echo "Mandatory options are: -b/-L [1-4] -f [FREQ LIST] -x [DIR] -t [NUM] -n [NUM]"
            exit 0 
            ;;
			
        b)
            #Make sure command has not already been processed (flag is unset)
			if [[ -n $BIG_CHOSEN ]]; then
				echo "Invalid input: option -b has already been used!" >&2
				exit 1
			else
				BIG_CHOSEN="$OPTARG"
			fi
		;;
		
	L)
            #Make sure command has not already been processed (flag is unset)
			if [[ -n $LITTLE_CHOSEN ]]; then
				echo "Invalid input: option -b has already been used!" >&2
				exit 1
			else
				LITTLE_CHOSEN="$OPTARG"
			fi
		;;

		f)
			if [[ -n $CORE1_FREQ ]]; then
				echo "Invalid input: option -f has already been used!" >&2
				exit 1
			else
				CORE1_FREQ="${OPTARG//,/ }"
			fi
		;;
		
		q)
			if [[ -n $CORE2_FREQ ]]; then
				echo "Invalid input: option -q has already been used!" >&2
				exit 1
			else
				CORE2_FREQ="${OPTARG//,/ }"
			fi
		;;		

        #Specify the save directory, if no save directory is chosen the results are saved in the $PWD
        s)
			if [[ -n $SAVE_DIR ]]; then
				echo "Invalid input: option -s has already been used!" >&2
				exit 1                
			fi

			if [[ -L "$OPTARG" ]]; then
				echo "-s $OPTARG is a symbolic link. Please enter a directory!" >&2
				exit 1
			elif [[ -d "$OPTARG" ]]; then
                    	#wait on user input here (Y/N)
                    	#if user says Y set writing directory to that
                    	#if no then exit and ask for better input parameters
                    	echo "-s $OPTARG already exists. Continue writing in directory? (Y/N)" >&1
                    	read USER_INPUT
                    	while true;
                    	do
                        	if [[ "$USER_INPUT" == Y || "$USER_INPUT" == y ]]; then
                            		echo "Using existing directory $OPTARG" >&1
                            		break
                        	elif [[ "$USER_INPUT" == N || "$USER_INPUT" == n ]]; then
                            		echo "Cancelled using save directory $OPTARG Program exiting." >&1
                            		exit 0                            
                        	else
                            		echo "Invalid input: $USER_INPUT !(Expected Y/N)" >&2
                            		exit 1
                        	fi
                    	done
                    	SAVE_DIR="$OPTARG"
                    	#Remove previosu results from the existing save directory structure. If you rerun MC.sh with different flags it might not overwrite all the old results, so this cleanup is necessary for correct analysis later on
                    	find "$SAVE_DIR/" -name "Run_*" -exec rm -r -v "{}" +
            	else
                	#directory does not exist, set mkdir flag. Directory is made only when results are successfully collected.
                	SAVE_DIR="$OPTARG"
            	fi
            	;;
        #specify the benchmark executable to be ran
        x)
            if [[ -n $BENCH_EXEC ]]; then
                echo "Invalid input: option -x has already been used!" >&2
                exit 1                
            fi
            #Make sure the benchmark directory selected exists
            if [[ ! -x "$OPTARG" ]]; then
                echo "-x $OPTARG is not an executable file or does not exist. Please enter the bechmark executable script/program!" >&2 
                exit 1
            else
                BENCH_EXEC="$OPTARG"
            fi
            ;;

        #specify the events list file
        e)
            if [[ -n $EVENTS_LIST_FILE ]]; then
                echo "Invalid input: option -e has already been used!" >&2
                exit 1
            fi
            #Make sure the selected events file exists
            if ! [[ -e "$OPTARG" ]]; then
                echo "-e $OPTARG does not exist. Please enter the events list file!" >&2
                exit 1
            else
                EVENTS_LIST_FILE="$OPTARG"
            fi
            ;;

        #specify the sensor sample time
        t)
            if [[ -n $SAMPLE_TIME ]]; then
                echo "Invalid input: option -t has already been used!" >&2
                exit 1
            fi
            if [[ "$OPTARG" -le 0 || "$OPTARG" -gt 999999999 ]]; then
                echo "Invalid input: option -t needs to have a positive integer and be less than 999999999 to prevent overflow!" >&2
                exit 1
            else
                SAMPLE_TIME="$OPTARG"
            fi
            ;;
        #Choose the number of runs. Data from different runs is saved in Run_(run number) subfolders in the save directory
        n)
            if [[ -n $NUM_RUNS ]]; then
                echo "Invalid input: option -n has already been used!" >&2
                exit 1                
            fi
            if [[ "$OPTARG" -le 0 ]]; then
                echo "Invalid input: option -n needs to have a positive integer!" >&2
                exit 1
            else        
                NUM_RUNS="$OPTARG"                        
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

#Critical checks
if [[ -z $BIG_CHOSEN && -z $LITTLE_CHOSEN ]]; then
    	echo "Nothing to run. Expected -b or -L flag (or both)!" >&2
    	exit 1
fi

if [[ -z $CORE1_FREQ ]]; then
    	echo "Nothing to run. Expected -f flag!" >&2
    	exit 1
fi

if [[ -n $BIG_CHOSEN && -n $LITTLE_CHOSEN && -z $CORE2_FREQ ]]; then
    	echo "Error: Expected -q flag when both -b and -L are selected to specify LITTLE core freqeuncy list!" >&2
    	exit 1
fi

if [[ -z $NUM_RUNS ]]; then
    	echo "Nothing to run. Expected -n flag!" >&2
    	exit 1
fi

if [[ -z $BENCH_EXEC ]]; then
    	echo "Nothing to run. Expected -x flag!" >&2
    	exit 1
fi

if [[ -z $SAMPLE_TIME ]]; then
        echo "Nothing to run. Expected -t flag!" >&2
        exit 1
fi

#Additional checks
if [[ -n $BIG_CHOSEN ]]; then
	if ! [[ "$BIG_CHOSEN" =~ ^[1-4]$ ]]; then
		echo "Invalid input: -b needs to be 1-4 (number of cores)!" >&2
		exit 1
	fi
	#Freq check
	for FREQ_SELECT in $CORE1_FREQ
	do
		if [[ $FREQ_SELECT -gt $BIG_MAX_F || $FREQ_SELECT -lt $BIG_MIN_F ]]; then 
			echo "selected frequency $FREQ_SELECT for -f is out of bounds for selected big cores (-b). Range is [$BIG_MIN_F;$BIG_MAX_F]"
			exit 1
		fi
	done
	
	if [[ -n $LITTLE_CHOSEN ]]; then
		if ! [[ "$LITTLE_CHOSEN" =~ ^[1-4]$ ]]; then
			echo "Invalid input: -b needs to be 1-4 (number of cores)!" >&2
			exit 1
		fi
		#Freq check
		for FREQ_SELECT in $CORE2_FREQ
		do
			if [[ $FREQ_SELECT -gt $LITTLE_MAX_F || $FREQ_SELECT -lt $LITTLE_MIN_F ]]; then 
				echo "selected frequency $FREQ_SELECT for -q is out of bounds for selected big cores (-L). Range is [$LITTLE_MIN_F;$LITTLE_MAX_F]"
				exit 1
			fi
		done
		#Set max and min core
		MIN_CORE="$LITTLE_MIN_CORE"
		MAX_CORE="$BIG_MAX_CORE"
		CORE_CHOSEN=$(echo "scale = 0; $LITTLE_CHOSEN+$BIG_CHOSEN;" | bc )
	else
		#Set max and min core
		MIN_CORE="$BIG_MIN_CORE"
		MAX_CORE="$BIG_MAX_CORE"
		CORE_CHOSEN="$BIG_CHOSEN"
	fi
else
	if ! [[ "$LITTLE_CHOSEN" =~ ^[1-4]$ ]]; then
		echo "Invalid input: -L needs to be 1-4 (number of cores)!" >&2
		exit 1
	fi
	#Freq check
	for FREQ_SELECT in $CORE1_FREQ
	do
		if [[ $FREQ_SELECT -gt $LITTLE_MAX_F || $FREQ_SELECT -lt $LITTLE_MIN_F ]]; then
			echo "selected frequency $FREQ_SELECT for -f is out of bounds for selected big cores (-L). Range is [$LITTLE_MIN_F;$LITTLE_MAX_F]"
			exit 1
		fi
	done
	#Set max and min core
	MIN_CORE="$LITTLE_MIN_CORE"
	MAX_CORE="$LITTLE_MAX_CORE"
	CORE_CHOSEN="$LITTLE_CHOSEN"
fi

SAMPLE_NS=$SAMPLE_TIME
SAMPLE_MS=$(echo "scale = 0; $SAMPLE_NS/1000000;" | bc )

COREs=($(awk '{if($1 == "processor") print $3}' /proc/cpuinfo))
for i in $(seq 0 $((${#COREs[@]} - 1)))
do
	if [[ ${COREs[$i]} -ge $MIN_CORE && ${COREs[$i]} -le $MAX_CORE ]]; then
		if [[ -z "$CORE_RUN" ]]; then 
			CORE_RUN="${COREs[$i]}"
		else
			#due to a bug in cpuset need to set the shield before I turn cores offline, hence not doing it here bit sumply storing them in an array
			#I store hotplug core names with commas to keep it consistent even though I can just iterate through the list better with spaces in the array
			if [[ $(( $(echo "$CORE_RUN" | tr -cd ',' | wc -c) + 1 )) < $CORE_CHOSEN ]]; then
				CORE_RUN+=",${COREs[$i]}"
			elif [[ -z "$CORE_HOTPLUG" ]]; then
                        	CORE_HOTPLUG="${COREs[$i]}"
			else
				CORE_HOTPLUG+=",${COREs[$i]}"
			fi
		fi	
	else
                if [[ -z "$CORE_COLLECT" ]]; then 
                        CORE_COLLECT="${COREs[$i]}"
                else    
                        [[ $(( $(echo "$CORE_COLLECT" | tr -cd ',' | wc -c) + 1 )) < $CORE_CHOSEN ]] && CORE_COLLECT+=",${COREs[$i]}"
                fi
	fi
done

if [[ $(( $(echo "$CORE_RUN" | tr -cd ',' | wc -c) + 1 )) < $CORE_CHOSEN ]]; then
	echo -e "Selected number of run COREs more than what the environment provides. Please check total number of enabled COREs on the system." >&2
	exit 1
else
	cset shield -c "$CORE_RUN" -k on --force
fi


#Turning off unwanted cores to enable directed cluster sensor readings
for i in ${CORE_HOTPLUG//,/ }
do
	echo 0 > "/sys/devices/system/cpu/cpu$i/online"
done

echo "Sanity check."

cpufreq-set -d 2000000 -u 2000000 -c 4
cpufreq-set -d 1400000 -u 1400000 -c 0

cpufreq-info
cset shield

#Turn on fan on max power to avoid throttling on 4 cores.
#Start manual mode
echo 0 > "/sys/devices/odroid_fan.15/fan_mode"
#Put fan on MAX RPM
echo 255 > "/sys/devices/odroid_fan.15/pwm_duty"

#Run benchmarks for specified number of runs
for i in $(seq 1 "$NUM_RUNS");
do   
	echo "This is run $i out of $NUM_RUNS"                    
	for FREQ_SELECT in $CORE1_FREQ
	do
		#Check for double core
	    if [[ -n $BIG_CHOSEN && -n $LITTLE_CHOSEN ]]; then
			cpufreq-set -d "$FREQ_SELECT" -u "$FREQ_SELECT" -c 4
			echo "Core frequency (big): $FREQ_SELECT""Mhz"
			for FREQ2_SELECT in $CORE2_FREQ
			do
				cpufreq-set -d "$FREQ2_SELECT" -u "$FREQ2_SELECT" -c 0
				echo "Core frequency (LITTLE): $FREQ2_SELECT""Mhz"
				#Run collections scripts in parallel to the benchmarks.
				#I can input the number of enabled LITTLE and big cores for sensor script, but for now I don't care about individual temperature so I'm just using 1 1 to save space on the output files. freq/volt/curr/power are all agreated per-cluster so 1 1 enables me to get that inforamtion from the sensors for both clusters. 
				#The only benefit of adding the involved cores would be to give me per-core temperature information, but those are normalized by the big fan anyway.
				#Technically CORE_CHOSEN represents number of big cores, size of CORE_COLLECT represent number of LITTLE and I can specify those for the sensors collection in the future if I need to.
				./sensors 1 1 "$SAMPLE_NS" > "sensors.data" &
				PID_sensors=$!
				disown
				
				#Run collections scripts in parallel to the benchmarks
				#taskset -c $CORE_COLLECT ./get_cpu_usage.sh -c $CORE_RUN -t $SAMPLE_NS > "usage.data" &
				#PID_usage=$!
				#disown
				
				if [[ -n $EVENTS_LIST_FILE ]]; then
					#If there is a specified events list then start events collection
					 ./get_cpu_events.sh -c "$CORE_RUN" -s "benchmarks.data" -x "$BENCH_EXEC" -e "$EVENTS_LIST_FILE" -t "$SAMPLE_MS" 2> "events_raw.data" 
				else
					#Else initiate collection without PMU events just power data (this is useful for overhead computation). Note that the $BENCH_EXEC is a wrapper that gets the nubmer of cores chosen to run. This is to enable PARSEC multithreading or to run cBench multiple concurrent times. We can also specify the core list as safe check to use taskset in the bench exec.	
					$BENCH_EXEC "$CORE_CHOSEN" "$CORE_RUN"  > "benchmarks.data"
				fi
			
				#after benchmarks have run kill sensor collect and smartpower (if chosen)
				sleep 1
				kill $PID_sensors > /dev/null
				#kill $PID_usage > /dev/null
				sleep 1
				echo "Data collection completed successfully"

				#Organize results -> copy them in the save dir that is specified or put them in the PWD
				if [[ -n $SAVE_DIR ]]; then
					mkdir -v -p "$SAVE_DIR/Run_$i/$FREQ_SELECT""_$FREQ2_SELECT"
					echo "Copying results to chosen dir: $SAVE_DIR/Run_$i/$FREQ_SELECT""_$FREQ2_SELECT"
					cp -v "sensors.data" "benchmarks.data" "$SAVE_DIR/Run_$i/$FREQ_SELECT""_$FREQ2_SELECT"
					rm -v "sensors.data" "benchmarks.data"
					#if we have event collection enabled, then copy those too
					if [[ -n $EVENTS_LIST_FILE ]]; then
						cp -v "events_raw.data" "$SAVE_DIR/Run_$i/$FREQ_SELECT""_$FREQ2_SELECT"
						rm -v "events_raw.data"
					fi
				else
					mkdir -v -p "Run_$i/$FREQ_SELECT""_$FREQ2_SELECT"
					echo "Copying results to dir: Run_$i/$FREQ_SELECT""_$FREQ2_SELECT"
					cp -v "sensors.data" "benchmarks.data" "Run_$i/$FREQ_SELECT""_$FREQ2_SELECT"
					rm -v "sensors.data" "benchmarks.data"
					if [[ -n $EVENTS_LIST_FILE ]]; then
						cp -v "events_raw.data" "Run_$i/$FREQ_SELECT""_$FREQ2_SELECT"
						rm -v "events_raw.data"
					fi
				fi
			done
		else
			cpufreq-set -d "$FREQ_SELECT" -u "$FREQ_SELECT" -c "$CORE_RUN"
			echo "Core frequency: $FREQ_SELECT""Mhz"
			#Run collections scripts in parallel to the benchmarks.
			#I can input the number of enabled LITTLE and big cores for sensor script, but for now I don't care about individual temperature so I'm just using 1 1 to save space on the output files. freq/volt/curr/power are all agreated per-cluster so 1 1 enables me to get that inforamtion from the sensors for both clusters. 
			#The only benefit of adding the involved cores would be to give me per-core temperature information, but those are normalized by the big fan anyway.
			#Technically CORE_CHOSEN represents number of big cores, size of CORE_COLLECT represent number of LITTLE and I can specify those for the sensors collection in the future if I need to.
			./sensors 1 1 "$SAMPLE_NS" > "sensors.data" &
			PID_sensors=$!
			disown
			
			#Run collections scripts in parallel to the benchmarks
			#taskset -c $CORE_COLLECT ./get_cpu_usage.sh -c $CORE_RUN -t $SAMPLE_NS > "usage.data" &
			#PID_usage=$!
			#disown
			
			if [[ -n $EVENTS_LIST_FILE ]]; then
				#If there is a specified events list then start events collection
				 ./get_cpu_events.sh -c "$CORE_RUN" -s "benchmarks.data" -x "$BENCH_EXEC" -e "$EVENTS_LIST_FILE" -t "$SAMPLE_MS" 2> "events_raw.data" 
			else
				#Else initiate collection without PMU events just power data (this is useful for overhead computation). Note that the $BENCH_EXEC is a wrapper that gets the nubmer of cores chosen to run. This is to enable PARSEC multithreading or to run cBench multiple concurrent times
				$BENCH_EXEC "$CORE_CHOSEN" "$CORE_RUN" > "benchmarks.data"
			fi
		
			#after benchmarks have run kill sensor collect and smartpower (if chosen)
			sleep 1
			kill $PID_sensors > /dev/null
			#kill $PID_usage > /dev/null
			sleep 1
					echo "Data collection completed successfully"

			#Organize results -> copy them in the save dir that is specified or put them in the PWD
			if [[ -n $SAVE_DIR ]]; then
				mkdir -v -p "$SAVE_DIR/Run_$i/$FREQ_SELECT"
				echo "Copying results to chosen dir: $SAVE_DIR/Run_$i/$FREQ_SELECT"
				cp -v "sensors.data" "benchmarks.data" "$SAVE_DIR/Run_$i/$FREQ_SELECT"
				rm -v "sensors.data" "benchmarks.data"
				#if we have event collection enabled, then copy those too
				if [[ -n $EVENTS_LIST_FILE ]]; then
					cp -v "events_raw.data" "$SAVE_DIR/Run_$i/$FREQ_SELECT"
					rm -v "events_raw.data"
				fi
			else
				mkdir -v -p "Run_$i/$FREQ_SELECT"
				echo "Copying results to dir: Run_$i/$FREQ_SELECT"
				cp -v "sensors.data" "benchmarks.data" "Run_$i/$FREQ_SELECT"
				rm -v "sensors.data" "benchmarks.data"
				if [[ -n $EVENTS_LIST_FILE ]]; then
					cp -v "events_raw.data" "Run_$i/$FREQ_SELECT"
					rm -v "events_raw.data"
				fi
			fi
		fi
	done
done

echo "Returning environment to previous state"
for i in ${CORE_HOTPLUG//,/ }
do
	echo 1 > "/sys/devices/system/cpu/cpu$i/online"
done
cpufreq-set -d 2000000 -u 2000000 -c 4
cpufreq-set -d 1400000 -u 1400000 -c 0
cset shield --reset

echo "Sanity check."
cpufreq-info
cset shield

#Put back fan on automatic mode
echo 1 > "/sys/devices/odroid_fan.15/fan_mode"

echo "Script End! :)"
exit
