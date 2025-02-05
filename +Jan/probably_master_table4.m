% Assuming `master_table` contains the necessary columns:
% - Date: datetime of the observation
% - TelescopeID: Telescope identifier (string or categorical)
% - FieldID: Field identifier (string or categorical)
% - RA: Right Ascension (degrees)
% - DEC: Declination (degrees)
% - ExpTime: Exposure time (seconds, 20 seconds for each observation)

% Add a column for ObsNight
master_table.ObsNight = master_table.Date;

% Define observing nights (2 PM to 6 AM next day)
afternoonMask = timeofday(master_table.Date) < hours(14); % Before 2 PM
master_table.ObsNight(afternoonMask) = master_table.ObsNight(afternoonMask) - days(1);
master_table.ObsNight = dateshift(master_table.ObsNight, 'start', 'day', 'nearest');

% ----- Group Observations by ObsNight and FieldID -----
% Use `findgroups` to group the data
[G, ObsNightGroup, FieldGroup] = findgroups(master_table.ObsNight, master_table.FieldID);

% Calculate total observing time per group
% Each row corresponds to a 20-second observation
TotalObsTime = splitapply(@(x) numel(x) * 20 / 3600, G, master_table.Date); % Total time in hours

% Create a summary table with results
SummaryTable = table(ObsNightGroup, FieldGroup, TotalObsTime, ...
    'VariableNames', {'ObsNight', 'FieldID', 'TotalObsTime'});

% ----- Filter Fields Observed for at Least 3 Hours -----
FilteredSummaryTable = SummaryTable(SummaryTable.TotalObsTime >= 3, :);

% ----- Visualization -----

% Scatter plot of field distribution on celestial sphere
figure;
scatter(master_table.RA, master_table.DEC, 50, G, 'filled');
title('Field Observed Distribution on the Celestial Sphere');
xlabel('RA (degrees)');
ylabel('DEC (degrees)');
colorbar;
grid on;

% Filtered celestial sphere plot (fields with >= 3 hours observation)
FilteredFields = ismember(master_table.FieldID, FilteredSummaryTable.FieldID);
figure;
scatter(master_table.RA(FilteredFields), master_table.DEC(FilteredFields), ...
        50, master_table.Date(FilteredFields), 'filled');
title('Filtered Field Observations (>= 3 Hours) on Celestial Sphere');
xlabel('RA (degrees)');
ylabel('DEC (degrees)');
colorbar;
grid on;

% ----- Bar Chart: Number of Fields Observed per Telescope -----
TelescopeGroup = findgroups(master_table.TelescopeID); % Group by TelescopeID
FieldsPerTelescope = splitapply(@numel, TelescopeGroup, master_table.FieldID);

figure;
bar(categorical(master_table.TelescopeID), FieldsPerTelescope);
title('Number of Fields Observed per Telescope');
xlabel('Telescope ID');
ylabel('Number of Fields');
grid on;

% ----- Statistics -----

% Total observing time per telescope
[Telescopes, TelescopeGroup] = findgroups(master_table.TelescopeID);
%TotalObsTimePerTelescope =
