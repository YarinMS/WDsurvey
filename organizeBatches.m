function batches = organizeBatches(fullPath, batchSize)
    % ORGANIZEBATCHES Groups visit directories into batches
    % Inputs:
    %   fullPath - Full path to the night's observation data
    %   batchSize - Number of visits per batch
    % Output:
    %   batches - Cell array of batches, where each batch contains visit directories

    % Load visit directories
    visitDirs = dir(fullfile(fullPath, '*v0'));
    visitNames = {visitDirs.name};

    % Extract times from folder names
    visitTimes = cellfun(@(x) sscanf(x, '%06dv0'), visitNames);
    visitHours = floor(visitTimes / 10000);
    amPmMask = visitHours < 12; % AM: hours < 12, PM: hours >= 12
    amVisits = visitDirs(amPmMask);
    pmVisits = visitDirs(~amPmMask);

    % Sort AM and PM visits separately
    [~, amOrder] = sort(visitTimes(amPmMask));
    [~, pmOrder] = sort(visitTimes(~amPmMask));

    % Concatenate sorted PM visits first, then AM visits
    sortedVisits = [pmVisits(pmOrder); amVisits(amOrder)];

    % Group visits into batches
    numVisits = length(sortedVisits);
    batches = cell(ceil(numVisits / batchSize), 1);
    for i = 1:length(batches)
        startIdx = (i - 1) * batchSize + 1;
        endIdx = min(i * batchSize, numVisits);
        batches{i} = sortedVisits(startIdx:endIdx);
    end
end
