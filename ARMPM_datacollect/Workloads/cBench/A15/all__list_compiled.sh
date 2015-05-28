#! /bin/sh

SMILE=0
if [ ! -z $1 ] ; then
 SMILE=$1
fi


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
 if [ -d "src_work" ] 
 then
  # *** process directory ***
  cd src_work
  if [ $SMILE -eq 0 ]
  then
   if [ ! -e "a.out" ] 
    then
     echo "==="
     echo "$i NOT OK :("
   fi
  else
   echo "==="
   if [ -e "a.out" ] 
    then
     echo "$i OK :)"
    else
     echo "$i NOT OK :("
    fi
  fi   
  # *************************
 fi
 cd $tmp  
fi
done
echo "==="

