****************************************************************
Collective Datasets (cDatasets)

cDatasets is a collection of open-source datasets for cBench benchmark
assembled by the community.  The behavior of individual programs 
and datasets is analyzed and recorded in the Collective Optimization 
Database (http://cTuning.org/cdatabase) to enable realistic benchmarking 
and research on program and architecture optimization. 

cBench/cDatasets website (downloads and documentation):
 http://cTuning.org/cbench

cTuning/cBench/cDatasets mailing lists (feedback, comments and bug reports):
 http://cTuning.org/community

cBench is originall based on MiBench bechmark:
 http://www.eecs.umich.edu/mibench/index.html

cBench/cDatasets are used for training of MILEPOST GCC to learn good optimizations 
across multiple programs, datasets, compilers and architectures, and correlate
them with program features and run-time behavior:

http://cTuning.org/milepost-gcc

****************************************************************
Author:

 cBench/cDatasets initiative has been started by Grigori Fursin 
 in 2008/2009 as an extension to MiBench/MiDataSets.

 http://fursin.net/research

****************************************************************
License:
 We have been collecting datasets from various public sources. Normally,
 they should be free to distribute. Though we made an effort to include 
 only copyright free benchmarks and datasets, mistakes are possible. 
 In such case, please report this problem immediately at:

 http://cTuning.org/cbench

****************************************************************
Release History:

 cDatasets:

  V1.1 March 15, 2010

       Datasets for bzip2 have been added. 
       All datasets have been checked with cBench V1.1.

 MiDatasets (this branch is now finished):

  V1.3 January 25, 2008

       Many thanks to Kenneth Hoste from Ghent University who evaluated 
       MiDataSets and provided a valuable feedback. Several datasets 
       have been modified/changed to work properly with the updated programs:
       
       * consumer_tiff_data (all ??.bw.tif have been converted to 8-bit grayscale
                            instead of 1-bit B&W to work properly with consumer_tiffdither)
       * office_data

  V1.0 March 17, 2007

       First official release.

  V0.1 February 01, 2006 

       Preliminary set of several datasets is prepared
       and used internally at INRIA for research.

********************************************************************************
Datasets description:

automotive_qsort_data
 20 datasets, random numbers, different size

automotive_susan_data
 20 datasets, pnm images, different size, different scenery

consumer_data
 20 datasets, mp3 audio, different size, different bit-rate, different genres
 20 datasets, wav audio converted from original mp3 datasets

consumer_jpeg_data
 20 datasets, jpeg images, different size, different scenery
 20 datasets, ppm images converted from original jpeg datasets

consumer_tiff_data
 30 datasets, tiff images converted from original jpeg datasets
 30 datasets, b&w tiff images converted from original jpeg datasets
 30 datasets, tiff images without compression converted from original jpeg datasets

network_dijkstra_data
 20 datasets, random numbers, random size
          
network_patricia_data
 20 datasets, random numbers, random size

office_data
 20 datasets, text files, different size, different genres
 20 datasets, ps converted from original text datasets
 20 datasets, pgp converted from original text datasets
 20 datasets, enc converted from original text datasets
 20 datasets, benc converted from original text datasets
 20 datasets, text small files with random words in each line, different size

telecom_data
 20 datasets, pcm audio converted from mp3 datasets
 20 datasets, adpcm audio converted from mp3 datasets

telecom_gsm_data
 20 datasets, au audio converted from mp3 datasets
 20 datasets, gsm audio converted from mp3 datasets

********************************************************************************
Notes:

You can find more info about how to use these benchmarks/datasets 
in your research in the following publications:

http://unidapt.org/index.php/Dissemination#YYLP2010
http://unidapt.org/index.php/Dissemination#FT2009
http://unidapt.org/index.php/Dissemination#Fur2009
http://unidapt.org/index.php/Dissemination#FMTP2008
http://unidapt.org/index.php/Dissemination#FCOP2007

********************************************************************************
Acknowledgments (suggestions, evaluation, bug fixes, etc):

 Erven Rohou (IRISA, France)
 Abdul Wahid Memon (Paris South University and INRIA, France)
 Yang Chen (ICT, China)
 Yuanjie Huang (ICT, China)
 Chengyong Wu (ICT, China)
 Kenneth Hoste (Ghent University, Belgium)
 Veerle Desmet (Ghent University, Belgium)
 Michael O'Boyle (University of Edinburgh, UK)
 John Cavazos (University of Delaware, USA)
 Olivier Temam (INRIA Saclay, France) (original concept)
 Grigori Fursin (INRIA Saclay, France) (original concept)
********************************************************************************
