#! /bin/sh

if [ -f bench_list ]
then
  benchmarks=`grep -v ^# bench_list`
else
  benchmarks=*  
fi

for i in $benchmarks
do

if [ -d "$i" ] 
then
 tmp=$PWD
 cd $i
 # *** source directory ***
 echo "**********************************************************"
 echo "Entering $i/src"
 cd src
 sed -e 's/-lm \*.o/\*.o -lm/' <Makefile.gcc >temp
 mv temp Makefile.gcc
 echo "Fixing $i - Done."
 # *************************
 cd $tmp  
fi

done

