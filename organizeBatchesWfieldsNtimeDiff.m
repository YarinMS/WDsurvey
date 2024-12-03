function [batches,Fields] = organizeBatchesWfieldsNtimeDiff(fullPath, batchSize)
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
    sortedVisitTimes = [visitTimes(~amPmMask); visitTimes(amPmMask)];

    % Group visits into batches
    numVisits = length(sortedVisits);
    batches = {}; %cell(ceil(numVisits / batchSize), 1);
    Fields = {};
    for i = 1:ceil(numVisits / batchSize)
        
        startIdx = (i - 1) * batchSize + 1;
        endIdx = min(i * batchSize, numVisits);
        checkVisDirs = sortedVisits(startIdx:endIdx);
        checkVisitTimes = sortedVisitTimes(startIdx:endIdx);

        visitFields = {};
        for Iv = 1:numel(checkVisDirs)
            % Get Field ID
            FN = dir(fullfile(checkVisDirs(Iv).folder, checkVisDirs(Iv).name, '*001_001_001_sci_proc_Cat_1.fits'));
            try
                fullFN = fullfile(FN.folder, FN.name);
                AH = AstroHeader(fullFN, 3);
                visitFields = [visitFields; {AH.Key.FIELDID}];
            catch
                visitFields = [visitFields];
                continue;
            end
        end

        [Ufields, Uidx, NewIdx] = unique(visitFields, 'rows');

        if size(Ufields, 1) == 1 && all(diff(checkVisitTimes) <= 1500)
            % If all visits have the same field and time difference <= 15 mins
            batches{end+1} = sortedVisits(startIdx:endIdx);
            Fields = [Fields; {Ufields}];
        else
            % Separate based on unique fields and time constraint
            [newIdx, ~, ~] = unique(NewIdx);
            toBatch = [startIdx:1:endIdx];
            for Iidx = 1:length(newIdx)
                currentBatchIdx = toBatch(NewIdx == Iidx);
                currentTimes = checkVisitTimes(NewIdx == Iidx);

                % Split further based on the time difference constraint
                splitIdx = [1, find(diff(currentTimes) > 1500) + 1, numel(currentTimes) + 1];
                for j = 1:(length(splitIdx) - 1)
                    batchRange = splitIdx(j):(splitIdx(j + 1) - 1);
                    if ~isempty(batchRange)
                        batches{end+1} = sortedVisits(currentBatchIdx(batchRange));
                        Fields = [Fields; {Ufields(Iidx)}];
                    end
                end
            end
        end
    end
end
