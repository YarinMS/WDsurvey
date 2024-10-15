function SSHfunpackFitsFiles(Data)
    % Calculate IP address dynamically based on ComputerNumber and East/West
    eventInfo  = Data.eventInfo;
    timeWindow = Data.timeWindow; 
    ipAddress = calculateIpAddress(eventInfo);

    % Remote SSH path
    remotePath = Data.remotePath;
    
    % Define the newY path (target directory for decompressed files)
    newYPath = sprintf('/last%02d%s/%s/archive/%s/newY', ...
        str2double(eventInfo.telescope(9:10)), ... % Computer number (XX)
        determineEastWest(eventInfo), ...          % e/w based on telescope number
        determineDataDir(eventInfo), ...           % data1/data2
        eventInfo.telescope);                      % telescope info

    % Command to create the newY directory if it doesn't exist
    createNewYDirCommand = sprintf('/usr/local/bin/sshpass -p "physics" ssh ocs@%s "mkdir -p %s"', ipAddress, newYPath);
    
    % Change time format
    startTime = datetime(timeWindow.startTime, 'InputFormat', 'yyyyMMdd.HHmmss.SSS');
    endTime = datetime(timeWindow.endTime, 'InputFormat', 'yyyyMMdd.HHmmss.SSS');
    startTimeFormatted = datestr(startTime, 'yyyy-mm-dd HH:MM:SS');
    endTimeFormatted = datestr(endTime, 'yyyy-mm-dd HH:MM:SS');
    
    decompressCommand = sprintf([ ...
    '/usr/local/bin/sshpass -p "physics" ssh ocs@%s "cd %s && ', ...                        % SSH and navigate to raw directory
    'find . -name ''*.fits.fz'' -newermt ''%s'' ! -newermt ''%s'' ', ...                    % Find files between startTime and endTime
    '-exec funpack {} \\; && mv *.fits %s"'], ...                                           % Decompress and move to newY
    ipAddress, remotePath, startTimeFormatted, endTimeFormatted, newYPath);

    % Run the commands
    system(createNewYDirCommand);  % Create the directory if it doesn't exist
    system(decompressCommand);     % Find, decompress, and move the files
end

function ipAddress = calculateIpAddress(eventInfo)
    % Extract the ComputerNumber from the telescope string
    computerNumber = str2double(eventInfo.telescope(9:10)); % XX from LAST.01.XX.YY
    
    % Determine East or West based on Telescope Number (1-2 = East, 3-4 = West)
    telescopeNumber = str2double(eventInfo.telescope(12:13));
    
    if telescopeNumber == 1 || telescopeNumber == 2
        % East: IP address = computerNumber * 2 - 1
        ipAddress = sprintf('10.23.1.%d', computerNumber * 2 - 1);
    elseif telescopeNumber == 3 || telescopeNumber == 4
        % West: IP address = computerNumber * 2
        ipAddress = sprintf('10.23.1.%d', computerNumber * 2);
    else
        error('Invalid Telescope Number');
    end
end

function dirSuffix = determineEastWest(eventInfo)
    % Determine if the telescope is east ('e') or west ('w')
    telescopeNumber = str2double(eventInfo.telescope(12:13));
    if telescopeNumber == 1 || telescopeNumber == 2
        dirSuffix = 'e';
    else
        dirSuffix = 'w';
    end
end

function dataDir = determineDataDir(eventInfo)
    % Determine if it's data1 or data2 based on telescope number (1 or 3 = data1, 2 or 4 = data2)
    telescopeNumber = str2double(eventInfo.telescope(12:13));
    if mod(telescopeNumber, 2) == 1
        dataDir = 'data1';  % Odd telescope numbers (1, 3) use data1
    else
        dataDir = 'data2';  % Even telescope numbers (2, 4) use data2
    end
end
