function visitFilenames = date2visFileNames(inputDate, pathDir)
    % This function finds the closest image to the given date and retrieves
    % filenames for the entire visit (Counter 1 to Counter 20).
    % Input:
    % - inputDate: Date in JD, [year, month, day], or datestr format 'yyyyMMdd.HHmmss.sss' or 'yyyy-MM-dd HH:mm:ss'.
    % - pathDir: Path to the directory containing FITS files.
    % Output:
    % - visitFilenames: A cell array of filenames for the entire visit (Counter 1 to Counter 20).
    %
    % Author Yarin Shani

    % Convert inputDate to JD format
    jdInput = convertToJD(inputDate);

    % Load filenames, timestamps (in JD), and counters from the specified path
    [datesJd, counters, filenames] = loadFITSFiles(pathDir);

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



function [datesJd, counters, filenames] = loadFITSFiles(pathDir)
    % This function loads compressed FITS files (.fits.fz) from the specified
    % directory and extracts their timestamps and counters from their filenames.
    % Input:
    % - pathDir: Path to the directory containing FITS files.
    % Output:
    % - datesJd: Julian dates extracted from filenames.
    % - counters: Counter values extracted from filenames.
    % - filenames: Filenames of the FITS files.

    % Get all .fits.fz files in the directory

    files = dir(fullfile(pathDir, '*.fits.fz'));
    if isempty(files)
        error('No FITS files found in the specified directory.');
    end

    % Initialize arrays to store dates (in JD), counters, and filenames
    numFiles = numel(files);
    datesJd = zeros(1, numFiles);
    counters = zeros(1, numFiles);
    filenames = {files.name};

    % Loop through the filenames to extract the date and counter
    for i = 1:numFiles
        % Extract the filename without extension
        fname = files(i).name;
        
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


function [imageDates, counters, filenames] = extractMetadata(AI)
    % This function extracts metadata from the AstroImage object.
    % Input:
    % - AI: AstroImage object containing the loaded FITS files.
    % Output:
    % - imageDates: Observation dates in ISO string format (DATE_OBS).
    % - counters: Counter values for each image.
    % - filenames: Filenames of the images.
    
    % Extract DATE_OBS, COUNTER, and FILENAME metadata
    imageDates = AI.getStructKey({'DATE_OBS'});  % Extract dates (ISO format)
    counters = AI.getStructKey({'COUNTER'});     % Extract counters
    filenames = AI.getStructKey({'FILENAME'});   % Extract filenames
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


