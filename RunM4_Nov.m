
 
 % Parameters
folderPath = '/last04e/data1/archive/LAST.01.04.01/2024/11/01/proc';
N = 2; % Minimum number of new directories required

logFolderPath = '~/Documents/WD_survey/Temp1/';

% Generate the current date as a string in the format YYYYMMDD
currentDate = datestr(now, 'yyyymmdd');

% Create the log file name with the date
logFile = fullfile(logFolderPath, ['processed_visits_', currentDate, '.log']);
% Timer Setup
checkForNewDirectories12(folderPath, 2, logFile);

