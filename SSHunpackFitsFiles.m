function SSHunpackFitsFiles(Data)
    % SSH into the remote system and get the list of files
    eventInfo  = Data.eventInfo;
    timeWindow = Data.timeWindow; 
    ipAddress = calculateIpAddress(eventInfo);
    remotePath = Data.remotePath;

     % Define the newY path (target directory for decompressed files)
    newYPath = sprintf('/last%02d%s/%s/archive/%s/newY', ...
        str2double(eventInfo.telescope(9:10)), ... % Computer number (XX)
        determineEastWest(eventInfo), ...          % e/w based on telescope number
        determineDataDir(eventInfo), ...           % data1/data2
        eventInfo.telescope);                      % telescope info

    % Command to create the newY directory if it doesn't exist
    createNewYDirCommand = sprintf('/usr/local/bin/sshpass -p "physics" ssh ocs@%s "mkdir -p %s"', ipAddress, newYPath);
    s = system(createNewYDirCommand);  % Create the directory if it doesn't exist
    
    % New command to list all .fits.fz files
    listFilesCommand = sprintf( ...
        '/usr/local/bin/sshpass -p "physics" ssh ocs@%s "cd %s && ls *.fits.fz"', ...
        ipAddress, remotePath);
    
    % Run the command and get the list of files
    [status, fileList] = system(listFilesCommand);
    
    if status ~= 0
        error('Failed to list files: %s', fileList);
    end
    
    % Split fileList into individual filenames
    files = strsplit(fileList, newline);
    files = files(~cellfun('isempty', files));  % Remove empty entries
    
    % Initialize an empty array to hold the files to decompress
    
    
    % Convert the start and end time into datetime
    startTime = datetime(timeWindow.startTime, 'InputFormat', 'yyyyMMdd.HHmmss.SSS');
    endTime = datetime(timeWindow.endTime, 'InputFormat', 'yyyyMMdd.HHmmss.SSS');
    
    % Extract and filter files from the current day
    filesToDecompress = filterFilesByTime(files, startTime, endTime);
    
    % If no files found, check the previous day's directory
    if isempty(filesToDecompress)
        % Compute the previous day's path
        previousDayPath = buildRemotePathForPreviousDay(eventInfo);
        remotePath = previousDayPath;
        listPrevDayFilesCommand = sprintf( ...
            '/usr/local/bin/sshpass -p "physics" ssh ocs@%s "cd %s && ls *.fits.fz"', ...
            ipAddress, previousDayPath);

        % Run the command and get the list of files for the previous day
        [status, prevFileList] = system(listPrevDayFilesCommand);
        
        if status == 0
            prevFiles = strsplit(prevFileList, newline);
            prevFiles = prevFiles(~cellfun('isempty', prevFiles));  % Remove empty entries
            
            % Extract and filter files from the previous day
            prevFilesToDecompress = filterFilesByTime(prevFiles, startTime, endTime);
            
            % Merge the results
            filesToDecompress = [filesToDecompress, prevFilesToDecompress];
        end
    end
    
    % If still no files found, print a message and return
    if isempty(filesToDecompress)
        fprintf('No files found within the time window on the current or previous day.\n');
        return;
    end
    
    
    % Prepare the decompress command for the selected files
    decompressCommand = sprintf( ...
        '/usr/local/bin/sshpass -p "physics" ssh ocs@%s "cd %s && ', ...
        ipAddress, remotePath);
    
    for i = 1:length(filesToDecompress)
        fileToDecompress = filesToDecompress{i};
        decompressCommand = [decompressCommand, sprintf('funpack %s && ', fileToDecompress)];
    end
    
    % Move the files to the newY directory after decompression
    decompressCommand = [decompressCommand, sprintf('mv *.fits %s"', newYPath)];
    
    % Run the decompression command
    status = system(decompressCommand);
    if status == 0
        fprintf('Files successfully decompressed and moved to %s.\n', newYPath);
    else
        fprintf('Failed to decompress files.\n');
    end
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


% Helper function to filter files by time
function filesToDecompress = filterFilesByTime(files, startTime, endTime)
    filesToDecompress = {};
    for i = 1:length(files)
        fileName = files{i};
        
        % Extract timestamp from the filename (e.g., 20240710.013430.783)
        fileTimestampStr = regexp(fileName, '\d{8}\.\d{6}\.\d{3}', 'match', 'once');
        
        if ~isempty(fileTimestampStr)
            % Convert the timestamp to datetime
            fileTimestamp = datetime(fileTimestampStr, 'InputFormat', 'yyyyMMdd.HHmmss.SSS');
            
            % Check if the file is within the time window
            if fileTimestamp >= startTime && fileTimestamp <= endTime
                filesToDecompress{end+1} = fileName; %#ok<AGROW>
            end
        end
    end
end


% Helper function to get the path for the previous day
function previousDayPath = buildRemotePathForPreviousDay(eventInfo)
    % Compute the previous day
    eventDate = datetime([eventInfo.year, eventInfo.month, eventInfo.day], 'InputFormat', 'yyyyMMdd');
    previousDay = eventDate - days(1);
    
    % Rebuild the path using the previous day
    previousDayPath = sprintf('/last%02d%s/%s/archive/%s/%s/%s/%s/raw', ...
        str2double(eventInfo.telescope(9:10)), ...  % Computer number (XX)
        determineEastWest(eventInfo), ...          % e/w based on telescope number
        determineDataDir(eventInfo), ...           % data1/data2
        eventInfo.telescope, ...
        datestr(previousDay, 'yyyy'), ...
        datestr(previousDay, 'mm'), ...
        datestr(previousDay, 'dd'));
end
