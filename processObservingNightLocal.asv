function processObservingNightLocal(mount, telescope, year, month, day, batchSize)
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
      
        basePath = sprintf('/%s/data2/archive/LAST.01.%02d.%02d_re/', computer, mount,telescope);
    else
        
        basePath = sprintf('/%s/data1/archive/LAST.01.%02d.%02d_re/', computer, mount,telescope);
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
        fitsFilesBatch = {};
        hdf5FilesBatch = {};
        fitsFilesNames = {};
        hdf5FilesNames  = {};
        fitsFilesFolders = {};
        hdf5FilesFolders = {};
        for i = 1:length(batch)
            visitPath = fullfile(fullPath, batch(i).name);
            fitsFiles = dir(fullfile(visitPath, '*proc_Image_1.fits'));
            hdf5Files = dir(fullfile(visitPath, '*.hdf5'));
            
            % Add files to the batch lists
            fitsFilesBatch = [fitsFilesBatch; fullfile({fitsFiles.folder}, {fitsFiles.name})']; %#ok<AGROW>
            hdf5FilesBatch = [hdf5FilesBatch; fullfile({hdf5Files.folder}, {hdf5Files.name})']; %#ok<AGROW>
            fitsFilesNames = [fitsFilesNames; {fitsFiles.name}'];
            hdf5FilesNames  = [hdf5FilesNames; {hdf5Files.name}'];
            fitsFilesFolders = [fitsFilesFolders; {fitsFiles.folder}'];
            hdf5FilesFolders = [hdf5FilesFolders; {hdf5Files.folder}'];
        end
        
        %% Categorize FITS and HDF5 Files by CropID
        cropIdsFits = regexp(fitsFilesBatch, '_\d{3}_\d{3}_(\d{3})_sci_proc', 'tokens', 'once');
        cropIdsFits = cellfun(@(x) x{1}, cropIdsFits, 'UniformOutput', false);
        uniqueCropIdsFits = unique(cropIdsFits);

        cropIdsHdf5 = regexp(hdf5FilesBatch, '_\d{3}_\d{3}_(\d{3})_sci_merged', 'tokens', 'once');
        cropIdsHdf5 = cellfun(@(x) x{1}, cropIdsHdf5, 'UniformOutput', false);
        uniqueCropIdsHdf5 = unique(cropIdsHdf5);
        
        %% Iterate Over Subframes
        for cropId = uniqueCropIdsFits'
            subframeFitsFiles   = fitsFilesBatch(strcmp(cropIdsFits, cropId));
            subframeHdf5File    = hdf5FilesBatch(strcmp(cropIdsHdf5, cropId));
            subframeFitsNames   = fitsFilesNames(strcmp(cropIdsFits, cropId));
            subframeHdf5Names   = hdf5FilesNames(strcmp(cropIdsHdf5, cropId));
            subframeFitsFolders = fitsFilesFolders(strcmp(cropIdsFits, cropId));
            subframeHdf5Folders = hdf5FilesFolders(strcmp(cropIdsHdf5, cropId));
            
          
            
            
            % Process catlaog data 
            MS = createMSlist(str2double(cropId),subframeHdf5Names,subframeHdf5Folders);
            
                % get coords of first image (from header)
                Coords = getMScoords(subframeFitsFile)
                
            
            % Process Each FITS File in the Subframe
            for j = 1:length(subframeFitsFiles)
                fitsFile = subframeFitsFiles{j};
                hdf5File = subframeHdf5File{1};

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

function MS = createMSlist(subframe,subframeHdf5Names,subframeHdf5Folders)
    List.FileName = subframeHdf5Names;
    List.Folder   = subframeHdf5Folders;
    List.CropID   = subframe;
    MS = MatchedSources.readList(List);

end

function getMScoords(subframeFitsFile)

    AI = AstroImage(subframeFitsFile);
    raMin = min([ AI.Key.RAU1;AI.Key.RAU2;AI.Key.RAU3;AI.Key.RAU4]);
    raMax = max([ AI.Key.RAU1;AI.Key.RAU2;AI.Key.RAU3;AI.Key.RAU4]);
    decMin = min([ AI.Key.DECU1;AI.Key.DECU2;AI.Key.DECU3;AI.Key.DECU4]);
    decMax = max([ AI.Key.DECU1;AI.Key.DECU2;AI.Key.DECU3;AI.Key.DECU4]);

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
