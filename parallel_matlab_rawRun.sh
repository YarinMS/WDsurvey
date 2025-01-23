#!/bin/bash

X_LIST=(1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9 10 10)
LOCAL_RESULTS_DIR="~/Documents/WD_survey"

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

mkdir -p "$LOCAL_RESULTS_DIR"

for ((i=0; i<${#X_LIST[@]}; i++)); do
    COMPUTER=${X_LIST[i]}
    BASE_DIR=${BASEDIRS[i]}
    
    sshpass -p 'physics' ssh -o StrictHostKeyChecking=no ocs@10.23.1.$((COMPUTER)) << EOF_INNER &
cd ~/Documents/WDsurvey
git pull

matlab -nosplash -nodesktop -r "
addpath('~/Documents/WDsurvey/');
fprintf('$BASE_DIR') 
AllRawData = countRawData('$BASE_DIR');
save('~/Documents/WD_survey/AllRawData_last$(printf "%02d" $COMPUTER)_$(basename "$BASE_DIR").mat', 'AllRawData');
exit;"
EOF_INNER

  ##  sshpass -p 'physics' scp -o StrictHostKeyChecking=no ocs@10.23.1.$((COMPUTER)):~/Documents/WD_survey/AllRawData_last$(printf "%02d" $COMPUTER)_$(basename "$BASE_DIR").mat "$LOCAL_RESULTS_DIR/"
done

echo "All MATLAB routines executed and results imported."
