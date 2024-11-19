function analysisSummary = analyzeWDtableResults(WDtable)
    % Initialize empty arrays to store aggregate metrics for each WD
    numWDs = height(WDtable);
    
    % Preallocate arrays to hold the results for each WD
    AvgValidPoints = zeros(numWDs, 1);
    AvgNaNs = zeros(numWDs, 1);
    NumDetections = zeros(numWDs, 1);
    AvgEventDepth = NaN(numWDs, 1); % NaN to handle cases with no events
    AvgMedianOutOfEvent = NaN(numWDs, 1);
    AvgStdOutOfEvent = NaN(numWDs, 1);
    AvgSDdiff = NaN(numWDs, 1);
    AvgMedianWithEvent = NaN(numWDs, 1);
    AvgStdWithEvent = NaN(numWDs, 1);

    % Loop through each WD entry in WDtable
    for i = 1:numWDs
        % Get the BatchData for this WD
        batchDataArray = WDtable.BatchData{i};
        
        % Initialize counters and accumulators
        validPointsList = [];
        numNaNsList = [];
        eventDepthList = [];
        medianOutOfEventList = [];
        stdOutOfEventList = [];
        SDdiffList = [];
        medianWithEventList = [];
        stdWithEventList = [];
        
        detectionCount = 0;
        
        % Loop through each batchData entry for this WD
        for j = 1:numel(batchDataArray)
            batchData = batchDataArray{j};
            
            % Collect valid points and NaN counts
            validPointsList = [validPointsList; batchData.ValidPoints];
            numNaNsList = [numNaNsList; batchData.NumNaNs];
            
            % If an event was detected, collect event metrics
            if batchData.Event
                detectionCount = detectionCount + 1;
                eventDepthList = [eventDepthList; batchData.eventMetrics.eventDepth];
                medianOutOfEventList = [medianOutOfEventList; batchData.eventMetrics.medianOutOfEvent];
                stdOutOfEventList = [stdOutOfEventList; batchData.eventMetrics.stdOutOfEvent];
                SDdiffList = [SDdiffList; batchData.eventMetrics.SDdiff];
                
                % Collect metrics with events
                medianWithEventList = [medianWithEventList; batchData.eventMetrics.medianWithEvent];
                stdWithEventList = [stdWithEventList; batchData.eventMetrics.stdWithEvent];
            end
        end
        
        % Compute averages and aggregate statistics for this WD
        AvgValidPoints(i) = mean(validPointsList, 'omitnan');
        AvgNaNs(i) = mean(numNaNsList, 'omitnan');
        NumDetections(i) = detectionCount;
        
        % Calculate averages of event-specific metrics if events were detected
        if ~isempty(eventDepthList)
            AvgEventDepth(i) = mean(eventDepthList, 'omitnan');
            AvgMedianOutOfEvent(i) = mean(medianOutOfEventList, 'omitnan');
            AvgStdOutOfEvent(i) = mean(stdOutOfEventList, 'omitnan');
            AvgSDdiff(i) = mean(SDdiffList, 'omitnan');
            AvgMedianWithEvent(i) = mean(medianWithEventList, 'omitnan');
            AvgStdWithEvent(i) = mean(stdWithEventList, 'omitnan');
        end
    end
    
    % Create a summary table with the aggregated statistics for each WD
    analysisSummary = table(WDtable.RA, WDtable.Dec, WDtable.FieldID, WDtable.CropID, ...
                            AvgValidPoints, AvgNaNs, NumDetections, AvgEventDepth, ...
                            AvgMedianOutOfEvent, AvgStdOutOfEvent, AvgSDdiff, ...
                            AvgMedianWithEvent, AvgStdWithEvent, ...
                            'VariableNames', {'RA', 'Dec', 'FieldID', 'CropID', ...
                                              'AvgValidPoints', 'AvgNaNs', ...
                                              'NumDetections', 'AvgEventDepth', ...
                                              'AvgMedianOutOfEvent', 'AvgStdOutOfEvent', ...
                                              'AvgSDdiff', 'AvgMedianWithEvent', ...
                                              'AvgStdWithEvent'});
    
    % Display the summary table for quick inspection
    disp(analysisSummary);
end
