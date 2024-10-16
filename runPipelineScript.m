function runPipelineScript(telescopeNumber, year, month, day)
    % Initialize the DemonLAST pipeline object
    D = pipeline.DemonLAST;
    
    % Set the Data Directory (data1 or data2 depending on the telescope number)
    if mod(telescopeNumber, 2) == 1
        D.DataDir = 1;  % Odd telescope numbers (1, 3) use data1
    else
        D.DataDir = 2;  % Even telescope numbers (2, 4) use data2
    end
    
    % Set the Camera Number as the Telescope Number (formatted as 2-digit string)
    D.CamNumber = telescopeNumber;
    
    % Define the Calibration and NewY paths
    CalibPath = D.CalibPath;           % Use existing calibration path from the pipeline object
    NewYPath = strcat(D.NewPath, 'Y'); % Append 'Y' to NewPath
    
    % Update base paths for reprocessing
    D.BasePath = strcat(D.BasePath, '_re');
    D.DefCalibPath = CalibPath;
    D.DefNewPath = NewYPath
    
    % Load the calibration data for the specified date (year, month, day)
    D.loadCalib('FlatNearJD', [year, month, day]);
    D.prepMasterDark;
    D.prepMasterFlat;



    
    % Run the pipeline with 'StopWhenDone' set to true
    D.main('StopButton',false,'StopWhenDone', true);
    
    % Optionally: Print a message after successful completion
    fprintf('Pipeline completed for Telescope %d on %d-%02d-%02d.\n', telescopeNumber, year, month, day);
end
