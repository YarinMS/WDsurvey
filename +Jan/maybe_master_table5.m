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
    
    % Count unique nights
    uniqueNights(i) = numel(unique(currentData.Date));
end

% Create a summary table
summaryTable = table(uniqueTelescopes, uniqueFields, uniqueNights, ...
    'VariableNames', {'TelescopeID', 'UniqueFields', 'UniqueNights'});

% Display the summary table
disp(summaryTable);groupedData = groupsummary(master_table, "TelescopeID", ["nunique"], ["FieldID", "Date"]);
