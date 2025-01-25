#!/bin/bash

# ================================================
# Script: parallel_matlab_rawRun.sh
# Description: Executes MATLAB routines on multiple
#              remote machines in parallel using
#              the dedicated runCountRawData.m script.
# ================================================

# Define the list of X values (last octet of the IP addresses)
X_LIST=(7 8)

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

    # Process data1
    BASEDIR="/last${COMPUTER}${SIDE}/data1/archive/"
    sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no ocs@10.23.1."$X" << EOF &
export BASEDIR="$BASEDIR"
cd ~/Documents/WDsurvey
git pull
matlab -nosplash -nodesktop -r "run('~/Documents/WDsurvey/runCountRawData.m');"
EOF

    # Process data2
    BASEDIR="/last${COMPUTER}${SIDE}/data2/archive/"
    sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no ocs@10.23.1."$X" << EOF &
export BASEDIR="$BASEDIR"
cd ~/Documents/WDsurvey
git pull
matlab -nosplash -nodesktop -r "run('~/Documents/WDsurvey/runCountRawData.m');"
EOF

done

# Wait for all background SSH processes to finish
wait

echo "All MATLAB routines have been executed on the remote machines."

