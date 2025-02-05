function categorizedFiles = categorizeFilesBySubframe(rootDir, mainPattern)
    % Categorizes files based on '0%02d_sci' subframe pattern in their names
    %
    % Inputs:
    % - rootDir: The root directory to start the search
    % - mainPattern: The specific pattern to match the desired files (string)
    %
    % Output:
    % - categorizedFiles: A structure containing subframe categories as fields
    
    % Get list of all matching files
    allFiles = dir(fullfile(rootDir, '**', '*'));
    allFiles = allFiles(~[allFiles.isdir]); % Exclude directories
    matchingFiles = {};
    
    % Filter files that match the main pattern
    for i = 1:length(allFiles)
        fileName = allFiles(i).name;
        if contains(fileName, mainPattern)
            if contains(fileName,'.hdf5')
                matchingFiles{end+1} = fullfile(allFiles(i).folder, fileName); 
            end
        end
    end
    
    % Initialize a structure to hold categorized files
    categorizedFiles = struct();
    for i = 1:24
        subframeID = sprintf('Subframe_%02d', i); % Generate subframe pattern
        categorizedFiles.(subframeID) = {};   % Initialize as an empty cell array
    end
    
    % Categorize files by subframe
    for i = 1:length(matchingFiles)
        filePath = matchingFiles{i};
        [~, fileName, ~] = fileparts(filePath);
        
        % Extract subframe information from the filename
        for subID = 1:24
            subframePattern = sprintf('0%02d_sci', subID);
            fieldName = sprintf('Subframe_%02d', subID); % Create a valid field name
            if contains(fileName, subframePattern)
                categorizedFiles.(fieldName){end+1} = filePath; %#ok<AGROW>
                break;
            end
        end
    end
    
    % Display results
    fprintf('Categorized files into subframes:\n');
    disp(categorizedFiles);
end
