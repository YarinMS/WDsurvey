% summarizeObservationData.m
% Combines all individual tables and generates observation statistics.

% Define the directory containing the .mat files
resultDir = '~/Projects/ObservationsStat'; % Adjust this path if needed
files = dir(fullfile(resultDir, '*.mat')); % Get all .mat files

if isempty(files)
    error('No .mat files found in the directory: %s', resultDir);
end

% Initialize the master table
masterTable = table();

% Loop through each file and load its table
for i = 1:numel(files)
    filePath = fullfile(files(i).folder, files(i).name);
    disp(['Loading file: ', files(i).name]);
    
    % Load the .mat file
    dataStruct = load(filePath);
    tableName = fieldnames(dataStruct);
    tableData = dataStruct.(tableName{1});
    
    % Skip empty tables
    if isempty(tableData)
        disp(['Skipping empty table in file: ', files(i).name]);
        continue;
    end

    if length(tableName{1}) == length('summaryStats')
        if tableName{1} == 'summaryStats'
        continue
        end
    end
       
    
    % Append to the master table
    masterTable = [masterTable; tableData]; %#ok<AGROW>
end

% Ensure 'Date' and 'Time' are datetime
if ~isdatetime(masterTable.Time)
    masterTable.Time = datetime(masterTable.Time, 'InputFormat', 'dd-MMM-yyyy HH:mm:ss');
end

% Define Observing Night
% Observing night starts at 2 PM and ends at 6 AM the following day
masterTable.ObsNight = masterTable.Date; % Start with the same dates
before6AM = masterTable.Time.Hour < 6;
masterTable.ObsNight(before6AM) = masterTable.ObsNight(before6AM) - days(1);
masterTable.ObsNight = dateshift(masterTable.ObsNight, 'start', 'day', 'next') - hours(10);

% Unique fields per telescope
[uniqueFields, ~, fieldIdx] = unique(masterTable(:, {'FieldID', 'TelescopeID'}), 'rows');

% Initialize summary variables
numUniqueFields = numel(uniqueFields.FieldID);
fieldStats = table(uniqueFields, zeros(numUniqueFields, 1), zeros(numUniqueFields, 1), ...
    'VariableNames', {'FieldID', 'NumNights', 'TotalExpTime'});

% Calculate statistics per field
for i = 1:numUniqueFields
    % Get all rows for this field and telescope
    rows = masterTable.FieldID == uniqueFields.FieldID(i) & ...
           masterTable.TelescopeID == uniqueFields.TelescopeID(i);
    fieldData = masterTable(rows, :);
    
    % Number of nights
    fieldStats.NumNights(i) = numel(unique(fieldData.ObsNight));
    
    % Total exposure time per field
    fieldStats.TotalExpTime(i) = sum(fieldData.ExpTime);
end

% Per-night observation summary
nightFieldGroups = groupsummary(masterTable, {'ObsNight', 'FieldID'}, {'sum', 'numel'}, 'ExpTime');
nightFieldGroups.Properties.VariableNames{'GroupCount'} = 'NumObservations';
nightFieldGroups.Properties.VariableNames{'sum_ExpTime'} = 'TotalExpTime';

% Save results
summaryFile = fullfile(resultDir, 'ObservationSummary.mat');
save(summaryFile, 'fieldStats', 'nightFieldGroups');

% Display the results
disp('Field-Level Statistics:');
disp(head(fieldStats));
disp('Per-Night Observation Summary:');
disp(head(nightFieldGroups));
