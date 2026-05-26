# Get Status of The Amount of RAM the System is using

echo -e "\n\tSystem Memory"
echo -e "\t--------------\n"

free -h |
 awk 'NR==1{print "Type\t\tTotal\tUsed\tFree"} NR==2{print "RAM:\t\t"$2"\t"$3"\t"$4} NR==3{print "Swap:\t\t"$2"\t"$3"\t"$4}'
