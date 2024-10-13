 function detectInMS(groupedMS,Table,outputDir)

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
                        
                        catJD = [];
                        LimMag    = [];

                        for Ivis = 1 : numel(batch{Ibatch})

                            OP        = WDtransits2.EfficientReadFromCat(batch{Ibatch}(Ivis).FileName, Table.CropID);
                            %obsParams = {obsParams; {OP}};
                            LimMag    =  [LimMag; OP.LimMag];
                            catJD    =  [catJD; OP.JD];
                        end

                    mms = WDtransits2.cleanMatchedSources(batch{Ibatch}, args);
                    lcData{Ibatch}.limMag = LimMag;
                    lcData{Ibatch}.catJD = catJD;
                    lcData{Ibatch} = WDtransits2.extractLightCurve(lcData{Ibatch}, mms,  Table.RA,Table.Dec,args);
                    
                    lcData{Ibatch} = WDtransits2.handleNaNValues(lcData{Ibatch},mms, mms.Nepoch);
                    [~,fname,~] = fileparts(batch{Ibatch}(Ivis).FileName);
                    part = strsplit(fname,'_');
                    lcData{Ibatch}.Tel = part{1};
                    lcData{Ibatch}.Date = part{2};
                                
                            
                    lcData{Ibatch}.Table.RA = Table.RA;
                    lcData{Ibatch}.Table.Dec = Table.Dec;
                    lcData{Ibatch}.Table.Gmag = 1;
                    lcData{Ibatch}.Table.Total_Visits = Table.Nvisits;
                    lcData{Ibatch}.Table.Visits_Found= length(batch) ;
                    lcData{Ibatch}.Table.Subframe = Table.CropID;
                    lcData{Ibatch}.Table.Name = Table.Name;


                   % NO TABLE FOR NOW lcData{Iwd,Ibatch}.Table = table(Iwd,:);



                     % if sum lcData{Iwd,Ibatch}.nanIndinces > 1
                     % find pattern in more source in mms



%                    lcData{Iwd,Ibatch} = transitSearch.handleNaNValues(lcData, numel(catJD));
         
                  

                   


                   results{Ibatch}  = WDtransits2.detectTransits(lcData{Ibatch}, args);
                   % outputDir = '/Users/yarinms/Documents/Data/6thRun';

                   WDtransits2.plotDetectionResults(results, 1, Ibatch, args, true, outputDir)

    end

   end