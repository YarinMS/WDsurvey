#!/bin/bash

# ================================================
# Script: gather_results.sh
# Description: Collects MATLAB output files from
#              remote machines and organizes them
#              into a local directory.
# ================================================

# Define the list of X values (last octet of the IP addresses)
X_LIST=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20)

# SSH password
PASSWORD="physics"

# Local destination directory for results
LOCAL_DIR=~/Projects/ObservationsStat

# Create the local directory if it doesn't exist
mkdir -p "$LOCAL_DIR"

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

# Loop through each X and gather results
for X in "${X_LIST[@]}"; do
    echo "Preparing to collect results from 10.23.1.$X..."

    # Determine 'computer' and 'Side' based on X
    COMPUTER=$(ceil_division "$X")
    SIDE=$(determine_side "$X")

    # Define remote paths for data1 and data2 results
    REMOTE_DIR1="~/Documents/WD_survey/AllRawData_${COMPUTER}${SIDE}_data1.mat"
    REMOTE_DIR2="~/Documents/WD_survey/AllRawData_${COMPUTER}${SIDE}_data2.mat"

    # Copy the results for data1
    sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no ocs@10.23.1."$X":"$REMOTE_DIR1" "$LOCAL_DIR/" 2>/dev/null && \
    echo "Collected: AllRawData_${COMPUTER}${SIDE}_data1.mat" || \
    echo "Failed to collect: AllRawData_${COMPUTER}${SIDE}_data1.mat"

    # Copy the results for data2
    sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no ocs@10.23.1."$X":"$REMOTE_DIR2" "$LOCAL_DIR/" 2>/dev/null && \
    echo "Collected: AllRawData_${COMPUTER}${SIDE}_data2.mat" || \
    echo "Failed to collect: AllRawData_${COMPUTER}${SIDE}_data2.mat"
done

echo "Results have been gathered into $LOCAL_DIR"
