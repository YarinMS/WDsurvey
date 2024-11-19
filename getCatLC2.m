function [lcData, results] = getCatLC2(mms, wdTable, args)
    % Initialize LC data and batch-specific metadata
    lcData = initializeLCData(args, wdTable);
    
    % Populate light curve data using WDtransits3
    lcData = WDtransits3.extractLightCurve(lcData, mms, wdTable.RA, wdTable.Dec, args);
    
    % Extract WD parameters (absolute magnitude, parallax, etc.)
    %[AbsMag, Plx, Dist, NonSingleStar, Neighbors, Identifiers] = getWDParams(wdTable.RA, wdTable.Dec);
    %lcData.Table.AbsMag = defaultNaN(AbsMag);
    %lcData.Table.Plx = defaultNaN(Plx);
    %lcData.Table.Dist = defaultNaN(Dist);
    %lcData.Table.NonSingleStar = defaultNaN(NonSingleStar);
    %lcData.Table.Neighbors = defaultNaN(Neighbors);
    
    % Parse Identifiers to populate designation and Gaia ID
    %lcData.Table.designation_id = parseDesignation(Identifiers);
    %lcData.Table.Identifiers = parseIdentifiers(Identifiers);
    
    % Check if there are detections; if so, perform transit detection
    results = initializeResultStruct();
    if ~isfield(lcData, 'Res')
     %   args.Ndet = 20;
        lcData.nanIndices = isnan(lcData.lc);
        results = WDtransits3.detectTransits(lcData, args);
        
        % Process detections
       % res = processDetections(results, lcData, args);
    end
end

% Helper Functions

function lcData = initializeLCData(args, wdTable)
    % Initializes lcData structure with metadata and initial values
    lcData.limMag = args.LimMag;
    lcData.catJD = args.catJD;
    %[~, fname, ~] = fileparts(args.FileName);
    %part = strsplit(fname, '_');
    %lcData.Tel = part{1};
    %lcData.Date = part{2};
    lcData.Table = struct();
    lcData.Table.FieldID = wdTable.FieldID;
    lcData.Table.RA = wdTable.RA;
    lcData.Table.Dec = wdTable.Dec;
    lcData.Table.Gmag = wdTable.Gmag;
    lcData.Table.BPmag = wdTable.BPmag;
    lcData.Table.BpRp = wdTable.BPmag - wdTable.RPmag;
    lcData.Table.Pwd = wdTable.Pwd;
    lcData.Table.AbsMag = wdTable.Gmag - (5 * log10(1000 / wdTable.Plx) - 5);
    lcData.Table.Subframe = wdTable.CropID;
end

function val = defaultNaN(value)
    % Returns value if valid, otherwise NaN
    if isnan(value) || ~isreal(value)
        val = NaN;
    else
        val = value;
    end
end

function designation_id = parseDesignation(Identifiers)
    % Extracts Gaia designation ID from Identifiers, if available
    matches = regexp(Identifiers{2}, 'Gaia DR3 (\d+)', 'tokens');
    if ~isempty(matches)
        designation_id = matches{1}{1};
    else
        designation_id = '';
    end
end

function identifiers = parseIdentifiers(Identifiers)
    % Populates Gaia and First identifiers from Identifiers array
    identifiers = struct();
    if length(Identifiers{2}) > 4 && length(Identifiers{1}) > 4 && ...
            sum(Identifiers{1}(1:8) == Identifiers{2}(1:8)) == 8
        identifiers.Gaia = Identifiers{2};
        identifiers.First = Identifiers{2};
    else
        identifiers.First = Identifiers{1};
        identifiers.Gaia = Identifiers{2};
    end
end

function res = initializeResultStruct()
    % Initializes result structure with default values
    res = struct('detection1', struct('events', [], 'lcStdWithoutEvent1', NaN, 'lcMedWithoutEvent1', NaN, 'EventDepth1', NaN), ...
                 'detection2', struct('events', [], 'lcStdWithoutEvent2', NaN, 'lcMedWithoutEvent2', NaN, 'EventDepth2', NaN), ...
                 'detection1flux', struct('events', [], 'lcStdWithoutEvent1flux', NaN, 'lcMedWithoutEvent1flux', NaN, 'EventDepth1flux', NaN), ...
                 'detection2flux', struct('events', [], 'lcStdWithoutEvent2flux', NaN, 'lcMedWithoutEvent2flux', NaN, 'EventDepth2flux', NaN));
end

function res = processDetections(results, lcData, args)
    % Process transit detection results and mask events
    res = initializeResultStruct();
    res.detection1 = results.detection1;
    res.detection2 = results.detection2;
    res.detection1flux = results.detection1flux;
    res.detection2flux = results.detection2flux;

    % Calculate masked statistics for detection events
    if ~isempty(res.detection1.events)
        [res.detection1.lcStdWithoutEvent1, res.detection1.lcMedWithoutEvent1, res.detection1.EventDepth1] = maskEventStats(lcData.lc, res.detection1.events);
    end
    if ~isempty(res.detection2.events)
        [res.detection2.lcStdWithoutEvent2, res.detection2.lcMedWithoutEvent2, res.detection2.EventDepth2] = maskEventStats(lcData.lc, res.detection2.events);
    end
    if ~isempty(res.detection1flux.events)
        [res.detection1flux.lcStdWithoutEvent1flux, res.detection1flux.lcMedWithoutEvent1flux, res.detection1flux.EventDepth1flux] = maskEventStats(lcData.relFlux, res.detection1flux.events);
    end
    if ~isempty(res.detection2flux.events)
        [res.detection2flux.lcStdWithoutEvent2flux, res.detection2flux.lcMedWithoutEvent2flux, res.detection2flux.EventDepth2flux] = maskEventStats(lcData.relFlux, res.detection2flux.events);
    end
end

function [lcStd, lcMed, eventDepth] = maskEventStats(data, events)
    % Masks events in the data, calculating std, median, and event depth
    mask = true(size(data));
    mask(events) = false;
    lcMasked = data(mask);
    lcStd = std(lcMasked, 'omitnan');
    lcMed = median(lcMasked, 'omitnan');
    eventDepth = max(data(~mask)) - lcMed;
end
