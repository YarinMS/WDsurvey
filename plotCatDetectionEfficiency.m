function plotCatDetectionEfficiency(stackedWDtable, args)
    % Plot Detection Efficiency as bars for every WD, with rotated text inside bars
    %
    % Inputs:
    %   stackedWDtable - Combined table with all WDs across fields
    %   args - Arguments structure containing Date and Telescope information

    % Calculate detection efficiency for each WD
    detectionEfficiency = (stackedWDtable.catBatchDetections ./ stackedWDtable.Nbatch) * 100;
    realData = detectionEfficiency > 0;
    magnitudes = stackedWDtable.Gmag(realData);

    detectionEfficiency = detectionEfficiency(detectionEfficiency > 0);

    % Sort by magnitude for better visualization
    %
    %
    BatchDetections = stackedWDtable.catBatchDetections(realData);
    Nbatch = stackedWDtable.Nbatch(realData);
    [sortedMagnitudes, sortIdx] = sort(magnitudes);
    sortedEfficiency = detectionEfficiency(sortIdx);
    sortedBatchDetections = BatchDetections(sortIdx);
    sortedNbatch = Nbatch(sortIdx);

    % Create distinct x values for each WD to prevent overlapping bars
    xValues = 1:length(detectionEfficiency);  % Sequential indices for WDs

    % Plot bar chart
    figure;
    bar(xValues, detectionEfficiency, 'FaceColor', [0.2, 0.6, 0.8], 'BarWidth', 0.8);
    hold on;

    % Add rotated text inside the bars
    for i = 1:length(xValues)
        text(xValues(i)+0.001, sortedEfficiency(i) - 5, ... % Position slightly below the bar top
             sprintf('%d / %d',sortedBatchDetections(i), sortedNbatch(i)), ...
             'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
             'Rotation', 90, 'FontSize', 13, 'Color', 'k', 'FontWeight', 'bold','FontSmoothing','on');
    end
    hold off;

    % Configure x-axis
    xticks(xValues);
    xticklabels(arrayfun(@(m) sprintf('%.2f', m), sortedMagnitudes, 'UniformOutput', false));
    xtickangle(45); % Rotate x-tick labels for better readability

    % Label axes
    xlabel('Magnitude (Gmag)');
    ylabel('Detection Efficiency (%)');
    title(sprintf('Detection Efficiency vs. Magnitude for %i WDs \n%s - %s',args.Nwds, args.Date, args.Tel));
    grid on;
end

