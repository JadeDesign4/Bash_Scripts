#!/bin/bash

# Display Storage Status of the HardDrive
echo -e "\n\t\t--- [ Disk Usage ] ---"
df -h --total |
	grep -E "Filesystem|total" |
		awk '{print "Total Disk:\tSize: "$2" | Used: "$3" | Available: "$4" ("$5")"}'
