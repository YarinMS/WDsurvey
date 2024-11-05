function [batches, fieldIDs] = groupByFieldAndConsecutive(dirs, N, folderPath)
    % Parameters
    tolerance = 10 / (24 * 60); % Consecutive tolerance in days (10 minutes here as an example)
    
    % Sort directories by datenum to ensure chronological order
    [~, sortIdx] = sort([dirs.datenum]);
    dirs = dirs(sortIdx);

    batches = {}; % Cell array to store batches of consecutive visits
    fieldIDs = {}; % Cell array to store Field IDs for each batch

    tempGroup = {}; % Temporary group to collect visits for the current batch
    lastDatenum = 0;
    lastFieldID = '';

    for i = 1:length(dirs)
        % Path to the current directory
        currDir = fullfile(folderPath, dirs(i).name);

        % Retrieve Field ID from the first file in the directory
        files = dir(fullfile(currDir, '*.fits'));
        if isempty(files)
            continue; % Skip if no files in directory
        end
        fieldID = extractFieldID(files(1).name);

        % Check if this directory is consecutive with the previous one
        if ~isempty(lastFieldID) && strcmp(lastFieldID, fieldID) && (dirs(i).datenum - lastDatenum <= tolerance)
            % Add to the current group if consecutive and same Field ID
            tempGroup{end+1} = currDir;
        else
            % If we have enough visits in the current group, add it as a batch
            if numel(tempGroup) >= N
                % Split into batches of size N
                numBatches = ceil(numel(tempGroup) / N);
                for b = 1:numBatches
                    startIdx = (b - 1) * N + 1;
                    endIdx = min(b * N, numel(tempGroup));
                    batches{end+1} = tempGroup(startIdx:endIdx);
                    fieldIDs{end+1} = lastFieldID;
                end
            end
            % Reset the group for the new Field ID and time
            tempGroup = {currDir};
        end

        % Update tracking variables
        lastFieldID = fieldID;
        lastDatenum = dirs(i).datenum;
    end

    % Check the last group after the loop ends
    if numel(tempGroup) >= N
        numBatches = ceil(numel(tempGroup) / N);
        for b = 1:numBatches
            startIdx = (b - 1) * N + 1;
            endIdx = min(b * N, numel(tempGroup));
            batches{end+1} = tempGroup(startIdx:endIdx);
            fieldIDs{end+1} = lastFieldID;
        end
    end
end

