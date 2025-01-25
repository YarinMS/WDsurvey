% runCountRawData.m
% -----------------------------------------------
% Script to count raw data and save the results
% -----------------------------------------------

% Add WDsurvey and its subdirectories to the MATLAB path
addpath(genpath('~/Documents/WDsurvey/'));

% Retrieve the base directory from the environment variable
baseDir = getenv('BASEDIR')
if isempty(baseDir)
    error('BASEDIR environment variable is not set.');
end

% Display the directory being processed
disp(['Running countRawData for: ', baseDir]);

% Call the countRawData function
try
    AllRawData = countRawData(baseDir); % Call your function
    % Define output file name based on baseDir
    outputFile = ['~/Documents/WD_survey/AllRawData_', strrep(baseDir(end-12:end), '/', '_'), '.mat'];
    % Save results
    save(outputFile, 'AllRawData');
    disp(['Results saved to: ', outputFile]);
catch ME
    % Catch errors and display them
    disp(['Error running countRawData: ', ME.message]);
end

% Exit MATLAB
exit;
