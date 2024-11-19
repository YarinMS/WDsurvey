function eventMetrics = processDetectedEvents3(results, LC)
    % Initialize metrics structure
    eventMetrics = struct('numDetectedPoints', 0, 'medianOutOfEvent', NaN, ...
                          'stdOutOfEvent', NaN, 'eventDepth', NaN, ...
                          'medianWithEvent', median(LC.lc, 'omitnan'), ...
                          'stdWithEvent', std(LC.lc, 'omitnan'), 'SDdiff', NaN);

    % Fields in `results` where events may be detected
    eventFields = {'detection1', 'detection2', 'detection1flux', 'detection2flux'};
    
    % Collect all event indices across the specified fields
    allEventIndices = [];
    for i = 1:numel(eventFields)
        fieldName = eventFields{i};
        if isfield(results, fieldName) && isstruct(results.(fieldName)) && isfield(results.(fieldName), 'events')
            allEventIndices = [allEventIndices; results.(fieldName).events(:)]; %#ok<AGROW>
        end
    end

    % Remove duplicates from combined event indices
    eventIndices = unique(allEventIndices);

    % Check if we found any events
    if isempty(eventIndices)
        disp('No events detected in specified fields.');
        return;
    end

    % Mask out the detected events from LC.lc to compute stats on non-event data
    lcValues = LC.lc;
    nonEventValues = lcValues;
    nonEventValues(eventIndices) = NaN; % Mask events with NaN

    % Calculate median and standard deviation outside of events
    eventMetrics.medianOutOfEvent = median(nonEventValues, 'omitnan');
    eventMetrics.stdOutOfEvent = std(nonEventValues, 'omitnan');
    
    % Calculate the difference in standard deviations with and without events
    eventMetrics.SDdiff = abs(eventMetrics.stdOutOfEvent - eventMetrics.stdWithEvent);

    % Calculate number of detected points
    eventMetrics.numDetectedPoints = numel(eventIndices);

    % Calculate event depth as the difference between max event value and median outside events
    maxEventValue = max(lcValues(eventIndices));
    eventMetrics.eventDepth = maxEventValue - eventMetrics.medianOutOfEvent;
end
