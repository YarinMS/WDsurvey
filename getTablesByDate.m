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





% Load the table (already loaded as `largestTable`)
dataTable = largestTable; % Assume your table is called 'largestTable'

% Extract unique observing units: Telescope, FieldID, and Date
observingUnits = unique(dataTable(:, {'TelescopeID', 'FieldID', 'Year', 'Month', 'Day'}));

% Preallocate arrays for statistics
%%
% Preallocate arrays for statistics
nUnits = height(observingUnits);
Stat.WDdet = zeros(nUnits, 1); % Number of white dwarfs (Pwd > 0) per observing unit
Stat.TelID = cell(nUnits, 1); % Store Telescope IDs
Stat.ID = cell(nUnits, 1);
Stat.Date = strings(nUnits, 1); % Store observation date strings

% Process each observing unit
for i = 1:nUnits
    % Filter data for the current observing unit
    unitFilter = all(dataTable.TelescopeID == observingUnits.TelescopeID(i,:),2)  & ...
                  strcmp(dataTable.FieldID, observingUnits.FieldID{i})& ...
                 dataTable.Year == observingUnits.Year(i) & ...
                 dataTable.Month == observingUnits.Month(i) & ...
                 dataTable.Day == observingUnits.Day(i);
 unitData = dataTable(unitFilter, :);
 Stat.Date(i) = sprintf('%04d-%02d-%02d', observingUnits.Year(i), observingUnits.Month(i), observingUnits.Day(i));


    % Count white dwarfs (Pwd > 0)
    Stat.WDdet(i) = sum(unitData.Pwd > 0);
  
    Stat.TelID{i} = sprintf('%s-%s', unitData.TelescopeID(1,:), observingUnits.FieldID{i});
    Stat.ID{i} =  unitData.TelescopeID(1,:);

    % Extract Max RMF values (all targets)
    Stat.MaxRMF{i} = unitData.maxRMF;

    % Count detections by methods
    Stat.MethodCount{i} = sum(unitData.RMF); % Example: Count `RMF == true`

end







%%


% Convert the data to a table for easier handling
StatTable = table(Stat.TelID, Stat.Date, Stat.WDdet, ...
    'VariableNames', {'TelescopeID', 'ObservationDate', 'WhiteDwarfsDetected'});

% Create a categorical array for TelescopeIDs
StatTable.TelescopeID = categorical(StatTable.TelescopeID);
Ntels = unique(Stat.ID)
% Plot histogram of white dwarfs detected as a function of TelescopeID
figure;
bar(StatTable.TelescopeID, StatTable.WhiteDwarfsDetected, 'FaceColor',[0.4 0.7 0.1]);
xlabel('Telescope ID');
ylabel('Number of White Dwarfs Detected ($P_{wd} > 0$)');
title(sprintf('White Dwarfs Detected per Observing Unit (%i)\n %s - N tel : %i',sum(StatTable.WhiteDwarfsDetected),Stat.Date(1),length(Ntels)));


%%
% Extract Max RMF values
maxRMF = dataTable.maxRMF;
maxPS = dataTable.MaxPS;
maxRMS = dataTable.RMSNsigma;


% Plot histogram for Max RMF
figure;
histogram(maxRMF, 'BinWidth', 0.5, 'FaceColor', [0.2, 0.6, 1], 'EdgeColor', [0, 0.3, 0.8]);
xlabel('Max RMF');
ylabel('Frequency');
title('Distribution of Max RMF');


%% Extract data for all targets
% Extract data for all targets


% Extract data for white dwarfs (Pwd > 0)
wdMaxRMF = dataTable.maxRMF(dataTable.Pwd > 0);

% Create the normalized histogram for all targets
figure;
histogram(maxRMF, 'BinWidth', 0.5, 'Normalization', 'probability', ...
    'FaceColor', [0.2, 0.6, 1], 'EdgeColor', 'none', 'FaceAlpha', 0.5);
hold on;

% Create the normalized histogram for white dwarfs
histogram(wdMaxRMF, 'BinWidth', 0.5, 'Normalization', 'probability', ...
    'FaceColor', [0, 0.8, 0.2], 'EdgeColor', 'none', 'FaceAlpha', 0.7);

% Add labels, title, and legend
xlabel('Max RMF');
ylabel('Probability');
title('Normalized Overlay of Max RMF Distributions');
legend('All Targets', 'White Dwarfs (Pwd > 0)');
hold off;









%%
% Extract relevant columns
maxRMF = dataTable.maxRMF;
maxPS = dataTable.MaxPS;
maxRMS = dataTable.RMSNsigma;

% Plot histograms for all metrics
figure;

% Subplot for Max RMF
subplot(3, 1, 1);
histogram(maxRMF, 'BinWidth', 0.5, 'FaceColor', [0.2, 0.6, 1], 'EdgeColor', [0, 0.3, 0.8]);
xlabel('Max RMF');
ylabel('Frequency');
title('Distribution of Max RMF');

% Subplot for Max PS
subplot(3, 1, 2);
histogram(maxPS, 'BinWidth', 0.5, 'FaceColor', [0.6, 0.2, 1], 'EdgeColor', [0.4, 0, 0.8]);
xlabel('Max PS');
ylabel('Frequency');
title('Distribution of Max PS');

% Subplot for RMSNsigma
subplot(3, 1, 3);
histogram(maxRMS, 'BinWidth', 0.5, 'FaceColor', [1, 0.6, 0.2], 'EdgeColor', [0.8, 0.3, 0]);
xlabel('RMS Nsigma');
ylabel('Frequency');
title('Distribution of RMS Nsigma');

% Sort the table by Max RMF, Max PS, and RMSNsigma independently
sortedByMaxRMF = sortrows(dataTable, 'maxRMF', 'descend');
sortedByMaxPS = sortrows(dataTable, 'MaxPS', 'descend');
sortedByMaxRMS = sortrows(dataTable, 'RMSNsigma', 'descend');

% Create a subtable where RMF and RMS are both true
rmfRmsSubTable = dataTable(dataTable.RMF & dataTable.RMS & dataTable.PS, :);
sortedT = sortrows(rmfRmsSubTable, 'MaxPS', 'descend')

% Subtable for white dwarfs (Pwd > 0)
wdTable = dataTable(dataTable.Pwd > 0, :);

% Subtables for white dwarfs: RMF and RMS both true
wdRmfRmsSubTable = wdTable(wdTable.RMF | wdTable.RMS | wdTable.PS, :);
% wdRmfRmsSubTable = wdTable(wdTable.RMF & wdTable.RMS & wdTable.PS, :);




% Display the sorted tables and subtables
disp('Top Rows Sorted by Max RMF:');
disp(sortedByMaxRMF(1:5, :));

disp('Top Rows Sorted by Max PS:');
disp(sortedByMaxPS(1:5, :));

disp('Top Rows Sorted by RMS Nsigma:');
disp(sortedByMaxRMS(1:5, :));

disp('Subtable where RMF and RMS are true:');
disp(rmfRmsSubTable);

disp('Subtable for White Dwarfs where RMF and RMS are true:');
disp(wdRmfRmsSubTable);

for i = 1 :height(wdRmfRmsSubTable)

    figure()
    t = datetime(wdRmfRmsSubTable.JD{i},'convertfrom','jd');
    plot(t,wdRmfRmsSubTable.MAG_PSF{i},'k-o')

    title(sprintf('(%.4f,%.4f) $P_{wd} - $ %.2f',wdRmfRmsSubTable.RA(i),wdRmfRmsSubTable.Dec(i), wdRmfRmsSubTable.Pwd(i)))
    
    set(gca,'YDir','reverse')
end



%%

for i = 1 :100

    figure()
    t = datetime(rmfRmsSubTable.JD{i},'convertfrom','jd');
    plot(t,rmfRmsSubTable.MAG_PSF{i},'k-o')

    title(sprintf('(%.4f,%.4f) $P_{wd} - $ %.3f',rmfRmsSubTable.RA(i),rmfRmsSubTable.Dec(i), rmfRmsSubTable.Pwd(i)))
    
    set(gca,'YDir','reverse')
end


%%
Sps = sortrows(rmfRmsSubTable, 'MaxPS', 'descend');
Srmf = sortrows(rmfRmsSubTable, 'maxRMF', 'descend');
Srms = sortrows(rmfRmsSubTable, 'RMSNsigma', 'descend');

tTable = Srmf
for i = 1 :98


    figure()
    t = datetime(tTable.JD{i},'convertfrom','jd');
    plot(t,tTable.MAG_PSF{i},'k-o')

    title(sprintf('(%.4f,%.4f) $P_{wd} - $ %.3f',tTable.RA(i),tTable.Dec(i), tTable.Pwd(i)))
    ylabel('MAG PSF')
    set(gca,'YDir','reverse')
end




%%
% Extract Max RMF values
wdsources = dataTable.Pwd > 0 ;
maxRMF = dataTable.maxRMF(wdsources);
maxPS = dataTable.MaxPS(wdsources);
maxRMS = dataTable.RMSNsigma(wdsources);


% Plot histogram for Max RMF
figure;
histogram(maxRMF, 'BinWidth', 0.5, 'FaceColor', [0.2, 0.6, 1], 'EdgeColor', [0, 0.3, 0.8]);
xlabel('Max RMF');
ylabel('Frequency');
title('Distribution of Max RMF for detected WDs');


% Plot histogram for Max RMF
figure;
histogram(maxPS, 'BinWidth', 0.5, 'FaceColor', [0.2, 0.6, 1], 'EdgeColor', [0, 0.3, 0.8]);
xlabel('Max PS');
ylabel('Frequency');
title('Distribution of Max PS for detected WDs');

figure;
histogram(maxRMS, 'BinWidth', 0.5, 'FaceColor', [0.2, 0.6, 1], 'EdgeColor', [0, 0.3, 0.8]);
xlabel('Max RMS');
ylabel('Frequency');
title('Distribution of Max Sigma RMS for detected WDs');

%%

















%%


%%
% Plot histogram for number of white dwarfs per observing unit
figure;
histogram(Stat.WDdet, 'BinWidth', 1, 'FaceColor', 'b');
xlabel('Number of White Dwarfs Detected (Pwd > 0)');
ylabel('Frequency');
title('Histogram of White Dwarf Detections per Observing Unit');

% Subsets: Pwd > 0 (White Dwarfs) and Pwd = 0 (Non-detections)
wdData = dataTable(dataTable.Pwd > 0, :); % Subset with Pwd > 0
nonWdData = dataTable(dataTable.Pwd == 0, :); % Subset with Pwd = 0

% Histogram for Max RMF (White Dwarfs only)
figure;
histogram(wdData.MaxRMF, 'BinWidth', 0.5, 'FaceColor', 'g');
xlabel('Max RMF');
ylabel('Frequency');
title('Histogram of Max RMF for White Dwarfs (Pwd > 0)');

% Histogram for Max RMF (Non-detections only)
figure;
histogram(nonWdData.MaxRMF, 'BinWidth', 0.5, 'FaceColor', 'r');
xlabel('Max RMF');
ylabel('Frequency');
title('Histogram of Max RMF for Non-Detections (Pwd = 0)');

% Analyze detection methods: Count entries detected in all methods, 2 methods, etc.
% Assuming detection methods are stored in logical columns such as 'Method1', 'Method2', etc.
methodCols = {'PS', 'Poly', 'MaxPS'}; % Example detection method columns
methodCounts = sum(dataTable{:, methodCols}, 2); % Sum across detection method columns

% Plot histogram of detection method counts
figure;
histogram(methodCounts, 'BinWidth', 1, 'FaceColor', 'c');
xlabel('Number of Detection Methods');
ylabel('Frequency');
title('Histogram of Detections by Method Count');

% Filter entries detected in all methods
allMethodsFilter = methodCounts == numel(methodCols);
allMethodsData = dataTable(allMethodsFilter, :);

% Display statistics for entries detected in all methods
fprintf('Total entries detected in all methods: %d\n', height(allMethodsData));






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
