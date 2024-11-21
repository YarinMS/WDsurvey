%% 
function stackedWDtable = WDmainLAST(mount, telescope, year, month, day, batchSize,args)

% Create path
 arguments
        mount
        telescope
        year
        month
        day
        batchSize
        args.saveDir = '~/Documents/test3/WD_LC';
        args.runMeanFilterArgs = {'Threshold', 5, 'StdFun', 'OutWin'};
        args.BadFlags = {'Saturated', 'Negative', 'NaN', 'Spike', 'Hole', 'NearEdge'};
        args.PlotNSave = true;
 end
    
    %% Default parameters
    set(0, 'DefaultFigureWindowStyle', 'docked');
    set(0, 'DefaultTextInterpreter', 'latex');
    set(0, 'DefaultAxesTickLabelInterpreter', 'latex');
    set(0, 'DefaultLegendInterpreter', 'latex');
    
    

    %% Setup Paths

    if telescope < 3 
      computer = sprintf('last%02de',mount);
    else
      computer = sprintf('last%02dw',mount);
    end
    
   args.Tel  = sprintf('LAST.01.%02d.%02d',mount,telescope)
   args.Date = sprintf('%i - %i - %i',year,month,day) 

    
    if mod(telescope, 2) == 0
      
        basePath = sprintf('/%s/data2/archive/LAST.01.%02d.%02d/', computer, mount,telescope);
   %basePath  = sprintf('~/marvin/LAST.01.%02d.%02d/', mount,telescope);
    else
   
        
        basePath = sprintf('/%s/data1/archive/LAST.01.%02d.%02d/', computer, mount,telescope);
   %     basePath = sprintf('~/marvin/LAST.01.%02d.%02d/', mount,telescope);
    end
    
    dateFolder = sprintf('%04d/%02d/%02d/proc/', year, month, day);
    fullPath = fullfile(basePath, dateFolder);

     

    if ~exist(args.saveDir, 'dir')
        mkdir(args.saveDir);
    end
    % Group visits for different fields. 
    %% Load Visit Directories, Sort consecutively and create batch Visits for Processing
     [batches,Fields] = organizeBatchesWfields(fullPath, batchSize);
   
    allFieldIDs = vertcat(Fields{:});
    [uniqueFields,~,NewIdx]  = unique(allFieldIDs);
    Nfields = length(uniqueFields);
    mainTable = {};

    % For each field, get WDs in field.
    for Ifield = 1: Nfields

       Batches =  batches(NewIdx == Ifield);
       totalVisits = sum(cellfun(@numel, Batches));
       B = Batches{1};
       catFiles = dir(fullfile(B(1).folder,B(1).name,'*001_001_*_sci_proc_Cat_1.fits'));
       % Intilize WD table
        % Initialize an empty table to store combined results
        combinedWdSources = table();
        
        % Iterate over each subframe (1 to 24)
        for subframeIdx = 1:length(catFiles)
            % Get the current subframe file
            catFilePath = fullfile(catFiles(subframeIdx).folder, catFiles(subframeIdx).name);
            % Make sure you take the correct CropID
            pattern = '_\d{3}_\d{3}_(\d{3})_sci_proc';
            tokens = regexp(catFiles(subframeIdx).name, pattern, 'tokens', 'once');
            cropIDs = str2double(tokens{1});

            
            % Extract RA, Dec, and field coordinates for the current subframe
            [subframeRA, subframeDec, fieldCoordsSF] = getMScoordsFromCat(catFilePath);
            
            % Find white dwarfs within this subframe's coordinates
            wdSources = findWhiteDwarfsL(subframeRA, subframeDec, fieldCoordsSF);
            
            % Check if the result is non-empty
            if ~isempty(wdSources)
                % Add subframe (crop) ID and field ID columns
                wdSources.CropID = repmat(cropIDs, height(wdSources), 1);  % Add crop ID (subframe index)
                wdSources.FieldID = repmat(string(uniqueFields(Ifield)), height(wdSources), 1);  % Add field ID as a string
                wdSources.catDetected = repmat(false,height(wdSources),1);
                wdSources.forcedDetected = repmat(false,height(wdSources),1);
                wdSources.Nvisits = repmat(totalVisits,height(wdSources),1);
                wdSources.BatchSize = repmat(batchSize,height(wdSources),1);
                wdSources.Nbatch = repmat(length(Batches),height(wdSources),1);
                wdSources.catBatchDetections = repmat(0,height(wdSources),1);
                wdSources.forcedBatchDetections = repmat(0,height(wdSources),1);
                wdSources.Nevents = repmat(0,height(wdSources),1);
                wdSources.NeventsF = repmat(0,height(wdSources),1);
                wdSources.DB = repmat(0,height(wdSources),length(Batches)) ;
                % Append to the combined table
                combinedWdSources = [combinedWdSources; wdSources];
            end
        end


        % Find unique rows based on 'RA' and 'Dec' columns
       % [uniqueRows, uniqueIdx] = unique(combinedWdSources(:, {'RA', 'Dec'}), 'rows');
        
        % Use the unique indices to get the rows without duplicates
        WDtable = combinedWdSources;
        WDtable.BatchData = cell(height(WDtable), 1); 
        WDtable.BatchDataF = cell(height(WDtable), 1); 
        
        % Helper function to check if events are detected
        isEventDetected = @(events) ~isempty(events);

        
        


 

        %% Iterate over batches of the same field.

        for b = 1 : length(Batches)

       
            Batch = Batches{b};
            % Analyze every frame of WDs.
            for cropID = 1:24

                cropWDs = find(WDtable.CropID == cropID);
                
                if isempty(cropWDs) 
                    continue;
                end


                %% Extract subframe products for the entire batch: 
                [catFP_all, MS_FP_all, imageFP_all] = arrayfun(@(dirInfo) extractPipelineProducts(dirInfo, cropID), Batch, 'UniformOutput', false);
                catFP = vertcat(catFP_all{:});
                MSfiles = vertcat(MS_FP_all{:});
                imagesFP = vertcat(imageFP_all{:});

                %% get observation data
                % Initialize AH and observation data structure
                AH           = AstroHeader(catFP,3); 
                obsData      = extractObservationData(AH);
                args.LimMag  = obsData.LimMag;
                args.catJD   = obsData.catJD;
                args.Nvisits = batchSize;

                %% Create MS obj
                List.FileName = {MSfiles.name};
                List.Folder   = {MSfiles.folder};
                List.CropID   = cropID;
                if ~isempty(List.FileName)
                    MS = MatchedSources.readList(List);
                else
                    MS =[]
                end

                %% analyaze WDs

                for Iwd = 1:numel(cropWDs)
                    fprintf('\nIwd = %i / %i (%i total) ; cropID =%i, batch = %i / %i \n',Iwd, numel(cropWDs),height(WDtable),cropID,b,length(batches))
                    WD = WDtable(cropWDs(Iwd), :);
                    WD = pmProp(WD, 'Date', obsData.catJD(1));
                    WDtable = pmProp(WDtable, 'Date',obsData.catJD(1));
                    
                    
                    batchData  = {};
                    batchDataF = {};

                    %% FP if exist
                    if ~isempty(imagesFP)
                        
                        % Get mask and PSF files.
                        maskFP = cellfun(@(x) strrep(x, 'Image', 'Mask'), imagesFP, 'UniformOutput', false);
                        psfFP  = cellfun(@(x) strrep(x, 'Image', 'PSF'), imagesFP, 'UniformOutput', false);


                        AI = AstroImage(imagesFP,'Mask',maskFP,'PSF',psfFP);
                        
                        
                        if b ==4
                            tt = 1
                        end
              
                        [FPms,FPresults,lcDataFP] = applyFPlast(AI,WDtable,Iwd,50);
                        
                        if isfield(lcDataFP,'lc')
                            if sum(lcDataFP.limMag-lcDataFP.lc < 0) > 0.3*length(lcDataFP.lc)  

                                batchDataF.ValidPoints = sum(lcDataFP.limMag-lcDataFP.lc > 0);
                                batchDataF.Event   = false;
                                batchDataF.Median  = mean(lcDataFP.lc);
                                batchDataF.StdDev  = std(lcDataFP.lc);
                                batchDataF.lcData  = lcDataFP;
                                batchDataF.Results = FPresults;



                            else
                                % store results

                                batchDataF.TelescopeID = args.Tel;
                                batchDataF.Date   = args.Date;
                                batchDataF.lcData = lcDataFP;
                                batchDataF.Results = FPresults;
                                batchDataF.ValidPoints = sum(lcDataFP.limMag-lcDataFP.lc > 0);
                                eventMetricsF = processDetectedEvents3(FPresults, lcDataFP);
                                batchDataF.eventMetrics = eventMetricsF;

                                if batchDataF.ValidPoints > 0.15*length(lcDataFP.lc)
                                    WD.forcedBatchDetections = WD.forcedBatchDetections +1;
                                    WD.forcedDetected = true;
                                end

                                batchDataF.Detected = isEventDetected(FPresults.detection1.events) || isEventDetected(FPresults.detection2.events);
                                batchDataF.FluxDetected = isEventDetected(FPresults.detection1flux.events) || isEventDetected(FPresults.detection2flux.events);

                                % Methods and FluxMethods arrays indicating which detection types have events
                                batchDataF.Methods = [isEventDetected(FPresults.detection1.events), isEventDetected(FPresults.detection2.events)];
                                batchDataF.FluxMethods = [isEventDetected(FPresults.detection1flux.events), isEventDetected(FPresults.detection2flux.events)];



                                % If detected sum N events
                                    if any(batchDataF.Methods) || any(batchDataF.FluxMethods)


                                        batchDataF.Event = true;
                                        WD.NeventsF = WD.NeventsF + 1;

                                        if args.PlotNSave




                                            lcDataFP.Tel = args.Tel;
                                            lcDataFP.Date = strcat(args.Date,' (FP)');
                                            plotAndSaveSingleLightCurve(FPresults, lcDataFP, args.saveDir, WDtable, Iwd)
                                        end

                                    else
                                        batchDataF.Event = false;

                                    end





                            end
                            
                        else
                               
                            batchDataF.lcData  = lcDataFP;
                            batchDataF.Results = FPresults;
            
                         end
                    end

                    %% Catalogs
                    nodata = false;
                    if ~isempty(MS)
                        

                        [mms, nanIdx] = searchNclean(MS, WD, args);
                        
                    else
                        mms = []
                        nodata =   true;
                        
                    end
                    
                    % Create a structure to hold batch-specific data for this WD
                    
                    
                    % Check if mms is empty, and set default values if needed
                    if isempty(mms) %|| sum(nanIdx) > 0.30*length(nanIdx)

                        batchData.Detected = sum(nanIdx) < 0.80*length(nanIdx);
                        batchData.Contaminated = size(nanIdx, 2) > 1;
                
                        batchData.ValidPoints = length(nanIdx) - sum(nanIdx);
                        batchData.NumNaNs = sum(nanIdx);
                        if nodata
                            BatchData.Data = 'Data dont exist';
                        end
                       
                    else
                        % Detection methods
                        [lcData, results] = getCatLC2(mms, WD, args);
                        % Calculate statistics when mms is non-empty


                        if isfield(lcData,'Res') || sum(nanIdx) > 0.3*length(nanIdx)

                                batchData.ValidPoints = 0;
                                batchData.NumNaNs = 0;
                                batchData.BadFlags = 0;  % Or set based on criteria
                                batchData.Event = false;
                                batchData.Median = NaN;
                                batchData.StdDev = NaN;
                                batchData.RMS = NaN;


                        else
                            
                                batchData.TelescopeID = args.Tel;
                                batchData.Date   = args.Date;
                                batchData.lcData = lcData;
                                batchData.Results = results;
                                batchData.ValidPoints = sum(~isnan(nanIdx));
                                eventMetrics = processDetectedEvents3(results, lcData);
                                batchData.eventMetrics = eventMetrics;
        
                                if batchData.ValidPoints > 0.85*length(lcData.lc)
                                    WD.catBatchDetections = WD.catBatchDetections +1;
                                    WD.catDetected = true;
                                end
                                    
        
                               
        
                                
        
        
                             
                                batchData.Detected = isEventDetected(results.detection1.events) || isEventDetected(results.detection2.events);
                                batchData.FluxDetected = isEventDetected(results.detection1flux.events) || isEventDetected(results.detection2flux.events);
                                
                                % Methods and FluxMethods arrays indicating which detection types have events
                                batchData.Methods = [isEventDetected(results.detection1.events), isEventDetected(results.detection2.events)];
                                batchData.FluxMethods = [isEventDetected(results.detection1flux.events), isEventDetected(results.detection2flux.events)];
                                
                            


                                % If detected sum N events
                                if any(batchData.Methods) || any(batchData.FluxMethods)

                                    eventMetrics = processDetectedEvents3(results, lcData);
                                    batchData.eventMetrics = eventMetrics;
                                    
                                    batchData.Event = true;
                                    WD.Nevents = WD.Nevents + 1;
        
                                    if args.PlotNSave
                                        
                                        results.res.Detected = batchData.Detected ;
                                        results.res.Detected = batchData.FluxDetected ;
                                        
                                       
                                        results.res.Methods = batchData.Methods ;
                                        results.res.FluxMethods = batchData.FluxMethods ;
                                        lcData.Tel = args.Tel;
                                        lcData.Date = args.Date;
                                        plotAndSaveSingleLightCurve(results, lcData, args.saveDir, WD, 1)
                                    end
        
                                else
                                    batchData.Event = false;
        
                                end
                                
                                
                                if isfield(batchDataF,'Methods')
                                    fluxFlag = any(batchDataF.Methods) || any(batchDataF.FluxMethods);
                                    catFlag  = any(batchData.Methods) || any(batchData.FluxMethods);
                                    DetectionFlag = fluxFlag && catFlag;

                                    if DetectionFlag 
                                        
                                        batchData.ResRMS=getRMS2(mms);
                                        batchDataF.ResRMS=getRMS2(FPms);
                                        wdSources.DB(cropWDs(Iwd),b) = 1;
                                        results.res.Detected = batchData.Detected ;
                                        results.res.Detected = batchData.FluxDetected ;


                                        results.Methods =    batchData.Methods ;
                                        results.FluxMethods = batchData.FluxMethods ;
                                        lcData.Tel = args.Tel;
                                        lcData.Date = args.Date;
                                        if args.PlotNSave 
                                            plotAndSaveLightCurves1(FPresults, lcDataFP, results, {lcData}, args.saveDir, WDtable, Iwd);
                                        end
                                    end
                                end

                        end


                        %batchData.BadFlags = sum(args.LimMag < 18);  % Example: Modify this to your flagging criteria
                       % batchData.Event = (batchData.ValidPoints > 10);  % Example criterion for event detection
                        %batchData.Median = median(mms, 'omitnan');  % Sigma-clipped median if necessary
                        %batchData.StdDev = std(mms, 'omitnan');  % Sigma-clipped standard deviation if necessary
                        %batchData.RMS = rms(mms, 'omitnan');  % Root mean square, excluding NaNs
                    end
                    % Add the batch data structure to the BatchData cell array
                    if isempty(WDtable.BatchData{cropWDs(Iwd)})
                        % Initialize as empty array if this is the first entry
                        WDtable.BatchData{cropWDs(Iwd)} = [];
                    end
                    if isempty(WDtable.BatchDataF{cropWDs(Iwd)})
                        % Initialize as empty array if this is the first entry
                        WDtable.BatchDataF{cropWDs(Iwd)} = [];
                    end
                    WDtable(cropWDs(Iwd),:) = WD;
                    WDtable.BatchData{cropWDs(Iwd)} = [ WDtable.BatchData{cropWDs(Iwd)} {batchData}];  % Append the batchData structure
                    WDtable.BatchDataF{cropWDs(Iwd)} = [ WDtable.BatchDataF{cropWDs(Iwd)} {batchDataF}];
                    
                end

                

                



                













            end % end cropID iter

            
            % HDF5 fiiles
            % fits files
            % cat files


            
            %% Extract method A
            [fitsFilesBatch, hdf5FilesBatch, fitsFilesNames, hdf5FilesNames, fitsFilesFolders, hdf5FilesFolders] = extractDataFiles(Batch, Batch(1).folder);
            % Extract CropIDs from FITS and HDF5 file names
            cropIdsFits = regexp(fitsFilesBatch, '_\d{3}_\d{3}_(\d{3})_sci_proc', 'tokens', 'once');
            cropIdsFits = cellfun(@(x) x{1}, cropIdsFits, 'UniformOutput', false);
            uniqueCropIds = unique(cropIdsFits); % Get unique CropIDs
    
            cropIdsHdf5 = regexp(hdf5FilesBatch, '_\d{3}_\d{3}_(\d{3})_sci_merged', 'tokens', 'once');
            cropIdsHdf5 = cellfun(@(x) x{1}, cropIdsHdf5, 'UniformOutput', false);
            uniqueCropIdsHdf5 = unique(cropIdsHdf5);

            %% Extract Method b ?
            
    
           
        
        end



        mainTable{end+1} = WDtable;
    end
  
     stackedWDtable = mainTable; %vertcat(mainTable{:})
  %   plotRMSvsMagnitude(stackedWDtable,args)
   %  plotDetectionEfficiency(stackedWDtable, args)

    % Detection efficenct plots. 

    % create a report ?
    % plot the light curves in the report ?











end



%%



%%



%%






%%



