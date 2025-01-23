#!/bin/bash

# List of computer indices
X_LIST=(1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9 10 10)

# Corresponding base directories
BASEDIRS=(
    '/last01e/data1/archive/' '/last01e/data2/archive/'
    '/last01w/data1/archive/' '/last01w/data2/archive/'
    '/last02e/data1/archive/' '/last02e/data2/archive/'
    '/last02w/data1/archive/' '/last02w/data2/archive/'
    '/last03e/data1/archive/' '/last03e/data2/archive/'
    '/last03w/data1/archive/' '/last03w/data2/archive/'
    '/last04e/data1/archive/' '/last04e/data2/archive/'
    '/last04w/data1/archive/' '/last04w/data2/archive/'
    '/last05e/data1/archive/' '/last05e/data2/archive/'
    '/last05w/data1/archive/' '/last05w/data2/archive/'
    '/last06e/data1/archive/' '/last06e/data2/archive/'
    '/last06w/data1/archive/' '/last06w/data2/archive/'
    '/last07e/data1/archive/' '/last07e/data2/archive/'
    '/last07w/data1/archive/' '/last07w/data2/archive/'
    '/last08e/data1/archive/' '/last08e/data2/archive/'
    '/last08w/data1/archive/' '/last08w/data2/archive/'
    '/last09e/data1/archive/' '/last09e/data2/archive/'
    '/last09w/data1/archive/' '/last09w/data2/archive/'
    '/last10e/data1/archive/' '/last10e/data2/archive/'
    '/last10w/data1/archive/' '/last10w/data2/archive/'
)

# Local directory to store results
LOCAL_RESULTS_DIR=~/Documents/WD_survey

# Function to run the commands on a remote computer
run_remote_command() {
    local computer_index=$1
    local base_dir=$2
    local remote_host="ocs@10.23.1.$(printf "%02d" $computer_index)"
    local remote_results_dir="~/Documents/WD_survey"
    local remote_file_name="AllRawData_${computer_index}_$(basename $base_dir | tr '/' '_').mat"
    
    sshpass -p "physics" ssh -o StrictHostKeyChecking=no "$remote_host" <<EOF
        cd ~/Documents/WDsurvey/
        git pull
        matlab -nodesktop -nosplash -r "
        try
            addpath('~/Documents/WDsurvey/');
            AllRawData = countRawData('$base_dir');
            save('$remote_results_dir/$remote_file_name', 'AllRawData');
        catch ME
            disp(ME.message);
        end;
        exit;"
EOF

    # Copy the result back to the local machine
    sshpass -p "physics" scp -o StrictHostKeyChecking=no \
        "$remote_host:$remote_results_dir/$remote_file_name" "$LOCAL_RESULTS_DIR/"
}

export -f run_remote_command

# Export the password to avoid repeated typing
export SSHPASS="physics"

# Use parallel to run the tasks for all computers
parallel -j 10 run_remote_command {1} {2} ::: "${X_LIST[@]}" ::: "${BASEDIRS[@]}"

echo "All tasks completed. Results saved to $LOCAL_RESULTS_DIR."
