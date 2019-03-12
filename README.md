# Data collection for use in power model generation for ARM big.LITTLE aka ARMPM\_DATACOLLECT

**August 2017 - Since adding parsec-3.0 to the workload selection and updating the main control script for multithread execution, this part of the project is finished.**

**February 2019 - I have reopened the [ARMPM\_BUILDMODEL](https://github.com/kranik/ARMPM_BUILDMODEL) project once again, however [ARMPM\_DATACOLLECT](https://github.com/kranik/ARMPM\_DATACOLLECT) is still considered complete since I am not planning on altering the data collection.** 

Full details about the methodology and the produced models are presented in the dissertation [**Power Modelling and Analysis on Heterogeneous Embedded Systems**](https://seis.bristol.ac.uk/~eejlny/downloads/kris_thesis.pdf).

## Getting Started

This software repo contains the data collection scripts that run the workoads and collect the on-board power sensor and PMU ardware event samples that are later used in [ARMPM\_BUILDMODEL](https://github.com/kranik/ARMPM_BUILDMODEL) to generate accurate power models. The final methodology is built and tested on the HARDKERNEL [ODROID-XU3](https://wiki.odroid.com/old_product/odroid-xu3/odroid-xu3) development board. The methodology is portable and can be ported to other platform if needed as long as the specific power and PMU event collection mechanism are updated for new platforms.

### Prerequisites and Setup

These are platform specific, however I have provided a very comprehensive set-up guide for the ODROID-XU3 at [XU3SETUP.md](XU3SETUP.md). Please refer to those instructions for ways to port the methodology to other platform or alter the workloads used in the methodology.

## Usage

After setting up the platform, loading the repository locally, compiling the auxiliarry programs and workloads, usage is pretty straightformward. The methodology uses [`MC_XU3.sh`](Scripts/ODROID_XU3/MC_XU3.sh) as the main control script to call the workloads and collect data. It has multiple options to indicate what data to collect and what is the benchmark executable. I have used the [`cset`](http://manpages.ubuntu.com/manpages/bionic/man1/cset.1.html) ustility to isolate OS and data collection overhead. The main control script requires a specific format of input files and folder so please refer to the source and examples provided to make sure new additions are compatible. The data collection methodology runs the workloads and in parallel collects data from multiple streams of information, namely the PMU hardware event counters and the on-board power sensors. The different data samples are all timestamped so that they can be analysed and concatenated later on by the [ARMPM\_BUILDMODEL](https://github.com/kranik/ARMPM_BUILDMODEL) scripts.

Example usage would be:
```
$ ./MC_XU3.sh -L 4 -f 1400000,200000 -n 3 -x /home/ARMPM_DATACOLLECT/Workloads/parsec-3.0/parsec_benchlist_timestamp_cset.sh -e /home/ARMPM_DATACOLLECT/ODROID_XU3/events_list_multithread/LITTLE/events_list_LITTLE_mt.data -t 500000000 -s /home/ARMPM_DATACOLLECT/Results/
```

Which calls the control script, specifying execution of the workload `/home/ARMPM_DATACOLLECT/Workloads/parsec-3.0/parsec_benchlist_timestamp_cset.sh` on 4 Cortex-A7 cores at 1.4 and 0.2GHz for 3 runs. The events to collect are specified in the file `/home/ARMPM_DATACOLLECT/ODROID_XU3/events_list_multithread/LITTLE/events_list_LITTLE_mt.data` and all the result files are stored in `/home/ARMPM_DATACOLLECT/Results/`. This is just an example call to the main script, so please refer to the comments in the source to understand the input flags. If you have any questions please contact me via [email](mailto:kris.nikov@bris.ac.uk).

### Troubleshooting

All the scripts have a `-h` flag which lists the possible number of inputs/flags and explains what their functionality is. An example is given below:
```
$ ./MC_XU3.sh -h
Available flags and options:
-b [NUMBER] -> Turn on collection for big cores [benchmarks and monitors]. Specify number of cores to involve.
-L [NUMBER] -> Turn on collection for LITTLE cores [benchmarks and monitors]. Specify number of cores to involve.
-f [FREQEUNCIES] -> Specify frequencies in Hz, separated by commas. Range is determined by core type. First core type.
-q [FREQEUNCIES] -> Specify frequencies in Hz, separated by commas. Range is determined by core type. Second core (if selected).
-s [DIRECTORY] -> Specify a save directory for the results of the different runs. If flag is not specified program uses current directory
-x [DIRECTORY] -> Specify the benchmark executable to be run. If multiple benchmarks are to be ran, put them all in a script and set that.
-e [DIRECTORY] -> Specify the events to be collected. Event labels must be on line 1, separated by commas. Event RAW identifiers must be sepcified on line 2, separated by commas.
-t [NUMBER] -> Specify the sensor sampling time. It needs to be a positive integer.
-n [NUMBER] -> specify number of runs. Results from different runs are saved in subdirectories.
Mandatory options are: -b/-L [1-4] -f [FREQ LIST] -x [DIR] -t [NUM] -n [NUM]
```

Again, the code is also heavily commented, so please check the source first before sending me a message.

## Contributing

So far I am the sole contributor, but if this project gets traction I will generate a proper Code of Conduct document and set some rules. For now please use the [ShellCheck](https://www.shellcheck.net/) bash code linter to verify your code and comment thoroughly. 

## Author

The work presented here was carried out almost entirely by me (so far), [Dr Kris Nikov](mailto:kris.nikov@bris.ac.uk) as part of my PhD project in the Department of Electrical and Electronic Enginnering at the Univeristy of Bristol, UK. I have received some minor contrubutions such as the initial code for the OLS model fitting in octave, given to me by my academic supervisor [Dr Jose Nunez-Yanez](http://www.bristol.ac.uk/engineering/people/jose-l-nunez-yanez/overview.html). I have also used a kernel patch, provided by my industrial supervisor [Dr Matt Horsnell](https://uk.linkedin.com/in/matthorsnell), which enables the on-board PMU on the ODROID-XU3 development board.

## Licence

This project is licensed under the BSD-3 License - please see [LICENSE.md](LICENSE.md) for more details.

## Acknowledgements

The primary project supervisor was [Dr Jose Nunez-Yanez](http://www.bristol.ac.uk/engineering/people/jose-l-nunez-yanez/overview.html). This work was initially supported by [ARM Research](https://www.arm.com/resources/research) funding, through an EPSRC iCASE studentship and the [University of Bristol](http://www.bristol.ac.uk/doctoral-college/) and by the EPSRC ENEAC grant number EP/N002539/1. Industrial project supervisor was [Dr Matt Horsnell](https://uk.linkedin.com/in/matthorsnell)