function processObservingNight(mount, telescope, year, month, day, batchSize)
    % Main Template for Forced Photometry Routine for LAST
    % Inputs:
    % mount - mount number (e.g., 1, 2, 3, ...)
    % telescope - telescope number (e.g., 1, 2, 3, 4, ...)
    % year, month, day - observation date
    % batchSize - number of visits per batch for processing
    % Author: Yarin Shani
    % Date: 2024-10-20

    %% Setup Paths

    if telescope < 3 
      computer = sprintf('last%02de',mount);
    else
      computer = sprintf('last%02dw',mount);
    end

    
    if mod(telescope, 2) == 0
      
        basePath = sprintf('%s/data2/archive/LAST.01.%02d/', computer, mount);
    else
        
        basePath = sprintf('%s/data1/archive/LAST.01.%02d/', computer, mount);
    end
    
    dateFolder = sprintf('%04d/%02d/%02d/proc/', year, month, day);
    fullPath = fullfile(basePath, dateFolder);
    
    %% Load Visit Directories and Sort Properly
    visitDirs = dir(fullfile(fullPath, '*v0'));
    visitNames = {visitDirs.name};
    
    % Extract hour, minute, second from folder names and handle AM/PM sorting
    visitTimes = cellfun(@(x) sscanf(x, '%06dv0'), visitNames);
    visitHours = floor(visitTimes / 10000);
    amPmMask = visitHours < 12; % AM: hours < 12, PM: hours >= 12
    amVisits = visitDirs(amPmMask);
    pmVisits = visitDirs(~amPmMask);
    
    % Sort AM and PM visits separately
    [~, amOrder] = sort(visitTimes(amPmMask));
    [~, pmOrder] = sort(visitTimes(~amPmMask));
    
    % Concatenate PM visits first, then AM visits
    sortedVisits = [pmVisits(pmOrder); amVisits(amOrder)];
    
    %% Batch Visits for Processing
    numVisits = length(sortedVisits);
    batches = cell(ceil(numVisits / batchSize), 1);
    for i = 1:length(batches)
        startIdx = (i - 1) * batchSize + 1;
        endIdx = min(i * batchSize, numVisits);
        batches{i} = sortedVisits(startIdx:endIdx);
    end

    %% Process Each Batch of Visits
    for b = 1:length(batches)
        batch = batches{b};
        for i = 1:length(batch)
            visitPath = fullfile(fullPath, batch(i).name);
            fitsFiles = dir(fullfile(visitPath, '*.fits'));
            hdf5Files = dir(fullfile(visitPath, '*.hdf5'));

            % Check if files exist
            if isempty(fitsFiles) || isempty(hdf5Files)
                warning('No fits or hdf5 files found for visit: %s', batch(i).name);
                continue;
            end

            % Process Each FITS File and Corresponding HDF5 Catalog
            for j = 1:length(fitsFiles)
                fitsFile = fullfile(visitPath, fitsFiles(j).name);
                hdf5File = fullfile(visitPath, hdf5Files(j).name);

                % Load Image Data
                imageData = fitsread(fitsFile);
                fitsInfo = fitsinfo(fitsFile);
                % Extract center coordinates from FITS header
                raCenter = fitsInfo.PrimaryData.Keywords{strcmp(fitsInfo.PrimaryData.Keywords(:, 1), 'CRVAL1'), 2};
                decCenter = fitsInfo.PrimaryData.Keywords{strcmp(fitsInfo.PrimaryData.Keywords(:, 1), 'CRVAL2'), 2};

                %% Query Sources in Field
                % Use catsHTM to query sources within rectangular region (modify catsHTM for rectangular search)
                wdSources = querySourcesRectangle(raCenter, decCenter, fitsInfo);
                
                %% Perform Forced Photometry
                % Perform PSF and Aperture photometry on the detected sources
                forcedResults = performForcedPhotometry(imageData, wdSources);

                %% Load HDF5 Catalog and Compare Results
                catalogData = loadHdf5Catalog(hdf5File);
                comparePhotometry(forcedResults, catalogData);
            end
        end
    end

    %% Merge Matched Sources for All Visits
    mergedMs = mergeMatchedSources(hdf5Files);
    % Apply ZP correction
    mergedMs = applyZpCorrection(mergedMs);

    %% Visualize Results
    visualizeLightCurves(mergedMs);
    
    %% Save Results
    outputFile = sprintf('Processed_%04d_%02d_%02d_Mount%d.mat', year, month, day, mount);
    save(outputFile, 'mergedMs');
end

function sources = querySourcesRectangle(ra, dec, fitsInfo)
    % Placeholder function for querying sources in a rectangular region
    % Modify catsHTM or use AstroPack for source extraction
    sources = []; % Replace with actual query implementation
end

function results = performForcedPhotometry(imageData, sources)
    % Placeholder for forced photometry routine
    % Use both PSF and aperture photometry
    results = []; % Replace with actual photometry implementation
end

function catalog = loadHdf5Catalog(hdf5File)
    % Load HDF5 Catalog Data
    catalog = h5read(hdf5File, '/catalog');
end

function comparePhotometry(forcedResults, catalogData)
    % Placeholder for comparing forced photometry with pipeline catalog
    % Generate comparison plots and statistics
end

function mergedMs = mergeMatchedSources(hdf5Files)
    % Placeholder for merging matched sources from multiple visits
    mergedMs = []; % Replace with merging implementation
end

function ms = applyZpCorrection(ms)
    % Apply Zero Point correction to matched sources
    % ZP correction relative to the first observation
end

function visualizeLightCurves(ms)
    % Visualize light curves for all sources
end
