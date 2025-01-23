#!/bin/bash

# ================================================
# Script: run_matlab_parallel.sh
# Description: Executes MATLAB routines on multiple
#              remote machines in parallel, with
#              automated password handling.
# ================================================

# Define the list of X values (last octet of the IP addresses)
X_LIST=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20)

# SSH password
PASSWORD="physics"

# Function to calculate ceil(X/2)
ceil_division() {
    local x=$1
    echo $(( (x + 1) / 2 ))
}

# Function to determine Side based on X
determine_side() {
    local x=$1
    if (( x % 2 == 1 )); then
        echo "e"
    else
        echo "w"
    fi
}

# Loop through each X and execute commands in parallel
for X in "${X_LIST[@]}"; do
    echo "Preparing to connect to 10.23.1.$X..."

    # Determine 'computer' and 'Side' based on X
    COMPUTER=$(ceil_division "$X")
    SIDE=$(determine_side "$X")

    # Determine base directory
    BASEDIR="/last${COMPUTER}${SIDE}/data1/archive/"

    echo "Computer: $COMPUTER, Side: $SIDE, BaseDir: $BASEDIR"

    # Execute SSH commands in the background
    sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no ocs@10.23.1."$X" << EOF &
cd ~/Documents/WDsurvey
git pull
matlab -nosplash -nodesktop -r "addpath('~/Documents/WDsurvey/'); AllRawData = countRawData('$BASEDIR'); save('~/Documents/WD_survey/AllRawData_${COMPUTER}${SIDE}_data1.mat', 'AllRawData'); exit;"
EOF

    # Also check and process for data2
    BASEDIR="/last${COMPUTER}${SIDE}/data2/archive/"
    sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no ocs@10.23.1."$X" << EOF &
cd ~/Documents/WDsurvey
git pull
matlab -nosplash -nodesktop -r "addpath('~/Documents/WDsurvey/'); AllRawData = countRawData('$BASEDIR'); save('~/Documents/WD_survey/AllRawData_${COMPUTER}${SIDE}_data2.mat', 'AllRawData'); exit;"
EOF

done

# Wait for all background SSH processes to finish
wait

echo "All MATLAB routines have been executed on the remote machines."
