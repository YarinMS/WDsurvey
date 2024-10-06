classdef WDtransits1
    properties (Constant)
        DEFAULT_ARGS = struct(...
            'MagField', {{'MAG_PSF'}}, ...
            'MagErrField', {{'MAGERR_PSF'}}, ...
            'BadFlags', {{'Saturated', 'Negative', 'NaN', 'Spike', 'Hole', 'NearEdge'}}, ...
            'EdgeFlags', {{'Overlap'}}, ...
            'runMeanFilterArgs', {{'Threshold', 5, 'StdFun', 'OutWin'}}, ...
            'Nvisits', 2, ...
            'Ndet', 16*2 ...
        );
    end
    
    methods (Static)

        function   results = analyzeWDTransits(rootPath, args)
            if nargin < 2
                args = WDtransits1.DEFAULT_ARGS;
            end
            txtRow = cell(0);

            [msCropID,fieldID] = WDtransits1.findMatchedSources(rootPath);
            args.fieldID = fieldID.ID;
            args.allVisits = size(msCropID,2);

            % Get WD from catalog per CropID
            tic
            [Results, wd] = WDtransits1.findWhiteDwarfsInField(msCropID,args);
            Tab = WDtransits1.createTable(Results,wd);
            wdInField = length(unique(Tab{:,3}));
            foundFlag  = (Tab{:,8} > 0);
            wdFoundInField = length(unique(Tab{foundFlag,3}));

            txtRow = [txtRow ;sprintf('Telescope : %s \n Time stamp : %s \n',fieldID.Tel,fieldID.Date);...
                sprintf('Number of visits: %i\n',args.allVisits);...
                sprintf('Out of %i WDs coordinates in Field %s\n',wdInField,fieldID.ID);...
                 sprintf('%i unique WDs found in catlaogs %s\n',wdFoundInField)];
          %  TranS.documentTableToPDF(Tab, Results, txtRow, fieldID)


            toc
           


            results = WDtransits1.analyzeWhiteDwarfs(msCropID, Tab, Results, args);


            %WDtransits.generateOutput(results);
        end
        
        function [msCropID,selectedField] = findMatchedSources(rootPath)
            cd(rootPath);
            list = MatchedSources.rdirMatchedSourcesSearch('FileTemplate','*.hdf5');
            %list = rdirMSfast();
            allFileNames = {list(16).FileName};
            [fieldNames,DN,TN] = cellfun(@WDtransits1.extractFieldNames, allFileNames, 'UniformOutput', false);
            [fieldNames,idx,c] = unique(fieldNames{:});
            
           % fprintf('Available fields:\n');
           % for i = 1:length(fieldNames)
           %     fprintf('%d. %s\n', i, fieldNames{i});
           % end

             if isempty(fieldNames)
                 error('\nCould not find field name in path.');
            end
            
            if length(fieldNames) > 1

               
            %choice = input('Enter the number of the field you want to analyze: ');
            %while ~isnumeric(choice) || choice < 1 || choice > length(fieldNames)
            %    choice = input('Invalid input. Please enter a valid number: ');
                
            %end
            choice = [];
timeout = 30; % Timeout in seconds
start_time = tic;

while isempty(choice)
    fprintf('Available fields:\n');
    for i = 1:length(fieldNames)
        fprintf('%d. %s\n', i, fieldNames{i});
    end
    
    choice_str = inputdlg('Enter the number of the field you want to analyze:', '', 1, {'1'});
    
    if ~isempty(choice_str)
        choice = str2double(choice_str{1});
        if ~isnumeric(choice) || choice < 1 || choice > length(fieldNames)
            choice = [];
            fprintf('Invalid input. Please enter a valid number.\n');
        end
    end
    
  %  if toc(start_time) > timeout
   %     fprintf('Timeout reached. Choosing the first field by default.\n');
    %    choice = 1;
     %   break;
    %end
end

if isempty(choice)
    choice = 1;
end

            
            selectedField.ID = fieldNames{choice};
            Idx = idx(choice);
            selectedField.Date = DN{1}{Idx};
            selectedField.Tel  = TN{1}{Idx};
            fprintf('Selected field: %s\n', selectedField.ID);
            
            [~,visIdx] = WDtransits1.filterListByFieldName(list(16).FileName, selectedField.ID);
            tic;
            msCropID = [];
            h = waitbar(0,'Creating MS')
            for Iid = 1:24
                [~,visIdx] = WDtransits1.filterListByFieldName(list(Iid).FileName, selectedField.ID);
                list(Iid).FileName = list(Iid).FileName(visIdx);
                list(Iid).Folder   = list(Iid).Folder(visIdx);
                matchedSources = MatchedSources.readList(list(Iid));
                msCropID = [msCropID ; matchedSources];
                waitbar(Iid/24,h,sprintf('Created MS for %i visits; subframe # %i',length(list(Iid).FileName),Iid))

            end
            close(h)
            
            times = toc;
            fprintf('\nCreated %i visits in %.2f sec',24*size(matchedSources,2),times)


            elseif length(fieldNames) == 1

            selectedField.ID = fieldNames{1};
            Idx = idx(1);
            selectedField.Date = DN{1}{Idx};
            selectedField.Tel  = TN{1}{Idx};
            
            fprintf('\nA single field exist: %s\n', selectedField.ID);
            
            [~,visIdx1] = WDtransits1.filterListByFieldName(list(16).FileName, selectedField.ID);
            tic;
            msCropID = [];
            h = waitbar(0,'Creating MS')
            for Iid = 1:24
                [~,visIdx] = WDtransits1.filterListByFieldName(list(Iid).FileName, selectedField.ID);
                
                list(Iid).FileName = list(Iid).FileName(visIdx);
                list(Iid).Folder   = list(Iid).Folder(visIdx);
                matchedSources = MatchedSources.readList(list(Iid));
                msCropID = [msCropID ; matchedSources];
                waitbar(Iid/24,h,sprintf('Created MS for %i visits; subframe # %i',length(list(Iid).FileName),Iid))
            end
            close(h)
            times = toc;
            fprintf('\nCreated %i visits in %.2f sec',24*size(matchedSources,2),times)


            end
             
       
        end
%%  CropID coords cross match with WD catalogs     
        function [Results, wd] = findWhiteDwarfsInField(matchedSources,args)
            % Search for white dwarfs in the field
            % This function should return the RA, Dec, and WD catalog data
            % TODO: Could add more catalog options
            % TODO: At the moment looking for sources by the first visit

            ra = []; dec = []; wd = [];
            
            RAD = pi./180;
            PWD = pwd;
            cd('~/Catalogs/WD/WDEDR3/') % Change to your catlaogs path if needed

            % A list per subframe:

                % Initialize summary counters
            totalWDs = 0;
            totalVisits = 0;
            totalContaminated = 0;
            totalDetections = 0;
            totalWDsWithDetections = 0;
            obsParams = cell(size(matchedSources));

            % obsParams
     

            for Iid = 1 : 24 

               ms1 = matchedSources(Iid,1);
    
                

                        
               obsParams = WDtransits1.EfficientReadFromCat(ms1.FileName, Iid); % you check only first visit which might be a problem
               obsCoord  = mean(obsParams.Coord,'omitnan');
              % limMag    = mean(obsParams.LimMag,'omitnan'); % this might result iin a lower lim mag!!!
                
               

               
                % Search for WDs in field according to first visit
                % obseravtion parameters
                RA = mean(ms1.Data.RA,'omitnan');
                Dec = mean(ms1.Data.Dec,'omitnan');

                Width = abs(min(RA) - max(RA));
                Height = abs(min(Dec) - max(Dec));
                Area = Width*Height;

                Cra  = obsCoord(1);
       
                Cdec = obsCoord(2);
         

                coneSearchRadius = sqrt(Width^2+Height^2)/2 +0.01; % in Deg
                WDS  = catsHTM.cone_search('WDEDR3',Cra.*RAD, Cdec.*RAD, 3600*coneSearchRadius, 'OutType','AstroCatalog');
                

                if ~isempty(WDS.Table)

                    AllWds = size(WDS.Table,1);
                    visWds = WDS.Table{:,11} < 19.6 ;
                    visWds = visWds & WDS.Table{:,7} > 0.75;
                    fprintf('\nOut of %i WDs %i are below Gmag 19.6 \n',AllWds,sum(visWds))


                    wd{Iid} = WDS.Table(visWds,:);
                    Res.ra  = WDS.Table{visWds,1}./RAD;
                    Res.Dec = WDS.Table{visWds,2}./RAD;
           
                    Nwds    = length(Res.ra);
                    Nvis =numel(matchedSources(Iid,:));

                    Res.Nvis = Nvis;
                    Res.Ind = cell(Nwds,Nvis);
                    Res.Flags = cell(Nwds,Nvis);
                    Res.Contaminated = zeros(Nwds,Nvis);
                    Res.Ndet = cell(Nwds,Nvis);

                    totalWDs = totalWDs + Nwds;
                    totalVisits = totalVisits + Res.Nvis;


                    

                    for Iwd = 1 : Nwds

                     for Ivis = 1 : Res.Nvis

                        ms1 = matchedSources(Iid,Ivis);

                        Ind = ms1.coneSearch(Res.ra(Iwd),...
                            Res.Dec(Iwd),6); % 6 arcsec search radius to flag contaminatiors 

                        if ~isempty(Ind.Ind)
                            if Ind.Nsrc >1
                                fprintf('\n Source # %i is probably contaminated - Visit %i(Gmag = %.2f)',Iwd,Ivis,wd{Iid}{Iwd,11})
                                Res.Contaminated(Iwd) = 1;
                                Res.Flags{Iwd,Ivis} = getFlags1(ms1,'SrcIdx',Ind.Ind(1));
                                Res.Ind{Iwd,Ivis} = Ind.Ind;
                            else
                               
                                Res.Ind{Iwd,Ivis} = Ind.Ind;
                                wdFlags = getFlags1(ms1,'SrcIdx',Ind.Ind);
                                Res.Flags{Iwd} = wdFlags;

                                fprintf('\nSource # %i Found in Visit %i(Gmag = %.2f)',Iwd,Ivis,wd{Iid}{Iwd,11})
                                fprintf('\nWith  %i Bad Flags and %i Overlap',sum(wdFlags.BFcounts),wdFlags.EFcounts)
                                Ndet = sum(~isnan(ms1.Data.MAG_PSF(:,Ind.Ind)));
                                fprintf('\nAnd %i Detections',Ndet);
                                Res.Ndet{Iwd,Ivis} = Ndet;
                                if ~isempty(Res.Ndet{Iwd, Ivis})
                                    totalDetections = totalDetections + Res.Ndet{Iwd, Ivis};
                                    totalWDsWithDetections = totalWDsWithDetections + 1;
                                end
                                

                              %  if Ivis == 12
                              %  figure();
                              %  plot(datetime(ms1.JD,'convertfrom','jd'),ms1.Data.MAG_PSF(:,Ind.Ind),'ok-')
                              %  set(gca,'Ydir','reverse')
                              %  ylabel('Mag PSF')
                              %  xlabel('Time')    
                              %  end


                              


                            end
                            


                        else
                             %fprintf('\nCouldnt find Source # %i in visit # %i (Gmag = %.2f)',Iwd,Ivis,wd{Iid}{Iwd,11})

                        end

                    end


                    end


           

                    Results{Iid} = Res;

                else
                    wd{Iid} = {};
                    Results{Iid} = {};
                end
                
                
                %wd{Iid} = WD;
            end

           % Calculate raw averages
            averageDetectionsPerWD = totalDetections / totalWDsWithDetections;

            % Create summary structure
            summary = struct();
            summary.TotalWDs = totalWDs;
            summary.TotalVisits = totalVisits;
            %summary.TotalContaminated = totalContaminated;
            summary.AverageDetectionsPerWD = averageDetectionsPerWD;

            % Print summary
            fprintf('\nSummary:\n');
            fprintf('Total WDs Found: %i\n', totalWDs);
            fprintf('Total Visits Processed: %i\n', totalVisits);
            %fprintf('Total Contaminated WDs: %i\n', totalContaminated);
            fprintf('Average Detections per WD: %.2f\n', averageDetectionsPerWD);

    % Restore the original directory
            cd(PWD)





 

        end
%%

        function results = analyzeWhiteDwarfs(matchedSources, table, Results, args)
            results = cell(size(table,1),table.Total_Visits(1));
            Batch = WDtransits1.groupVisits(table, matchedSources, Results, args);
            lcData = cell(size(table,1),table.Total_Visits(1));
            tic;
            for Iwd = 1 : size(table,1)

                batch = Batch{Iwd};
               
                if iscell(batch) 
                    
                    

                    for Ibatch = 1 : length(batch)
                        
                        catJD = [];
                        LimMag    = [];

                        for Ivis = 1 : numel(batch{Ibatch})

                            OP        = WDtransits1.EfficientReadFromCat(batch{Ibatch}(Ivis).FileName, table.Subframe(Iwd));
                            %obsParams = {obsParams; {OP}};
                            LimMag    =  [LimMag; OP.LimMag];
                            catJD    =  [catJD; OP.JD];
                        end

                        mms = WDtransits1.cleanMatchedSources(batch{Ibatch}, args);
                    lcData{Iwd,Ibatch}.limMag = LimMag;
                    lcData{Iwd,Ibatch}.catJD = catJD;
                    lcData{Iwd,Ibatch} = WDtransits1.extractLightCurve(lcData{Iwd,Ibatch}, mms, table.RA(Iwd), table.Dec(Iwd),args);
                    
                    lcData{Iwd,Ibatch} = WDtransits1.handleNaNValues(lcData{Iwd,Ibatch},mms, mms.Nepoch);
                    [~,fname,~] = fileparts(batch{Ibatch}(Ivis).FileName);
                    part = strsplit(fname,'_');
                    lcData{Iwd,Ibatch}.Tel = part{1};
                    lcData{Iwd,Ibatch}.Date = part{2};


                    lcData{Iwd,Ibatch}.Table = table(Iwd,:);



                     % if sum lcData{Iwd,Ibatch}.nanIndinces > 1
                     % find pattern in more source in mms



%                    lcData{Iwd,Ibatch} = transitSearch.handleNaNValues(lcData, numel(catJD));
         
                  

                   


                   results{Iwd,Ibatch}  = WDtransits1.detectTransits(lcData{Iwd,Ibatch}, args);
                   outputDir = '/Users/yarinms/Documents/Data/5thRun';

                   WDtransits1.plotDetectionResults(results, Iwd, Ibatch, args, true, outputDir)


                    

                    end

                end
                

            end
            times = toc;
            fprintf('\n%.3f seconds to extract all available light curves and their limitng magnitudes',times)
            %finalTable = transitSearch.createTable2(Results, table, lcData, args)
                    i = 1;
                    Stats = WDtransits1.countCells(lcData,table)

                    LCAvb = Stats.WDs(:,7)./ceil(args.allVisits/ args.Nvisits);
                    MagAvb = Stats.WDs(:,6);
                    [~,fname,~] = fileparts(matchedSources(1,1).FileName);
                    parts = strsplit(fname,'_');
                    figure()
                    scatter(MagAvb,LCAvb,'k','filled')
                    title(sprintf('Detection Rates for $N_{vis} =$ %i\nField ID: %s \n %s ',Stats.WDs(1,1),args.fieldID,...
                        parts{1}))
                    xlabel(sprintf('$N_{detections} > $  %i \n LC = %i Visits',args.Ndet,args.Nvisits))
                    legend(sprintf('$N_{WD}$ = %i',length(Stats.WDs(:,1))))

                   plot_filename = sprintf('/Users/yarinms/Documents/Data/FirstRun/Detections_%s_%s_%s.pdf',args.fieldID,parts{1},parts{2});
                  print(gcf, plot_filename, '-dpdf', '-bestfit');
                   %close;

                    if i > 900   
                    for i = 1 :1
                         figure();
                         LC = lcData{14,i};
            
                         t = LC.JD;
                         y = LC.lc;
                         c = LC.Ctrl.CtrlStar;
                         lm = LC.limMag;
                         lmt = LC.catJD;
                         sum(LC.nanIndices)

                         plot(t,y,'Ok-')
                         hold on
                         plot(t,c,'xr--')
                         hold on 
                         plot(t,LC.Ctrl.medLc,'--')
                         hold on
                         plot(lmt,lm,'s-')
                         set(gca,'YDir','reverse')
                      

                    end
                    end



        end
        
    %    function [ms, res] = findSourceInMatchedSources(matchedSources, ra, dec)
            % Implement logic to find the source in matched sources
            % Placeholder implementation:
    %        ms = []; res = [];
            % TODO: Implement actual logic
    %    end
        
    %    function lcData = analyzeLightCurve(ms, res, ra, dec, args)
    %        mms = transitSearch.cleanMatchedSources(ms, args);
    %        lcData = transitSearch.extractLightCurve(mms, ra, dec);
    %        lcData = transitSearch.handleNaNValues(lcData, res);
    %    end
        
        function mms = cleanMatchedSources(ms, args)
            if size(ms,2) > 1
                ms = mergeByCoo(ms,ms(1));
            end
            mms = ms.setBadPhotToNan('BadFlags', args.BadFlags, 'MagField', 'MAG_PSF', 'CreateNewObj', true);
            r = lcUtil.zp_meddiff(ms, 'MagField', args.MagField, 'MagErrField', args.MagErrField);
            [mms, ~] = applyZP(mms, r.FitZP, 'ApplyToMagField', args.MagField);
            mms = WDtransits1.removeSourcesWithFewDetections(mms, args.Ndet);
        end
        
        function mms = removeSourcesWithFewDetections(mms, minNdet)
            NdetGood = sum(~isnan(mms.Data.MAG_PSF), 1);
            Fndet = NdetGood > minNdet;
            mms = mms.selectBySrcIndex(Fndet, 'CreateNewObj', false);
        end
        
        function lcData = extractLightCurve(lcData,mms, ra, dec,args)
            ind = mms.coneSearch(ra, dec, 6).Ind;
            if ~isempty(ind)
                if isscalar(ind)
                lcData.Ind = ind;
                MSra = mean(mms.Data.RA(:,ind),'omitnan');
                MSdec = mean(mms.Data.Dec(:,ind),'omitnan');
                lcData.Coords = [MSra,MSdec];
                lcData.JD = mms.JD;
                lcData.lc = mms.Data.MAG_PSF(:, ind);
                lcData.lcErr = mms.Data.MAGERR_PSF(:, ind);
                lcData.typicalSD = clusteredSD1(mms, 'Isrc', ind);
                 lcData.Flags = getFlags1(mms,'SrcIdx',ind);
                % get control star |version 1
                %lcData.Ctrl = transitSearch.getControl(mms,ind,args) ;
                % TODO : add weights to control stars?>??>>?>?>?>?>?>?>?
                lcData.Ctrl = WDtransits1.getCloseControl(mms, ind,args,ra,dec);

%                lcData = WDtransits1.handleNaNValues(lcData,mms, mms.Nepoch);


                % From control group get ensemble photometry
                enssembeleLC = lcData.Ctrl.medLc;
                deltaMag = lcData.lc-enssembeleLC;
                relFlux = 10.^(-0.4*(deltaMag));
                lcData.relFlux = relFlux/median(relFlux,'omitnan'); % Relative normalized flux
              %  lcData.relFluxErr = lcData.relFlux .* lcData.Ctrl.fluxErr; % Errors from control group
              
                lcData.typScatter = min(lcData.Ctrl.enssembleFluxScatter, std(lcData.lc,'omitnan'));
                

                
                
                else
                    fprintf('')
                    lcData.Res = 'Contaminated source.'; 

                end
            else
                lcData.Res = 'Empty coneSearch result.';
            end

        end

        function lc = getControl(mms, ind,args)

            model = mms.Data.MAG_PSF(:,ind);
            medBin = median(model,'omitnan');
            ctrlGroup = [];
            window = 0.1;
            go = true;
            while isempty(ctrlGroup) && go
                window = window +0.05;
                ctrlGroup = median(mms.Data.MAG_PSF,'omitnan') <  medBin + window  &...
                median(mms.Data.MAG_PSF,'omitnan') >  medBin - window;

                if sum(ctrlGroup) == 0
                    ctrlGroup = [];
                end

                if window > 1

                    go = false;

                end

            end
            % sigma clip outliers:
            if ~isempty(ctrlGroup)
                NoNan = sum(~isnan(mms.Data.MAG_PSF));
                ctrlGroup =  ctrlGroup & NoNan > args.Ndet*args.Nvisits;
                M = mms.Data.MAG_PSF(:,ctrlGroup);
                medMed = median(M,'omitnan');

                medSd = std(M,'omitnan');
                lc.medSD = SigmaClips(medSd);

                lc.medMED = SigmaClips(medMed) ;


                lc.medLc = median(M,2,'omitnan');
                [s,crlStrIdx] = min(abs(medMed -  lc.medMED));
                lc.CtrlStar = M(:,crlStrIdx);

            else
                lc = 'No control group : ('
            end
        end
        %% get close control
        function lc = getCloseControl(mms, ind,args,ra,dec)

            model = mms.Data.MAG_PSF(:,ind);
            medBin = median(model,'omitnan');
            % coneSearch of up to 0.1 deg
            ctrlGroup = [];
            window = 0.2;
            go = true;
            enoughC = 0;
            deg = 0.1;
            
            while enoughC < 10 && deg < 0.75
            S = mms.coneSearch(ra,dec,(deg)*3600);
            % make sure the center of coneSearch is your taget
            SIdx = find(S.Dist == min(S.Dist));
            wdIdx = S.Ind(SIdx);
            wdRa = mean(mms.Data.RA(:,wdIdx),'omitnan');
            wdDec = mean(mms.Data.Dec(:,wdIdx),'omitnan');
            Diff  = sqrt((wdRa-ra).^2+(wdDec-dec).^2);
            

            if Diff > (1/3600 * 10)

                error('\nProblem finding the source itself in control group.\n')
            end

            ctrlInd = S.Ind([1:(SIdx-1), SIdx+1:end]);

            Cms =  mms.selectBySrcIndex(ctrlInd , 'CreateNewObj', true);

            Cmean = mean(Cms.Data.MAG_PSF,'omitnan');

            goodC = Cmean  <  medBin + window  &...
               Cmean >  medBin - window;

            enoughC = sum(goodC);

            deg = deg +0.05;

            end

            % new MS
           
            if enoughC >= 10
               % Cms =  mms.selectBySrcIndex(goodC , 'CreateNewObj', false);

                lc.NanMask = isnan(Cms.Data.MAG_PSF(:,goodC));
                 VGC = sum(lc.NanMask) < 3;
                
                M = Cms.Data.MAG_PSF(:,goodC);
                medMed = median(M,'omitnan');

                medSd = std(M,'omitnan');
                lc.medSD = SigmaClips(medSd);

                lc.medMED = SigmaClips(medMed) ;

                 
                lc.medLc = median(M,2,'omitnan');
                lc.magErr = std(M , 0, 1,'omitnan');  % std along first dimension
                % Relative normalized typical scatter.
                deltaMag = M-lc.medLc;
                relFlux = 10.^(-0.4*(deltaMag));
                ctrlRelFlux = relFlux./median(relFlux,'omitnan');
                lc.enssembleFluxScatter = SigmaClips(std(ctrlRelFlux,'omitnan'));





                lc.fluxErr = 0.921 * lc.magErr ; 
                [~,crlStrIdx] = min( medSd );
                lc.CtrlStar = M(:,crlStrIdx);
            elseif enoughC > 0 && enoughC < 10
                %Cms =  mms.selectBySrcIndex(goodC , 'CreateNewObj', false);
                lc.NanMask = isnan(Cms.Data.MAG_PSF(:,goodC));
                VGC = sum(lc.NanMask) < 3;
                
                M = Cms.Data.MAG_PSF(:,goodC);
                medMed = median(M,'omitnan');

                medSd = std(M,'omitnan');
                lc.medSD = SigmaClips(medSd);

                lc.medMED = SigmaClips(medMed) ;


                lc.medLc = median(M,2,'omitnan');
                [s,crlStrIdx] = min( medSd );
                lc.CtrlStar = M(:,crlStrIdx);
                lc.lowNCtrl = true;


            else
                lcData =  transitSearch.getControl(mms,ind,args);
            end
        end


        %% Handle Nans
        
        function sourceData = handleNaNValues(sourceData,mms, Npts)
                if ~isstruct(sourceData) || ~isfield(sourceData, 'lc')
                    % If the input is not a struct or doesn't have 'lc' field, return it unchanged
                    return;
                end
            
                % Process light curve with lc field
                lc = sourceData.lc;
                jd = sourceData.JD;
                limMag = sourceData.limMag;
                limMagt = sourceData.catJD;
            
                % Check if JD needs sorting
                if mean(abs(jd - limMagt)) > 20 / (24 * 60)
                    [~, sorted] = sort(jd);
                    jd = jd(sorted);
                    lc = lc(sorted);
                    fprintf('\nSorted JD');
                    
                    % Double-check after sorting
                    if mean(abs(jd - limMagt)) > 20 / (24 * 60)
                       % error('\nProblem with JD and lim mag JD. Please check.\n');
                    end
                end
            
                % Find NaN values and replace with limiting magnitude
                nanIndices = isnan(lc);
                lc(nanIndices) = limMag(nanIndices);
            
                % Update the processed data
                sourceData.lc = lc;
                sourceData.JD = jd;
                sourceData.nanIndices = nanIndices;
            
                % Note: Still no com[arison to control Nans
        end
        
        function results = detectTransits(lcData, args)
            if ~isstruct(lcData) || ~isfield(lcData, 'lc')
                    % If the input is not a struct or doesn't have 'lc' field, return it unchanged
                    results = {};
                    return;
            end

            if sum(lcData.nanIndices) < args.Ndet*args.Nvisits

                results.detection1 = WDtransits1.detectConsecutivePoints(lcData, args,false);
                results.detection1flux = WDtransits1.detectConsecutivePoints(lcData, args,true);
                results.detection2 = WDtransits1.runMeanFilter(lcData, args,false);
                results.detection2flux = WDtransits1.runMeanFilter(lcData, args,true);
                results.detection3 = [];% WDtransits1.detectAreaEvents(lcData, args,false);
                results.detection3flux = []%; WDtransits1.detectAreaEvents(lcData, args,true);
                %results.results     = results;
                results.lcData     = lcData;

            else

                fprintf('\nSource has to many NaN to consider\n')
                results = {};

            end

        end
        
         function detection = detectConsecutivePoints(lcData, args, flux)
            % Implement detection method 1 (2 consecutive points)
            if ~flux
                y  = lcData.lc;
                newM = median(y, 'omitnan');
                [~, newS] = SigmaClips(y, 'SigmaThreshold', 3, 'MeanClip', false);

                if newS > lcData.typicalSD
                    threshold = lcData.typicalSD * 2.5;
                else
                    threshold = newS * 2.5;
                end

            else
                y = lcData.relFlux ; 
                newM = median(y, 'omitnan');
                [~, newS] = SigmaClips(y, 'SigmaThreshold', 3, 'MeanClip', false);

                if newS > lcData.typScatter
                    threshold = lcData.typScatter * 2.5;
                else
                    threshold = newS * 2.5;
                end
            end
            y_nan = lcData.nanIndices;
            

            
            
            MarkedEvents = [];
            for Ipt = 1 : length(y) - 1
                if abs(y(Ipt) - newM) > threshold && abs(y(Ipt+1) - newM) > threshold
                    MarkedEvents = [MarkedEvents, Ipt, Ipt+1];
                end
            end

            if ~isempty(MarkedEvents)
                MarkedEvents = unique(MarkedEvents);
           
                    if any(y_nan(MarkedEvents))
                        NanDet = true;
                    else
                        NanDet = false;
        
                    end
        
                    detection = struct('events', MarkedEvents,'NanDet',NanDet, 'lightCurve', lcData.lc);

                   

            else
                    detection = struct('events', [],'NanDet',[], 'lightCurve',[]);
            end
        end
        
        function detection = runMeanFilter(lcData, args,flux)
            % Implement run mean filter detection
            if ~flux
                ResFilt = timeSeries.filter.runMeanFilter(lcData.lc, args.runMeanFilterArgs{:}, 'WinSize', 2);
            else
                ResFilt = timeSeries.filter.runMeanFilter(lcData.relFlux, args.runMeanFilterArgs{:}, 'WinSize', 2);
            end
            FlagRunMean = any(ResFilt.FlagCand, 1);

                      if FlagRunMean
           
                            if any(lcData.nanIndices(ResFilt.FlagCand))
                                NanDet = true;
                            else
                                NanDet = false;
                
                            end
                
                            detection = struct('events',find((ResFilt.FlagCand) == 1),'NanDet',NanDet, 'lightCurve', lcData.lc,'FlagRunMean',FlagRunMean);
        
                           
                     else
                            detection = struct('events', [],'NanDet',[], 'lightCurve',[]);
                     end
                    
           
        end
        
        function detection = detectAreaEvents(lcData, args,flux)
            % Implement area detection method
            if ~flux
                LC = MagToFlux(lcData.lc, 'ZPflux', 10000000000);
                [D, S, dc] = detectEvents(LC, mean(LC), std(LC, 'omitnan'), "GetDev", true, "Window", 3, 'Threshold', 2.5);
            else
                 LC = lcData.relFlux;
                [D, S, dc] = detectEvents(LC, mean(LC), std(LC, 'omitnan'), "GetDev", true, "Window", 3, 'Threshold', 2.5);

            end

                    if any(D)
           
                    if any(lcData.nanIndices(logical(D)))
                        NanDet = true;
                    else
                        NanDet = false;
        
                    end
        
                    detection = struct('events',D,'stats', S, 'deviationCurve', dc,'NanDet',NanDet, 'lightCurve', lcData.lc);

                   
                            
                     else
                            detection = struct('events', [],'NanDet',[], 'lightCurve',[]);
                     end
            detection = struct('events', D, 'stats', S, 'deviationCurve', dc);
        end

        
        function generateOutput(results)
            % Implement output generation (tables, plots, documentation)
            % TODO: Implement actual logic
        end
        

        %% Get field names. 
        function [fieldNames,DateNames,TelNames] = extractFieldNames(fileNames)
            % Extract the field names from a cell array of file names
            % Input: fileNames - a cell array of file names
            % Output: fieldNames - a cell array of field names

            % Ensure input is a cell array
            if ~iscell(fileNames)
                error('Input must be a cell array of file names.');
            end

            % Initialize a cell array to store the field names
            numFiles = length(fileNames);
            fieldNames = cell(numFiles, 1);
            DateNames = cell(numFiles, 1);
            DateNames = cell(numFiles, 1);
    
            for i = 1:numFiles
                fileName = fileNames{i};
                parts = strsplit(fileName, '_');
                % Ensure there is at least one part in the split filename
                if numel(parts) >= 4
                    fieldNames{i} = parts{4};
                    DateNames{i} = parts{2};
                    TelNames{i} = parts{1}; %
                else
                    fieldNames{i} = '';  % If no parts, assign an empty string
                    DateNames{i} = '';
                    TelNames{i} = '';
                end
            end
    

        end 
        %% Extract Results of find white dwarfs in field
         function Tab = createTable(results,wd)
            % Initialize variables to store data
            subframes = [];
            wdIds = cell(0);
            Ras = [];
            Decs = [];
            visitsFound = [];
            totalVisits = [];
            badFlags = [];
            overlapFlags = [];
            contaminated = [];
            avgDetections = [];
            Gmag = [];
            Bpmag = [];
            Pwd   = [];

            % Loop through all subframes
            for i = 1:24
                subframData = results{i};
                NWds = length(subframData.ra);
                tableData = wd{i}; 

                for j = 1:NWds
                    subframes = [subframes; i];
                    wdIds = [wdIds; {sprintf('WD_%02d_%03d', i, j)}]; 
                    Ras = [Ras; subframData.ra(j)];
                    Decs = [Decs; subframData.Dec(j)];
                    Gmag = [Gmag; tableData{j,11}];
                    Bpmag = [Bpmag; tableData{j,12}];
                    Pwd = [Pwd; tableData{j,7}];

                    % Count visits where WD was found
                    visits_found_count = sum(~cellfun(@isempty, subframData.Ind(j,:)));
                    visitsFound = [visitsFound; visits_found_count];

                    totalVisits = [totalVisits; subframData.Nvis];

                    % Count bad flags
                    bad_flag_count = 0;
                    overlap_flag_count = 0;
                    for k = 1:subframData.Nvis
                        if ~isempty(subframData.Flags{j,k})
                            bad_flag_count = bad_flag_count + sum(subframData.Flags{j,k}.BFcounts) ;
                            overlap_flag_count = overlap_flag_count + subframData.Flags{j,k}.EFcounts;
                        end
                    end
                    badFlags = [badFlags; bad_flag_count];
                    overlapFlags = [overlapFlags; overlap_flag_count];

                    contaminated = [contaminated; any(subframData.Contaminated(j,:))];

                    % Calculate average detections
                    detections = cellfun(@(x) WDtransits1.ifelse(isempty(x), 0, x), subframData.Ndet(j,:));
                    avgDetections = [avgDetections; mean(detections)];
                end
            end

            % Create the table
            Tab = table(subframes, wdIds, Ras, Decs,Gmag,Bpmag,Pwd, visitsFound, totalVisits, overlapFlags, badFlags, contaminated, avgDetections, ...
                'VariableNames', {'Subframe', 'WD_ID', 'RA', 'Dec','Gmag','Bp_mag','P_wd', 'Visits_Found', 'Total_Visits','Overlap_Flags',...
                'Bad_Flags', 'Contaminated', 'Avg_Detections'});
        end
% Helper function
        function result = ifelse(condition, true_value, false_value)
            if condition
                result = true_value;
            else
                result = false_value;
            end
        end
        %% Documentation of results table
        function documentTableToPDF(table, Results, txtRow, fieldID)

            filename = ['/Users/yarinms/Documents/Data/',fieldID.Tel,'_',fieldID.Date,'_',fieldID.ID];

    
            % Create the plots %%
            [hist_filename, scatter_filename] = WDtransits1.createEfficiencyPlots(Results,table);
    
            % Create a LaTeX table
            numRows = size(table, 1);
            numCols = size(table, 2);
            columnNames = table.Properties.VariableNames;
            data = table2cell(table);  % Convert table to cell array
            latexTable = '\begin{tabular}{';

            % Define column alignment (e.g., 'l' for left, 'c' for center, 'r' for right)
            for col = 1:numCols
                latexTable = [latexTable, 'l '];  % Change 'l' to 'c' or 'r' as needed
            end
            latexTable = [latexTable, '}\n'];

            % Add column names
            latexTable = [latexTable, strjoin(columnNames, ' & '), ' \\\n'];
            latexTable = [latexTable, '\hline\n'];  % Add horizontal line after the header

            % Add data rows
            for row = 1:numRows
                rowData = data(row, :);
                formattedRow = strjoin(cellfun(@num2str, rowData, 'UniformOutput', false), ' & ');
                latexTable = [latexTable, formattedRow, ' \\\n'];
            end

            % End the LaTeX table environment
            latexTable = [latexTable, '\end{tabular}\n'];

            
            
            
            
            %latex_table = latex(table);

            % Write the LaTeX document
            fid = fopen([filename, '.tex'], 'w');
            fprintf(fid, '\\documentclass{article}\n');
            fprintf(fid, '\\usepackage{booktabs}\n');
            fprintf(fid, '\\usepackage{geometry}\n');
            fprintf(fid, '\\usepackage{graphicx}\n');
            fprintf(fid, '\\usepackage{pgfplots}\n');
            fprintf(fid, '\\pgfplotsset{compat=newest}\n');
            fprintf(fid, '\\usepgfplotslibrary{colormaps}\n');
            fprintf(fid, '\\geometry{a4paper,margin=1in}\n');
            fprintf(fid, '\\begin{document}\n');
    
            % Add text rows
            fprintf(fid, '\\begin{center}\n');
            for i = 1:length(txtRow)
                fprintf(fid, '%s\n\n', strrep(txtRow{i}, '\n', ' \\\\ '));
            end
            fprintf(fid, '\\end{center}\n\n');
    
            % Add the table
            fprintf(fid, '\\begin{table}\n');
            fprintf(fid, '\\centering\n');
            fprintf(fid, sprintf('\\caption{\\footnotesize White Dwarf Observation Summary (%s ; %s)}\n',fieldID.Tel,fieldID.Date));
            fprintf(fid, latexTable);
            fprintf(fid, '\\end{table}\n\n');
    
            % Add the plots
            fprintf(fid, '\\begin{figure}[htbp]\n');
            fprintf(fid, '\\centering\n');
            fprintf(fid, '\\input{%s}\n', hist_filename);
            fprintf(fid, '\\caption{\\footnotesize Detection Efficiency vs G magnitude}\n');
            fprintf(fid, '\\end{figure}\n\n');
    
            fprintf(fid, '\\begin{figure}[htbp]\n');
            fprintf(fid, '\\centering\n');
            fprintf(fid, '\\input{%s}\n', scatter_filename);
            fprintf(fid, '\\caption{\\footnotesize Average Detection Efficiency vs G magnitude (Scatter plot)}\n');
            fprintf(fid, '\\end{figure}\n');
    
    fprintf(fid, '\\end{document}\n');
    fclose(fid);

    % Use system command to compile the LaTeX document to PDF
    %system('pdflatex -shell-escape %s.tex', filename);
    command = sprintf('pdflatex -shell-escape "%s.tex"', filename);

    %    Execute the system command
    status = system(command);
    
    disp(['PDF created: ', filename, '.pdf']);
end

function [hist_filename, scatter_filename] = createEfficiencyPlots(Results,Tab)
    % Calculate efficiencies 
    num_visits = Results{1}.Nvis;
    efficiencies = zeros(size(Tab, 1), num_visits);
    
    for i = 1:size(Tab, 1)
        subframe = Tab.Subframe(i);
        wd_index = str2double(regexp(Tab.WD_ID{i}, '\d+$', 'match'));
        
        for visit = 1:num_visits
            Ndet = Results{subframe}.Ndet{wd_index, visit};
            if isempty(Ndet)
                efficiencies(i, visit) = 0;
            else
                Npts = 20;  % Assuming Npts is always 20, adjust if necessary
                efficiencies(i, visit) = Ndet / Npts;
            end
        end
    end
    
    avg_efficiencies = mean(efficiencies, 2);
    
    % Create histogram
    figure('Visible', 'off');
    [a,b,c] = unique(Tab.Gmag);
    h = bar(Tab.Gmag(b), avg_efficiencies(b));
    hold on
    
    % Find indices where the data is zero and plot x markers
    zeroIndices = find(avg_efficiencies(b) == 0);
    Zidx         = Tab.Gmag(b);
    for i = 1:length(zeroIndices)
        % Mark the zero value with an 'x'
        plot(Zidx(i), 0, 'x', 'MarkerSize',5, 'LineWidth', 2, 'Color', 'r');
    end
    hold off
    xlabel('G magnitude');
    ylabel('Detection Efficiency');
    title('Detection Efficiency vs G magnitude');
    
    
   % Save histogram as PDF
    hist_filename = 'efficiency_histogram.pdf';
    print(gcf, hist_filename, '-dpdf', '-bestfit');
    close;
    
    % Create scatter plot
    figure('Visible', 'off');
    scatter(Tab.Gmag, avg_efficiencies, 'filled');
    xlabel('G magnitude');
    ylabel('Average Detection Efficiency');
    title('Average Detection Efficiency vs G magnitude');
    
    scatter_filename = 'efficiency_scatter.pdf';
    print(gcf, scatter_filename, '-dpdf', '-bestfit');
    close;
end

%% Group to batches functions
function res = groupVisits(table, matchedSources, Results, args)

    res = cell(size(table, 1), 1); % Preallocate results

    for Iwd = 1:length(table.Subframe)
        
        if table.Visits_Found(Iwd) > 0
            
            CropID = table.Subframe(Iwd);
            Nvis = table.Total_Visits(Iwd);
            ms = matchedSources(CropID, :);



                m = zeros(Nvis,1);
                for Ijd = 1 :Nvis

                    m(Ijd) = mean(ms(Ijd).JD);

                end
               [~,idx] = sort(m);
               matchedSources(CropID, :) = matchedSources(CropID, idx);
                ms = matchedSources(CropID, :);


      
            % Check for consecutive visits
            if all([ms.Nepoch] == 20)

                if any(diff(mean([ms.JD])) * 24 * 60 > 60)
                    % error('Visit might not be consecutive\n Please Check....');
                end

            else
                m = zeros(Nvis,1);
                for Ijd = 1 :Nvis

                    m(Ijd) = mean(ms(Ijd).JD);

                end
                [~,idx] = sort(m);
               matchedSources(CropID, :) = matchedSources(CropID, idx);
                ms = matchedSources(CropID, :);

                if any(diff(m) * 24 * 60 > 60)
                    % error('Visit might not be consecutive\n Please Check....');
                end

            end
            
            % Find the corresponding RA and detection values
            [~, j] = find(Results{CropID}.ra == table.RA(Iwd));
            detections = cellfun(@(x) WDtransits1.ifelse(isempty(x), 0, x), Results{CropID}.Ndet(j, :));
            
            if any(detections < Nvis)
                %fprintf('\nCannot find source in all visits\n %i', detections);
                
                visToTake = detections ~= 0;
                
                if sum(visToTake) > 0
                    mms = matchedSources(CropID, visToTake);
                    batches = WDtransits1.groupBatches(mms, args.Nvisits);
                else
                    fprintf('\nCannot find source # %i at all  \n Gmag = %.2f ', Iwd, table.Gmag(Iwd));
                    continue;
                end
            else
                fprintf('\nFound source  #%i in all visits',Iwd);
                batches =  WDtransits1.groupBatches(matchedSources(CropID, :), args.Nvisits);
            end
            
            %[ms, res] = TranS.findSourceInMatchedSources(matchedSources, table.RA(Iwd), table.Dec(Iwd));
            res{Iwd} = batches; % Store result
        else
            res{Iwd} = 'Empty'; % Mark as empty if no visits found
        end
    end
end

function batches = groupBatches(matchedSources, Nvisits)
    % Helper function to create batches
    numBatches = ceil(size(matchedSources, 2) / Nvisits);
    batches = cell(numBatches, 1);

    for i = 1:numBatches
        startIdx = (i - 1) * Nvisits + 1;
        endIdx = min(i * Nvisits, size(matchedSources, 2));
        batches{i} = matchedSources(startIdx:endIdx);
    end
end
        %% Efficent readFromCat

        function Result = EfficientReadFromCat(catalogPath, subframe)
            % Extract visit directory from the catalog path
            [visitPath, ~, ~] = fileparts(catalogPath);
    
            % Create the pattern for finding relevant catalog files
            pattern = sprintf('/*_%03d_sci_proc_Cat_1.fits', subframe);
            % Find all relevant catalog files in the visit directory
            %PWD = pwd;
            %cd(visitPath)

            catFiles = dir(fullfile(visitPath, pattern));
    
            % Initialize result arrays
            nFiles = length(catFiles);
            FIELDID = cell(nFiles, 1);
            JD = zeros(nFiles, 1);
            FWHM = zeros(nFiles, 1);
            LimMag = zeros(nFiles, 1);
            RA = zeros(nFiles, 1);
            DEC = zeros(nFiles, 1);
    
            % Read headers and extract information
            for i = 1:nFiles
                AH = AstroHeader(fullfile(catFiles(i).folder, catFiles(i).name), 3);
        
                FIELDID{i} = AH.Key.FIELDID;
                JD(i) = AH.Key.JD;
                FWHM(i) = AH.Key.FWHM;
                LimMag(i) = AH.Key.LIMMAG;
        
                alpha = [AH.Key.RAU1, AH.Key.RAU2, AH.Key.RAU3, AH.Key.RAU4];
                delta = [AH.Key.DEC1, AH.Key.DEC2, AH.Key.DEC3, AH.Key.DECU4];
                RA(i) = mean(alpha);
                DEC(i) = mean(delta);
            end
    
            % Sort results by JD
            [sortedJD, sortIdx] = sort(JD);
    
            % Prepare the Result structure
            Result.FIELDID = FIELDID(sortIdx);
            Result.JD = sortedJD;
            Result.FWHM = FWHM(sortIdx);
            Result.LimMag = LimMag(sortIdx);
            Result.Coord = [RA(sortIdx), DEC(sortIdx)];
        end
        %% Count cells
        function Res = countCells(lcData,table)
     
            % Initialize matrices to store the classification
            emptyCells = false(size(lcData));
            detWDs = false(size(lcData,1),3);
            singleFieldStructCells = false(size(lcData));
            multiFieldStructCells = false(size(lcData));
            otherCells = false(size(lcData));
            Nlc = 0;
            Nolc = 0;
            WDS = [];
            Nvis = [];
            
            
            % Loop through the cell array
            for i = 1:size(lcData, 1)
                Det = false;
                Con = false;
                Nvisj = 0 ;
                Nmissj = 0 ;
                Found = false;

                for j = 1:size(lcData, 2)
                    if isempty(lcData{i, j})
                        emptyCells(i, j) = true;
                    elseif isstruct(lcData{i, j})
                        Found = true;
                        
                        % Check the number of fields in the structure
                        numFields = numel(fieldnames(lcData{i, j}));
                        if numFields == 3
                            Nolc = Nolc +1;
                            detWDs(i,2) = true;
                            detWDs(i,3) = true;
                            Nmissj = Nmissj +1;
                            
                            singleFieldStructCells(i, j) = true;
                        elseif numFields > 3
                            detWDs(i,1) = true;
                            detWDs(i,3) = true;
                            multiFieldStructCells(i, j) = true;
                            Nlc = Nlc+1;
                            Nvisj = Nvisj+1;
                        end
                    else
                        otherCells(i, j) = true; % For any other data types if applicable
                    end
                end
                
                if Found
                WDS =[WDS ; size(lcData, 2) i j table.RA(i) table.Dec(i) table.Gmag(i) Nvisj Nmissj];
                end

            

            end

            Res.empty = emptyCells;
            Res.noDet = singleFieldStructCells;
            Res.Detected = multiFieldStructCells;
            Res.Other   = otherCells;
            Res.Ndet = sum(detWDs(:,1))
            Res.noDet = sum(detWDs(:,2))
            Res.inField = sum(detWDs(:,3))
            Res.Nlc = Nlc;
            Res.NoLc = Nolc;
            Res.WDs = WDS;
            
         
            nnz(sum(multiFieldStructCells > 0 ,2))
            % Display the results
            fprintf('Empty cells: %d\n', nnz(emptyCells));
            fprintf('Struct cells with one field: %d\n', nnz(singleFieldStructCells));
            fprintf('Struct cells with more than one field: %d\n', nnz(multiFieldStructCells));
            fprintf('Other cells: %d\n', nnz(otherCells));


        end
        %% Create table 2
        function Tab = createTable2(results, wd, lcData, args)
    % Initialize variables to store data
    subframes = [];
    wdIds = cell(0);
    Ras = [];
    Decs = [];
    visitsFound = [];
    totalVisits = [];
    badFlags = [];
    overlapFlags = [];
    contaminated = [];
    avgDetections = [];
    Gmag = [];
    Bpmag = [];
    Pwd = [];
    year = [];
    monthday = [];
    mount = [];
    camera = [];
    cropID = [];
    totalDetections = [];
    nNaN = [];
    avgNaN = [];
    avgLimMag = [];
    visitsConsidered = [];
    numDetections = [];

    % Loop through all subframes
    for i = 1:24
        subframData = results{i};
        NWds = length(subframData.ra);
        tableData = wd;

        for j = 1:NWds
            subframes = [subframes; i];
            wdIds = [wdIds; {sprintf('WD_%02d_%03d', i, j)}];
            Ras = [Ras; subframData.ra(j)];
            Decs = [Decs; subframData.Dec(j)];
            Gmag = [Gmag; tableData{j,11}];
            Bpmag = [Bpmag; tableData{j,12}];
            Pwd = [Pwd; tableData{j,7}];

            % Count visits where WD was found
            visits_found_count = sum(~cellfun(@isempty, subframData.Ind(j,:)));
            visitsFound = [visitsFound; visits_found_count];

            totalVisits = [totalVisits; subframData.Nvis];

            % Count bad flags
            bad_flag_count = 0;
            overlap_flag_count = 0;
            for k = 1:subframData.Nvis
                if ~isempty(subframData.Flags{j,k})
                    bad_flag_count = bad_flag_count + sum(subframData.Flags{j,k}.BFcounts);
                    overlap_flag_count = overlap_flag_count + subframData.Flags{j,k}.EFcounts;
                end
            end
            badFlags = [badFlags; bad_flag_count];
            overlapFlags = [overlapFlags; overlap_flag_count];

            contaminated = [contaminated; any(subframData.Contaminated(j,:))];

            % Calculate average detections
            detections = cellfun(@(x) WDtransits1.ifelse(isempty(x), 0, x), subframData.Ndet(j,:));
            avgDetections = [avgDetections; mean(detections)];
            
            % Extract additional information from lcData
            if ~isempty(lcData{j,i})
                lc = lcData{j,i};
                [~, fname, ~] = fileparts(lc.FileName);
                parts = strsplit(fname, '_');
                year = [year; str2double(parts{2}(1:4))];
                monthday = [monthday; str2double(parts{2}(5:8))];
                mount = [mount; parts{1}];
                camera = [camera; parts{3}];
                cropID = [cropID; i];
                totalDetections = [totalDetections; sum(~isnan(lc.lc))];
                nNaN = [nNaN; sum(isnan(lc.lc))];
                avgNaN = [avgNaN; mean(isnan(lc.lc))];
                avgLimMag = [avgLimMag; mean(lc.limMag)];
                visitsConsidered = [visitsConsidered; size(lc.lc, 1)];
                numDetections = [numDetections; sum(~isnan(lc.lc))];
            else
                year = [year; NaN];
                monthday = [monthday; NaN];
                mount = [mount; ''];
                camera = [camera; ''];
                cropID = [cropID; i];
                totalDetections = [totalDetections; 0];
                nNaN = [nNaN; 0];
                avgNaN = [avgNaN; 0];
                avgLimMag = [avgLimMag; NaN];
                visitsConsidered = [visitsConsidered; 0];
                numDetections = [numDetections; 0];
            end
        end
    end

    % Create the table
    Tab = table(subframes, wdIds, Ras, Decs, Gmag, Bpmag, Pwd, visitsFound, totalVisits, overlapFlags, badFlags, contaminated, avgDetections, ...
        year, monthday, mount, camera, cropID, totalDetections, nNaN, avgNaN, avgLimMag, visitsConsidered, numDetections, ...
        'VariableNames', {'Subframe', 'WD_ID', 'RA', 'Dec', 'Gmag', 'Bp_mag', 'P_wd', 'Visits_Found', 'Total_Visits', 'Overlap_Flags', ...
        'Bad_Flags', 'Contaminated', 'Avg_Detections', 'Year', 'MonthDay', 'Mount', 'Camera', 'CropID', 'Total_Detections', 'Num_NaN', ...
        'Avg_NaN', 'Avg_Lim_Mag', 'Visits_Considered', 'Num_Detections'});
end

        %% Plot functions...
        function plotDetectionResults(results, Iwd, Ibatch, args, plotFlag, outputDir)
            % plotDetectionResults - Plot detection results for a given WD and batch
            %
            % Inputs:
            %   results   - Cell array containing detection results
            %   Iwd       - Index of the white dwarf
            %   Ibatch    - Index of the batch
            %   args      - Structure containing additional arguments
            %   plotFlag  - Boolean flag to control plotting (true to plot, false to skip)
            %   outputDir - Directory to save the output plots (default: current directory)
            
            if nargin < 5
                plotFlag = true;
            end
            
            if nargin < 6
                outputDir = pwd;
            end
            
            if isempty(results{Iwd,Ibatch})
                return
            end
            
            RAD = 180 / pi;
            LC = results{Iwd,Ibatch}.lcData;
            
            % Check if any detection method found events
            Detected = ~isempty(results{Iwd,Ibatch}.detection1.events) || ...
                       ~isempty(results{Iwd,Ibatch}.detection2.events) ;%|| ...
                       %sum(results{Iwd,Ibatch}.detection3.events) > 0;
            FluxDetected = ~isempty(results{Iwd,Ibatch}.detection1flux.events) || ...
                       ~isempty(results{Iwd,Ibatch}.detection2flux.events) ;%|| ...
                       %sum(results{Iwd,Ibatch}.detection3flux.events) > 0;
            
            if ~Detected && ~FluxDetected
                return
            end
            
            % Generate URLs
             if ~isfield(LC,'Table')
                 LC.Table.RA = LC.Coords(1);
                 LC.Table.Dec = LC.Coords(2);
                 LC.Table.Gmag = 1;
                 LC.Table.Total_Visits = 1;
                 LC.Table.Visits_Found= 1 ;
                  LC.Table.Subframe = 0;
             end

            [results{Iwd,Ibatch}.UserData.Simbad, results{Iwd,Ibatch}.UserData.SDSS] = WDtransits1.generateURLs(LC.Table.RA, LC.Table.Dec, RAD);
            [results{Iwd,Ibatch}.UserData.SimbadMS, results{Iwd,Ibatch}.UserData.SDSSMS] = WDtransits1.generateURLs(LC.Coords(1), LC.Coords(2), RAD);
            
            % Determine which detection methods were successful
            Methods = [~isempty(results{Iwd,Ibatch}.detection1.events), ...
                       ~isempty(results{Iwd,Ibatch}.detection2.events),];% ...
                       %sum(results{Iwd,Ibatch}.detection3.events) > 0];

            FluxMethods = [~isempty(results{Iwd,Ibatch}.detection1flux.events), ...
                       ~isempty(results{Iwd,Ibatch}.detection2flux.events),];% ...
                       %sum(results{Iwd,Ibatch}.detection3flux.events) > 0];
            
            if plotFlag
                 if ~exist(outputDir ,'dir')
                     mkdir(outputDir);
                     mkdir(strcat(outputDir,'/FluxDetections'));
                 end
                if Detected 
                    WDtransits1.plotDetectionFigures(results, Iwd, Ibatch, LC, Methods, args, outputDir,    FluxMethods );

                else
                    outputDir = fullfile(outputDir ,'/FluxDetections');
                    WDtransits1.plotDetectionFigures(results, Iwd, Ibatch, LC, Methods, args, outputDir,    FluxMethods);

                end
                
            end
            
            end
            
            function [SimbadURL, SDSS_URL] = generateURLs(RA, Dec, RAD)
                SimbadURL = VO.search.simbad_url(RA ./ RAD, Dec ./ RAD);
                SDSS_URL = VO.SDSS.navigator_link(RA ./ RAD, Dec ./ RAD);
            end
            
            function plotDetectionFigures(results, Iwd, Ibatch, LC, Methods, args, outputDir, FluxMethods)
                % Plot main figure
                fig = figure();
                
                % Subplot 1: Light curve
                subplot(2,1,1);
                WDtransits1.plotLightCurve(results, Iwd, Ibatch, LC, Methods,false, FluxMethods);
                
                % Subplot 2: Additional information
                subplot(2,1,2);
                WDtransits1.plotAdditionalInfo(LC, args, results{Iwd,Ibatch}.UserData);
                
                % Save the plot
         
                WDtransits1.savePlot(fig, LC,outputDir,'Mag_Info' );
                
                % Plot flux figure
                WDtransits1.plotFluxFigure(results, Iwd, Ibatch, LC, Methods, outputDir,    FluxMethods);
            end
            
            function plotLightCurve(results, Iwd, Ibatch, LC, Methods,flux, FluxMethods)
                t = datetime(LC.JD, 'ConvertFrom', 'jd');
                y = LC.lc;
                c = LC.Ctrl.CtrlStar;
                C = LC.Ctrl.medLc;
                lm = LC.limMag;
                lmt = datetime(LC.catJD, 'ConvertFrom', 'jd');
                
                plot(t, y, 'Ok-', 'LineWidth', 2,'DisplayName', sprintf('WD $\\sigma =$ %.3f',std(y,'omitnan')));
                hold on;
                
                WDtransits1.plotDetectedEvents(results, Iwd, Ibatch, t, y, Methods, FluxMethods);
                
                plot(lmt, lm, 'sr-','DisplayName', 'Lim Mag');
                
                if ~isempty(c)
                    plot(t, c, '.b--', 'LineWidth', 1.5,'DisplayName', 'Control Star');
                end

                plot(t, C, '-', 'LineWidth', 0.75,'DisplayName', 'Averaged control');
                
                if ~isempty(LC.nanIndices)
                    plot(t(LC.nanIndices), y(LC.nanIndices), 'kx', 'MarkerSize', 15,'DisplayName', 'NaNs');
                end
                
                WDtransits1.formatLightCurvePlot(LC, Methods, y,flux);
            end
            
            function plotDetectedEvents(results, Iwd, Ibatch, t, y, Methods,FluxMethods)

                markerSize = 4;
                if Methods(1)
                    MarkedEvents = results{Iwd,Ibatch}.detection1.events;
                    plot(t(MarkedEvents), y(MarkedEvents), 'Or', 'MarkerSize', markerSize,'DisplayName','Events');
                elseif Methods(2)
                    FlagRunMean = results{Iwd,Ibatch}.detection2.FlagRunMean;
                    plot(t(FlagRunMean), y(FlagRunMean), 'Or', 'MarkerSize', markerSize,'DisplayName','Events');
             %   elseif Methods(3)
              %      D = results{Iwd,Ibatch}.detection3.events;
               %     plot(t(logical(D)), y(logical(D)), 'Or', 'MarkerSize', markerSize,'DisplayName','Events');
                end
                if ~any(Methods)
                    if FluxMethods(1)
                        MarkedEvents = results{Iwd,Ibatch}.detection1flux.events;
                        plot(t(MarkedEvents), y(MarkedEvents), 'Or', 'MarkerSize', markerSize,'DisplayName','Events');
                    elseif FluxMethods(2)
                        FlagRunMean = results{Iwd,Ibatch}.detection2flux.FlagRunMean;
                        plot(t(FlagRunMean), y(FlagRunMean), 'Or', 'MarkerSize', markerSize,'DisplayName','Events');
               %     elseif FluxMethods(3)
                %        D = results{Iwd,Ibatch}.detection3flux.events;
                 %       plot(t(logical(D)), y(logical(D)), 'Or', 'MarkerSize', markerSize,'DisplayName','Events');
                    end

                end

            end
            
            function formatLightCurvePlot(LC, Methods, y,flux)
                set(gca, 'YDir', 'reverse');
                ylim([min(y)-0.15,max(y)+0.15]);
                
                v = 1:3;
                formatStr = strjoin(arrayfun(@(x) sprintf('\\#%i', x), v(Methods), 'UniformOutput', false), ' ');
                title(sprintf('Detect in Method %s \n %s , %s', formatStr, LC.Tel, LC.Date));
                
                xlabel(sprintf('Coord : %.3f , %.3f ;\n ', LC.Table.RA, LC.Table.Dec));
                if exist('flux','var')
                    legend('show', 'Location', 'southwest');
                else
                    legend('show', 'Location', 'northwestoutside');
                end
            end
            
            function plotAdditionalInfo(LC, args, UserData)
                set(gca, 'Position', [0.0 0.15 0.8 0.15]);
                axis off;
                
                text(0.5, 0.8, sprintf('Total Visits: %d\nVisits Considered: %d\nBad Flags: %d\nOverlap Flags: %d\nContaminated Flags: %d \nID: %s', ...
                    LC.Table.Total_Visits, LC.Table.Visits_Found, sum(LC.Flags.BFcounts), LC.Flags.EFcounts, LC.Table.Visits_Found,LC.Table.Name), 'FontSize', 14);
                
                text(0.2, 0.8, sprintf('CropID: %d\nTel: %s\nDate: %s\nNaNs : %d', ...
                    LC.Table.Subframe, LC.Tel, LC.Date, sum(LC.nanIndices)), 'FontSize', 14);
                
                text(0.8, 0.8, sprintf('%i Visits LC\nMinimal detections: %d', ...
                    args.Nvisits, args.Ndet), 'FontSize', 14);
                
                WDtransits1.addSimbadLink(UserData);
            end
            
            function addSimbadLink(UserData)
                linkLen = size(UserData.Simbad.URL, 2);
                sameLink = sum(UserData.Simbad.URL == UserData.SimbadMS.URL);
                
                if linkLen == sameLink
                    text(0.2, -0.11, 'Simbad Link:', 'FontSize', 12);
                    hyperlink = UserData.Simbad.URL;
                    text(0.2, -0.015, sprintf('Simbad: %s', hyperlink), 'FontSize', 5, 'Interpreter', 'none');
                else
                    text(0.2, 0.11, '2 Simbad Links:', 'FontSize', 12);
                    hyperlink = UserData.Simbad.URL;
                    text(0.2, 0.015, sprintf('Simbad: %s', hyperlink), 'FontSize', 5, 'Interpreter', 'none');
                    hyperlink = UserData.SimbadMS.URL;
                    text(0.2, -0.05, sprintf('Simbad 2: %s', hyperlink), 'FontSize', 5, 'Interpreter', 'none');
                end
            end
            
            function savePlot(fig, LC, outputDir,str)
                set(fig, 'PaperPositionMode', 'auto');
                set(fig, 'PaperUnits', 'inches');
                set(fig, 'PaperSize', [12 10]);
                set(fig, 'PaperPosition', [0 0 12 8]);
                
                plot_filename = fullfile(outputDir, sprintf('%s_Final_plot_%s_%s_%i_%s.pdf',str, LC.Tel, LC.Date, LC.Table.Subframe, LC.Table.Name));
                print(fig, plot_filename, '-dpdf', '-bestfit');
                png_filename = fullfile(outputDir, sprintf('%s_Final_plot_%s_%s_%i_%s.png',str, LC.Tel, LC.Date, LC.Table.Subframe, LC.Table.Name));
                set(gca, 'FontSize', 10);
                set(gca, 'LooseInset', get(gca, 'TightInset')); 
                axis tight;
                exportgraphics(fig, png_filename, 'Resolution', 400);
                close(fig);
            end
            
            function plotFluxFigure(results, Iwd, Ibatch, LC, Methods, outputDir,    FluxMethods)
                fig = figure('Position', [400, 400, 600, 400]);
                
                subplot(2,1,1);
                WDtransits1.plotLightCurve(results, Iwd, Ibatch, LC, Methods,true,    FluxMethods);
                
                subplot(2,1,2);
                WDtransits1.plotFlux(results, Iwd, Ibatch, LC, Methods,    FluxMethods);
                
                WDtransits1.savePlot(fig, LC, outputDir,'Flux');
            end
            
            function plotFlux(results, Iwd, Ibatch, LC, Methods,    FluxMethods)
                t = datetime(LC.JD, 'ConvertFrom', 'jd');
                y = LC.relFlux;
                
                plot(t, y, 'Ok-', 'LineWidth', 2,'DisplayName',sprintf('WD $ \\sigma = %.3f',std(y)));
                hold on;
                
                WDtransits1.plotDetectedEvents(results, Iwd, Ibatch, t, y, Methods,    FluxMethods);
                
                yline(1 - 2.5 * LC.typScatter);
                
                v = 1:3;
                formatStr = strjoin(arrayfun(@(x) sprintf('\\#%i', x), v(Methods), 'UniformOutput', false), ' ');
                title('Relative normalized flux');
                
                legend(sprintf('Rel Flux $\\sigma = $ %.3f', LC.typScatter), 'Mag Events', ...
                    sprintf('1- 2.5 $\\sigma = $ %.3f', 1 - 2.5 * LC.typScatter), 'Location', 'southwest');
            end

        %%
        
        function [filteredList,isMatchingField] = filterListByFieldName(list, fieldName)
            isMatchingField = cellfun(@(x) contains(x, fieldName), {list{:}});
            filteredList = list(isMatchingField);
        end
    end
end