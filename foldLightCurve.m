function foldLightCurve(time, magnitude, period, epoch)
    % Folds a light curve by a given periodicity.
    %
    % Inputs:
    %   time       - Time vector (e.g., in days or Julian dates)
    %   magnitude  - Magnitude vector corresponding to the time
    %   period     - Periodicity for folding (e.g., days)
    %   epoch      - Reference time (e.g., a specific transit time)

    % Step 1: Normalize magnitudes to correct for magnitude shifts
    uniqueNights = floor(time); % Assuming time is in days
    nights = unique(uniqueNights); % Identify unique nights
    normalizedMag = magnitude;

    for i = 1:numel(nights)
        % Find indices of the current night
        idx = (uniqueNights == nights(i));
        % Calculate and remove median magnitude shift for the night
        nightShift = median(magnitude(idx),'omitnan');
        normalizedMag(idx) = magnitude(idx) - nightShift;
    end

    % Step 2: Fold the light curve
    phase = mod(time - epoch, period) / period; % Compute phase
    % Ensure phase is in the range [0, 1]
    phase(phase < 0) = phase(phase < 0) + 1;

    % Step 3: Sort by phase for better visualization
    [sortedPhase, sortIdx] = sort(phase);
    sortedMag = normalizedMag(sortIdx);

    % Step 4: Plot the folded light curve
    figure;
    scatter(sortedPhase, sortedMag, 10, 'b', 'filled'); % Phase vs Magnitude
    hold on;
    scatter(sortedPhase + 1, sortedMag, 10, 'b', 'filled'); % Wrap phase for clarity
    hold off;
    xlabel('Phase');
    ylabel('Magnitude');
    title(['Folded Light Curve (Period = ', num2str(period), ' days)']);
    set(gca, 'XLim', [0, 2]); % Phase range [0, 2] for wrapping
    set(gca, 'YDir', 'reverse'); % Magnitude plot (lower is brighter)
    grid on;
end
