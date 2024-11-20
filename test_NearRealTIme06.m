% Parameters
folderPath = '/last06e/data2/archive/LAST.01.06.02/2024/11/04/proc';
N = 2; % Minimum number of new directories required
timerPeriod =30; % Check every 60 seconds 
% Define the folder path where you want to save the log file
logFolderPath = '~/Documents/WD_survey/';

% Generate the current date as a string in the format YYYYMMDD
currentDate = datestr(now, 'yyyymmdd');

% Create the log file name with the date
logFile = fullfile(logFolderPath, ['processed_visits_', currentDate, '.log']);
% Timer Setup
timerObj = timer('ExecutionMode', 'fixedRate', 'Period', timerPeriod, ...
                 'TimerFcn', @(~,~)checkForNewDirectories1(folderPath, N, logFile),'BusyMode', 'drop');

% Start the monitoring
start(timerObj);