% Define base directory with wildcard
baseDir = '~/marvin/LAST*/2024/09/01';

% Expand wildcard to find all matching directories
dirList = dir(baseDir);

% Initialize empty cell array for results
fileList = {};

% Loop through each matching directory
for i = 1:length(dirList)
    if dirList(i).isdir % Ensure it's a directory
        % Construct full path
        currentDir = fullfile(dirList(i).folder, dirList(i).name);
        
        % Find all files containing 'Nagi1b' in the filename within this directory
        files = dir(fullfile(currentDir, '*Nagi1b*'));

        % Store full file paths
        for j = 1:length(files)
            fileList{end+1} = fullfile(files(j).folder, files(j).name); %#ok<AGROW>
        end
    end
end

% Display results
disp('Found files:');
disp(fileList);
