function observations = processObservingNights(dates, ComputerID, batchSize, sourceRA, sourceDec)
    % Observations Processing for Multiple Nights
    % Inputs:
    % - dates: [yyyy, mm, dd; ...] matrix for multiple observation dates.
    % - ComputerID: [mount, telescope] array defining telescope setup.
    % - batchSize: Number of visits to group per batch.
    % - sourceRA, sourceDec: Coordinates of the source in RA and Dec.
    %
    % Outputs:
    % - observations: Struct array with data for each night.

    mount = ComputerID(1);
    telescope = ComputerID(2);
    telescopeID = sprintf('LAST.01.%02d.%02d', mount, telescope);

    observations = struct('date', [], 'batches', [], 'lightCurves', []);

    % Iterate over each date in the dates matrix
    for i = 1:size(dates, 1)
        year = dates(i, 1);
        month = dates(i, 2);
        day = dates(i, 3);

        % Construct the path for the current date
        basePath = sprintf('~/marvin/%s/', telescopeID);
        dateFolder = sprintf('%04d/%02d/%02d/proc/', year, month, day);
        fullPath = fullfile(basePath, dateFolder);

        % Check if the path exists
        if ~isfolder(fullPath)
            fprintf('Directory does not exist: %s\n', fullPath);
            continue;
        end

        % Organize visits into batches for processing
        batches = organizeBatches(fullPath, batchSize);

        % Initialize storage for the night’s data
        nightData = struct('batches', [], 'lightCurves', []);
        
        % Loop over batches and process each batch
        for j = 1:numel(batches)
            batch = batches{j};
            
            % Process photometry for each batch and extract source light curves
            [lightCurve, cropID] = processBatch(batch, fullPath, sourceRA, sourceDec, 0); % for forced phot
            
            % Store batch data and light curve for further analysis
            nightData.batches{j} = batch;
            nightData.lightCurves{j} = lightCurve;
        end

        % Append night’s data to observations
        observations(i).date = sprintf('%04d-%02d-%02d', year, month, day);
        observations(i).batches = nightData.batches;
        observations(i).lightCurves = nightData.lightCurves;
    end

    disp('Data processing complete for all dates.');
end

function [lightCurve, cropID] = processBatch(batch, fullPath, sourceRA, sourceDec, forcePhotometry)
    % Process a batch to extract photometry data and identify cropID for source.
    % Inputs:
    % - batch: Cell array of file paths for the current batch.
    % - fullPath: Base directory path for the current observation date.
    % - sourceRA, sourceDec: Coordinates of the source in RA and Dec.
    % - forcePhotometry: Boolean to determine if forced photometry should be conducted.
    %
    % Outputs:
    % - lightCurve: Struct containing extracted light curve data.
    % - cropID: ID of the subframe (crop) containing the source.

    [fitsFilesBatch, hdf5FilesBatch, fitsFilesNames, hdf5FilesNames, fitsFilesFolders, hdf5FilesFolders] = extractDataFiles(batch, fullPath);
    
    % Extract CropIDs from FITS and HDF5 file names
    cropIdsFits = regexp(fitsFilesBatch, '_\d{3}_\d{3}_(\d{3})_sci_proc', 'tokens', 'once');
    cropIdsFits = cellfun(@(x) x{1}, cropIdsFits, 'UniformOutput', false);
    uniqueCropIds = unique(cropIdsFits); % Get unique CropIDs

    cropIdsHdf5 = regexp(hdf5FilesBatch, '_\d{3}_\d{3}_(\d{3})_sci_merged', 'tokens', 'once');
    cropIdsHdf5 = cellfun(@(x) x{1}, cropIdsHdf5, 'UniformOutput', false);
    uniqueCropIdsHdf5 = unique(cropIdsHdf5);

    % Separate FITS and HDF5 files within the batch
    %fitsFiles = extractFilesByType(batch, '.fits');
    %hdf5Files = extractFilesByType(batch, '.hdf5');
    
    % Decide whether to proceed with forced photometry
    conductForcedPhotometry = shouldConductForcedPhotometry(fitsFilesBatch, forcePhotometry);

    % Initialize outputs
    lightCurve = [];
    cropID = [];

    

    % Loop through each unique cropID and process the photometry data
    for i = 1:numel(uniqueCropIdsHdf5)
        cropId = uniqueCropIdsHdf5{i};

        if conductForcedPhotometry
            % Extract FITS files specific to this cropID
          
            subframeFitsFiles = fitsFilesBatch(strcmp(cropIdsFits, cropId));
            subframeFitsNames   = fitsFilesNames(strcmp(cropIdsFits, cropId));
            subframeFitsFolders = fitsFilesFolders(strcmp(cropIdsFits, cropId));
            if ~isempty(subframeFitsFiles)
                % Conduct forced photometry on the subframe
                FPAI = generateFPImg(cropID, subframeFitsFolders, subframeFitsNames);
            end
        end

        % Get catalog photometry and light curve data from HDF5 files
        % Get FITS and HDF5 files for this specific CropID
            
        subframeHdf5File = hdf5FilesBatch(strcmp(cropIdsHdf5, cropId));
        subframeHdf5Names   = hdf5FilesNames(strcmp(cropIdsHdf5, cropId));
        subframeHdf5Folders = hdf5FilesFolders(strcmp(cropIdsHdf5, cropId));
        subframeFitsFiles = fitsFilesBatch(strcmp(cropIdsFits, cropId));
        FPAI = AstroHeader(subframeFitsFiles);
    
      
            
            % Extract relevant photometry data for analysis
            nFiles       = numel(FPAI);  
            args.LimMag  = NaN(nFiles, 1); 
            args.airmass = NaN(nFiles, 1);
            args.catJD   = NaN(nFiles, 1);
            args.FWHM    = NaN(nFiles, 1);
            args.FieldID = cell(nFiles, 1);

            try

            args.LimMag = arrayfun(@(x) x.Key.LIMMAG, FPAI)';
            args.airmass = arrayfun(@(x) x.Key.AIRMASS, FPAI)';
            args.catJD = arrayfun(@(x) x.Key.JD, FPAI)';
            args.FWHM = arrayfun(@(x) x.Key.FWHM, FPAI)';
            args.FieldID = arrayfun(@(x) x.Key.FIELDID, FPAI,'UniformOutput',false);

            catch
                args.LimMag = arrayfun(@(x) x.Key.AIRMASS+18, FPAI)';
                args.airmass = arrayfun(@(x) x.Key.AIRMASS, FPAI)';
                args.catJD = arrayfun(@(x) x.Key.JD, FPAI)';
                args.FWHM = arrayfun(@(x) x.Key.FWHM, FPAI)';
                args.FieldID = arrayfun(@(x) x.Key.FIELDID, FPAI,'UniformOutput',false);

            end

        uFieldID = unique(args.FieldID);
        args.FileName = 'MasterOT';
        
        if ~(args.FileName(1) == uFieldID{:}(1))
            continue;
        end

        msAll = processCatalogData(cropId, subframeHdf5Names,subframeHdf5Folders,args );

        if ~isempty(msAll)
        
        %% Compare to catalogs
        Table.RA = sourceRA; Table.Dec = sourceDec; args= [];
        [mms, nanIdx] = searchNclean(msAll, Table, args);
        if ~isempty(mms)
            args.nanIdx = nanIdx;
            args.FileName = 'W';
            [lcDataCat, resCat] = getCatLC(mms, Table, args);
            % Append calibrated light curve data for this cropID
            lightCurve = [lightCurve; calibratedLightCurve];
        end
        
        end

        
    end
end

% -------- Helper Functions --------

function files = extractFilesByType(batch, extension)
    % Extract files of specified extension from batch.
    files = batch(endsWith(batch, extension));
end

function conduct = shouldConductForcedPhotometry(fitsFiles, forcePhotometry)
    % Decide if forced photometry should be conducted.
    conduct = forcePhotometry && ~isempty(fitsFiles);
end

function [uniqueCropIDs, cropData] = identifyCropIDs(hdf5Files, sourceRA, sourceDec)
    % Identify cropIDs containing the source within HDF5 files.
    % Outputs:
    % - uniqueCropIDs: List of cropIDs containing the source.
    % - cropData: Struct with folder and name information for each cropID.
    uniqueCropIDs = {};
    cropData = struct('cropID', {}, 'subframeFolders', {}, 'subframeNames', {});
    
    % (Example logic for source position matching goes here...)
    % This would involve extracting RA/Dec ranges from the catalog data in the HDF5 files.
end

function msAll = processCatalogData(cropId,subframeHdf5Names,subframeHdf5Folders, args)
    % PROCESSCATALOGDATA Processes catalog data from HDF5 files
    % Inputs:
    %   hdf5FilesBatch - List of HDF5 files for the batch
    %   cropId - Crop ID of the subframe to process
    %   args - Configuration and threshold arguments
    % Outputs:
    %   msAll - Matched sources after cleaning and processing
    
    % Create a matched sources object from the HDF5 catalog data
    try

    MS = createMSlist(cropId, subframeHdf5Names,subframeHdf5Folders);
    msAll = getGoodSources(MS, args); 
   % msAll = applyZpCorrection(msAll);


    catch
        msAll = []

    end

  
end


%% Clean MS


function mms = getGoodSources(MS,args)

    args.BadFlags = {'Saturated', 'Negative', 'NaN', 'Spike', 'Hole', 'NearEdge'};
    try 
        mms =  cleanBadSources(MS,args);
    catch
        mms =[];
    end
end


function MS = createMSlist(subframe,subframeHdf5Names,subframeHdf5Folders)
    List.FileName = subframeHdf5Names;
    List.Folder   = subframeHdf5Folders;
    List.CropID   = subframe;
    MS = MatchedSources.readList(List);

end


function [mms,nanIdx] = searchNclean(ms,wdTable,args)

 % Look for source in batch:
Src = ms.coneSearch(wdTable.RA,wdTable.Dec,6);
IndValues = {Src.Ind};

% Check for non-empty 'Ind' values
firstNonEmptyInd = find(cellfun(@(x) ~isempty(x), IndValues), 1);

% Analyze the result
if ~isempty(firstNonEmptyInd)
    args.mergeBy = firstNonEmptyInd;
    args.RA = wdTable.RA ; args.Dec = wdTable.Dec;
else
   
    %disp('Ind is empty for all elements.');
    mms =[];
    nanIdx =[];
    return
end
end




function [lcData,res] = getCatLC(mms,wdTable,args)
 %mms.coneSearch(Table.RA,Table.Dec).Ind
                    Ibatch = 1;
                    lcData{Ibatch}.limMag = args.LimMag;
                    lcData{Ibatch}.catJD = args.catJD;
                    lcData{Ibatch} = WDtransits3.extractLightCurve(lcData{Ibatch}, mms,  wdTable.RA,wdTable.Dec,args);
                    
                    %lcData{Ibatch} = WDtransits3.handleNaNValues(lcData{Ibatch},mms, mms.Nepoch);
                    [~,fname,~] = fileparts(args.FileName);
                    part = strsplit(fname,'_');
                    lcData{Ibatch}.Tel = part{1};
                    lcData{Ibatch}.Date = part{2};
                    %lcData{Ibatch}.Table.FWHM = FWHM;
                    %lcData{Ibatch}.Table.Airmass = AM;
                    %lcData{Ibatch}.Table.visTable = Table;
                    lcData{Ibatch}.Table.FieldID  = part{4};
                    %lcData{Ibatch}.Table.fwhm    = median(FWHM,'omitnan');
                    %lcData{Ibatch}.Table.airmass = median(AM,'omitnan');
                    lcData{Ibatch}.Table.RA = wdTable.RA;
                    lcData{Ibatch}.Table.Dec = wdTable.Dec;
                    lcData{Ibatch}.Table.Gmag = wdTable.Gmag;
                    lcData{Ibatch}.Table.BPmag = wdTable.BPmag;
                    lcData{Ibatch}.Table.BpRp = wdTable.BPmag - wdTable.RPmag;
                    lcData{Ibatch}.Table.Pwd = wdTable.Pwd;
                    lcData{Ibatch}.Table.AbsMag= wdTable.Gmag - (5.*log10(1000./wdTable.Plx)-5);
                    %lcData{Ibatch}.Table.Total_Visits = Table.Nvisits;
                    %lcData{Ibatch}.Table.Visits_Found= length(batch) ;
                    lcData{Ibatch}.Table.Subframe = args.CropID;
                    %lcData{Ibatch}.Table.Name = Table.Name;
                    


                   % NO TABLE FOR NOW lcData{Iwd,Ibatch}.Table = table(Iwd,:);



                     % if sum lcData{Iwd,Ibatch}.nanIndinces > 1
                     % find pattern in more source in mms



%                    lcData{Iwd,Ibatch} = transitSearch.handleNaNValues(lcData, numel(catJD));
         
                  if isfield(lcData{Ibatch},'Res')
                      % find how many detections you had of this target TBD
                      % in the future
                        a = 1;
                        res =[]

                  else
                        %Nnans =  sum(nanIdx);
                        lcData{Ibatch}.nanIndices = args.nanIdx;
                        args.Ndet = 20;
                        results{Ibatch}  = WDtransits3.detectTransits(lcData{Ibatch}, args);
                        res.detection1 = results{Ibatch}.detection1;
                        res.detection1flux = results{Ibatch}.detection1flux;
                        res.detection2 = results{Ibatch}.detection2;
                        res.detection2flux = results{Ibatch}.detection2flux;

                        [AbsMag, Plx, Dist, NonSingleStar, Neighbors, Identifiers] = getWDParams(wdTable.RA, wdTable.Dec);
                        if isnan(AbsMag) || ~isreal(AbsMag)
                            AbsMag = 0;

                        end
                        if isnan(Plx)
                            Plx = 0;
                        end
                        if isnan(NonSingleStar)
                            NonSingleStar=0;
                        end
                        if isnan(Neighbors)
                            Neighbors=0;
                        end

                        % Populate lcData with these parameters
                        lcData{Ibatch}.Table.WDtable = wdTable;
                        %lcData{Ibatch}.Table.AbsMag = AbsMag;
                        lcData{Ibatch}.Table.Plx = Plx;
                        lcData{Ibatch}.Table.Dist = Dist;
                        lcData{Ibatch}.Table.NonSingleStar = NonSingleStar;
                        lcData{Ibatch}.Table.Neighbors = Neighbors;
                        %lcData{Ibatch}.VisitID = sprintf('# %i/%i',Ibatch,length(batch));
                        
                        matches = regexp(Identifiers{2},'Gaia DR3 (\d+)', 'tokens');
                        if ~isempty(matches)
                            designation_id = matches{1}{1}; 
                        else
                            designation_id = '';
                        end
                        lcData{Ibatch}.Table.designation_id = designation_id;
                     
                        if length(Identifiers{2}) > 4 && length(Identifiers{1}) > 4
                        
                                if sum(Identifiers{1}(1:8) == Identifiers{2}(1:8)) == 8
                                    lcData{Ibatch}.Table.Identifiers.Gaia = Identifiers{2};
                                    lcData{Ibatch}.Table.Identifiers.First = Identifiers{2};
                                else
                                    lcData{Ibatch}.Table.Identifiers.First = Identifiers{1};
                                    lcData{Ibatch}.Table.Identifiers.Gaia = Identifiers{2};
                                end

                        else
                            lcData{Ibatch}.Table.Identifiers.First = Identifiers{1};
                            lcData{Ibatch}.Table.Identifiers.Gaia = Identifiers{2};


                        end
                       if ~isempty(res.detection1.events) || ~isempty(res.detection2.events)
                                                a = 2;
                       end
                        lcData{Ibatch}.Table.SimbadLink = sprintf('http://simbad.u-strasbg.fr/simbad/sim-coo?Coord=%f+%f&Radius=%f&Radius.unit=arcsec&output.format=ASCII', wdTable.Dec, wdTable.RA, 4);
                        res.detection1.lcStdWithoutEvent1 =0;
                            res.detection1.lcMedWithoutEvent1 = 0;
                            res.detection1.EventDepth1 =  0;
                             res.detection2.lcStdWithoutEvent2 =0;
                            res.detection2.lcMedWithoutEvent2 = 0;
                            %depth = 
                            res.detection2.EventDepth2 = 0;
                              res.detection1flux.lcStdWithoutEvent1flux =0;
                            res.detection1flux.lcMedWithoutEvent1flux = 0;
                            %depth = 
                            res.detection1flux.EventDepth1flux = 0;
                            
                            res.detection2flux.lcStdWithoutEvent2flux = 0;
                            res.detection2flux.lcMedWithoutEvent2flux = 0;
                            %depth = 
                            res.detection2flux.EventDepth2flux =  0;

                        %% try to create here beacuse cannot create in insert
                        mask = true(size(lcData{Ibatch}.lc));
                        if ~isempty(res.detection1.events)
                            mask1 = mask;
                            mask1(res.detection1.events) = false;
                            
                            lcWithoutEvent1 = lcData{Ibatch}.lc(mask1);
                    
                    
                            res.detection1.lcStdWithoutEvent1 = std(lcWithoutEvent1,'omitnan');
                            res.detection1.lcMedWithoutEvent1 = median(lcWithoutEvent1,'omitnan');
                  
                            res.detection1.EventDepth1 =  max(lcData{Ibatch}.lc(~mask1)) - res.detection1.lcMedWithoutEvent1;
                            
                        end
                        mask2 = true(size(lcData{Ibatch}.lc));
                        
                        if ~isempty(res.detection2.events)
                           
                            mask = mask2;
                            mask(res.detection2.events) = false;
                          
                            lcWithoutEvent2 = lcData{Ibatch}.lc(mask);
                    
                    
                            res.detection2.lcStdWithoutEvent2 = std(lcWithoutEvent2,'omitnan');
                            res.detection2.lcMedWithoutEvent2 = median(lcWithoutEvent2,'omitnan');
                            %depth = 
                            res.detection2.EventDepth2 =  max(lcData{Ibatch}.lc(~mask)) - res.detection2.lcMedWithoutEvent2;
                            
                        end
                        mask3 = true(size(lcData{Ibatch}.lc));
                        if ~isempty(res.detection1flux.events)
                                  
                            mask = mask3;
                            mask(res.detection1flux.events) = false;
                          
                            lcWithoutEvent1flux = lcData{Ibatch}.relFlux(mask);
                    
                    
                            res.detection1flux.lcStdWithoutEvent1flux = std(lcWithoutEvent1flux,'omitnan');
                            res.detection1flux.lcMedWithoutEvent1flux = median(lcWithoutEvent1flux,'omitnan');
                            %depth = 
                            res.detection1flux.EventDepth1flux =  min(lcData{Ibatch}.relFlux(~mask)) - res.detection1flux.lcMedWithoutEvent1flux;
                            
                        
                        end
                        mask4 = true(size(lcData{Ibatch}.lc));
                        if ~isempty(res.detection2flux.events)
                            
                            mask = mask4;
                            mask(res.detection2flux.events) = false;
                          
                            lcWithoutEvent2flux = lcData{Ibatch}.relFlux(mask);
                    
                    
                            res.detection2flux.lcStdWithoutEvent2flux = std(lcWithoutEvent2flux,'omitnan');
                            res.detection2flux.lcMedWithoutEvent2flux = median(lcWithoutEvent2flux,'omitnan');
                            %depth = 
                            res.detection2flux.EventDepth2flux =  min(lcData{Ibatch}.relFlux(~mask)) - res.detection2flux.lcMedWithoutEvent2flux;

                        
                        end

                            results = res;
                            res.Detected = ~isempty(results.detection1.events) || ~isempty(results.detection2.events);
                            res.FluxDetected = ~isempty(results.detection1flux.events) || ~isempty(results.detection2flux.events);
                            res.Methods = [~isempty(results.detection1.events), ~isempty(results.detection2.events)];
                            res.FluxMethods = [~isempty(results.detection1flux.events), ~isempty(results.detection2flux.events)];
    
                        

                  end
end