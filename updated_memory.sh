#!/bin/bash

# Display Current User
user=$(whoami)
if [ $user == $(whoami) ]; then
	echo -e "=====\t============"
	echo -e "User:\t$user"
	echo -e "=====\t============\n"
fi

# Display System Memory Status
echo -e "--- [ Memory (RAM) ] ---"
free -h |
	awk 'NR==1{print "TYPE\t\tTotal\tUsed\tFree\tavailable"} NR==2{print "RAM:\t\t"$2"\t"$3"\t"$4"\t"$7} NR==3{print"Swap:\t\t"$2"\t"$3"\t"$4"\t"$7}'



