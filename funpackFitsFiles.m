function funpackFitsFiles(startDateTime, endDateTime,baseDir, destinationDir)
    % unpackFitsFilesWithFunpack Unpacks .fits.fz files within a date and time range (down to seconds) using funpack
    % and stores the results in a new folder.
    %
    % INPUTS:
    %   startDateTime  - Start date and time as a string, format: 'yyyy-MM-dd HH:mm:ss'
    %   endDateTime    - End date and time as a string, format: 'yyyy-MM-dd HH:mm:ss'
    %   destinationDir - Path where to unpack the fits files
    %
    % Example:
    % unpackFitsFilesWithFunpack('2024-08-11 17:30:30', '2024-08-11 17:34:45','/last04e/data1/archive/LAST.01.04.01/', '~/Documents/to/unpack/')

    % Parse input date-times with seconds precision
    startDateTime = datetime(startDateTime, 'InputFormat', 'yyyy-MM-dd HH:mm:ss');
    endDateTime = datetime(endDateTime, 'InputFormat', 'yyyy-MM-dd HH:mm:ss');
    
   
    % Check and create the destination directory if it doesn't exist
    if ~exist(destinationDir, 'dir')
        mkdir(destinationDir);
    end
    
    % Loop through the days within the range
    currentDateTime = startDateTime;
    
    while currentDateTime <= endDateTime
        yearStr = datestr(currentDateTime, 'yyyy');
        monthStr = datestr(currentDateTime, 'mm');
        dayStr = datestr(currentDateTime, 'dd');
        
        % Construct the path to the "raw" folder for this specific day
        rawDir = fullfile(baseDir, yearStr, monthStr, dayStr, 'raw');
        
        % Check if rawDir exists
        if ~exist(rawDir, 'dir')
            fprintf('Directory does not exist: %s\n', rawDir);
            currentDateTime = currentDateTime + caldays(1);
            continue;
        end
        
        % Find all .fits.fz files in this directory
        fitsFiles = dir(fullfile(rawDir, '*.fits.fz'));
        
        % Loop over each .fits.fz file
        for i = 1:length(fitsFiles)
            fileName = fitsFiles(i).name;
            
            % Extract the timestamp from the file name, assuming format:
            % 'LAST.xx.xx.xx_yyyymmdd.HHMMSS_xxx_clear_Test20s_020_001_001_sci_raw_Image_1.fits.fz'
            filePattern = 'LAST\.\d{2}\.\d{2}\.\d{2}_(\d{8})\.(\d{6})';  % Regex for extracting date and time
            tokens = regexp(fileName, filePattern, 'tokens');
            
            if isempty(tokens)
                warning('File name does not match expected pattern: %s', fileName);
                continue;
            end
            
            fileDate = tokens{1}{1};  % yyyymmdd
            fileTime = tokens{1}{2};  % HHMMSS
            
            % Convert file date and time to a datetime object (with seconds precision)
            fileDateTime = datetime([fileDate fileTime], 'InputFormat', 'yyyyMMddHHmmss');
            
            % Check if the file falls within the specified range
            if fileDateTime >= startDateTime && fileDateTime <= endDateTime
                filePath = fullfile(fitsFiles(i).folder, fitsFiles(i).name);
                destinationFile = fullfile(destinationDir, erase(fitsFiles(i).name, '.fz'));
                
                % Use the 'funpack' command to decompress the .fits.fz file
                try
                    fprintf('Unpacking file with funpack: %s\n', fitsFiles(i).name);
                    % Construct the system command to call 'funpack'
                    funpackCommand = sprintf('funpack -O %s%s %s', destinationDir,fitsFiles(i).name(1:end-3), filePath);
                    % Run the command
                    system(funpackCommand);
                catch ME
                    warning('Failed to unpack %s: %s', fitsFiles(i).name, ME.message);
                end
            end
        end
        
        % Move to the next day
        currentDateTime = currentDateTime + caldays(1);
    end
end
