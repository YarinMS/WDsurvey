function [batches,Fields] = organizeBatchesWfields(fullPath, batchSize)
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
    batches = {}; %cell(ceil(numVisits / batchSize), 1);
    Fields = {};
    for i = 1:ceil(numVisits / batchSize)
        
        startIdx = (i - 1) * batchSize + 1;
        endIdx = min(i * batchSize, numVisits);
        checkVisDirs = sortedVisits(startIdx:endIdx);

        visitFields = {};
        for Iv = 1 : numel (checkVisDirs)
            
          % get Field ID
          FN     =  dir(fullfile(checkVisDirs(Iv).folder,checkVisDirs(Iv).name,'*001_001_001_sci_proc_Cat_1.fits'));
          fullFN = fullfile(FN.folder,FN.name) ;
          AH = AstroHeader(fullFN,3);
          visitFields  = [visitFields; {AH.Key.FIELDID}];
        end

        [Ufields,Uidx,NewIdx] = unique(visitFields,'rows');
        Fields = [Fields; {Ufields}];
        
        if size(Ufields,1) == 1
      
            batches{end+1} = sortedVisits(startIdx:endIdx);
        else
            %
            [newIdx,~,~] = unique(NewIdx);
            toBatch = [startIdx:1:endIdx];
            for Iidx = 1 : length(newIdx)
                if Iidx == 1 
                    
                    toBatch1 = toBatch(NewIdx == Iidx);
                    batches{end+1} = sortedVisits(toBatch1);

                else
                    toBatch2 = toBatch(NewIdx == Iidx);
                    batches{end+1} = sortedVisits(toBatch2);

                    
                end
            end
        end
    end
end
