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
  do_temp() {
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
  do_temp
  DO_CPU
  echo -e $YELLOW "CPU Idle Temp=$CYAN$TEMP C" 

# Time to start stressing the cpu to warm it up.
  
  echo -e $RED "Warming up the CPU for 60 Seconds"
#  stress --cpu $TC --timeout 60 > /dev/null
  echo -e $YELLOW "CPU Frequancy=$RED$CS1 MHz"
  echo -e $RED "CPU Temperature=$CYAN$TEMP C" 
 
# This is where the benchmarking starts.

 do_prime() {
 do_temp
 DO_CPU 
  echo -e $PURPLE "Running Prime to $BENCH Timing Test"
  sysbench --test=cpu --num-threads=$TC --cpu-max-prime=$BENCH run > temp.txt 
  cat temp.txt | grep -o "total time:.*" | awk '{print " Total Time: " $3}'
  echo -e $YELLOW "CPU Frequancy=$RED$CS1 MHz"
  echo -e $YELLOW "CPU Temperature=$CYAN$TEMP C"
 }
 
 DO_MEM()  {
  echo -e $GREEN "Running Memory Speed Test $MEMS"
  sysbench --test=memory --memory-total-size=$MEMS run > temp2.txt
  cat temp2.txt | grep -o  “$MEMS transferred.*" | awk '{print " Memory Speed:" $4 $5}'
 }

 
# Benchmark Variables.

#  BENCH=5000
#  do_prime
#  BENCH=10000
#  do_prime
#  BENCH=20000
#  do_prime
#  BENCH=50000
#  do_prime

# Memory size and operations

  MEMS=1024.00 MB
  DO_MEM
  MEMS=2048.00 MB
  DO_MEM
  MEMS=3096.00 MB
  DO_MEM

#Remove Temp.txt
  rm temp.txt
  rm temp2.txt
