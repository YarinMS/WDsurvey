%% Observation & WD statistics. 
logFile = '~/Projects/ObservationStatistics/progress_log.mat';
wdTab   =  '~/Projects/ObservationStatistics/wd.mat';
if isfile(logFile)
    load(logFile,'processedVisits');
    load(wdTab,'wd');
else
    processedVisits = [];
    wd=table();
end


allDates = [];
for m = 1:10
  for tel = 1:4 
    for year = 2023:2024
        for month = 1:12
            for day = 1:31
                
                visitPath = fullfile('~/marvin',sprintf('LAST.01.%02d.%02d',m,tel),sprintf('%04d%',year),sprintf('%02d',month),sprintf('%02d',day),'proc');
                
                if ~isfolder(visitPath)
                    continue;
                else
  
                     allDates  = [allDates;sprintf('%04d-%02d-%02d',year,month,day)];
                end


                visits = dir(fullfile(visitPath,'*v0'));
                for Ivis = 1: length(visits)
                    
                    visitPath = fullfile(visits(Ivis).folder,visits(Ivis).name);

                    visitCropIDs = dir(fullfile(visitPath,'*.hdf5'));
                    for Iid = 1 : length(visitCropIDs)
                       
                        cropIDpath = fullfile(visitCropIDs(Iid).folder,visitCropIDs(Iid).name);

                        if ismember( cropIDpath,processedVisits)
                            fprintf('\ncovered \n')
                          continue
                        end

                        %process the visit
                        fprintf('\nProcessing %s',visitCropIDs(Iid).name)
                  
                        MS =  MatchedSources.read(cropIDpath);
                        Ndet = sum(~isnan(MS.Data.RA)) >= 15;
                        MS = MS.selectBySrcIndex(Ndet, 'CreateNewObj', false);
                        MS.sortData;
                        RA  = mean(MS.Data.RA,'omitnan');
                        Dec = mean(MS.Data.Dec,'omitnan');

                        for Isource = 1:length(RA)

                            WD = catsHTM.cone_search('WDEDR3', RA(Isource).*pi/180, Dec(Isource).*pi/180, 3, 'OutType', 'AstroCatalog');

                            if ~isempty(WD.Table)
                                
                                WD= WD.Table;
                                if height(WD.Table) > 1
                                    WD= WD(1,:)
                                end
                                WD.RA =  WD.RA*180/pi;
                                WD.Dec= WD.Dec*180/pi;
                                WD.Nepoch = MS.Nepoch;
                                WD.Ndet = sum(~isnan(MS.Data.MAG_PSF(:,Isource)));
                                
                                WD.Median = mean(MS.Data.MAG_PSF(:,Isource),'omitnan');
                                WD.SD = std(MS.Data.MAG_PSF(:,Isource),'omitnan');
                                
                                WD.Mount = m;
                                WD.Tel = tel;
                               
                                WD.Year = year;
                                WD.Month = month;
                                WD.Day = day;
                                WD.Visit =   visits(Ivis).name;  
                                wd = vertcat(wd,WD);
                                processedVisits = [processedVisits; {cropIDpath}];
                                save(logFile, 'processedVisits');
                                save(wdTab,'wd')
                            end
                        end
                    end
                end

            end
        end
    end
  end
end
wd

%% good fields:
WD = catsHTM.cone_search('WDEDR3', 120.9*pi/180, 41.3*pi/180, 3600*2.2, 'OutType', 'AstroCatalog');
WD = WD.Table(WD.Table.Gmag < 19,:)
