
% Convert Date and Time columns to datetime if needed
master_table.Date = datetime(master_table.Date, 'InputFormat', 'dd-MMM-yyyy');
master_table.Time = datetime(master_table.Time, 'InputFormat', 'dd-MMM-yyyy HH:mm:ss');

% Adjust observation times to define unique observing nights
master_table.ObsNight = master_table.Date; % Initialize ObsNight
timeOfDay = timeofday(master_table.Time);  % Extract time of day for all rows
adjustedDates = master_table.Date;         % Base date for adjustment

% Adjust rows where time is before 6:00 to belong to the previous day
isMorning = timeOfDay < hours(6);
adjustedDates(isMorning) = adjustedDates(isMorning) - days(1);

% Assign the adjusted dates as the observation nights
master_table.ObsNight = adjustedDates;

% Initialize a table to store results
uniqueFields = unique(master_table.FieldID);
results = table('Size', [0, 6], 'VariableTypes', {'string', 'string', 'double', 'double', 'double', 'double'}, ...
    'VariableNames', {'FieldID', 'TelescopeID', 'NumNights', 'ImagesPerNight', 'MeanRA', 'MeanDec'});

% Loop through each unique field
for i = 1:numel(uniqueFields)
    fieldData = master_table(strcmp(master_table.FieldID, uniqueFields{i}), :); % Filter by FieldID
    
    % Calculate the mean RA and Dec for this field
    meanRA = mean(fieldData.RA);
    meanDec = mean(fieldData.DEC);
    
    % Get unique TelescopeIDs observing this field
    telescopes = unique(fieldData.TelescopeID);
    
    % Loop through each TelescopeID
    for j = 1:numel(telescopes)
        telescopeData = fieldData(strcmp(fieldData.TelescopeID, telescopes{j}), :);
        
        % Count unique observation nights
        uniqueNights = unique(telescopeData.ObsNight);
        numNights = numel(uniqueNights);
        
        % Count images per night
        imagesPerNightArray = zeros(numNights, 1);
        for k = 1:numNights
            % Count rows corresponding to the current night
            imagesPerNightArray(k) = sum(telescopeData.ObsNight == uniqueNights(k));
        end
        imagesPerNight = mean(imagesPerNightArray); % Average images per night
        
        % Append the results
        results = [results; {uniqueFields{i}, telescopes{j}, numNights, imagesPerNight, meanRA, meanDec}];
    end
end

% Display the results
disp(results);
