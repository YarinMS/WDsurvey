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
        '/usr/local/bin/sshpass -p "physics" ssh ocs@%s "cd %s && ls *sci_raw*.fits.fz"', ...
        ipAddress, remotePath);
    
    % Run the command and get the list of files
    [status, fileList] = system(listFilesCommand);
    
    if status ~= 0
        error('Failed to list files: %s', fileList);
    end
    
    % Split fileList into individual filenames
    files = strsplit(fileList, newline);
    files = files(~cellfun('isempty', files));  % Remove empty entries
    
    % Filter from files
    [datesJd, counters, filenames] = loadFITSFiles(files);

   

    % Initialize an empty array to hold the files to decompress
    
    
    % Convert the start and end time into datetime
    startTime = datetime(timeWindow.startTime, 'InputFormat', 'yyyyMMdd.HHmmss.SSS');
   
    
    endTime   = datetime(timeWindow.endTime, 'InputFormat', 'yyyyMMdd.HHmmss.SSS');
    
    
   


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
            [datesJd, counters, filenames] = loadFITSFiles(prevFiles);
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

    startTime = datestr(startTime, 'yyyy-mm-dd HH:MM:SS');
    midTime   = eventInfo.dateStr;
    endTime = datestr(endTime, 'yyyy-mm-dd HH:MM:SS');
    visitFilenamesStart = date2visFileNames(startTime, datesJd, counters, filenames);
    visitFilenamesMid = date2visFileNames(midTime, datesJd, counters, filenames);
    visitFilenamesEnd = date2visFileNames(endTime, datesJd, counters, filenames);
    allVisFileNames   = [visitFilenamesStart,visitFilenamesMid,visitFilenamesEnd];
    uniqueVisitFilenames = unique(allVisFileNames);
    % Prepare the decompress command for the selected files
    decompressCommand = sprintf( ...
        '/usr/local/bin/sshpass -p "physics" ssh ocs@%s "cd %s && ', ...
        ipAddress, remotePath);
    
    for i = 1:length(uniqueVisitFilenames)
        fileToDecompress = uniqueVisitFilenames{i};
        decompressCommand = [decompressCommand, sprintf('funpack %s && ', fileToDecompress)];
    end

      
    % Move the files to the newY directory after decompression
    decompressCommand = [decompressCommand, sprintf('mv *.fits %s"', newYPath)];
    
    % Run the decompression command
    status = system(decompressCommand);
    if status == 0
        fprintf('Files successfully decompressed and moved to %s.\n', newYPath);


        % Run remote pipeline
        telescopeNumber = str2double(eventInfo.telescope(end-1:end))
        year  = str2double(eventInfo.year);
        month = str2double(eventInfo.month);
        day   = str2double(eventInfo.day);
        runRemotePipeline(ipAddress, telescopeNumber, year, month, day)
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



function visitFilenames = date2visFileNames(inputDate, datesJd, counters, filenames)
   
    jdInput = convertToJD(inputDate);


    % Find the closest image to the input date
    idxClosest = findClosestImage(datesJd, jdInput);

    % Retrieve filenames for the entire visit (Counter 1 to Counter 20)
    visitFilenames = getVisitFiles(counters, filenames, idxClosest);
end

function jdInput = convertToJD(inputDate)
    % This function converts various date formats into Julian Date (JD).
    % Input:
    % - inputDate: Can be JD, [year, month, day], or custom string format 'yyyymmdd.HHMMSS.SSS'.
    % Output:
    % - jdInput: Date in Julian Date format.

    if isnumeric(inputDate) && length(inputDate) == 1
        % Input is already in JD format
        jdInput = inputDate;
    elseif isnumeric(inputDate) && length(inputDate) == 3
        % Input is in [year, month, day] format
        jdInput = juliandate(datetime(inputDate));
    elseif ischar(inputDate) || isstring(inputDate)
        % Handle custom 'yyyymmdd.HHMMSS.SSS' format
        if contains(inputDate, '.')
            % Split the string into date and time components
            parts = split(inputDate, '.');
            datePart = parts{1};
            timePart = parts{2};

            % Convert date part 'yyyymmdd' -> 'yyyy-mm-dd'
            yearStr = datePart(1:4);
            monthStr = datePart(5:6);
            dayStr = datePart(7:8);

            % Convert time part 'HHMMSS' and fractional seconds
            hourStr = timePart(1:2);
            minStr = timePart(3:4);
            secStr = timePart(5:6);
            fracSecStr = parts{3};

            % Create a valid datetime string
            dateTimeStr = sprintf('%s-%s-%s %s:%s:%s.%s', yearStr, monthStr, dayStr, hourStr, minStr, secStr, fracSecStr);

            % Convert to datetime
            dt = datetime(dateTimeStr, 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSS');

            % Convert datetime to JD
            jdInput = juliandate(dt);
        else
            % Input is a standard datestr format
            jdInput = juliandate(datetime(inputDate, 'InputFormat', 'yyyy-MM-dd HH:mm:ss'));
        end
    else
        error('Invalid date format. Please provide JD, [year, month, day], or a valid date string.');
    end
end



function [datesJd, counters, filenames] = loadFITSFiles(files)
    % This function loads compressed FITS files (.fits.fz) from the specified
    % directory and extracts their timestamps and counters from their filenames.
    % Input:
    % - pathDir: Path to the directory containing FITS files.
    % Output:
    % - datesJd: Julian dates extracted from filenames.
    % - counters: Counter values extracted from filenames.
    % - filenames: Filenames of the FITS files.

    % Get all .fits.fz files in the directory

   
    if isempty(files)
        error('No FITS files found in the specified directory.');
    end

    % Initialize arrays to store dates (in JD), counters, and filenames
    numFiles = numel(files);
    datesJd = zeros(1, numFiles);
    counters = zeros(1, numFiles);
    filenames = files;

    % Loop through the filenames to extract the date and counter
    for i = 1:numFiles
        % Extract the filename without extension
        fname = files{i};
        
        % Split the filename based on underscores
        parts = split(fname, '_');
        
        % Extract date part (e.g., '20240709.005006.826')
        datePart = parts{2};
        
        % Convert date part into JD
        dateStr = [datePart(1:4) '-' datePart(5:6) '-' datePart(7:8) ' ' ...
                   datePart(10:11) ':' datePart(12:13) ':' datePart(14:15) '.' datePart(17:end)];
        dt = datetime(dateStr, 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSS');
        datesJd(i) = juliandate(dt);
        
        % Extract the counter part (assumed to be the third numeric part after the field ID)
        counterStr = parts{5};  % For example, this might be '009'
        counters(i) = str2double(counterStr);
    end
end




function idxClosest = findClosestImage(datesJd, jdInput)
    % This function finds the closest image to the input date.
    % Input:
    % - datesJd: Array of dates (in JD format).
    % - jdInput: Input date in Julian Date format.
    % Output:
    % - idxClosest: Index of the closest image.

    % Find the closest date (minimize the absolute difference)
    [~, idxClosest] = min(abs(datesJd - jdInput));
end

function visitFiles = getVisitFiles(counters, filenames, idxClosest)
    % This function retrieves the previous and next files around the closest
    % counter found. The goal is to collect up to 20 files, balancing around
    % the closest file.
    % Input:
    % - counters: Counter values for each image.
    % - filenames: Corresponding filenames for the images.
    % - idxClosest: Index of the closest image.
    % Output:
    % - visitFiles: Cell array of filenames for the entire visit.

    % Initialize the list of visit filenames
    visitFiles = {};

    % Get the counter of the closest image
    closestCounter = counters(idxClosest);

    % Number of files to collect before and after the closest counter
    maxBefore = min(closestCounter - 1, 20);  
    maxAfter = min(20 - closestCounter, 20);  

    % Step 1: Collect previous files from closestCounter - maxBefore down to 001
    for i = closestCounter - maxBefore-1:closestCounter-1
        % Find the index of the file with this counter
        idx = idxClosest - i;
        if ~isempty(idx)
            visitFiles{end+1} = filenames{idx};  % Add this file to the visit list
        end
    end

    % Step 2: Collect next files from closestCounter + 1 up to COUNTER 20
    for i = 1:length(closestCounter+1:closestCounter+maxAfter)
        % Find the index of the file with this counter
        idx = idxClosest + i ;
        if ~isempty(idx)
            visitFiles{end+1} = filenames{idx};  % Add this file to the visit list
        end
    end

    % Ensure files are in order by sorting based on counters
    visitFiles = sortVisitFiles(visitFiles);
end

function sortedFiles = sortVisitFiles(visitFiles)
    % This function sorts the visit files based on their counters.
    sortedFiles = sort(visitFiles);  % Assuming filenames are ordered by counter naturally
end



function runRemotePipeline(ipAddress, telescopeNumber, year, month, day)
    % Build the MATLAB command to add the path and run the pipeline remotely
    matlabCommand = sprintf([ ...
        'addpath(''~/Documents/WDsurvey/'');', ...
        'runPipelineScript(%d, %d, %d, %d);', ...
        'exit;'], telescopeNumber, year, month, day);

    % SSH command to run MATLAB remotely
    remoteMatlabCommand = sprintf( ...
        '/usr/local/bin/sshpass -p "physics" ssh ocs@%s "matlab -nodesktop -nodisplay -r ''%s''"', ...
        ipAddress, matlabCommand);

    % Execute the remote MATLAB pipeline
    status = system(remoteMatlabCommand);

    if status == 0
        fprintf('Pipeline executed successfully on remote machine %s.\n', ipAddress);
    else
        fprintf('Failed to execute pipeline on remote machine %s.\n', ipAddress);
    end
end


