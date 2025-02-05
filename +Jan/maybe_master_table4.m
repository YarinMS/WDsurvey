% Convert Date and Time columns to datetime if needed
master_table.Date = datetime(master_table.Date, 'InputFormat', 'dd-MMM-yyyy');
master_table.Time = datetime(master_table.Time, 'InputFormat', 'dd-MMM-yyyy HH:mm:ss');

% Create a new column to define observation nights
observationStart = hours(14); % 14:00 (2 PM)
observationEnd = hours(6);    % 06:00 (6 AM next day)

% Compute observation nights
master_table.ObsNight = master_table.Date;
for i = 1:height(master_table)
    timeOfDay = timeofday(master_table.Time(i)); % Extract time of day
    if timeOfDay < observationEnd % If before 06:00, it belongs to the previous day
        master_table.ObsNight(i) = master_table.Date(i) - days(1);
    end
end

% Get all unique TelescopeIDs
uniqueTelescopes = unique(master_table.TelescopeID);

% Initialize arrays to store results
uniqueFields = zeros(length(uniqueTelescopes), 1);
uniqueNights = zeros(length(uniqueTelescopes), 1);

% Loop through each TelescopeID
for i = 1:length(uniqueTelescopes)
    % Get data for the current TelescopeID
    currentData = master_table(strcmp(master_table.TelescopeID, uniqueTelescopes{i}), :);
    
    % Count unique fields
    uniqueFields(i) = numel(unique(currentData.FieldID));
    
    % Count unique observation nights
    uniqueNights(i) = numel(unique(currentData.ObsNight));
end

% Create a summary table
summaryTable = table(uniqueTelescopes, uniqueFields, uniqueNights, ...
    'VariableNames', {'TelescopeID', 'UniqueFields', 'UniqueNights'});

% Display the summary table
disp(summaryTable);
