function results = getLCfromMS(groupedMS,Table,outputDir,Args)


 arguments
        groupedMS
        Table
        outputDir
        Args.MagField = {'MAG_PSF'}
        Args.MagErrField = {'MAGERR_PSF'}
        Args.BadFlags = {'Saturated', 'Negative', 'NaN', 'Spike', 'Hole', 'NearEdge'}
        Args.EdgeFlags = {'Overlap'}
        Args.runMeanFilterArgs = {'Threshold', 5, 'StdFun', 'OutWin'}
        Args.Nvisits (1,1) double {mustBePositive} = 2  % Example constraint: must be positive
        Args.Ndet (1,1) double = 16 * 2
        Args.plotAll (1,1) logical = true  % Assuming plotAll is boolean (use true/false instead of 1/0)
    end
           lcData  = cell(0);
           batch = groupedMS;
           args = Args;
    
    
    for Ibatch = 1 : length(batch)
                        
                        catJD = [];
                        LimMag    = [];

                        for Ivis = 1 : numel(batch{Ibatch})

                            OP        = WDtransits1.EfficientReadFromCat(batch{Ibatch}(Ivis).FileName, Table.CropID);
                            %obsParams = {obsParams; {OP}};
                            LimMag    =  [LimMag; OP.LimMag];
                            catJD    =  [catJD; OP.JD];
                        end

                    mms = WDtransits1.cleanMatchedSources(batch{Ibatch}, args);
                    lcData{Ibatch}.limMag = LimMag;
                    lcData{Ibatch}.catJD = catJD;
                    lcData{Ibatch} = WDtransits1.extractLightCurve(lcData{Ibatch}, mms,  Table.RA,Table.Dec,args);
                    
                    

                   

                    lcData{Ibatch} = WDtransits1.handleNaNValues(lcData{Ibatch},mms, mms.Nepoch);
                    [~,fname,~] = fileparts(batch{Ibatch}(Ivis).FileName);
                    part = strsplit(fname,'_');
                    lcData{Ibatch}.Tel = part{1};
                    lcData{Ibatch}.Date = part{2};
                                
                            
                    lcData{Ibatch}.Table.RA = Table.RA;
                    lcData{Ibatch}.Table.Dec = Table.Dec;
                    % lcData{Ibatch}.Table.Gmag = 1;
                    lcData{Ibatch}.Table.Total_Visits = Table.Nvisits;
                    lcData{Ibatch}.Table.Visits_Found= length(batch) ;
                    lcData{Ibatch}.Table.Subframe = Table.CropID;
                    lcData{Ibatch}.Table.Name = Table.Name;


                   % NO TABLE FOR NOW lcData{Iwd,Ibatch}.Table = table(Iwd,:);



                     % if sum lcData{Iwd,Ibatch}.nanIndinces > 1
                     % find pattern in more source in mms



%                    lcData{Iwd,Ibatch} = transitSearch.handleNaNValues(lcData, numel(catJD));
         
                   if args.plotAll

                        if isfield(lcData{Ibatch},'lc')

                        figure();
                        plotLightCurve([],1,Ibatch,lcData{Ibatch})
                        
                        end



                    end

                   


                   results{Ibatch}  = WDtransits1.detectTransits(lcData{Ibatch}, args);
                   % outputDir = '/Users/yarinms/Documents/Data/6thRun';

                   WDtransits1.plotDetectionResults(results, 1, Ibatch, args, true, outputDir)

    end

   end