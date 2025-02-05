%% Get all MS data from marvin for a field + telescope
FR = load('/home/yarinms/Documents/WDsurvey/+Jan/observationStatisticResults.mat')
FR = FR.filteredResults;

%% For a Field ID

FieldIdx = 274;
disp(FR(FieldIdx,:))
currentField = FR(FieldIdx,:);

%% go to marvin
cd(sprintf('~/marvin/%s',currentField.TelescopeID))