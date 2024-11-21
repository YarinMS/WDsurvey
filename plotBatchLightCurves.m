function plotBatchLightCurves(WD, saveDir, args)
    % PLOTLIGHTCURVES Visualizes light curves from BatchData and BatchDataF
    %
    % Inputs:
    %   WD - A single WD row from WDtable.
    %   saveDir - Directory to save the plots (optional).
    %   args - Struct with the following fields:
    %          args.display: Whether to display the plots (true/false).
    %          args.save: Whether to save the plots (true/false).
    %          args.plotOnlyEvents: Plot only batches with Event = true (true/false).

    % Ensure the save directory exists if saving is enabled
    if args.save && ~exist(saveDir, 'dir')
        mkdir(saveDir);
    end

    % Extract BatchData and BatchDataF
    batchDataArray = WD.BatchData{1};
    batchDataFArray = WD.BatchDataF{1};

    % Initialize arrays for catalog and forced photometry
    catalogLC = [];
    forcedLC = [];
    batchIndices = [];
    rmsCatalog = [];
    rmsForced = [];

    % Iterate through batches
    for batchIdx = 1:numel(batchDataArray)
        catalogBatch = batchDataArray{batchIdx};
        forcedBatch = batchDataFArray{batchIdx};

        % Check if filtering by Event = true
        if args.plotOnlyEvents && ...
           (~isfield(catalogBatch, 'Event') || ~catalogBatch.Event) && ...
           (~isfield(forcedBatch, 'Event') || ~forcedBatch.Event)
            continue; % Skip batches without events
        end

        % Extract catalog light curve and RMS
        if isfield(catalogBatch, 'lcData') && isfield(catalogBatch.lcData, 'lc')
            catalogLC = [catalogLC; catalogBatch.lcData.lc];
            rmsCatalog = [rmsCatalog; std(catalogBatch.lcData.lc, 'omitnan')];
        end

        % Extract forced photometry light curve and RMS
        if isfield(forcedBatch, 'lcData') && isfield(forcedBatch.lcData, 'lc')
            forcedLC = [forcedLC; forcedBatch.lcData.lc];
            rmsForced = [rmsForced; std(forcedBatch.lcData.lc, 'omitnan')];
        end

        % Keep track of batch indices
        batchIndices = [batchIndices; batchIdx];
    end

    % Plot catalog and forced photometry light curves
    figure;
    hold on;
    plot(batchIndices, catalogLC, 'b-o', 'DisplayName', 'Catalog LC');
    plot(batchIndices, forcedLC, 'r-o', 'DisplayName', 'Forced LC');

    % Overlay RMS as shaded areas
    catalogRMSPlot = plot(batchIndices, rmsCatalog, '--', 'Color', [0.1 0.5 0.8], 'DisplayName', 'Catalog RMS');
    forcedRMSPlot = plot(batchIndices, rmsForced, '--', 'Color', [0.8 0.2 0.2], 'DisplayName', 'Forced RMS');

    % Finalize plot
    xlabel('Batch Index');
    ylabel('Flux');
    title(sprintf('Light Curve for WD (Field: %s, CropID: %d)', WD.FieldID, WD.CropID));
    legend('show');
    grid on;

    % Save plot if requested
    if args.save
        filename = sprintf('%s/WDF_%s_Crop_%d_LightCurves.png', saveDir, WD.FieldID, WD.CropID);
        saveas(gcf, filename);
    end

    % Display plot if requested
    if args.display
        hold off;
    else
        close(gcf);
    end
end
