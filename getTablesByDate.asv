% Define the folder containing the .mat files
folderPath = '/media/yarinms/Data2/Projects/MarvinRuns/20Vis'; % Adjust the path as needed

% Define a date patern 
datePat = '*2024.10.26'
% List all .mat files in the folder
fileList = dir(fullfile(folderPath, strcat(datePat,'*.mat')));
%%
% Sort the files by size in descending order
[~, sortIdx] = sort([fileList.bytes], 'descend'); % Sort by file size
sortedFiles = fileList(sortIdx);
largestFile = sortedFiles(1);

largestFilePath = fullfile(largestFile.folder, largestFile.name);
data = load(largestFilePath)

%%
tableVars = struct2cell(data); % Convert to cell array
tableFound = find(cellfun(@(x) istable(x), tableVars), 1);

if isempty(tableFound)
    error('No table found in the largest file: %s', largestFile.name);
end

% Extract the first table found
largestTable = tableVars{tableFound}
%%

% Initialize an empty array to store all tables
allTables = [];
Nwds = 0;
Stat.WDdet = zeros(size(fileList));
Stat.FNs   = cell(size(fileList));

% Load and concatenate data from all files
for k = 1:length(fileList)
    filePath = fullfile(fileList(k).folder, fileList(k).name);
    
    % Load the file content
    data = load(filePath);
    
    % Check for a table variable in the loaded data
    tableVars = struct2cell(data); % Convert to cell array
    tableFound = find(cellfun(@(x) istable(x), tableVars), 1);
    
    if isempty(tableFound)
        warning('No table found in %s. Skipping.', fileList(k).name);
        continue;
    end
    
    % Extract the first table found
    tbl = tableVars{tableFound};
    nWDs = sum(tbl.Pwd > 0);
    fprintf('\n%i WDs found in Field %s of %s',nWDs,tbl.FieldID{1},tbl.TelescopeID(1,:))
    Nwds = Nwds+nWDs;
    Stat.WDdet = nWDs;
    Stat.FNs   = tbl.TelescopeID(1,:);
    % Concatenate it into the combined table
    if isempty(allTables)
        allTables = tbl; % Initialize on the first iteration
    else
        allTables = [allTables; tbl]; %#ok<AGROW> 
    end
end


%%
% Check the size of the combined table
fprintf('Loaded %d rows into the combined table.\n', height(allTables));

% Perform some example operations
% Sorting by a specific column (replace 'ColumnName' with your column name)
if ismember('ColumnName', allTables.Properties.VariableNames)
    allTables = sortrows(allTables, 'ColumnName');
end

% Filtering rows based on conditions (example: filtering a date column)
if ismember('DateColumn', allTables.Properties.VariableNames)
    dateFilter = allTables.DateColumn >= datetime(2024, 1, 1);
    filteredTable = allTables(dateFilter, :);
end

% Save the combined table
save(fullfile(folderPath, 'Combined_Table.mat'), 'allTables');
disp('Combined table saved as Combined_Table.mat');
