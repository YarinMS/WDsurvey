% Convert Date and Time columns to datetime if needed
master_table.Date = datetime(master_table.Date, 'InputFormat', 'dd-MMM-yyyy');
master_table.Time = datetime(master_table.Time, 'InputFormat', 'dd-MMM-yyyy HH:mm:ss');

% Define observing nights based on your criteria (14:00 to 06:00 next day)
timeOfDay = timeofday(master_table.Time); % Extract time of day for all rows
obsNight = master_table.Date;             % Initialize observation night
obsNight(timeOfDay < hours(6)) = obsNight(timeOfDay < hours(6)) - days(1); % Shift early morning to previous day

% Add ObsNight column to the table
master_table.ObsNight = obsNight;

% Extract unique fields
uniqueFields = unique(master_table.FieldID);

% Initialize results storage
results = table('Size', [0, 6], 'VariableTypes', {'string', 'string', 'double', 'double', 'double', 'double'}, ...
    'VariableNames', {'FieldID', 'TelescopeID', 'NumNights', 'ImagesPerNight', 'MeanRA', 'MeanDec'});

% Loop over each unique field
for i = 1:numel(uniqueFields)
    % Filter data for the current field
    fieldData = master_table(strcmp(master_table.FieldID, uniqueFields{i}), :);
    
    % Calculate mean RA and Dec for the field
    meanRA = mean(fieldData.RA);
    meanDec = mean(fieldData.DEC);
    
    % Get unique telescopes observing this field
    uniqueTelescopes = unique(fieldData.TelescopeID);
    
    % Loop over each telescope
    for j = 1:numel(uniqueTelescopes)
        % Filter data for the current telescope
        telescopeData = fieldData(strcmp(fieldData.TelescopeID, uniqueTelescopes{j}), :);
        
        % Get unique observation nights for this telescope and field
        uniqueNights = unique(telescopeData.ObsNight);
        numNights = numel(uniqueNights); % Total unique nights
        
        % Count images per night
        imagesPerNightArray = zeros(numNights, 1);
        for k = 1:numNights
            % Count rows for the current observation night
            imagesPerNightArray(k) = sum(telescopeData.ObsNight == uniqueNights(k));
        end
        avgImagesPerNight = mean(imagesPerNightArray); % Average images per night
        
        % Append results
        results = [results; {uniqueFields{i}, uniqueTelescopes{j}, numNights, avgImagesPerNight, meanRA, meanDec}];
    end
end

% Display the results table
disp(results);
