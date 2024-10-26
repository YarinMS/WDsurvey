function processObservingNight2(mount, telescope, year, month, day, batchSize,args)
    % Main Template for Forced Photometry Routine for LAST
    % Inputs:
    % mount - mount number (e.g., 1, 2, 3, ...)
    % telescope - telescope number (e.g., 1, 2, 3, 4, ...)
    % year, month, day - observation date
    % batchSize - number of visits per batch for processing
    % Author: Yarin Shani
    % Date: 2024-10-20

    arguments
        mount
        telescope
        year
        month
        day
        batchSize
        args.saveDir = '~/Documents/Temp/WD_survey/';

    end

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
        
        %% Categorize FITS and HDF5 Files y CropID
        cropIdsFits = regexp(fitsFilesBatch, '_\d{3}_\d{3}_(\d{3})_sci_proc', 'tokens', 'once');
        cropIdsFits = cellfun(@(x) x{1}, cropIdsFits, 'UniformOutput', false);
        uniqueCropIdsFits = unique(cropIdsFits);

        cropIdsHdf5 = regexp(hdf5FilesBatch, '_\d{3}_\d{3}_(\d{3})_sci_merged', 'tokens', 'once');
        cropIdsHdf5 = cellfun(@(x) x{1}, cropIdsHdf5, 'UniformOutput', false);
        uniqueCropIdsHdf5 = unique(cropIdsHdf5);
        
        nightData = struct;
        %% Iterate Over Subframes
        for cropId = uniqueCropIdsFits'
            args.CropID = cropId;
            subframeFitsFiles   = fitsFilesBatch(strcmp(cropIdsFits, cropId));
            subframeHdf5File    = hdf5FilesBatch(strcmp(cropIdsHdf5, cropId));
            subframeFitsNames   = fitsFilesNames(strcmp(cropIdsFits, cropId));
            subframeHdf5Names   = hdf5FilesNames(strcmp(cropIdsHdf5, cropId));
            subframeFitsFolders = fitsFilesFolders(strcmp(cropIdsFits, cropId));
            subframeHdf5Folders = hdf5FilesFolders(strcmp(cropIdsHdf5, cropId));
            
          
            
            
            % Process catlaog data 
            MS = createMSlist(str2double(cropId),subframeHdf5Names,subframeHdf5Folders);
            args.FileName = MS(1).FileName;
            args.runMeanFilterArgs = {'Threshold', 6, 'StdFun', 'OutWin'};
                % # cleanMS
                    % # Detect in MS - All good sources use 2 detection methods. + be able to gather all the data you need. 
                        % # Look for WDs in results
            

            %% Query Sources in Field
            % get coords of first image (from header)
            [RA,Dec,fieldCoords,AI] = getMScoords(subframeFitsFiles{1});
            % Use catsHTM to query sources within rectangular region (modify catsHTM for rectangular search)
            
            wdSources = querySourcesRectangle(RA,Dec,fieldCoords);

            %% Create Image visit Batch 
            FPAI = generateFPImg(cropId,subframeFitsFolders,subframeFitsNames);
            % Store in args.
            args.LimMag = arrayfun(@(x) x.Key.LIMMAG, FPAI)';
            args.airmass = arrayfun(@(x) x.Key.AIRMASS, FPAI)';
            args.catJD = arrayfun(@(x) x.Key.JD, FPAI)';
            args.FWHM = arrayfun(@(x) x.Key.FWHM, FPAI)';

            
            
            %% Good sources Logic
            msAll = getGoodSources(MS,args);

            % Detect all
            args.reportFN = sprintf('Variable_candidates_LAST.01.%02d.%02d_%04d%02d%02d_batch_%i_%s.pdf',mount,telescope,year,month,day,b,cropId{1});

            [Cand,WDcand, FlagComb, ReportFile] = findVariableCandidates(msAll,'Plot',true,'Report',true,'args',args);

            if ~isempty(Cand)

                % Consider WD candidates.
                Implemenrt=1 ;


                % conside WD photometry candidates. 
            

                % Summarize
            end

            
            
            
            % Specifically consider WDs
            %% WD sources + FP logic

                

            processWdSources(wdSources, FPAI, MS, batchSize, args.saveDir,args)
                
            
        
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

function [RA,Dec,fieldCoords,AI] = getMScoords(subframeFitsFile)

    AI = AstroImage(subframeFitsFile);
    raMin  = min([ AI.Key.RAU1;AI.Key.RAU2;AI.Key.RAU3;AI.Key.RAU4]);
    raMax  = max([ AI.Key.RAU1;AI.Key.RAU2;AI.Key.RAU3;AI.Key.RAU4]);
    decMin = min([ AI.Key.DECU1;AI.Key.DECU2;AI.Key.DECU3;AI.Key.DECU4]);
    decMax = max([ AI.Key.DECU1;AI.Key.DECU2;AI.Key.DECU3;AI.Key.DECU4]);
    RA     = raMin + abs(raMin-raMax)/2;    
    Dec    = decMin + abs(decMax - decMin)/2;

    fieldCoords.raMin = raMin;
    fieldCoords.raMax =  raMax;
    fieldCoords.decMin = decMin;
    fieldCoords.decMax = decMax;

end



function sources = querySourcesRectangle(ra, dec, fieldCoords)
    
     RAD = pi/180;
    % Modify catsHTM or use AstroPack for source extraction
     PWD = pwd;
     cd('~/marvin/catsHTM/WD/WDEDR3/')
     Width = abs(fieldCoords.raMax - fieldCoords.raMin);
     Height = abs(fieldCoords.decMax - fieldCoords.decMin);

     coneSearchRadius = sqrt(Width^2+Height^2)/2 +0.01; % in Deg
     WDS  = catsHTM.cone_search('WDEDR3',ra.*RAD, dec.*RAD, 3600*coneSearchRadius, 'OutType','AstroCatalog');
                

    % Filter the WDS table to keep sources within the defined coordinates
    wdTable = WDS.Table;
    wdTable.RA = wdTable.RA*1./RAD;
    wdTable.Dec = wdTable.Dec*1./RAD;
    withinRaRange = (wdTable.RA >= fieldCoords.raMin) & (wdTable.RA <= fieldCoords.raMax);
    withinDecRange = (wdTable.Dec >= fieldCoords.decMin) & (wdTable.Dec <= fieldCoords.decMax);
    withinMagRange = wdTable.BPmag < 19.6;
    filteredTable = wdTable(withinRaRange & withinDecRange & withinMagRange, :);

    sources = filteredTable;
    
    cd(PWD)

end

function AI = generateFPImg(cropID,subframeFitsFolders,subframeFitsNames)
PWD = pwd;
uniqueVisits = unique(subframeFitsFolders);
AI = [];
for Ivis = 1 : length(uniqueVisits)

    cd(uniqueVisits{Ivis})
    fitsFiles = dir(fullfile(uniqueVisits{Ivis}, sprintf('*%s_sci_proc_Image_1.fits',cropID{1})));
    

        fn    = FileNames.generateFromFileName({fitsFiles.name});
  
        AI = [AI AstroImage.readFileNamesObj(fn)];
end
cd(PWD)
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

function [FP,results,lcData] = applyFP(AI,wdTable,Iwd)
    ra  = wdTable.RA(Iwd);
    dec = wdTable.Dec(Iwd);


    FP = imProc.sources.forcedPhot(AI, 'Coo', [ra, dec], ...
'ColNames', {'RA', 'Dec', 'X', 'Y', 'Xstart', 'Ystart', 'Chi2dof', 'FLUX_PSF', 'FLUXERR_PSF', 'MAG_PSF', 'MAGERR_PSF', 'BACK_ANNULUS', 'STD_ANNULUS', 'FLUX_APER', 'FLAG_POS', 'FLAGS'});
    
    limMag = arrayfun(@(x) x.Key.LIMMAG, AI)';
    airmass = arrayfun(@(x) x.Key.AIRMASS, AI)';
    JD = arrayfun(@(x) x.Key.JD, AI)';
    FWHM = arrayfun(@(x) x.Key.FWHM, AI)';

    mms = FP.setBadPhotToNan('BadFlags', {'Saturated', 'Negative', 'NaN', 'Spike', 'Hole', 'NearEdge'}, 'MagField', 'MAG_PSF', 'CreateNewObj', true);
    r = lcUtil.zp_meddiff(mms, 'MagField', {'MAG_PSF'}, 'MagErrField', {'MAGERR_PSF'});
    [ms, ~] = applyZP(mms, r.FitZP, 'ApplyToMagField', {'MAG_PSF'});
    NdetGood = sum(~isnan(ms.Data.MAG_PSF), 1);
    Fndet = NdetGood > ms.Nepoch - 4;
    Fndet(1) = 1;
    ms = ms.selectBySrcIndex(Fndet, 'CreateNewObj', false);
    lcData.lc = ms.Data.MAG_PSF(:,1);
    lcData.JD = ms.JD;
    
    lcData.limMag = limMag;
    lcData.catJD = JD;
    lcData.Airmass = airmass;

    lcData.FWHM = FWHM;
    lcData.Table.Airmass = median(airmass,'omitnan');
    lcData.Table.fwhm  = median(FWHM,'omitnan');
    lcData.Table.RA = ra;
    lcData.Table.Dec = dec;
    lcData.Table.Gmag = wdTable.Gmag(Iwd);
    [~, fname, ~] = fileparts(AI(1).Key.FILENAME);
    part = strsplit(fname, '_');
    lcData.Tel = part{1};
    lcData.Date = part{2};
    lcData.Ctrl = WDtransits3.getCloseControl(ms, 1, {}, ra, dec);
    enssembeleLC = lcData.Ctrl.medLc;
    deltaMag = lcData.lc - enssembeleLC;
    relFlux = 10.^(-0.4 * deltaMag);
    lcData.relFlux = relFlux / median(relFlux, 'omitnan');
    lcData.typicalSD = std(lcData.lc, 'omitnan');
    lcData.typScatter = std(lcData.relFlux, 'omitnan');
    lcData.nanIndices = isnan(lcData.lc);
    args.Ndet = sum(~isnan(lcData.lc));
    args.Nvisits = 100000;
    args.runMeanFilterArgs = {'Threshold', 6, 'StdFun', 'OutWin'};
    results = WDtransits3.detectTransits(lcData, args);

    
    results.res.Detected = ~isempty(results.detection1.events) || ~isempty(results.detection2.events);
    results.res.FluxDetected = ~isempty(results.detection1flux.events) || ~isempty(results.detection2flux.events);
    results.res.Methods = [~isempty(results.detection1.events), ~isempty(results.detection2.events)];
    results.res.FluxMethods = [~isempty(results.detection1flux.events), ~isempty(results.detection2flux.events)];
    
   % figure()
   % WDtransits3.plotLightCurve({results}, 1, 1, lcData, results.res.Methods, lcData.relFlux, results.res.FluxMethods);


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
                    
args.BadFlags = {'Saturated', 'Negative', 'NaN', 'Spike', 'Hole', 'NearEdge'};
[mms,nanIdx] =  cleanMatchedSources3(ms, args);




end



%% Clean MS


function mms = getGoodSources(MS,args)

    args.BadFlags = {'Saturated', 'Negative', 'NaN', 'Spike', 'Hole', 'NearEdge'};
    mms =  cleanBadSources(MS,args);

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






%% Function to change


 function [results,lcData] = detectInMS(groupedMS,Table,outputDir,WDtable)
 

           args = struct(...
            'MagField', {{'MAG_PSF'}}, ...
            'MagErrField', {{'MAGERR_PSF'}}, ...
            'BadFlags', {{'Saturated', 'Negative', 'NaN', 'Spike', 'Hole', 'NearEdge'}}, ...
            'EdgeFlags', {{'Overlap'}}, ...
            'runMeanFilterArgs', {{'Threshold', 5, 'StdFun', 'OutWin'}}, ...
            'Nvisits', 2, ...
            'Ndet', 16*2 ...
        );
           lcData  = cell(0);
           batch = groupedMS;
    

    for Ibatch = 1 : length(batch)

                    
                        % Look for source in batch:
                        Src = batch{Ibatch}.coneSearch(Table.RA,Table.Dec);
                        IndValues = {Src.Ind};

                        % Check for non-empty 'Ind' values
                        firstNonEmptyInd = find(cellfun(@(x) ~isempty(x), IndValues), 1);

                        % Analyze the result
                        if ~isempty(firstNonEmptyInd)
                            args.mergeBy = firstNonEmptyInd;
                        else
                           
                            disp('Ind is empty for all elements.');
                            continue;
                        end
                        
                        

                    args.catJD =catJD ; args.LimMag = LimMag;

                    

                    [mms,nanIdx] =  cleanMatchedSources1(batch{Ibatch}, args);
                    lcData{Ibatch}.limMag = LimMag;
                    lcData{Ibatch}.catJD = catJD;
                    %mms.coneSearch(Table.RA,Table.Dec).Ind
                    lcData{Ibatch} = WDtransits3.extractLightCurve(lcData{Ibatch}, mms,  Table.RA,Table.Dec,args);
                    
                    %lcData{Ibatch} = WDtransits3.handleNaNValues(lcData{Ibatch},mms, mms.Nepoch);
                    [~,fname,~] = fileparts(batch{Ibatch}(Ivis).FileName);
                    part = strsplit(fname,'_');
                    lcData{Ibatch}.Tel = part{1};
                    lcData{Ibatch}.Date = part{2};
                    lcData{Ibatch}.Table.FWHM = FWHM;
                    lcData{Ibatch}.Table.Airmass = AM;
                    lcData{Ibatch}.Table.visTable = Table;
                    lcData{Ibatch}.Table.FieldID  = Table.FieldID;
                    lcData{Ibatch}.Table.fwhm    = median(FWHM,'omitnan');
                    lcData{Ibatch}.Table.airmass = median(AM,'omitnan');
                    lcData{Ibatch}.Table.RA = Table.RA;
                    lcData{Ibatch}.Table.Dec = Table.Dec;
                    lcData{Ibatch}.Table.Gmag = WDtable.Gmag;
                    lcData{Ibatch}.Table.BPmag = WDtable.BPmag;
                    lcData{Ibatch}.Table.BpRp = WDtable.BPmag - WDtable.RPmag;
                    lcData{Ibatch}.Table.Pwd = WDtable.Pwd;
                    lcData{Ibatch}.Table.AbsMag= WDtable.Gmag - (5.*log10(1000./WDtable.Plx)-5);
                    lcData{Ibatch}.Table.Total_Visits = Table.Nvisits;
                    lcData{Ibatch}.Table.Visits_Found= length(batch) ;
                    lcData{Ibatch}.Table.Subframe = Table.CropID;
                    lcData{Ibatch}.Table.Name = Table.Name;
                    


                   % NO TABLE FOR NOW lcData{Iwd,Ibatch}.Table = table(Iwd,:);



                     % if sum lcData{Iwd,Ibatch}.nanIndinces > 1
                     % find pattern in more source in mms



%                    lcData{Iwd,Ibatch} = transitSearch.handleNaNValues(lcData, numel(catJD));
         
                  if isfield(lcData{Ibatch},'Res')
                      % find how many detections you had of this target TBD
                      % in the future
                        a = 1;

                  else
                        %Nnans =  sum(nanIdx);
                        lcData{Ibatch}.nanIndices = nanIdx(:,lcData{Ibatch}.Ind);
                        results{Ibatch}  = WDtransits3.detectTransits(lcData{Ibatch}, args);
                        res.detection1 = results{Ibatch}.detection1;
                        res.detection1flux = results{Ibatch}.detection1flux;
                        res.detection2 = results{Ibatch}.detection2;
                        res.detection2flux = results{Ibatch}.detection2flux;

                        [AbsMag, Plx, Dist, NonSingleStar, Neighbors, Identifiers] = getWDParams(Table.RA, Table.Dec);
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
                        lcData{Ibatch}.Table.WDtable = WDtable;
                        %lcData{Ibatch}.Table.AbsMag = AbsMag;
                        lcData{Ibatch}.Table.Plx = Plx;
                        lcData{Ibatch}.Table.Dist = Dist;
                        lcData{Ibatch}.Table.NonSingleStar = NonSingleStar;
                        lcData{Ibatch}.Table.Neighbors = Neighbors;
                        lcData{Ibatch}.VisitID = sprintf('# %i/%i',Ibatch,length(batch));
                        
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
                        lcData{Ibatch}.Table.SimbadLink = sprintf('http://simbad.u-strasbg.fr/simbad/sim-coo?Coord=%f+%f&Radius=%f&Radius.unit=arcsec&output.format=ASCII', Table.Dec, Table.RA, 4);
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


                        %insertLCDataToDB6(lcData{Ibatch}, res, 'LAST_WDs20.db') % outputDir = '/Users/yarinms/Documents/Data/6thRun';
                      
                        WDtransits3.plotDetectionResults(results, 1, Ibatch, args, true, outputDir)
                
                        a = 2; 
                  end

                   


                         
    
    
    end

   end






function processWdSources(wdSources, FPAI, MS, batchSize, saveDir,args)
    % Function to process WD sources and perform forced photometry, catalog comparison, and plotting
    % Inputs:
    %   wdSources  - Table of WD sources to process, containing RA and Dec columns
    %   FPAI       - Forced Photometry Analysis Input
    %   MS         - Catalog or observation data for comparison
    %   batchSize  - Number of visits (used in args.Nvisits)
    %   saveDir    - Directory to save plots and data (optional)
    
    % Set up the directory to save outputs
    if nargin < 5 || isempty(saveDir)
        saveDir = '~/Projects/WD_Transits/Results/';
    end
    if ~exist(saveDir, 'dir')
        mkdir(saveDir);
    end
    
    % Loop over each WD source
    for Iwd = 1 : height(wdSources)
        %% Perform Forced Photometry
        [FP, results, lcData] = applyFP(FPAI, wdSources, Iwd);
        args.Nvisits = batchSize;
        
        %% Compare to catalogs
        [mms, nanIdx] = searchNclean(MS, wdSources(Iwd,:), args);
        
        if ~isempty(mms)
            args.nanIdx = nanIdx;
            [lcDataCat, resCat] = getCatLC(mms, wdSources(Iwd,:), args);
            
            if ~isempty(resCat)
                % Check if we need to plot both light curves
                if any(results.res.Methods == 1) || any(results.res.FluxMethods == 1) || ...
                   any(resCat.Methods == 1) || any(resCat.FluxMethods == 1)
                    
                    % Plot both light curves and save
                    plotAndSaveLightCurves(results, lcData, resCat, lcDataCat, saveDir, wdSources, Iwd);
                end
            end
            
        else
            % No catalog match: plot only the source's light curve
            if any(results.res.Methods == 1) || any(results.res.FluxMethods == 1)
                plotAndSaveSingleLightCurve(results, lcData, saveDir, wdSources, Iwd);
            end
        end
    end
end

% ---------- Helper Functions -----------

function plotAndSaveLightCurves(results, lcData, resCat, lcDataCat, saveDir, wdSources, Iwd)
    % Helper function to plot two light curves on top of each other and save them
    
    % Create a new figure
    figure();
    
    % Plot the first light curve (results)
    WDtransits3.plotLightCurve({results}, 1, 1, lcData, results.res.Methods, lcData.relFlux, results.res.FluxMethods);
    hold on;
    
    % Plot the catalog light curve
    plotLightCurveSpec({resCat}, 1, 1, lcDataCat{1}, resCat.Methods, lcDataCat{1}.relFlux, resCat.FluxMethods);
    hold off;
    axis tight;
    % Retrieve RA and Dec for naming purposes
    RA = wdSources.RA(Iwd);
    Dec = wdSources.Dec(Iwd);
    
    % Generate filename with RA and Dec in the name
    filename = sprintf('%sRA_%.6f_Dec_%.6f_Observation_%d_LC.png', saveDir, RA, Dec, Iwd);
    
    % Save the figure
    saveas(gcf, filename);
    
    % Save relevant data as .mat file
    dataFile = sprintf('%sRA_%.6f_Dec_%.6f_Observation_%d_Info.mat', saveDir, RA, Dec, Iwd);
    save(dataFile, 'results', 'lcData', 'resCat', 'lcDataCat');
end

function plotAndSaveSingleLightCurve(results, lcData, saveDir, wdSources, Iwd)
    % Helper function to plot a single light curve and save it
    
    % Create a new figure
    figure();
    
    % Plot the light curve
    WDtransits3.plotLightCurve({results}, 1, 1, lcData, results.res.Methods, lcData.relFlux, results.res.FluxMethods);
    axis tight;
    % Retrieve RA and Dec for naming purposes
    RA = wdSources.RA(Iwd);
    Dec = wdSources.Dec(Iwd);
    
    % Generate filename with RA and Dec in the name
    filename = sprintf('%sRA_%.6f_Dec_%.6f_Observation_%d_LC_NoCat.png', saveDir, RA, Dec, Iwd);
    
    % Save the figure
    saveas(gcf, filename);
    
    % Save relevant data as .mat file
    dataFile = sprintf('%sRA_%.6f_Dec_%.6f_Observation_%d_NoCat_Info.mat', saveDir, RA, Dec, Iwd);
    save(dataFile, 'results', 'lcData');
end
function finalizeReport()
    % Finalize and close the report once all sections have been appended
    persistent Rpt ch1 reportInitialized;
    
    if reportInitialized
        append(Rpt, ch1);  % Append chapter to the report
        close(Rpt);  % Close and save the report
        disp('PDF Report finalized and saved.');
        
        % Clear persistent variables
        reportInitialized = [];
        Rpt = [];
        ch1 = [];
    end
end