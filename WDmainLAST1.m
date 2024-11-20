function mainTable = WDmainLAST1(mount, telescope, year, month, day, batchSize, args)
    arguments
        mount
        telescope
        year
        month
        day
        batchSize
        args.saveDir = '~/Documents/test3/WD_LC';
        args.runMeanFilterArgs = {'Threshold', 5, 'StdFun', 'OutWin'};
        args.BadFlags = {'Saturated', 'Negative', 'NaN', 'Spike', 'Hole', 'NearEdge'};
        args.PlotNSave = true;
    end

    % Setup default parameters
    setupDefaultParameters();

    % Setup paths
    [~, fullPath] = setupPaths(mount, telescope, year, month, day);

    % Create save directory if needed
    if ~exist(args.saveDir, 'dir')
        mkdir(args.saveDir);
    end

    % Organize batches and fields
    [batches, Fields, uniqueFields, NewIdx] = organizeBatchesAndFields(fullPath, batchSize);

    % Analyze fields
    mainTable = analyzeFields(uniqueFields, NewIdx, batches, batchSize, args);

    % Combine results into the output table
    %stackedWDtable = vertcat(mainTable{:});
end


%% --- Helper Functions ----

% Setup Default Parameters
function setupDefaultParameters()
    set(0, 'DefaultFigureWindowStyle', 'docked');
    set(0, 'DefaultTextInterpreter', 'latex');
    set(0, 'DefaultAxesTickLabelInterpreter', 'latex');
    set(0, 'DefaultLegendInterpreter', 'latex');
end

%Setup Paths
function [basePath, fullPath] = setupPaths(mount, telescope, year, month, day)
    if telescope < 3
        computer = sprintf('last%02de', mount);
    else
        computer = sprintf('last%02dw', mount);
    end

    if mod(telescope, 2) == 0
        basePath = sprintf('/%s/data2/archive/LAST.01.%02d.%02d/', computer, mount, telescope);
    else
        basePath = sprintf('/%s/data1/archive/LAST.01.%02d.%02d/', computer, mount, telescope);
    end

    dateFolder = sprintf('%04d/%02d/%02d/proc/', year, month, day);
    fullPath = fullfile(basePath, dateFolder);
end

%Organize Batches and Fields
function [batches, Fields, uniqueFields, NewIdx] = organizeBatchesAndFields(fullPath, batchSize)
    [batches, Fields] = organizeBatchesWfields(fullPath, batchSize);
    allFieldIDs = vertcat(Fields{:});
    [uniqueFields, ~, NewIdx] = unique(allFieldIDs);
end

% Analyze Fields 
function mainTable = analyzeFields(uniqueFields, NewIdx, batches, batchSize, args)
    Nfields = length(uniqueFields);
    mainTable = cell(Nfields, 1);

    for Ifield = 1:Nfields
        Batches = batches(NewIdx == Ifield);
        WDtable = processField(uniqueFields{Ifield}, Batches, batchSize, args);
        mainTable{Ifield} = WDtable;
    end
end

% Process a Field Encapsulate WD-specific logic.
function WDtable = processField(fieldID, Batches, args)
    % Initialize combined WD sources table
    combinedWdSources = initializeCombinedTable(Batches, fieldID);

    % Remove duplicate entries
    WDtable = removeDuplicates(combinedWdSources);

    % Process Batches for this field
    for b = 1:length(Batches)
        WDtable = processBatch(WDtable, Batches{b}, args);
    end
end
% Process a Batch Encapsulate batch-specific logic.
function WDtable = processBatch(WDtable, Batch, args)
    for cropID = 1:24
        cropWDs = find(WDtable.CropID == cropID);
        if isempty(cropWDs)
            continue;
        end

        [catFP, MSfiles, imagesFP] = extractPipelineProducts(Batch, cropID);
        args.obsData = extractObservationData(AstroHeader(catFP, 3));

        % Process each WD in the crop
        for Iwd = cropWDs'
            WDtable = analyzeWD(WDtable, Iwd, MSfiles, args);
        end
    end
end

function combinedWdSources = initializeCombinedTable(Batches, fieldID)
    % Initialize an empty table to store combined results
    combinedWdSources = table();

    % Iterate over each subframe (1 to 24)
    for subframeIdx = 1
        % Assuming all batches share the same folder structure
        catFiles = dir(fullfile(Batches{1}.folder, Batches{1}.name, '*001_001_*_sci_proc_Cat_1.fits'));
        if isempty(catFiles)
            continue;
        end

        % Process each file in the frame
        for iFile = 1:length(catFiles)
            catFilePath = fullfile(catFiles(iFile).folder, catFiles(iFile).name);

            % Extract RA, Dec, and field coordinates
            [subframeRA, subframeDec, fieldCoordsSF] = getMScoordsFromCat(catFilePath);

            % Find White Dwarfs in the subframe
            wdSources = findWhiteDwarfsL(subframeRA, subframeDec, fieldCoordsSF);

            % Append data to the combined table if results exist
            if ~isempty(wdSources)
                % Add subframe (crop) ID and field ID columns
                wdSources.CropID = repmat(subframeIdx, height(wdSources), 1);  % Add crop ID (subframe index)
                wdSources.FieldID = repmat(string(uniqueFields(Ifield)), height(wdSources), 1);  % Add field ID as a string
                wdSources.Detected = repmat(false,height(wdSources),1);
                wdSources.Nvisits = repmat(totalVisits,height(wdSources),1);
                wdSources.BatchSize = repmat(batchSize,height(wdSources),1);
                wdSources.Nbatch = repmat(length(Batches),height(wdSources),1);
                wdSources.BatchDetections = repmat(0,height(wdSources),1);
                wdSources.Nevents = repmat(0,height(wdSources),1);
                % Append to the combined table
                combinedWdSources = [combinedWdSources; wdSources];
            end
        end
    end
    
    WDtable = combinedWdSourcesSources;
end





% Analyze WD Perform WD-specific analysis.
function WDtable = analyzeWD(WDtable, Iwd, MSfiles, args)
    WD = WDtable(Iwd, :);
    MS = MatchedSources.readList(MSfiles);

    % Extract and clean data
    [mms, nanIdx] = searchNclean(MS, WD, args);

    % Perform detection and analysis
    batchData = analyzeBatchData(mms, nanIdx, WD, args);

    % Append batch data
    WDtable.BatchData{Iwd} = [WDtable.BatchData{Iwd}; {batchData}];
    WDtable(Iwd, :) = WD;
end
