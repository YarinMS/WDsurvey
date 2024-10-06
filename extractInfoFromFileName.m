function [ra, dec, cropID, fullPath, telescopeFolder,fieldID] = extractInfoFromFileName(fileName)
    % EXTRACTINFOFROMFILENAME extracts the RA, Dec, CropID, telescope folder, and date path from the file name.
    % Input:
    %   fileName : Name of the image file (e.g. '291.102139_23.659743_...')
    % Output:
    %   ra             : RA coordinate
    %   dec            : Dec coordinate
    %   cropID         : CropID of the source
    %   fullPath       : Full path to the processing directory
    %   telescopeFolder: Telescope folder extracted from the file name

    % Step 1: Split the file name based on underscores
    parts = split(fileName, '_');
    
    % Step 2: Extract RA, Dec, and CropID
    ra = str2double(parts{1});    % RA part
    dec = str2double(parts{2});   % Dec part
    cropID = str2double(parts{6});  % CropID part

    % Step 3: Extract telescope folder from the filename
    telescopeFolder = parts{7};  % Example: 'LAST.01.10.01'
    
    % Step 4: Extract date part from the filename (find part with date)
    dateTimeStr = parts{8};  % Example: '20230821.210413.966'
    dateStr = dateTimeStr(1:8);  % Extract date 'yyyymmdd'
    timeStr = dateTimeStr(10:15);  % Extract time 'hhmmss'

    % Step 5: Convert the date to YYYY/MM/DD format
    year = dateStr(1:4);
    month = dateStr(5:6);
    day = dateStr(7:8);

    % Step 6: Adjust for post-midnight case (if timeStr > 000000)
    hhmmss = str2double(timeStr(1:2));
    if hhmmss < 7  % Check if the time is after midnight but still before 7AM
        day = num2str(str2double(day) - 1, '%02d');  % Adjust the day
    end

    % Step 7: Create the full path for the 'proc' directory
    fullPath = fullfile('~/marvin', telescopeFolder, year, month, day, 'proc');
    fieldID  = parts{10};
    
end
