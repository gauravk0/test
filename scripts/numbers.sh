
#!bin/bash

#SCRIPTNAME=$(basename $0)
SCRIPTNAME="testlog.sh"

i=1
while [ $i -le 15 ]
do
    echo $i
    i=$(($i+1))
done

echo $SCRIPTNAME

