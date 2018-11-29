#!/bin/bash
  clear #CLEARING TERMINAL WINDOW

#Thread Count Function
 TC=$(( $(lscpu | awk '/^Socket/{ print $2 }') * $(lscpu | awk '/^Core/{ print $4 }') * $(lscpu | awk '/^Thread/{ print $4 }') ))

#Add Color for help list
  RED='\e[0;31m'
  GREEN='\e[1;32m'
  YELLOW='\e[1;33m'
  CYAN='\e[0;36m'
  WHITE='tput sgr0'
  PURPLE='\e[0;35m'

#Temp Location
  DO_TEMP() {
  unset TEMP

#Typical RPI settings
  if [ -f /sys/class/thermal/thermal_zone0/temp ];then
  TEMP=$(cat /sys/class/thermal/thermal_zone0/temp | awk '{print $1/1000}' | cut -d "." -f1)
  fi

## Friendlyarm settings ##
  if [ -f /sys/class/hwmon/hwmon0/device/temp_label ]; then
  TEMP=$(cat /sys/class/hwmon/hwmon0/device/temp_label | awk '{print $1/1}')
  fi

## Server ##
  if [ -f /sys/class/hwmon/hwmon0/temp2_input ]; then
  TEMP=$(cat /sys/class/hwmon/hwmon0/temp2_input | awk '{print $1/1000}')
  fi
 }

  DO_CPU() {
#GETTING CPU FREQUANCY

  CS0=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)
  CS1=$(($CS0/1000))
 }

# Just saying Hello.

  echo -e $CYAN "Hello! Thank you so much for using my benchmark script!!!"

# Showing Cpu temp.
  DO_TEMP
  DO_CPU
  echo -e $YELLOW "CPU Idle Temp=$CYAN$TEMP C" 

# Time to start stressing the cpu to warm it up.
  
  echo -e $RED "Warming up the CPU for 60 Seconds"
  stress --cpu $TC --timeout 60 > /dev/null
  echo -e $YELLOW "CPU Frequancy=$RED$CS1 MHz"
  echo -e $RED "CPU Temperature=$CYAN$TEMP C" 
 
# This is where the benchmarking starts.

 DO_PRIME() {
 DO_TEMP
 DO_CPU 
  echo -e $PURPLE "Running Prime to $BENCH Timing Test"
  sysbench --test=cpu --num-threads=$TC --cpu-max-prime=$BENCH run > temp.txt 
  cat temp.txt | grep -o "total time:.*" | awk '{print " Total Time: " $3}'
  echo -e $YELLOW "CPU Frequancy=$RED$CS1 MHz"
  echo -e $YELLOW "CPU Temperature=$CYAN$TEMP C"
 }
 
 DO_MEM1()  {
  echo -e $GREEN "Running Memory Speed Test $MEM1G"
  sysbench --test=memory --memory-total-size=$MEM1G run > temp.txt
  cat temp.txt | grep -o  "1024.00 MB transferred.*" | awk '{print " Memory Speed:" $4 $5}'
 }

 DO_MEM2()  {
  echo -e $GREEN "Running Memory Speed Test $MEM2G"
  sysbench --test=memory --memory-total-size=$MEM2G run > temp.txt
  cat temp.txt | grep -o  "2048.00 MB transferred.*" | awk '{print " Memory Speed:" $4 $5}'
 }
 
  DO_MEM3()  {
  echo -e $GREEN "Running Memory Speed Test $MEM3G"
  sysbench --test=memory --memory-total-size=$MEM3G run > temp.txt
  cat temp.txt | grep -o  "3072.00 MB transferred.*" | awk '{print " Memory Speed:" $4 $5}'
 }
 
# Benchmark Variables.

  BENCH=5000
  DO_PRIME
  BENCH=10000
  DO_PRIME
  BENCH=20000
  DO_PRIME
  BENCH=50000
  DO_PRIME

# Memory size and operations

  MEM1G=1G
  DO_MEM1
  MEM2G=2G
  DO_MEM2
  MEM3G=3G
  DO_MEM3

#Remove Temp.txt
  rm temp.txt

