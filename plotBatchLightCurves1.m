function plotBatchLightCurves1(WD, saveDir, args)
    % PLOTLIGHTCURVES Visualizes light curves from BatchData and BatchDataF
    %
    % Inputs:
    %   WD - A single WD row from WDtable.
    %   saveDir - Directory to save the plots (optional).
    %   args - Struct with the following fields:
    %          args.display: Whether to display the plots (true/false).
    %          args.save: Whether to save the plots (true/false).
    %          args.plotOnlyEvents: Plot only batches with Event = true (true/false).
    
    arguments
        WD
        saveDir
        args.plotOnlyEvents = false;
        args.save = false;
        args.display = true;
    end

    % Ensure the save directory exists if saving is enabled
    if ~exist(saveDir, 'dir')
        mkdir(saveDir);
    end

    % Check for the existence of BatchData and BatchDataF
    hasBatchData = ismember('BatchData', WD.Properties.VariableNames);
    hasBatchDataF = ismember('BatchDataF', WD.Properties.VariableNames);

    % Initialize data arrays
    batchDataArray = [];
    batchDataFArray = [];

    % Extract BatchData and BatchDataF if they exist
    if hasBatchData
        batchDataArray = WD.BatchData{1};
    end

    if hasBatchDataF
        batchDataFArray = WD.BatchDataF{1};
    end

    % Determine the number of batches based on the available data
    numBatches = max(numel(batchDataArray), numel(batchDataFArray));

    % Initialize arrays for catalog and forced photometry
    catalogLC = [];
    forcedLC = [];
    batchIndices = [];
    rmsCatalog = [];
    rmsForced = [];

    % Iterate through batches
    for batchIdx = 1:numBatches
        % Extract catalog and forced batches if they exist
        catalogBatch = [];
        forcedBatch = [];

        if hasBatchData && batchIdx <= numel(batchDataArray)
            catalogBatch = batchDataArray{batchIdx};
        end

        if hasBatchDataF && batchIdx <= numel(batchDataFArray)
            forcedBatch = batchDataFArray{batchIdx};
        end

        % Check if filtering by Event = true
        if args.plotOnlyEvents
            if (~isempty(catalogBatch) && (~isfield(catalogBatch, 'Event') || ~catalogBatch.Event)) && ...
               (~isempty(forcedBatch) && (~isfield(forcedBatch, 'Event') || ~forcedBatch.Event))
                continue; % Skip batches without events
            end
        end

        catFlag = false;
        forcedFlag = false;

        % Extract catalog light curve and RMS
        if ~isempty(catalogBatch) && isfield(catalogBatch, 'lcData') && isfield(catalogBatch.lcData, 'lc')
            catalogLC = [catalogLC; catalogBatch.lcData.lc];
            rmsCatalog = [rmsCatalog; std(catalogBatch.lcData.lc, 'omitnan')];
            catFlag = true;
        end

        % Extract forced photometry light curve and RMS
        if ~isempty(forcedBatch) && isfield(forcedBatch, 'lcData') && isfield(forcedBatch.lcData, 'lc')
            forcedLC = [forcedLC; forcedBatch.lcData.lc];
            rmsForced = [rmsForced; std(forcedBatch.lcData.lc, 'omitnan')];
            forcedFlag = true;
        end

        % Keep track of batch indices
        batchIndices = [batchIndices; batchIdx];

        % Plotting logic for catalog and forced photometry data
        if catFlag && forcedFlag
            if catalogBatch.Event && forcedBatch.Event
                catalogBatch.Results.Methods = catalogBatch.Methods;
                catalogBatch.Results.FluxMethods = catalogBatch.FluxMethods;
                catalogBatch.lcData.Tel = forcedBatch.lcData.Tel;
                catalogBatch.lcData.Date = forcedBatch.lcData.Date;

                plotAndSaveLightCurves1(forcedBatch.Results, forcedBatch.lcData, ...
                    catalogBatch.Results, {catalogBatch.lcData}, saveDir, WD, 1);
            elseif catalogBatch.Event && ~forcedBatch.Event
                % Catalog only (Strange)
                disp('Catalog only event detected');
            elseif forcedBatch.Event
                % Forced only (Weak?)
                plotAndSaveSingleLightCurve(forcedBatch.Results, forcedBatch.lcData, saveDir, WD, 1);
            end
        end
    end

    % Save and display plots if required
    if args.save
        filename = sprintf('%s/WDF_%s_Crop_%d_LightCurves.png', saveDir, WD.FieldID, WD.CropID);
        saveas(gcf, filename);
    end

    if ~args.display
        close(gcf);
    end
end
