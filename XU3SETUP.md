# Setting up the ODROID-XU3 platform for use in the ARMPM\_DATACOLLECT experiments

**March 2019 - This guide has been added to the project reposityry to help future research parties. Unfortunately the ODROID-XU3 board is no longer manufactured and the superceeding eneration, the [ODROID-XU4](https://www.hardkernel.com/shop/odroid-xu4/) does not have on-board power sensors so its not useful for this project.**

## Getting started

This is a guide on setting up the [ODROID-XU3](https://wiki.odroid.com/old_product/odroid-xu3/odroid-xu3) development platform/board for use in the power-modelling experiments as part of my research project [ARMPM\_DATACOLLECT](https://github.com/kranik/ARMPM_DATACOLLECT).

This process involves a few steps with details for each one listed below.
1. Install the OS. I use `ubuntu-16.04-minimal` with kernel version `3.10.106+` which is modified by HARDKERNEL, specifically for the ODROID-XU3 platform.
2. Install supporting programs. This involves installing [`perf`](https://perf.wiki.kernel.org/index.php/Main_Page), updating the kernel with PMU support and interfacng with the on-board monitors. 
3. Install the workloads to be used for power modelling. I use [_cBench\\_V1.1_](http://ctuning.org/wiki/index.php/CTools:CBench:Downloads) and [_parsec-3.0_](https://parsec.cs.princeton.edu/) and provide modified shell scripts to conrol the workload execution specific to each benchmark suite in the methodology. The software reposityory does not include the workload binaries or source due to upload limit limitations.

## Installing the OS

Download `ubuntu-16.04-minimal-odroid-xu3-20170727.img.xz` from [_here_](https://odroid.in/?directory=.%2Fubuntu_16.04lts%2F) or [_here_](https://odroid.in/ubuntu_16.04lts/ubuntu-16.04-mate-odroid-xu3-20170731.img.xz).
Then copy the image on an microSD or an eMMC card. Hardkernel provide ther own eMMC cards for use with the boards [_here_](https://www.hardkernel.com/shop/16gb-emmc-module-xu4-linux/). I recomment at least 16GB in size since the benchmarks used in the methodology require more space. There are multiple guides on the internet how to burn an image onto a flash-based memory card. In addition you can also use [`gparted`](https://gparted.org/) ro resize the rootfs partition.

From my experiments, the eMMC card is much more stable and is the preferred choice, but the board can also run on an microSD card. Just make sure its at least UHS Class 1 in terms of read/write speed. If you would like more information about the difference I have a chapter dedicated to that in my doctorate dissertation [**Power Modelling and Analysis on Heterogeneous Embedded Systems**](https://seis.bristol.ac.uk/~eejlny/downloads/kris_thesis.pdf).

After the OS image has been loaded onto the card, insert it on the board and use the switch to select the boot mode (either boot from eMMC or mSD).

### Interfacing with the board

The next step is to interface with the board. My choise is via serial since it gives the least ammount of OS overhead (compared to graphical interface). There is an on-board UART connector and I use a usb-to-uart chip to interface with it. HARDKENEL provide a [_module_](https://www.hardkernel.com/shop/usb-uart-module-kit/) but you can use any other one as long as you connect the rights pins to the on-board connector. 
On the host machine you can either use [_PuTTY_](https://www.putty.org/) or [_minicom_](https://help.ubuntu.com/community/Minicom) to talk to the serial port. Again there are peanty of guides that cover this online so I will not provide details here. 

Also make sure to enable internet access on the board so you can download the kernel, methodology nad workloads.

Username ans pwd are as follows:
```
odroid login: root
password: odroid
```

## Installing supporting programs and loading the methodology on the board

After installing the OS, you need to run the following commands to install the supporting software packages from the ubuntu database.
```
$ apt-get install xterm
$ apt-get install cpufrequtils
$ apt-get install cpuset
$ apt-get install bc
$ apt-get install git
$ apt-get install ssh
```
`xterm` is useful to `resize` the terminal windows size to fir more information. `cpufrequtils` is used to get easy-to-read inforamtion about the CPU which is used by the contol scripts in the methodology. `cpuset` is used to isolate the CPU core which is to be modelled from the rest of the system in order to minimise OS overhead and unsure accurate models. `bc` is a mathematical tool used by the contol scripts to perform floating point calculations when needed since bash does not support that. `git` and `ssh` are used to donwload the software from the repositories and also move files easily to and from the board via sftp and are optional. 

The next step is to copy the project files to the board - `$ git clone --depth 1 git@github.com:kranik/ARMPM_DATACOLLECT.git -b odroid_xu3`.

### Compiling perf

The methodology uses [`perf`](https://perf.wiki.kernel.org/index.php/Main_Page) to collect the PMU events so the next step is to load the source of the modified kernel by doing `$ git clone --depth 1 https://github.com/hardkernel/linux -b odroidxu3-3.10.y`. Please check kernel version of build first to ensure you are using the correct kernel source, since it might not be `3.10.*`

In order to compile perf fisrt you need to install [_flex_](https://www.gnu.org/software/flex/) and [_bison_](https://www.gnu.org/software/bison/) ,which are used in compilation and then move to the source diretory in the downloaded kernel files to compile.
```
$ apt-get install flex
$ apt-get install bison
$ cd /home/linux/tools/perf (this is just an example directory, please check where you downloaded the kernel source)
$ make
```

Then test the resulting executable `$ ./perf stat ls`. The output should be something similar to this, sicne the default kernel configuration does not support the PMU, so we are unable to access the hardware event counters.
```
...
 Performance counter stats for 'ls':

          3.585209 task-clock                #    0.812 CPUs utilized
                 1 context-switches          #    0.279 K/sec
                 0 cpu-migrations            #    0.000 K/sec
               187 page-faults               #    0.052 M/sec
   <not supported> cycles
   <not supported> stalled-cycles-frontend
   <not supported> stalled-cycles-backend
   <not supported> instructions
   <not supported> branches
   <not supported> branch-misses

       0.004414463 seconds time elapsed
...
```
### Updating the kernel with PMU support

In order to access the PMU counters the kernel needs to be updated. This involves patching the device tree file with support for the hardware interrupts used by the PMU.

I have provided a [`PMU.patch`](PlatformSet/PMU.patch) that makes it easier to see what files to change, but I will also outline this here:

First update `odroidxu3_defconfig` with the following lines in order to enable `perf` support: 
```
...
-# CONFIG_PERF_EVENTS is not set
+CONFIG_PERF_EVENTS=y
-# CONFIG_PROFILING is not set
+CONFIG_PROFILING=y
...
```

Next update the device tree file `xynos5422_evt0.dtsi` with the PMU interrupt so that we can access the counters. Just add this to the file:
```
...
arm-pmu {
     compatible = "arm,cortex-a15-pmu",  "arm,cortex-a7-pmu";
     interrupts = <0 79 4>,
                  <0 80 4>,
                  <0 81 4>,
                  <0 92 4>,
                  <0 93 4>,
                  <0 97 4>;
};
...
```     

Finally you need to recompile the kernel boot files using the kernel source:
```     
$ cd linux
$ make odroidxu3_defconfig
$ make -j9
$ sudo make modules_install
$ sudo cp arch/arm/boot/zImage /media/boot
$ sudo cp arch/arm/boot/dts/exynos5422-odroidxu3.dtb /media/boot
$ sync && reboot
```

Please refer to [_this tutorial_](https://odroid.com/dokuwiki/doku.php?id=en:xu3_ubuntu_release_note_20160708) for detailed instructions on how to recompile the kernel on the board and load the boot files to the eMMC/microSD card.
After rebooting the board with the updated kernel you can test the previously compiled perf and the output should show hardware event couts coming from the PMU registers now:
```
...
 Performance counter stats for 'ls':

         12.749209 task-clock                #    0.655 CPUs utilized
                 2 context-switches          #    0.157 K/sec
                 0 cpu-migrations            #    0.000 K/sec
               189 page-faults               #    0.015 M/sec
           7201733 cycles                    #    0.565 GHz
   <not supported> stalled-cycles-frontend
   <not supported> stalled-cycles-backend
           2986877 instructions              #    0.41  insns per cycle
            610637 branches                  #   47.896 M/sec
             47933 branch-misses             #    7.85% of all branches

       0.019454542 seconds time elapsed
...
```

### Accessing the on-board power monitors

The other key component to the power modelling methodology are the on-board power sensors on the ODROID-XU3 board. The board had 4 dedicated sensors - one for the GPU, one for the RAM, and one each for the ARM Cortex-A7 and ARM Cortex-A15 processing clusters. Please refer to the official HARDKERNEL [_wiki_](https://wiki.odroid.com/old_product/odroid-xu3/odroid-xu3) for more details about the sensors. The methodology contains a dedicated program to initialize and read information from the sensors. All the source files for the program are located in the [_PowerMon_](PowerMon/) directory. The main functionality is taken from [_here_](https://github.com/hardkernel/EnergyMonitor), but I have ommitted the graphical interface, provided a stricter format for the output and added the ability to alter the sampling frequency. The produced output is designed such that it can be easily analysed by the power model generation scripts in [ARMPM\_BUILDMODEL](https://github.com/kranik/ARMPM_BUILDMODEL).

You can compile the program from the source files using `$ sudo g++ -std=c++0x -o sensors main.cpp getnode.cpp`. The program takes two input flags, which enable the ARM Cortex-A15 and/or the ARM Cortex-A7 power sensor and then a third flag, which specifies the sample interval in nanoseconds. Here is an example usage:

```
$ ./sensors 1 1 1000000000
...
#Timestamp      CPU(0) Frequency(MHz)   CPU(0) Temperature(C)   A7 Voltage(V)   A7 Current(A)   A7 Power(W)     CPU(4) Frequency(MHz)   CPU(4) Temperature(C)   A15 Voltage(V)  A15 Current(A)  A15 Power(W)    GPU Frequency(MHz)      GPU Temperature(C)   GPU Voltage(V)  GPU Current(A)  GPU Power(W)    RAM Voltage(V)  RAM Current(A)  RAM Power(W)
1551884067782157619     1400 60 1.200000 0.107000 0.128000 2000 59 1.200000 0.932000 1.165000 600 64 1.000000 0.143000 0.143000 1.200000 0.023000 0.027000
1551884067787862319     1400 60 1.200000 0.107000 0.128000 2000 59 1.200000 0.932000 1.165000 600 64 1.000000 0.143000 0.143000 1.200000 0.023000 0.027000
1551884067793312352     1400 61 1.200000 0.107000 0.128000 2000 59 1.200000 0.932000 1.165000 600 64 1.000000 0.143000 0.143000 1.200000 0.023000 0.027000
1551884067798763219     1400 61 1.200000 0.107000 0.128000 2000 59 1.200000 0.932000 1.165000 600 65 1.000000 0.143000 0.143000 1.200000 0.023000 0.027000
1551884067804210461     1400 61 1.200000 0.107000 0.128000 2000 59 1.200000 0.932000 1.165000 600 64 1.000000 0.143000 0.143000 1.200000 0.023000 0.027000
1551884067809607911     1400 61 1.200000 0.107000 0.128000 2000 59 1.200000 0.932000 1.165000 600 65 1.000000 0.143000 0.143000 1.200000 0.023000 0.027000
1551884067815033528     1400 61 1.200000 0.107000 0.128000 2000 59 1.200000 0.932000 1.165000 600 65 1.000000 0.143000 0.143000 1.200000 0.023000 0.027000
1551884067820523437     1400 61 1.200000 0.107000 0.128000 2000 59 1.200000 0.932000 1.165000 600 65 1.000000 0.143000 0.143000 1.200000 0.023000 0.027000
1551884067825968887     1400 61 1.200000 0.107000 0.128000 2000 59 1.200000 0.932000 1.165000 600 66 1.000000 0.143000 0.143000 1.200000 0.023000 0.027000
1551884067831409504     1400 61 1.200000 0.107000 0.128000 2000 59 1.200000 0.932000 1.165000 600 66 1.000000 0.143000 0.143000 1.200000 0.023000 0.027000
1551884067836842413     1400 61 1.200000 0.107000 0.128000 2000 59 1.200000 0.932000 1.165000 600 66 1.000000 0.143000 0.143000 1.200000 0.023000 0.027000
1551884067842277571     1400 61 1.200000 0.107000 0.128000 2000 59 1.200000 0.932000 1.165000 600 66 1.000000 0.143000 0.143000 1.200000 0.023000 0.027000
1551884067847691980     1400 61 1.200000 0.107000 0.128000 2000 59 1.200000 0.932000 1.165000 600 66 1.000000 0.143000 0.143000 1.200000 0.023000 0.027000
1551884067853172347     1400 62 1.200000 0.107000 0.128000 2000 59 1.200000 0.932000 1.165000 600 66 1.000000 0.143000 0.143000 1.200000 0.023000 0.027000
1551884067858553547     1400 62 1.200000 0.107000 0.128000 2000 59 1.200000 0.932000 1.165000 600 66 1.000000 0.143000 0.143000 1.200000 0.023000 0.027000
1551884067863975622     1400 62 1.200000 0.107000 0.128000 2000 59 1.200000 0.932000 1.165000 600 66 1.000000 0.143000 0.143000 1.200000 0.023000 0.027000
...
```

The program is designed to continuously run until it is manually stopped by the user/control script.  

The last thing left to do is to copy the compiled `perf` and `sensors` programs in the main scripts directory, where [`MC_XU3.sh`](Scripts/ODROID_XU3/MC_XU3.sh) is located since the promary control script looks for the locally. However you can alter the source/add the to your `$PATH` variable and make the script call them in that way.

## Installing the workloads for the models

Now that the key components of the methodology are loaded and compiled on to the board the last thing left to do is to download and compile the workloads to be used in the models. You can essentually use any workloads you like as long as you can provide some control script that help [`MC_XU3.sh`](Scripts/ODROID_XU3/MC_XU3.sh) set the environment and call the benchmarks. The supporting scripts are given [_here_](BenchmarkMods/cBench_V1.1/) for `cBench and [_here_](BenchmarkMods/parsec-3.0/) for `parsec`. 

### cBench_V1.1

First download [cBench](http://ctuning.org/wiki/index.php/CTools:CBench:DownloadsO its its own directory and copy over all the script and files in [`BenchmarkMods/cBench_V1.1/`](BenchmarkMods/cBench_V1.1/) to the newly downloaded benchmark directory. In order to set-up the benchmark suite you need to enable all script files for execution using `$ chmod +x all_*` and then compile the benchmarks using the following commands/scripts:
```
$ ./all__list_compiled.sh
$ ./all__create_work_dirs
$ ./all__fix_libmath.sh
$ ./all_compile
```

You can test if the benchmarks have compiled correctly by doing `$ ./all__list_compiled.sh`. 

The support files also contain one file called [`bench_list`](BenchmarkMods/cBench_V1.1/bench_list) which you can edit to specify which benchmarks to compile/use. You can edit it as you see fit by commenting out the unwanted benchmarks from the list like so:

```
automotive_bitcount
automotive_qsort1
automotive_susan_c
automotive_susan_e
automotive_susan_s
bzip2d
bzip2e
consumer_jpeg_c
consumer_jpeg_d
#consumer_lame -> this is causing problems with buffer overflow
#consumer_mad -> problem with libraries
consumer_tiff2bw
consumer_tiff2rgba
consumer_tiffdither
consumer_tiffmedian
network_dijkstra
network_patricia
#office_ghostscript
#office_ispell
office_rsynth
office_stringsearch1
security_blowfish_d
security_blowfish_e
#security_pgp_d
#security_pgp_e
security_rijndael_d
security_rijndael_e
security_sha
telecom_adpcm_c
telecom_adpcm_d
telecom_CRC32
telecom_gsm
```
You can test the benchmarks suite by doing `$ ./all_run__1_dataset`. A sample output would be:

```
**********************************************************
automotive_bitcount
##########################################################
Dataset: 1
Found dataset:  1
Command line:   1125000 > ftmp_out
Loop wrap:      80


real    0m14.781s
user    0m14.780s
sys     0m0.005s
**********************************************************
automotive_qsort1
##########################################################
Dataset: 1
Found dataset:  1
Command line:   ../../automotive_qsort_data/1.dat output.dat > ftmp_out
Loop wrap:      226


real    0m14.854s
user    0m14.540s
sys     0m0.315s
**********************************************************
...
**********************************************************
telecom_CRC32
##########################################################
Dataset: 1
Found dataset:  1
Command line:   ../../telecom_data/1.pcm > output_large.txt
Loop wrap:      3431


real    1m34.304s
user    1m33.710s
sys     0m0.590s
**********************************************************
telecom_gsm
##########################################################
Dataset: 1
Found dataset:  1
Command line:   -fps -c ../../telecom_gsm_data/1.au > output_large.encode.gsm
Loop wrap:      558


real    0m9.829s
user    0m9.535s
sys     0m0.295s
```

Please note that I have provided a wrapper script [`all_run__1_dataset_timestamp_cset`](BenchmarkMods/cBench_V1.1/all_run__1_dataset_timestamp_cset), which is used by [`MC_XU3.sh`](Scripts/ODROID_XU3/MC_XU3.sh) abd it in turn calls the benchmarks. The important part of that script is setting up data collection timestamps for later syncronization and isolating the workload on a required processing cluster/core via `cset`.

If you want to use other benchmark suites please provide a proper wrap file which does include the `cset` shielding and timestaps.

### parsec-3.0

Setting up [_parsec_](https://parsec.cs.princeton.edu/) is straightforward, but more time consuming and not all benchmarks might compile natively on the platform. First you need to download the [core]( http://parsec.cs.princeton.edu/download/3.0/parsec-3.0-core.tar.gz) and [native inputs](http://parsec.cs.princeton.edu/download/3.0/parsec-3.0-input-native.tar.gz) and extrac them in the same directory. You should end up with one _parsec-3.0_ folder with all files in it. Please allow at least 5GB free space on the memory card before you do this.

Afterwards, simularly to the _cBench_ setup you need to copy the modified scripts in [BenchmarkMods/parsec-3.0/](BenchmarkMods/parsec-3.0/) to the parsec directory. Before you do anything else, please look at the parsec _README_ file, wich contains insrutions on how to compile and run the benchmarks. 

You can do the following commands to set the environment and compile the benchmarks, again not all benchmarks compile and I have provided a list which worked for me.
```
$ source env.sh     
$ chmod +x bin/parsecmgmt
$ parsecmgmt -a build -p parsec.facesim parsec.freqmine parsec.streamcluster splash2x.barnes splash2x.fmm splash2x.radiosity splash2x.raytrace splash2x.water_nsquared parsec.blackscholes parsec.bodytrack
```

The benchmarks I used in my experiments are also given in [`bench_list.data`](BenchmarkMods/parsec-3.0/bench_list.data).

If during the process you get the following build error:

```
...
[PARSEC] [========== Building package parsec.bodytrack [1] ==========]
[PARSEC] [---------- Analyzing package parsec.bodytrack ----------]
[PARSEC] parsec.bodytrack does not depend on any other packages.
[PARSEC] [---------- Building package parsec.bodytrack ----------]
[PARSEC] Error: Need 'configure' script or a '[Mm]akefile' to build package parsec.bodytrack.
...
```

You need to go to the benchmark source directory, in this example - `/parsec-3.0/pkgs/apps/bodytrack/src` and do `$ chmod +x configure` so that the cofigure script is executable. Then, assuming all prerequisites are met, the benchmark should compule natively.

After compilation you can test if the benchmarks execute correctly by running:
` $ parsecmgmt -a run -p parsec.facesim parsec.freqmine parsec.streamcluster splash2x.barnes splash2x.fmm splash2x.radiosity splash2x.raytrace splash2x.water_nsquared parsec.blackscholes parsec.bodytrack`

If you get the following error:
```
...
[PARSEC] [========== Running benchmark splash2x.barnes [2] ==========]
[PARSEC] Error: Binary '/home/ARMPM_DATACOLLECT/Workloads/parsec-3.0/ext/splash2x/apps/barnes/inst/arm-linux.gcc/bin/run.sh' of package 'splash2x.barnes' cannot be found.
...
```

Again you need to `chmod +x` the `*.sh` script file to enable execution. Again for further instruction on how to use `$ parsecmgmt` and control the benchmark suite execution, please refer to the _README_ file. I have also provided a dedicated control script [`parsec_benchlist_timestamp_cset.sh`](BenchmarkMods/parsec-3.0/parsec_benchlist_timestamp_cset.sh), which handles `cset` calls and timestamping.

### Adding your own benchmarks

If you want to add your own benchmarks, the most important thing is to add a wrapper script that the [`MC_XU3.sh`](Scripts/ODROID_XU3/MC_XU3.sh). The key parts of that are to use timestamps before and after execution for later syncronization and to use `cset` to shield the execution on the required core, in order to minimize data collection and OS overhead. Please refer to this example:
```
t1=$(date +'%s%N')
cset shield -e bash ./benchmark_executable
t2=$(date +'%s%N')
echo -e "$benchmark_name\t$t1\t$t2"
```
Where `./benchmark_executable` is the actual benchmark program and `$benchmark_name` is the benchmark identifier.

Please let me know if you have any difficulties following this guide via [email](mailto:kris.nikov@bris.ac.uk).
