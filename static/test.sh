#!/bin/bash
POD_NAME="bingo"
MAX_SLEEP=3
my_sleep() {
     # Sleep between 0 and 3 seconds
    delay=$(($RANDOM % $1)).$(($RANDOM % 9 ))
    echo "sleeping $delay seconds"
    sleep $delay
}

i=1
while [ $i -lt 3 ]
    do
    echo $i
    len=$(($RANDOM % 10000 + 1000))
    echo $len
    file="${POD_NAME}.txt"
    echo "$POD_NAME writing $file"
    printf '=%.0s' $(seq 1 $len) > $file
    my_sleep $MAX_SLEEP
    echo "$POD_NAME deleting $file"
    rm $file
    my_sleep $MAX_SLEEP
   ((i=i+1))
done