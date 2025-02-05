% Convert Date and Time columns to datetime if not already in that format
master_table.Date = datetime(master_table.Date, 'InputFormat', 'dd-MMM-yyyy');
master_table.Time = datetime(master_table.Time, 'InputFormat', 'dd-MMM-yyyy HH:mm:ss');

% Create a unique identifier for each observing night
obsNight = dateshift(master_table.Time, 'start', 'day'); % Start from midnight
timeOfDay = timeofday(master_table.Time); % Extract time of day

% Assign observation nights based on time ranges
obsNight(timeOfDay >= hours(14)) = obsNight(timeOfDay >= hours(14)) + days(1); % Observations after 14:00
master_table.ObsNight = obsNight; % Add this as a new column to the table

% Get unique fields
uniqueFields = unique(master_table.FieldID);

% Initialize results storage
results = table('Size', [0, 8], 'VariableTypes', ...
    {'string', 'string', 'double', 'double', 'double', 'double', 'double', 'double'}, ...
    'VariableNames', {'FieldID', 'TelescopeID', 'NumNights', 'ImagesPerNight', ...
    'MeanRA', 'MeanDec', 'ExpTime', 'TotalObservingTime'});

% Loop over each unique field
for i = 1:numel(uniqueFields)
    % Filter data for the current field
    fieldData = master_table(strcmp(master_table.FieldID, uniqueFields{i}), :);
    
    % Calculate mean RA and Dec for the field
    meanRA = mean(fieldData.RA);
    meanDec = mean(fieldData.DEC);
    
    % Get the exposure time for this field (assumes consistent exposure time per field)
    expTime = unique(fieldData.ExpTime);
    if numel(expTime) > 1
        warning("FieldID %s has multiple exposure times. Using the first one.", uniqueFields{i});
        expTime = expTime(1);
    end
    
    % Get unique telescopes observing this field
    uniqueTelescopes = unique(fieldData.TelescopeID);
    
    % Loop over each telescope
    for j = 1:numel(uniqueTelescopes)
        % Filter data for the current telescope
        telescopeData = fieldData(strcmp(fieldData.TelescopeID, uniqueTelescopes{j}), :);
        
        % Get unique observation nights for this telescope and field
        uniqueNights = unique(telescopeData.ObsNight);
        numNights = numel(uniqueNights); % Total unique nights
        
        % Count images per night
        imagesPerNightArray = zeros(numNights, 1);
        for k = 1:numNights
            % Count rows for the current observation night
            imagesPerNightArray(k) = sum(telescopeData.ObsNight == uniqueNights(k));
        end
        avgImagesPerNight = mean(imagesPerNightArray); % Average images per night
        
        % Total observing time for this field
        totalImages = height(telescopeData); % Total images for this telescope-field combo
        totalObservingTime = totalImages * expTime; % Total time in seconds
        
        % Append results
        results = [results; {uniqueFields{i}, uniqueTelescopes{j}, numNights, ...
            avgImagesPerNight, meanRA, meanDec, expTime, totalObservingTime}];
    end
end

% Sort the results table by TelescopeID
results = sortrows(results, 'TelescopeID');

% Display the results table
disp(results);


%%

% Filter the results table for fields with more than 300 exposures per night
filteredResults = results(results.ImagesPerNight > 300, :);

% Display the filtered table
disp(filteredResults);


%%
% Filter the results table for fields with more than 300 exposures per night
filteredResults = results(results.ImagesPerNight > 300, :);

% Check if there are any fields to plot
if isempty(filteredResults)
    disp('No fields with more than 300 exposures per night to plot.');
else
    % Extract RA and Dec coordinates
    RA = filteredResults.MeanRA; % Right Ascension (in degrees)
    Dec = filteredResults.MeanDec; % Declination (in degrees)
    
    % Create a celestial sphere plot
    figure;
    hold on;
    
    % Plot fields
    scatter(RA, Dec, 50, 'filled'); % Points with size 50 and filled markers
    
    % Add grid and labels
    grid on;
    xlabel('Right Ascension (deg)');
    ylabel('Declination (deg)');
    title('Fields with >300 Exposures per Night on the Celestial Sphere');
    
    % Adjust RA for celestial convention (RA increases right-to-left)
    set(gca, 'XDir', 'reverse');
    
    % Annotate points with FieldID
    for i = 1:height(filteredResults)
        text(RA(i), Dec(i), filteredResults.FieldID{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right','FontSize',10);
    end
    
    hold off;
end

%%
% Filter the results table for fields with more than 300 exposures per night
filteredResults = results(results.ImagesPerNight > 300, :);

% Check if there are any fields to plot
if isempty(filteredResults)
    disp('No fields with more than 300 exposures per night to plot.');
else
    % Extract RA, Dec, and Total Observing Time
    RA = filteredResults.MeanRA; % Right Ascension (in degrees)
    Dec = filteredResults.MeanDec; % Declination (in degrees)
    totalTime = filteredResults.TotalObservingTime; % Color-code by total observing time

    % Normalize total observing time for color mapping
    normalizedTime = (totalTime - min(totalTime)) / (max(totalTime) - min(totalTime));
    
    % Create a celestial sphere plot
    figure;
    hold on;
    
    % Plot celestial grid
    celestialGrid(); % Helper function to plot celestial grid (defined below)

    % Scatter plot with color coding
    scatter(RA, Dec, 100, normalizedTime, 'filled'); % Points with size 100 and color-coded
    
    % Add colorbar
    colormap jet; % Use a jet color map
    c = colorbar;
    c.Label.String = 'Normalized Total Observing Time';
    
    % Add grid and labels
    xlabel('Right Ascension (deg)');
    ylabel('Declination (deg)');
    title('Fields with >300 Exposures per Night on the Celestial Sphere');
    
    % Adjust RA for celestial convention (RA increases right-to-left)
    set(gca, 'XDir', 'reverse');
    grid on;

    % Annotate points with FieldID
    for i = 1:height(filteredResults)
        text(RA(i), Dec(i), filteredResults.FieldID{i}, ...
            'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    end
    
    hold off;
end

% Function to plot celestial grid
function celestialGrid()
    % Plot celestial grid with RA and Dec
    raTicks = 0:30:360; % RA ticks (degrees)
    decTicks = -90:15:90; % Dec ticks (degrees)
    
    % Plot RA lines
    for ra = raTicks
        decLine = linspace(-90, 90, 100); % Dec values
        plot(ra * ones(size(decLine)), decLine, 'k:', 'LineWidth', 0.5); % RA lines
    end
    
    % Plot Dec lines
    for dec = decTicks
        raLine = linspace(0, 360, 100); % RA values
        plot(raLine, dec * ones(size(raLine)), 'k:', 'LineWidth', 0.5); % Dec lines
    end
    
    % Add labels for RA and Dec
    for ra = raTicks
        text(ra, -90, sprintf('%d°', ra), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
    end
    for dec = decTicks
        text(0, dec, sprintf('%d°', dec), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
    end
end


%%
% Filter the results table for fields with more than 300 exposures per night
filteredResults = results(results.ImagesPerNight > 300, :);

% Check if there are any fields to plot
if isempty(filteredResults)
    disp('No fields with more than 300 exposures per night to plot.');
else
    % Extract RA, Dec, and Total Observing Time
    RA = filteredResults.MeanRA; % Right Ascension (in degrees)
    Dec = filteredResults.MeanDec; % Declination (in degrees)
    totalTime = filteredResults.TotalObservingTime; % Color-code by total observing time

    % Normalize total observing time for color mapping
    normalizedTime = (totalTime - min(totalTime)) / (max(totalTime) - min(totalTime));
    
    % Convert RA to celestial convention for plotting (-180 to 180 degrees)
    RA_plot = mod(RA + 180, 360) - 180;

    % Create a celestial sphere plot in Mollweide projection
    figure;
    axesm('mollweid', 'Frame', 'on', 'Grid', 'on'); % Mollweide projection
    setm(gca, 'Origin', [0 0 0]); % Centered at RA = 0, Dec = 0
    setm(gca, 'MLineLocation', 30, 'PLineLocation', 15); % Grid spacing
    setm(gca, 'ParallelLabel', 'on', 'MeridianLabel', 'on'); % Labels for grid
    
    % Scatter plot with color coding
    scatterm(Dec, RA_plot, 30, filteredResults.TotalObservingTime./3600, 'filled'); % Points with size 100 and color-coded
    
    % Add colorbar
    colormap jet; % Use a jet color map
    c = colorbar;
    c.Label.String = 'Normalized Total Observing Time';
    
    % Annotate points with FieldID
    % for i = 1:height(filteredResults)
    %     textm(Dec(i), RA_plot(i), filteredResults.FieldID{i}, ...
    %         'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    % end
    
    % Add title
    title('Fields with >300 Exposures per Night (Mollweide Projection)');
end


%%
% Filter the results table for fields with more than 300 exposures per night
filteredResults = results(results.ImagesPerNight > 300, :);

% Check if there are any fields to process
if isempty(filteredResults)
    disp('No fields with more than 300 exposures per night to process.');
else
    % Add columns for Total Images and Total Integration Time
    filteredResults.TotalImages = zeros(height(filteredResults), 1);
    filteredResults.TotalIntegrationTime = zeros(height(filteredResults), 1);
    
    % Loop through each row of the filtered table
    for i = 1:height(filteredResults)
        % Get the current FieldID and TelescopeID
        fieldID = filteredResults.FieldID{i};
        telescopeID = filteredResults.TelescopeID{i};
        
        % Filter the master_table for rows matching this FieldID and TelescopeID
        matchingRows = master_table(strcmp(master_table.FieldID, fieldID) & ...
                                     strcmp(master_table.TelescopeID, telescopeID), :);
        
        % Count the total number of images
        totalImages = height(matchingRows);
        
        % Calculate the total integration time (TotalImages * ExpTime)
        expTime = unique(matchingRows.ExpTime); % Exposure time for this field-telescope combo
        if numel(expTime) > 1
            warning("FieldID %s with TelescopeID %s has inconsistent exposure times. Using the first value.", ...
                    fieldID, telescopeID);
            expTime = expTime(1);
        end
        totalIntegrationTime = totalImages * expTime;
        
        % Update the filtered table
        filteredResults.TotalImages(i) = totalImages;
        filteredResults.TotalIntegrationTime(i) = totalIntegrationTime;
    end
    
    % Display the updated filtered table
    disp(filteredResults);
end
