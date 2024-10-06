function [msCropID] = extractLCFromObs2(Path, Args)
% extractLCFromWD - Extracts light curves for WD sources from LAST
% astronomical catalogs.
%
% This function searches for a source based on its coordinates,
% extracts observation data, creates light curves (LC), handles NaNs, applies
% corrections, and optionally detects transits.
%
% Inputs:
%   - Path: The file path to the observation data.
%   - Args: A struct of arguments containing the following fields:
%       - RA (deg): Right ascension of the source. If empty, search for sources.
%       - Dec (deg): Declination of the source. If empty, output MatchedSources.
%       - FieldID: Field ID for the source. Default is [].
%       - CropID: Crop ID to narrow the search. Default is [] (search entire frame).
%       - CropIDsearchRad: Radius for cone search (default: 5 arcsec).
%       - timeRange: Limits the data extraction to a specific time range.
%       - Nconsecutive: Minimum number of consecutive visits (default: 2).
%       - consecutiveTimeDiff: Time difference for long exposure visits (default: 21 sec).
%       - getHeaderInfo: If true, retrieves header info (limiting mag, FWHM, JD). Default is true.
%       - maxNan: Max NaNs allowed (default: 3 per visit).
%       - cleanNan: If true, replaces NaNs with limiting mag values.
%       - Flags: Retrieve bitmask flags. Default is true.
%       - badFlags: List of bad flags (default: {'saturated','Negative'}).
%       - CleanFlags: If true, turns bad flag data into NaNs. Default is false.
%       - ZP: Apply zero-point correction. Default is true.
%       - getMag: Field for magnitude data extraction (default: 'MAG_PSF').
%       - getFlux: Extract relative flux (default: true).
%       - Detect: Run transit detection algorithms using WDtransits2 (default: false).
%       - Plot: Plot light curve (default: true).
%       - plotTitle: Plot title format (default: '(RA,Dec) LAST.01.XX.XX Date CropID').
%       - saveVars: If true, saves lcData and matched sources as .mat files.
%       - savePath: Path to save plots and data (default: '~/Projects/WD_survey/LC_output_%i').
%
% Outputs:
%   -MS sourced.
%
% Author: Yarin Shani

arguments
    Path string
    Args.RA double = []
    Args.Dec double = []
    Args.FieldID string = ""
    Args.CropID double = []
    Args.CropIDsearchRad double = 5  % arcsec
    Args.timeRange = []
    Args.Nconsecutive double = 2
    Args.consecutiveTimeDiff double = 21  % seconds
    Args.getHeaderInfo logical = true
    Args.maxNan double = 3
    Args.cleanNan logical = false
    Args.Flags logical = true
    Args.badFlags cell = {'saturated','Negative'}
    Args.CleanFlags logical = false
    Args.ZP logical = false
    Args.getMag string = 'MAG_PSF'
    Args.getFlux logical = false
    Args.Detect logical = false
    Args.Plot logical = false
    Args.plotTitle string = "(RA,Dec) LAST.01.XX.XX Date CropID"
    Args.saveVars logical = false
    Args.savePath string = "~/Projects/WD_survey/LC_output_%i"
end

% Step 1: Search for matched sources
if isempty(Args.RA) || isempty(Args.Dec)
    fprintf('Searching for matched sources...\n');
    [msCropID, fieldID] = WDtransits2.findMatchedSources(Path);
else
    fprintf('Source coordinates provided: RA = %.2f, Dec = %.2f\n', Args.RA, Args.Dec);
    [msCropID, fieldID] = WDtransits2.findMatchedSources(Path, Args.RA, Args.Dec);
end

% Step 2: Extract FieldID if not provided
if isempty(Args.FieldID)
    Args.FieldID = fieldID.ID;
    fprintf('Extracting field: %s\n', Args.FieldID);
end

% Step 3: Cone search for CropID if not provided
if isempty(Args.CropID) && ~isempty(Args.RA)
    fprintf('Performing cone search for the source...\n');
    [msCropID, Args.CropID] = WDtransits2.findMatchedSources(Path);
end

% Step 4: Process matched sources and merge into N consecutive visits
%fprintf('Processing matched sources for light curve extraction...\n');
%lcData = WDtransits2.groupVisits(msCropID, Args);

% Step 5: Handle NaNs and apply calibration (WDtransits2 methods)
if Args.cleanNan
    fprintf('Cleaning NaNs and applying zero-point calibration...\n');
    lcData = WDtransits2.cleanMatchedSources(lcData, Args);
    lcData = WDtransits2.applyZP(lcData, Args.ZP);
end

% Step 6: Detect transits (if enabled)
if Args.Detect
    fprintf('Running transit detection (methods 1 and 2)...\n');
    lcData = WDtransits2.detectTransits(lcData, Args);
end

% Step 7: Plot the light curve
if Args.Plot
    fprintf('Plotting light curve...\n');
    WDtransits2.plotDetectionResults(lcData, Args.plotTitle, Args);
end

% Step 8: Save variables and results if required
if Args.saveVars
    fprintf('Saving lcData and matched sources...\n');
    saveFilePath = sprintf(Args.savePath, length(dir(Args.savePath))+1);
    save(saveFilePath, 'lcData', 'msCropID');
end

end
