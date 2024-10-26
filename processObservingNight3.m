function processObservingNight3(mount, telescope, year, month, day, batchSize,args)
    % Main Template for Forced Photometry Routine for LAST
    % Inputs:
    % mount - mount number (e.g., 1, 2, 3, ...)
    % telescope - telescope number (e.g., 1, 2, 3, 4, ...)
    % year, month, day - observation date
    % batchSize - number of visits per batch for processing
    % Author: Yarin Shani
    % Date: 2024-10-20

    % Import MATLAB report generator class:
    

    arguments
        mount
        telescope
        year
        month
        day
        batchSize
        args.saveDir = '~/Documents/Temp/WD_survey/';
        args.runMeanFilterArgs = {'Threshold', 6.5, 'StdFun', 'OutWin'};

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

     
    % Initialize the catalog analysis report
    if ~exist(args.saveDir, 'dir')
        mkdir(args.saveDir);
    end


    catalogReportFile = fullfile(args.saveDir, sprintf('Catalog_Report_%04d_%02d_%02d_Mount%d_1.pdf', year, month, day, mount));
    rptCatalog = initializeReport(catalogReportFile, 'Catalog Analysis Report');
    
    % Initialize the forced photometry report
    fpReportFile = fullfile(args.saveDir, sprintf('Photometry_Report_%04d_%02d_%02d_Mount%d.pdf', year, month, day, mount));
    rptPhotometry = initializeReport(fpReportFile, 'Forced Photometry Report');

    
    %% Load Visit Directories, Sort consecutively and create batch Visits for Processing
     batches = organizeBatches(fullPath, batchSize);



     r = 0;
     h = waitbar(0)
     pos = get(h, 'Position');  % Get current position: [left, bottom, width, height]
     pos(4) = 100;
     pos(3) = 80;
     set(h, 'Position', pos);
     wbCounter = 0;

     for b =1:length(batches)
        batch = batches{b};
        
        % Data extraction for FITS and HDF5 files (from Step 2)
        [fitsFilesBatch, hdf5FilesBatch, fitsFilesNames, hdf5FilesNames, fitsFilesFolders, hdf5FilesFolders] = extractDataFiles(batch, fullPath);
    
        % Extract CropIDs from FITS and HDF5 file names
        cropIdsFits = regexp(fitsFilesBatch, '_\d{3}_\d{3}_(\d{3})_sci_proc', 'tokens', 'once');
        cropIdsFits = cellfun(@(x) x{1}, cropIdsFits, 'UniformOutput', false);
        uniqueCropIds = unique(cropIdsFits); % Get unique CropIDs

        cropIdsHdf5 = regexp(hdf5FilesBatch, '_\d{3}_\d{3}_(\d{3})_sci_merged', 'tokens', 'once');
        cropIdsHdf5 = cellfun(@(x) x{1}, cropIdsHdf5, 'UniformOutput', false);
        uniqueCropIdsHdf5 = unique(cropIdsHdf5);
        
        % Process each CropID individually
        for c =1:length(uniqueCropIds)
            wbCounter = wbCounter +1;
            cropId = uniqueCropIds{c};
            args.CropID = cropId; % Set the CropID for this iteration
    
            % Get FITS and HDF5 files for this specific CropID
            subframeFitsFiles = fitsFilesBatch(strcmp(cropIdsFits, cropId));
            subframeHdf5File = hdf5FilesBatch(strcmp(cropIdsHdf5, cropId));
            subframeFitsNames   = fitsFilesNames(strcmp(cropIdsFits, cropId));
            subframeHdf5Names   = hdf5FilesNames(strcmp(cropIdsHdf5, cropId));
            subframeFitsFolders = fitsFilesFolders(strcmp(cropIdsFits, cropId));
            subframeHdf5Folders = hdf5FilesFolders(strcmp(cropIdsHdf5, cropId));
            
            % Generate forced photometry image input
          %  FPAI = generateFPImg(cropId,subframeFitsFolders,subframeFitsNames);
            FPAI = AstroHeader(subframeFitsFiles);
            
            % Extract relevant photometry data for analysis
            args.LimMag = arrayfun(@(x) x.Key.LIMMAG, FPAI)';
            args.airmass = arrayfun(@(x) x.Key.AIRMASS, FPAI)';
            args.catJD = arrayfun(@(x) x.Key.JD, FPAI)';
            args.FWHM = arrayfun(@(x) x.Key.FWHM, FPAI)';
            % Process catalog data (HDF5 files) for this CropID
            msAll = processCatalogData(cropId, subframeHdf5Names,subframeHdf5Folders,args );
            catalogSection = createChapter(sprintf('Batch %d, Subframe (CropID): %s', b, cropId));
            
            %chapterCatalog = Chapter('Catalog Analysis');
            [Cand, WDcand, FlagComb,resultChapter] = findVariableCandidates3(msAll, 'args',args,'catalogChapter', catalogSection);

            if ~isempty(WDcand) || ~isempty(Cand)
                append(rptCatalog,resultChapter)
                r=r +1;
                % if WD is not empty we want to store its data in the
                % length(WDcand) Ind sources. 
                % forced photometry pdf. 
                % together with its FP light curve.
                if ~isempty(WDcand)
                    

                    
                    append(rptCatalog,resultChapter)

                    
                    % Report WD in sub frame 
                    forcedChapter = createChapter(sprintf('Batch %d, Subframe (CropID): %s', b, cropId));

                    % 2 consec points detecrtio
                    % in report HR di  processWdSourcesagram ? maybe int th
                    FPAI = generateFPImg(cropId,subframeFitsFolders,subframeFitsNames);
                    Nwds = length(WDcand);
                    for Iwd = 1:Nwds
                    
                        wdSources = WDcand{Iwd}.WD.Table;
                        wdSources.RA = WDcand{Iwd}.WD.Table.RA(:).*180/pi;
                        wdSources.Dec = WDcand{Iwd}.WD.Table.Dec(:).*180/pi;
                        
                        appendWDToReport(forcedChapter, wdSources.RA,wdSources.Dec,wdSources);
                        processWdSources(wdSources, FPAI, msAll, batchSize, args.saveDir, args,forcedChapter);
                        
                    
                    
                    end


                    append(rptPhotometry,forcedChapter)

                end
                
                
                waitbar((wbCounter)/(24*length(batches)),h,sprintf('Processing %s/%s\nBatch # %i/%i\nCropID # %i\nTotal Detections : %i\n %i/%i ',fullPath,subframeHdf5Folders{1},b,length(batches),c,r,wbCounter,24*length(batches)))
            end
           
            % Query and find White Dwarfs (WDs) for this CropID
  %          [RA, Dec, fieldCoords, ~] = getMScoords(subframeFitsFiles{1});
 %           wdSources = findWhiteDwarfs(RA, Dec, fieldCoords);
            
            % Further processing can go here, such as processing WD sources
%            processWdSources(wdSources, FPAI, msAll, batchSize, args.saveDir, args);
             %% Report Generation for Catalog and Photometry
            % Catalog report section
            %appendCatalogReport(rptCatalog, msAll, subframeHdf5Names, b, cropId, wdSources);

            % Photometry report section
            %appendPhotometryReport(rptPhotometry, FPAI, subframeFitsNames, b, cropId, RA, Dec, args.saveDir);

        end
     end
     %% Finalize and Save Both Reports
    close(rptCatalog);
    close(rptPhotometry);
    disp(['Catalog report generated: ' catalogReportFile]);
    disp(['Photometry report generated: ' fpReportFile]);


        %% Process Each Batch of Visits
    for b = 1:length(batches)
       
        %% Iterate Over Subframes
        for cropId = uniqueCropIdsFits'
          
            
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

            if ~isempty(WDCand)

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
    fitsFiles = dir(fullfile(uniqueVisits{Ivis}, sprintf('*%s_sci_proc_Image_1.fits',cropID)));
    

        fn    = FileNames.generateFromFileName({fitsFiles.name});
  
        AI = [AI AstroImage.readFileNamesObj(fn)];
end
cd(PWD)
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






function processWdSources(wdSources, FPAI, MS, batchSize, saveDir,args,chapter)
    % Function to process WD sources and perform forced photometry, catalog comparison, and plotting
    % Inputs:
    %   wdSources  - Table of WD sources to process, containing RA and Dec columns
    %   FPAI       - Forced Photometry Analysis Input
    %   MS         - Catalog or observation data for comparison
    %   batchSize  - Number of visits (used in args.Nvisits)
    %   saveDir    - Directory to save plots and data (optional)
    
    % Set up the directory to save outputs
    if nargin < 5 || isempty(saveDir)
        saveDir = '~/Documents/Temp/';
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
            args.FileName = FPAI(1).Key.FILENAME;
            [lcDataCat, resCat] = getCatLC(mms, wdSources(Iwd,:), args);
            
            if ~isempty(resCat)
                % Check if we need to plot both light curves
                if (any(results.res.Methods == 1) || any(results.res.FluxMethods == 1) ) || ...
                    (any(resCat.Methods == 1) || any(resCat.FluxMethods == 1))
                    
                    % Plot both light curves and save
                    plotAndSaveLightCurves(results, lcData, resCat, lcDataCat, saveDir, wdSources, Iwd);
                    AppendLC(results, lcData, resCat, lcDataCat, saveDir, wdSources, Iwd,chapter)
                end
            end
            
        else
            % No catalog match: plot only the source's light curve
            if any(results.res.Methods == 1) || any(results.res.FluxMethods == 1)
                plotAndSaveLightCurves(results, lcData, resCat, lcDataCat, saveDir, wdSources, Iwd);
                AppendLC(results, lcData, resCat, lcDataCat, saveDir, wdSources, Iwd)
                %plotAndSaveSingleLightCurve(results, lcData, saveDir, wdSources, Iwd);
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




%%%%% New edit 

function msAll = processCatalogData(cropId,subframeHdf5Names,subframeHdf5Folders, args)
    % PROCESSCATALOGDATA Processes catalog data from HDF5 files
    % Inputs:
    %   hdf5FilesBatch - List of HDF5 files for the batch
    %   cropId - Crop ID of the subframe to process
    %   args - Configuration and threshold arguments
    % Outputs:
    %   msAll - Matched sources after cleaning and processing
    
    % Create a matched sources object from the HDF5 catalog data
    MS = createMSlist(cropId, subframeHdf5Names,subframeHdf5Folders);

    % Clean the matched sources and get "good" sources
    msAll = getGoodSources(MS, args);
    
    % Apply Zero Point correction if necessary
    msAll = applyZpCorrection(msAll);
end


function [FPAI,args] = getVisImages(cropId,subframeFitsFolders,subframeFitsNames,args)
    % PERFORMFORCEDPHOTOMETRY Performs forced photometry on FITS images
    % Inputs:
    %   fitsFilesBatch - List of FITS files for the batch
    %   cropId - Crop ID of the subframe to process
    %   args - Configuration and photometry parameters
    % Outputs:
    %   FPAI - Forced photometry analysis input (results of the photometry)

    % Generate forced photometry image input (using AstroPack or custom methods)
    FPAI = generateFPImg(cropId,subframeFitsFolders,subframeFitsNames);
    
    % Extract relevant photometry data for analysis
    args.LimMag = arrayfun(@(x) x.Key.LIMMAG, FPAI)';
    args.airmass = arrayfun(@(x) x.Key.AIRMASS, FPAI)';
    args.catJD = arrayfun(@(x) x.Key.JD, FPAI)';
    args.FWHM = arrayfun(@(x) x.Key.FWHM, FPAI)';

    % Expand this section to perform additional photometry analysis
end



function wdSources = findWhiteDwarfs(RA, Dec, fieldCoords)
    % FINDWHITEDWARFS Queries and finds white dwarf candidates in the field
    % Inputs:
    %   RA, Dec - Coordinates of the image field center
    %   fieldCoords - Struct containing boundary coordinates of the field
    % Outputs:
    %   wdSources - Table of potential White Dwarf sources in the field
    
    % Define cone search radius based on field coordinates
    coneSearchRadius = sqrt(abs(fieldCoords.raMax - fieldCoords.raMin)^2 + ...
                            abs(fieldCoords.decMax - fieldCoords.decMin)^2) / 2 + 0.01;

    % Query the WD catalog (using AstroPack's catsHTM or custom method)
    wdSources = catsHTM.cone_search('WDEDR3', RA * pi / 180, Dec * pi / 180, ...
                                    3600 * coneSearchRadius, 'OutType', 'AstroCatalog');

    % Filter the sources by magnitude or other criteria
    wdTable = wdSources.Table;
    wdTable.RA = wdTable.RA / pi * 180;
    wdTable.Dec = wdTable.Dec / pi * 180;
    withinRaRange = (wdTable.RA >= fieldCoords.raMin) & (wdTable.RA <= fieldCoords.raMax);
    withinDecRange = (wdTable.Dec >= fieldCoords.decMin) & (wdTable.Dec <= fieldCoords.decMax);
    withinMagRange = wdTable.BPmag < 19.6;
    
    % Return only White Dwarfs in the field
    wdSources = wdTable(withinRaRange & withinDecRange & withinMagRange, :);
end



%%%%%% Reporting
function chapter = createChapter(chapterName)
import mlreportgen.report.*
import mlreportgen.dom.*


chapter = Chapter(chapterName);

end




function appendPhotometryReport(rptPhotometry, FPAI, subframeFitsNames, batchNum, cropId, RA, Dec, saveDir)
    import mlreportgen.dom.*
    import mlreportgen.report.*

    % Create a new chapter for forced photometry data
    photometrySection = Chapter(sprintf('Batch %d, Subframe (CropID): %s', batchNum, cropId));
    append(photometrySection, Paragraph(sprintf('FITS Files Processed: %s', strjoin(subframeFitsNames, ', '))));

    % Add photometry results if available
    if ~isempty(FPAI)
        append(photometrySection, Paragraph(sprintf('Photometry results for CropID %s:', cropId)));
        % Add more details, e.g., limiting magnitudes, airmass, etc.
    else
        append(photometrySection, Paragraph('No forced photometry data available.'));
    end

    % Append light curve plot (if available)
    imgFile = sprintf('%sRA_%.6f_Dec_%.6f_CropID_%s_LightCurve.png', saveDir, RA, Dec, cropId);
    if exist(imgFile, 'file')
        img = Image(imgFile);
        img.Height = '3in';
        img.Width = '5in';
        append(photometrySection, img);
    end

    % Append the photometry section to the report
    append(rptPhotometry, photometrySection);
end

function appendCatalogReport(rptCatalog, msAll, subframeHdf5Names, batchNum, cropId, wdSources)
    import mlreportgen.dom.*
    import mlreportgen.report.*

    % Create a new chapter for catalog data
    catalogSection = Chapter(sprintf('Batch %d, Subframe (CropID): %s', batchNum, cropId));
    append(catalogSection, Paragraph(sprintf('Catalog Files Processed: %s', strjoin(subframeHdf5Names, ', '))));

    % Add catalog data details (msAll object)
    if ~isempty(msAll)
        append(catalogSection, Paragraph('Matched sources processed:'));
        % Additional details could be added here
    else
        append(catalogSection, Paragraph('No catalog data found.'));
    end

    % Add WD table if WDs were found
    if ~isempty(wdSources)
        wdTable = createWDTable(wdSources);
        append(catalogSection, wdTable);
    else
        append(catalogSection, Paragraph('No White Dwarfs Found.'));
    end

    % Append the catalog section to the report
    append(rptCatalog, catalogSection);
end

function rpt = initializeReport(reportFile, reportTitle)
    import mlreportgen.report.*
    import mlreportgen.dom.*

    rpt = Report(reportFile, 'pdf');
    titlePage = TitlePage;
    titlePage.Title = reportTitle;
    titlePage.Author = 'WD Survey';
    titlePage.PubDate = date;
    append(rpt, titlePage);
    append(rpt, TableOfContents);
end



function wdTable = createWDTable(wdSources)
    import mlreportgen.dom.*

    % Create a table for White Dwarf (WD) sources
    wdTable = Table();
    
    % Define the header row
    headerRow = TableRow();
    append(headerRow, TableEntry('RA [deg]  '));
    append(headerRow, TableEntry('Dec [deg]  '))
    append(headerRow, TableEntry('Gmag  '));
    append(headerRow, TableEntry('BPmag  '));
    append(headerRow, TableEntry('RPmag  '));
    append(headerRow, TableEntry('AbsMag  '));
    append(headerRow, TableEntry('Bp-Rp  '));
    append(headerRow, TableEntry('Parallax [mas]'));
    append(headerRow, TableEntry('Distance [pc]'));
    append(wdTable, headerRow);
    
    % Loop through WD sources and add rows to the table
    for i = 1:height(wdSources)
        wdTableRow = TableRow();
        append(wdTableRow, TableEntry(num2str(wdSources.RA(i))));
        append(wdTableRow, TableEntry(num2str(wdSources.Dec(i))));
        append(wdTableRow, TableEntry(num2str(wdSources.Gmag(i))));
        append(wdTableRow, TableEntry(num2str(wdSources.BPmag(i))));
        append(wdTableRow, TableEntry(num2str(wdSources.RPmag(i))));
        
        append(wdTableRow, TableEntry(num2str(wdSources.Gmag(i)-5*log10(1000/wdSources.Plx(i))+5)));
        append(wdTableRow, TableEntry(num2str(wdSources.BPmag(i)-wdSources.RPmag(i))));
        append(wdTableRow, TableEntry(num2str(wdSources.Plx(i))));
        append(wdTableRow, TableEntry(num2str(1000/wdSources.Plx(i))));
        append(wdTable, wdTableRow);
    end
    
    % Optional: Set table styles (border, alignment, etc.)
    wdTable.Border = 'solid';
    wdTable.ColSep = 'solid';
    wdTable.RowSep = 'solid';
end




function AppendLC(results, lcData, resCat, lcDataCat, saveDir, wdSources, Iwd,chapter)
    % Helper function to plot two light curves on top of each other and save them
    import mlreportgen.dom.*
    import mlreportgen.report.*
    % Create a new figure
    figure('Visible','off');
    
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
    

    % Insert figure

    fig = Figure(gcf);
    fig.Snapshot.Height = '5in';
    fig.Snapshot.Width = '7in';
    append(chapter, fig);

    pageBreak = PageBreak();
    append(chapter, pageBreak);
    


    % Insert simbad link





    % Generate filename with RA and Dec in the name
    %filename = sprintf('%sRA_%.6f_Dec_%.6f_Observation_%d_LC.png', saveDir, RA, Dec, Iwd);
    
    % Save the figure
    %saveas(gcf, filename);
    
    % Save relevant data as .mat file
    %dataFile = sprintf('%sRA_%.6f_Dec_%.6f_Observation_%d_Info.mat', saveDir, RA, Dec, Iwd);
    %save(dataFile, 'results', 'lcData', 'resCat', 'lcDataCat');
end


function sec1 = appendWDToReport(ch1, RA, Dec,wdTable)
    import mlreportgen.report.*;
    import mlreportgen.dom.*;

   
    
    sec1 = Section;
     % Define the text that will be displayed in the paragraph

    sec1.Title = sprintf('RA=%.6f Dec=%.6f', RA, Dec);
    
    AbsMag = calcAbsMag(RA, Dec);
    Color = wdTable.BPmag - wdTable.RPmag;
    
    para = Text(sprintf('AbsMag=%.2f Color=%.2f\n', AbsMag, Color));
    append(sec1, para);


    WDTable = createWDTable(wdTable);
    append(sec1, WDTable);

   % append(sec1,Paragraph(FlagsType))

    [simbadLink, ~] = WDtransits3.generateURLs(RA, Dec, 180/pi);

     % Use Hyperlink instead of ExternalLink
  %  link = ExternalLink(simbadLink.URL,'Simbad Link');  % Create the hyperlink
  %  append(link, Text('Simbad Link'));  % Set the display text of the link
    %par1 = Paragraph();
    % Insert the link into a paragraph and add to the chapter
   % append(par1, Paragraph(link));

    insertLinkToChapter(sec1,simbadLink.URL,'Simbad Link');

 
    % Flag if WD
 
        
    % Create the section and the formatted paragraph
    paraWD = Paragraph();
    
    % Create and format the text for the Pwd value
    highlightedText = Text(sprintf('Pwd = %.4f',wdTable.Pwd));
    highlightedText.Bold = true;         % Make text bold
    highlightedText.Color = '#FF8C00';       % Change text color to red
    highlightedText.FontSize = '14pt';   % Increase font size
    
    % Append the formatted text to the paragraph and add it to the section
    append(paraWD, highlightedText);
    append(sec1, paraWD);
  


 
    append(ch1, sec1);
end



function AbsMag = calcAbsMag( RA, Dec)
    % Calculate absolute magnitude
    PWD = pwd;
    cd('~/marvin/catalogs/GAIA/DR3/');
    AC = catsHTM.cone_search('GAIADR3', RA*pi./180, Dec*pi./180, 3, 'OutType', 'AstroCatalog');
    cd(PWD);
    
    AbsMag = AC.Table.phot_g_mean_mag - (5 * log10(1000 ./ AC.Table.Plx) - 5);
end
function insertLinkToChapter(chapter, linkURL, linkText)
    % Insert a hyperlink into a report chapter
    import mlreportgen.dom.*;  % Ensure the required class is imported
    
    link = ExternalLink(linkURL, linkText);  % Create the external link
    append(chapter, Paragraph(link));  % Insert it into a paragraph and add to chapter
end
