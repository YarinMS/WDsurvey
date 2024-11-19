function eventMetrics = processDetectedEvents(results, LC)
    % Initialize metrics structure
    eventMetrics = struct('numDetectedPoints', 0, 'medianOutOfEvent', NaN, ...
                          'stdOutOfEvent', NaN, 'eventDepth', NaN, 'medianWithEvent',median(LC.lc,'omitnan'),'stdWithEvent',std(LC.lc,'omitnan'),'SDdiff',NaN);

    % Check if there are any detected events in results
    if isempty(results.detection2) || isempty(results.detection2.events)
        disp('No events detected in detection2.');
        return;
    end

    % Get event indices from results.detection2.events
    eventIndices = results.detection2.events;

    % Mask out the detected events from LC.lc to compute stats on non-event data
    lcValues = LC.lc;
    nonEventValues = lcValues;
    nonEventValues(eventIndices) = NaN; % Mask events with NaN

    % Calculate median and standard deviation outside of events
    eventMetrics.medianOutOfEvent = median(nonEventValues, 'omitnan');
    eventMetrics.stdOutOfEvent = std(nonEventValues, 'omitnan');
    eventMetrics.SDdiff = abs(std(nonEventValues, 'omitnan') - std(LC.lc,'omitnan'));

    % Calculate number of detected points
    eventMetrics.numDetectedPoints = numel(eventIndices);

    % Calculate event depth as the difference between max event value and median outside event
    if ~isempty(eventIndices)
        maxEventValue = max(lcValues(eventIndices));
        eventMetrics.eventDepth = maxEventValue - eventMetrics.medianOutOfEvent;
    end
end
