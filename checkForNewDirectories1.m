function checkForNewDirectories1(folderPath, N, logFile)

    persistent waitStartTime;

    % Load processed directories from the log file
    if isfile(logFile)
        processedDirs = readcell(logFile, 'FileType', 'text');
    else
        processedDirs = {}; % Initialize empty if log file doesn't exist
    end

    % List all visit directories in the main folder path
    visitDirs = dir(fullfile(folderPath, '*v0')); % Assuming *v0 pattern
    numVisits = length(visitDirs);
    
    % Check if we have at least N new directories
    if numVisits < N
        fprintf('Waiting for more visits... Currently %d out of %d needed.\n', numVisits, N);
        return; % Exit if fewer than N directories
    end

    % Proceed with processing if we have N or more directories
    % Filter out already processed directories
    visitDirs = visitDirs(~ismember({visitDirs.name}, processedDirs));

    % Sort directories by `datenum
    [~, sortIdx] = sort([visitDirs.datenum]);
    visitDirs = visitDirs(sortIdx);

    % Check for Field ID and consecutive batches of N
    [validGroups, fieldIDs] = groupByFieldAndConsecutive(visitDirs, N, folderPath);
    
    % If the last group is smaller than N and hasn't reached the 25-minute limit, wait
    if numel(validGroups) > 0 && numel(validGroups{end}) < N
        if isempty(waitStartTime)
            waitStartTime = datetime('now');
        end
        elapsedTime = minutes(datetime('now') - waitStartTime);
        if elapsedTime < 2
            fprintf('Waiting for more visits to fill the last group... Time elapsed: %.2f minutes.\n', elapsedTime);
            return;
        else
            fprintf('25 minutes elapsed. Processing available groups.\n');
            waitStartTime = []; % Reset wait time
        end
    else
        waitStartTime = []; % Reset wait time if we have a full group
    end

    % Process each valid group and update the log file
    for i = 1:numel(validGroups)
        fprintf('Starting transit detection for FIELD ID:: %s\nVisit Group %i out of %i\n', fieldIDs{i},i,numel(validGroups));
        transitDetectionRoutine(validGroups{i},'BatchSize',N); % Call the detection routine

        % Extract and log each visit name
        for j = 1:numel(validGroups{i})
            [~, visitName] = fileparts(validGroups{i}{j});
            processedDirs = [processedDirs; {visitName}];
        end
        
        processedDirs = [processedDirs; {'--------'}];
        
    end

    % Write updated processed directories back to the log file
    writecell(processedDirs, logFile, 'FileType', 'text');
end
