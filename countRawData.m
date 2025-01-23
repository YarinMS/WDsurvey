function data = countRawData(baseDir)

telescopes = dir(fullfile(baseDir, 'LAST.*')); % Find telescope directories
telescopes = telescopes([telescopes.isdir]); % Keep only directories
telescopes = telescopes(~endsWith({telescopes.name}, '_re'));
fprintf('\n Start to count raw images for %s',baseDir)

% Initialize table for data
data = table('Size', [0, 14], ...
             'VariableTypes', {'datetime', 'datetime', 'string', 'string', 'double', 'double', 'double', ...
                               'string', 'string', 'double', 'double', 'double', 'double','double'}, ...
             'VariableNames', {'Date', 'Time', 'TelescopeID', 'FieldID', 'RA', 'DEC', 'ExpTime', ...
                               'FileName', 'FilePath', 'Year', 'Month', 'Day', 'MountNum', 'Telescope'});

% Loop through telescopes
for i = 1:numel(telescopes)
    telescopeDir = fullfile(telescopes(i).folder, telescopes(i).name);
    
    % Extract Mount and Camera numbers from telescope ID
    telescopeParts = split(telescopes(i).name, '.');
    MountNum = str2double(telescopeParts{3}); % Extract Mount number
    CameraNum = str2double(telescopeParts{4}); % Extract Camera number
    
    years = dir(fullfile(telescopeDir, '202*')); % Year directories
    years = years([years.isdir]);
    
    for j = 3 %1:numel(years)
        yearDir = fullfile(years(j).folder, years(j).name);
        months = dir(fullfile(yearDir, '*')); % Month directories
        months = months(~ismember({months.name}, {'.', '..'}));
        
        for k = 1:numel(months)
            monthDir = fullfile(months(k).folder, months(k).name);
            days = dir(fullfile(monthDir, '*')); % Day directories
            days = days(~ismember({days.name}, {'.', '..'}));
            
            for l = 1:numel(days)
                dayDir = fullfile(days(l).folder, days(l).name);
                rawDir = fullfile(dayDir, 'raw'); % Raw directory
                if ~isfolder(rawDir), continue; end
                
                % Find compressed FITS files
                fitsFiles = dir(fullfile(rawDir, '*.fits.fz')); % Adjust for actual format
                for m = 1:numel(fitsFiles)
                    filePath = fullfile(fitsFiles(m).folder, fitsFiles(m).name);
                    
                    % Extract metadata from file name (customize this)
                    fileName = fitsFiles(m).name;
                    parts = split(fileName, '_');
                    times = split(parts{2}, '.');
                    if str2double(times{2}(end-1:end)) > 59
                        times{2}(end-1:end) = '59';
                        mili = '999';
                    else
                        mili = times{3};
                    end
                    dateTime = datetime([times{1} times{2}], 'InputFormat', 'yyyyMMddHHmmss');
                    dateTime = dateTime + milliseconds(str2double(mili));
                    telescopeID = parts{1};
                    fieldID = parts{4};
                    
                    % Extract RA, DEC, and ExpTime from FITS header
                    info = fitsinfo(filePath);
                    header = info.Image.Keywords;
                    RA = NaN; DEC = NaN; ExpT = NaN; % Defaults
                    idxRA = find(strcmp(header(:, 1), 'RA'), 1);
                    idxDEC = find(strcmp(header(:, 1), 'DEC'), 1);
                    idxExpT = find(strcmp(header(:, 1), 'EXPTIME'));
                    if ~isempty(idxRA), RA = header{idxRA, 2}; end
                    if ~isempty(idxDEC), DEC = header{idxDEC, 2}; end
                    if ~isempty(idxExpT), ExpT = header{idxExpT, 2}; end
                    
                    % Extract Year, Month, Day
                    Year = year(dateTime);
                    Month = month(dateTime);
                    Day = day(dateTime);
                    
                    % Append to table
                    newRow = {dateTime, dateTime, telescopeID, fieldID, RA, DEC, ExpT, ...
                              fileName, filePath, Year, Month, Day, MountNum, CameraNum}

                    data = [data; newRow];
                end
            end
        end
    end
end

end



