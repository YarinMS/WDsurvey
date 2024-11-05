function checkForNewDirectories(folderPath, N, logFile)
    % Load processed directories from the log file
    if isfile(logFile)
        processedDirs = readcell(logFile, 'FileType', 'text');
    else
        processedDirs = {}; % Initialize empty if log file doesn't exist
    end

    % List all directories in the main folder path
    dirInfo = dir(folderPath);
    isDir = [dirInfo.isdir];
    dirs = dirInfo(isDir);

    % Filter out irrelevant directories (e.g., '.', '..')
    dirs = dirs(~ismember({dirs.name}, {'.', '..'}));

    % Sort directories by name to ensure HHMMSS order
    [~, sortIdx] = sort([dirs.datenum]);
    dirs = dirs(sortIdx);

    % Filter out directories that have already been processed
    newDirs = dirs(~ismember({dirs.name}, processedDirs));

    % Check for Field ID and consecutiveness for only new directories
    [validGroups, fieldIDs] = groupByFieldAndConsecutive(newDirs, N, folderPath);

    % Process each valid group and update the log file
    for i = 1:numel(validGroups)
        fprintf('Starting transit detection for FIELD ID:: %s\nVisit Group %i out of %i', fieldIDs{i},i,numel(validGroups));
        transitDetectionRoutine(validGroups{i}); % Call the detection routine

        % Log these directories as processed
        for j = 1:numel(validGroups{i})
            % Extract just the directory name
            [~, visitName] = fileparts(validGroups{i}{j});

            % Append the visit name to processedDirs
            processedDirs = [processedDirs; {visitName}];
        end %#
        length(processedDirs)
    end

    % Write updated processed directories back to the log file
    writecell(processedDirs, logFile, 'FileType', 'text');
end
