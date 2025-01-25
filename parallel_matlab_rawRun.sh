#!/bin/bash

# ================================================
# Script: run_matlab_parallel.sh
# Description: Executes MATLAB routines on multiple
#              remote machines in parallel, with
#              automated password handling.
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
#!/bin/bash

# ================================================
# Script: parallel_matlab_countRawData.sh
# Description: Executes `countRawData` MATLAB function
#              on multiple remote machines and gathers results.
# ================================================

# Define the list of X values (last octet of the IP addresses)
X_LIST=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20)

# SSH password
PASSWORD="physics"

# Local directory to store gathered results
LOCAL_DIR=~/Projects/ObservationsStat
mkdir -p "$LOCAL_DIR" # Create the directory if it doesn't exist

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
    echo "Connecting to 10.23.1.$X..."

    # Determine 'computer' and 'Side' based on X
    COMPUTER=$(ceil_division "$X")
    SIDE=$(determine_side "$X")

    # Correct formatting for `COMPUTER`
    if (( COMPUTER < 10 )); then
        COMPUTER="0$COMPUTER"
    fi

    # Construct the computer name
    COMPUTER_NAME="last${COMPUTER}${SIDE}"

    # Process data1
    BASEDIR="/${COMPUTER_NAME}/data1/archive/"
    sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no ocs@10.23.1."$X" << EOF &
cd ~/Documents/WDsurvey
echo "Pulling the latest code..."
git pull

echo "Running MATLAB for $BASEDIR..."
matlab -nosplash -nodesktop -r "addpath(genpath('~/Documents/WDsurvey/')); AllRawData = countRawData('$BASEDIR'); disp(['Size of AllRawData: ', num2str(size(AllRawData, 1))]); save('~/Documents/WD_survey/${COMPUTER_NAME}_data1.mat', 'AllRawData'); exit;"
EOF

    # Process data2
    BASEDIR="/${COMPUTER_NAME}/data2/archive/"
    sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no ocs@10.23.1."$X" << EOF &
cd ~/Documents/WDsurvey
echo "Pulling the latest code..."
git pull

echo "Running MATLAB for $BASEDIR..."
matlab -nosplash -nodesktop -r "addpath(genpath('~/Documents/WDsurvey/')); AllRawData = countRawData('$BASEDIR'); disp(['Size of AllRawData: ', num2str(size(AllRawData, 1))]); save('~/Documents/WD_survey/${COMPUTER_NAME}_data2.mat', 'AllRawData'); exit;"
EOF

done

# Wait for all background SSH processes to finish
wait

echo "All MATLAB routines have been executed on the remote machines."

# ================================================
# Step: Gather Results into Local Directory
# ================================================
for X in "${X_LIST[@]}"; do
    # Determine 'computer' and 'Side' based on X
    COMPUTER=$(ceil_division "$X")
    SIDE=$(determine_side "$X")

    if (( COMPUTER < 10 )); then
        COMPUTER="0$COMPUTER"
    fi

    # Construct the computer name
    COMPUTER_NAME="last${COMPUTER}${SIDE}"

    # Define remote file paths for data1 and data2 results
    REMOTE_FILE1="~/Documents/WD_survey/${COMPUTER_NAME}_data1.mat"
    REMOTE_FILE2="~/Documents/WD_survey/${COMPUTER_NAME}_data2.mat"

    # Copy files to the local directory
    sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no ocs@10.23.1."$X":"$REMOTE_FILE1" "$LOCAL_DIR/" 2>/dev/null && \
    echo "Collected: ${COMPUTER_NAME}_data1.mat" || \
    echo "Failed to collect: ${COMPUTER_NAME}_data1.mat"

    sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no ocs@10.23.1."$X":"$REMOTE_FILE2" "$LOCAL_DIR/" 2>/dev/null && \
    echo "Collected: ${COMPUTER_NAME}_data2.mat" || \
    echo "Failed to collect: ${COMPUTER_NAME}_data2.mat"
done

echo "All results have been gathered into $LOCAL_DIR."
