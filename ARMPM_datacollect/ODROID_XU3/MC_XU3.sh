#!/bin/bash
#This is my main script to run benchmarks in parallel with sensor collection
#KrNikov 2014

if [[ "$#" -eq 0 ]]; then
  echo "This program requires inputs. Type -h for help." >&2
  exit 1
fi

#main loop b=big L=LITTLE s=save directory n=specify number of runs -t=benchmark directory -h=help
#requires getops, but this should not be an issue since ints built in bash
while getopts ":b:L:f:s:x:t:n:e:h" opt;
do
    case $opt in
        h)
            echo "Available flags and options:" >&2
            echo "-b [NUMBER] -> Turn on collection for big cores [benchmarks and monitors]. Specify number of cores to involve."
            echo "-L [NUMBER] -> Turn on collection for LITTLE cores [benchmarks and monitors]. Specify number of cores to involve."
            echo "-f [FREQEUNCIES] -> Specify frequencies in Hz, separated by commas. Range is determined by core type."
            echo "-s [DIRECTORY] -> Specify a save directory for the results of the different runs. If flag is not specified program uses current directory"
            echo "-x [DIRECTORY] -> Specify the benchmark executable to be run. If multiple benchmarks are to be ran, put them all in a script and set that."
            echo "-e [DIRECTORY] -> Specify the events to be collected. Event labels must be on line 1, separated by commas. Event RAW identifiers must be sepcified on line 2, separated by commas."
            echo "-t [NUMBER] -> Specify the sensor sampling time. It needs to be a positive integer."
            echo "-n [NUMBER] -> specify number of runs. Results from different runs are saved in subdirectories."
            echo "Mandatory options are: -b/-L [1-4] -f [FREQ LIST] -x [DIR] -t [NUM] -n [NUM]"
            exit 0 
            ;;
        b|L)
            #Make sure command has not already been processed (flag is unset)
            	if [[ -n $CORE_CHOSEN ]]; then
                	echo "Invalid input: option -b or -L has already been used!" >&2
                	exit 1
		fi
                
		if ! [[ "$OPTARG" =~ ^[1-4]$ ]]; then
                	echo "Invalid input: $OPTARG needs to be 1-4 (number of cores)!" >&2
			exit 1
		fi

		if [[ $opt == b ]]; then
			MAX_CORE=7
			MIN_CORE=4
			CORE_COLLECT_FREQ=1400000
               		MAX_F=2000000
             		MIN_F=200000
               	else
			MAX_CORE=3
			MIN_CORE=0
			CORE_COLLECT_FREQ=2000000
               		MAX_F=1400000
               		MIN_F=200000
              	fi
               	
		CORE_CHOSEN="$OPTARG"
		;;

	f)
                if [[ -n $CORE_FREQ ]]; then
                        echo "Invalid input: option -f has already been used!" >&2
                        exit 1
                fi

            	spaced_OPTARG="${OPTARG//,/ }"

            	#Go throught the selected frequecnies and make sure they are not out of bounds
	    	#Also make sure they are present in the frequency table located at /sys/devices/system/cpu/cpufreq/iks-cpufreq/freq_table because the kernel rounds up
            	#Specifying a higher/lower frequency or an odd frequency is now wrong, jsut the kernel handles it in the background and might lead to collection of unwanted resutls
            	for FREQ_SELECT in $spaced_OPTARG
            	do
            		if [[ $FREQ_SELECT -gt $MAX_F || $FREQ_SELECT -lt $MIN_F ]]; then 
		    		echo "selected frequency $FREQ_SELECT for -$opt is out of bounds. Range is [$MAX_F;$MIN_F]"
                    		exit 1
                	else
				[[ -z "$CORE_FREQ" ]] && CORE_FREQ="$FREQ_SELECT" || CORE_FREQ+=" $FREQ_SELECT"
                    	fi
            	done
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

        #specify the benchmark executable to be ran
        e)
            if [[ -n $EVENTS_LIST_FILE ]]; then
                echo "Invalid input: option -e has already been used!" >&2
                exit 1
            fi
            #Make sure the benchmark directory selected exists
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
            if [[ "$OPTARG" -le 0 ]]; then
                echo "Invalid input: option -n needs to have a positive integer!" >&2
                exit 1
            else
                SAMPLE_TIME="$OPTARG"
            fi
            ;;

        n)
            #Choose the number of runs. Data from different runs is saved in Run_(run number) subfolders in the save directory
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

#Check if user has specified something to run
if [[ -z $CORE_CHOSEN ]]; then
    	echo "Nothing to run. Expected -b or -L flag!" >&2
    	exit 1
fi

if [[ -z $CORE_FREQ ]]; then
    	echo "Nothing to run. Expected -f flag!" >&2
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

if [[ -z $EVENTS_LIST_FILE ]]; then
        echo "Invalid input: option -e (events list) has not been specified!" >&2
        exit 1
fi

if [[ -z $SAMPLE_TIME ]]; then
        echo "Nothing to run. Expected -t flag!" >&2
        exit 1
fi

SAMPLE_NS=$SAMPLE_TIME
SAMPLE_MS=$(echo "scale = 0; $SAMPLE_NS/1000000;" | bc )

COREs=($(awk '{if($1 == "processor") print $3}' /proc/cpuinfo))
for i in `seq 0 $((${#COREs[@]} - 1))`
do
	if [[ ${COREs[$i]} -ge $MIN_CORE && ${COREs[$i]} -le $MAX_CORE ]]; then
		if [[ -z "$CORE_RUN" ]]; then 
			CORE_RUN="${COREs[$i]}"
		else
			#due to a bug in cpuset need to set the shield before I turn cores offline, hence not doing it here bit sumply storing them in an array
			#I store hotplug core names with commas to keep it consistent even though I can just iterate through the list better with spaces in the array
			if [[ $(( `echo $CORE_RUN | tr -cd ',' | wc -c` + 1 )) < $CORE_CHOSEN ]]; then
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
                        [[ $(( `echo $CORE_COLLECT | tr -cd ',' | wc -c` + 1 )) < $CORE_CHOSEN ]] && CORE_COLLECT+=",${COREs[$i]}"
                fi
	fi
done


if [[ $(( `echo $CORE_RUN | tr -cd ',' | wc -c` + 1 )) < $CORE_CHOSEN ]]; then
	echo -e "Selected number of run COREs more than what the environment provides. Please check total number of enabled COREs on the system." >&2
	exit 1
else
	echo "core_run = "$CORE_RUN
	cset shield -c $CORE_RUN -k on --force
fi


if [[ -z "$CORE_COLLECT" ]]; then
	echo -e "The system does not have any COREs left to collect results. This can result in unwanted overhead and skew the power consumption of the monitored run COREs. Continue with execution? (Y/N)" >&1
	read USER_INPUT
	while true;
	do
		if [[ "$USER_INPUT" == Y || "$USER_INPUT" == y ]]; then
			echo "Continuing with program." >&1
			break
		elif [[ "$USER_INPUT" == N || "$USER_INPUT" == n ]]; then
			echo "Program exiting." >&1
			exit 0                            
		else
			echo "Invalid input: $USER_INPUT !(Expected Y/N)" >&2
			exit 1
		fi
	done
fi

echo "core_hotplug = "$CORE_HOTPLUG
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

#Run benchmarks for specified number of runs
for i in `seq 1 $NUM_RUNS`;
do   
	echo "This is run $i out of $NUM_RUNS"                    
	for FREQ_SELECT in $CORE_FREQ
	do
		cpufreq-set -d $FREQ_SELECT -u $FREQ_SELECT -c $CORE_RUN
		echo "Core frequency: $FREQ_SELECT""Mhz" 
		
		#Run collections scripts in parallel to the benchmarks
		./sensors 1 1 $SAMPLE_NS > "sensors.data" &
		PID_sensors=$!
		disown
		
		#Run collections scripts in parallel to the benchmarks
		#taskset -c $CORE_COLLECT ./get_cpu_usage.sh -c $CORE_RUN -t $SAMPLE_NS > "usage.data" &
		#PID_usage=$!
		#disown

		./get_cpu_events.sh -c $CORE_RUN -s "benchmarks.data" -x $BENCH_EXEC -e $EVENTS_LIST_FILE -t $SAMPLE_MS 2> "events_raw.data" 

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
			cp -v "sensors.data" "benchmarks.data" "events_raw.data" "$SAVE_DIR/Run_$i/$FREQ_SELECT"
			rm -v "sensors.data" "benchmarks.data" "events_raw.data"
		else
			mkdir -v -p "Run_$i/$FREQ_SELECT"
			echo "Copying results to dir: Run_$i/$FREQ_SELECT"
			cp -v "sensors.data" "benchmarks.data" "events_raw.data" "Run_$i/$FREQ_SELECT"
			rm -v "sensors.data" "benchmarks.data" "events_raw.data"
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

echo "Script End! :)"
exit
