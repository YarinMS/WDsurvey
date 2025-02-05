function matchingFiles = findFilesByPattern(rootDir, pattern)
    % Finds files matching a specific pattern in their names within a directory tree
    %
    % Inputs:
    % - rootDir: The root directory to start the search
    % - pattern: The specific pattern to match in file names (string or regex)
    %
    % Output:
    % - matchingFiles: Cell array of full paths to the matching files
    
    % Get list of all files in the directory tree
    allFiles = dir(fullfile(rootDir, '**', '*'));
    
    % Filter only files (ignore directories)
    allFiles = allFiles(~[allFiles.isdir]);
    
    % Initialize the list of matching files
    matchingFiles = {};
    
    % Loop through the files to find matches
    for i = 1:length(allFiles)
        fileName = allFiles(i).name;
        % Check if the file name contains the specific pattern
        if contains(fileName, pattern)
            if contains(fileName,'.hdf5')
                matchingFiles{end+1} = fullfile(allFiles(i).folder, fileName); 
            end
        end
    end
  % Initialize a structure to hold categorized files
    categorizedFiles = struct();
    for i = 1:24
        subframeID = sprintf('0%02d_sci', i); % Generate subframe pattern
        categorizedFiles.(subframeID) = {};   % Initialize as an empty cell array
    end
    
    % Categorize files by subframe
    for i = 1:length(matchingFiles)
        filePath = matchingFiles{i};
        [~, fileName, ~] = fileparts(filePath);
        
        % Extract subframe information from the filename
        for subID = 1:24
            subframePattern = sprintf('0%02d_sci', subID);
            if contains(fileName, subframePattern)
                categorizedFiles.(num2str(subID)){end+1} = filePath; %#ok<AGROW>
                break;
            end
        end
    end
    
    % Display results
    fprintf('Categorized files into subframes:\n');
    disp(categorizedFiles);
end
