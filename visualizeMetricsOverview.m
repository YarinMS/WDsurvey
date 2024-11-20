function visualizeMetricsOverview(WDtable, saveDir, args)
    % VISUALIZEMETRICSOVERVIEW creates various plots to summarize metrics in BatchData
    %
    % Inputs:
    %   WDtable - Table containing WDs and their BatchData.
    %   saveDir - Directory to save plots.
    %   args - Struct containing optional arguments (e.g., Date, Telescope).
    %
    % Outputs:
    %   Saves a set of visualizations summarizing the BatchData metrics.

    % Ensure the save directory exists
    if ~exist(saveDir, 'dir')
        mkdir(saveDir);
    end

    %% Initialize Metrics Storage
    allEventDepths = [];
    allMedianOutOfEvent = [];
    allDetectedPoints = [];
    allStdWithEvent = [];
    allStdOutOfEvent = [];
    allDetectionEfficiencies = [];
    allGmag = [];

    %% Extract Metrics from BatchData
    for i = 1:height(WDtable)
        batchDataArray = WDtable.BatchData{i};
        gmag = WDtable.Gmag(i);
        detectionCount = 0;
        totalBatches = numel(batchDataArray);

        for j = 1:totalBatches
            batchData = batchDataArray{j};
            if isfield(batchData, 'eventMetrics') && isfield(batchData.eventMetrics, 'eventDepth')
                eventMetrics = batchData.eventMetrics;

                % Collect metrics
                if ~isnan(eventMetrics.eventDepth)
                    allEventDepths(end+1) = eventMetrics.eventDepth; %#ok<AGROW>
                    allMedianOutOfEvent(end+1) = eventMetrics.medianOutOfEvent; %#ok<AGROW>
                    allStdWithEvent(end+1) = eventMetrics.stdWithEvent; %#ok<AGROW>
                    allStdOutOfEvent(end+1) = eventMetrics.stdOutOfEvent; %#ok<AGROW>
                    allGmag(end+1) = gmag; %#ok<AGROW>
                end

                % Count detections
                if batchData.Event
                    detectionCount = detectionCount + 1;
                end
            end
        end

        % Calculate detection efficiency for this WD
        if totalBatches > 0
            efficiency = (detectionCount / totalBatches) * 100;
            allDetectionEfficiencies(end+1) = efficiency; %#ok<AGROW>
        end
    end

    %% Visualization 1: Event Depth vs. Median Out of Event
    figure;
    scatter(allMedianOutOfEvent, allEventDepths, 40, allGmag, 'filled');
    colorbar;
    xlabel('Median Flux Outside Event');
    ylabel('Event Depth');
    title(sprintf('Event Depth vs. Median Out of Event\n%s - %s', args.Date, args.Tel));
    saveas(gcf, fullfile(saveDir, 'EventDepth_vs_MedianOutOfEvent.png'));
    close;

    %% Visualization 2: Detection Efficiency vs. Magnitude
    figure;
    scatter(allGmag, allDetectionEfficiencies, 50, 'b', 'filled');
    xlabel('Magnitude (Gmag)');
    ylabel('Detection Efficiency (%)');
    title(sprintf('Detection Efficiency vs. Magnitude\n%s - %s', args.Date, args.Tel));
    grid on;
    saveas(gcf, fullfile(saveDir, 'DetectionEfficiency_vs_Gmag.png'));
    close;

    %% Visualization 3: STD Inside vs. Outside Events
    figure;
    scatter(allStdOutOfEvent, allStdWithEvent, 40, allGmag, 'filled');
    colorbar;
    xlabel('STD Outside Events');
    ylabel('STD With Events');
    title(sprintf('STD Comparison Inside vs. Outside Events\n%s - %s', args.Date, args.Tel));
    saveas(gcf, fullfile(saveDir, 'STD_Inside_vs_Outside.png'));
    close;

    %% Visualization 4: Event Depth Distribution
    figure;
    histogram(allEventDepths, 20, 'FaceColor', [0.2 0.6 0.8]);
    xlabel('Event Depth');
    ylabel('Count');
    title(sprintf('Event Depth Distribution\n%s - %s', args.Date, args.Tel));
    saveas(gcf, fullfile(saveDir, 'EventDepth_Distribution.png'));
    close;

    %% Visualization 5: Temporal Evolution of STD
    figure;
    for i = 1:height(WDtable)
        batchDataArray = WDtable.BatchData{i};
        stdValues = [];
        batchIndices = [];
        for j = 1:numel(batchDataArray)
            batchData = batchDataArray{j};
            if isfield(batchData, 'eventMetrics')
                stdValues(end+1) = batchData.eventMetrics.stdWithEvent; %#ok<AGROW>
                batchIndices(end+1) = j; %#ok<AGROW>
            end
        end
        plot(batchIndices, stdValues, '-o', 'DisplayName', sprintf('WD #%d', i));
        hold on;
    end
    xlabel('Batch Index');
    ylabel('STD With Event');
    title(sprintf('Temporal Evolution of STD Across Batches\n%s - %s', args.Date, args.Tel));
    legend('show', 'Location', 'northeast');
    grid on;
    saveas(gcf, fullfile(saveDir, 'Temporal_STD_Evolution.png'));
    close;

    fprintf('Visualizations saved to %s\n', saveDir);
end
