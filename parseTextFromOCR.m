function eventInfo = parseTextFromOCR(textData)
    % Parse RA and Dec
    raDecPattern = 'Coord\s*:\s*(\d+\.\d+)\s*,\s*(\d+\.\d+)';
    coords = regexp(textData, raDecPattern, 'tokens', 'once');
    if ~isempty(coords)
        eventInfo.ra = str2double(coords{1});
        eventInfo.dec = str2double(coords{2});
    end
    
    % Parse CropID, FieldID, Telescope, and Date
    cropIDPattern = 'CropID\s*:\s*(\d+)';
    cropID = regexp(textData, cropIDPattern, 'tokens', 'once');
    eventInfo.cropID = str2double(cropID{1});
    
    fieldIDPattern = 'FieldID\s*:\s*(\w+)';
    fieldID = regexp(textData, fieldIDPattern, 'tokens', 'once');
    eventInfo.fieldID = fieldID{1};

    telescopePattern = 'Tel:\s*(LAST\.\d+\.\d+\.\d+)';
    telescope = regexp(textData, telescopePattern, 'tokens', 'once');
    eventInfo.telescope = telescope{1};
    
    % Parse date and time
    datePattern = 'Date\s*:\s*(\d{8})\.(\d{6}\.\d{3})';
    dateTokens = regexp(textData, datePattern, 'tokens', 'once');
    if ~isempty(dateTokens)
        eventInfo.dateStr = [dateTokens{1}, '.', dateTokens{2}]; % full date
        eventInfo.year = dateTokens{1}(1:4);
        eventInfo.month = dateTokens{1}(5:6);
        eventInfo.day = dateTokens{1}(7:8);
        eventInfo.timeStr = dateTokens{2}; % HHMMSS.sss
    end
end
