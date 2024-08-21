function wdTransitSearch(rootPath, fieldName, Args)
% Analyze white dwarf transits in a given field
% 
% Inputs:
%   rootPath - Path to the directory tree
%   fieldName - Name of the field to analyze
%   args - Struct containing optional arguments

% Set default arguments
if nargin < 3
    Args = setDefaultArgs();
end

% Find and read matched sources
matchedSources = findMatchedSources(rootPath, fieldName);

% Find white dwarfs in the field
[ra, dec, wd] = findWhiteDwarfsInField(matchedSources);

% Analyze each white dwarf
results = analyzeWhiteDwarfs(matchedSources, ra, dec, wd, Args);

% Generate output
generateOutput(results);

end

function args = setDefaultArgs()
    args.MagField = {'MAG_PSF'};
    args.MagErrField = {'MAGERR_PSF'};
    args.BadFlags = {'Saturated','Negative','NaN' ,'Spike','Hole','CR_DeltaHT','NearEdge'};
    args.EdgeFlags = {'Overlap'};
    args.runMeanFilterArgs = {'Threshold',5, 'StdFun','OutWin'};
    args.Nvisits = 1;
    args.Ndet = 17 * args.Nvisits;
end


%% Create MS (by field name).
function matchedSources = findMatchedSources(rootPath)
    cd(rootPath);
    list = MatchedSources.rdirMatchedSourcesSearch('FileTemplate','*.hdf5');
    
    % Extract unique field names
    allFileNames = {list.FileName};
    fieldNames = unique(cellfun(@extractFieldName, allFileNames, 'UniformOutput', false));
    
    % Present field choices to the user
    fprintf('Available fields:\n');
    for i = 1:length(fieldNames)
        fprintf('%d. %s\n', i, fieldNames{i});
    end
    
    % Get user input
    choice = input('Enter the number of the field you want to analyze: ');
    while ~isnumeric(choice) || choice < 1 || choice > length(fieldNames)
        choice = input('Invalid input. Please enter a valid number: ');
    end
    
    selectedField = fieldNames{choice};
    fprintf('Selected field: %s\n', selectedField);
    
    % Filter the list based on the selected field
    filteredList = filterListByFieldName(list, selectedField);
    
    % Read the matched sources
    matchedSources = MatchedSources.readList(filteredList);
end

function fieldName = extractFieldName(fileName)
    % Extract the field name from the file name
    % Modify this function based on your file naming convention
    parts = strsplit(fileName, '_');
    fieldName = parts{1};  % Assuming the field name is the first part
end

function filteredList = filterListByFieldName(list, fieldName)
    isMatchingField = cellfun(@(x) contains(x, fieldName), {list.FileName});
    filteredList = list(isMatchingField);
end

%%

function [ra, dec, wd] = findWhiteDwarfsInField(matchedSources)
    % Implement the logic to find white dwarfs in the field
    % This function should return the RA, Dec, and WD catalog data
end

function results = analyzeWhiteDwarfs(matchedSources, ra, dec, wd, args)
    results = struct();
    for i = 1:numel(ra)
        [ms, res] = findSourceInMatchedSources(matchedSources, ra(i), dec(i));
        if ~isempty(ms)
            lcData = analyzeLightCurve(ms, res, ra(i), dec(i), args);
            results(i) = detectTransits(lcData, args);
        end
    end
end

function lcData = analyzeLightCurve(ms, res, ra, dec, args)
    % Clean and prepare the light curve data
    mms = cleanMatchedSources(ms, args);
    lcData = extractLightCurve(mms, ra, dec);
    lcData = handleNaNValues(lcData, res);
end

function mms = cleanMatchedSources(ms, args)
    mms = ms.setBadPhotToNan('BadFlags', args.BadFlags, 'MagField', 'MAG_PSF', 'CreateNewObj', true);
    r = lcUtil.zp_meddiff(ms, 'MagField', args.MagField, 'MagErrField', args.MagErrField);
    [mms, ~] = applyZP(mms, r.FitZP, 'ApplyToMagField', args.MagField);
    mms = removeSourcesWithFewDetections(mms, args.Ndet);
end

function lcData = extractLightCurve(mms, ra, dec)
    ind = mms.coneSearch(ra, dec, 6).Ind;
    lcData.lc = mms.Data.MAG_PSF(:, ind);
    lcData.typicalSD = clusteredSD1(mms, 'Isrc', ind);
end

function lcData = handleNaNValues(lcData, res)
    % Implement NaN handling logic here
end

function results = detectTransits(lcData, args)
    results.detection1 = detectConsecutivePoints(lcData, args);
    results.detection2 = runMeanFilter(lcData, args);
    results.detection3 = detectAreaEvents(lcData, args);
end

function detection = detectConsecutivePoints(lcData, args)
    % Implement detection method 1 (2 consecutive points)
end

function detection = runMeanFilter(lcData, args)
    % Implement run mean filter detection
end

function detection = detectAreaEvents(lcData, args)
    % Implement area detection method
end

function generateOutput(results)
    % Implement output generation (tables, plots, documentation)
end