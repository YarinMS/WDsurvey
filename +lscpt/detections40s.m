%%
cd('/Users/yarinms/marvin/LAST.01.10.03/2024/08/11/proc')
List = MatchedSources.rdirMatchedSourcesSearch('FileTemplate','*.hdf5');

FN = 'Test40s_';
if exist("List","var")
    flag =1;
end

Args.MagField = {'MAG_PSF'}; Args.MagErrField = {'MAGERR_PSF'};
Args.BadFlags = {'Saturated','Negative','NaN' ,'Spike','Hole','CR_DeltaHT','NearEdge'};
Args.EdgeFlags = {'Overlap'};
Args.runMeanFilterArgs      = {'Threshold',5, 'StdFun','OutWin'};
Args.Nvisits = 1;
Args.Ndet = 17*Args.Nvisits;


MMS = [];
MMSi = [];


%%

for Iid = 1



    list1.FileName = List(Iid).FileName(contains(List(Iid).FileName,FN));
    list1.Folder   = List(Iid).Folder(contains(List(Iid).FileName,FN));
    list1.CropID = List(Iid).CropID;
    ms1 =  MatchedSources.readList(list1);
    Nvis = length(ms1);

RA = median(mean(ms1(16).Data.RA,'omitnan'));
Dec = median(mean(ms1(16).Data.Dec,'omitnan'));
RAD = pi./180;
PWD = pwd;
cd('~/Catalogs/WD/WDEDR3/')
WD  = catsHTM.cone_search('WDEDR3',RA.*RAD, Dec.*RAD, 3600*2.5, 'OutType','AstroCatalog');
cd(PWD)
RA = WD.Table{:,1}./RAD;
Dec = WD.Table{:,2}./RAD;

Batches = tools.createBatches(list1.Folder, 1);

for iid =116 :numel(RA)

    
    [ms_Batch,Res] = tools.FindInMS(Batches,"Coords",[RA(iid) Dec(iid)]);

    MMSi = [MMSi; {ms_Batch},{Res}]


end


end

c= 0
idx = {}
Coords =[];
for i = 1 : length(MNS)

    if ~isempty(MNS{i})
        c=c+1;
        idx{end+1} = i;
        Coords = [Coords; [RA(i),Dec(i)]]
    end

end


end
end


%%
h = waitbar(0,'Looking for events.....')
for Isrc = 1 :numel(RA)


    MS = mss{idx{Isrc},1};
    RES = mss{idx{Isrc},2};

    %MS = [MS];

    for Ims = 1 : numel(MS)
        % analyze light curve.
        ms = MS(Ims);

        if ~isempty(MS)
            Np = MS.Nepoch;

            Ind = MS.coneSearch(RA(idx{Isrc}),Dec(idx{Isrc}),6).Ind;

        if ~isempty(Ind)

        % clean MS

            MMS = ms.setBadPhotToNan('BadFlags',Args.BadFlags, 'MagField','MAG_PSF', 'CreateNewObj',true);
            R = lcUtil.zp_meddiff(ms,'MagField',Args.MagField,'MagErrField',Args.MagErrField);
            [MMS,ApplyToMagFieldr] = applyZP(MMS, R.FitZP,'ApplyToMagField',Args.MagField);
            % Remove sources with NdetGood<MinNdet
            NdetGood = sum(~isnan(MMS.Data.MAG_PSF), 1);
            if NdetGood(Ind) < 9
            Lost(Isrc,1) =sum(isnan(MMS.Data.MAG_PSF(:,Ind))) ;
            Lost(Isrc,2) = 1; 
            Lost(Isrc,3) = Ims; 
       
     

            else
            Fndet    = NdetGood>16;
            if NdetGood(Ind) < 16
            Lost(Isrc,1) =sum(isnan(MS.Data.MAG_PSF(:,Ind))) ;
            Lost(Isrc,2) = 1; 
            Lost(Isrc,3) = Ims; 
            Lost(Isrc,3) = sprintf('in Visit %i the source has %i detections',Ims,NdetGood(Ind) );
            return;
            end

                % good stars found
                MMS      = MMS.selectBySrcIndex(Fndet, 'CreateNewObj',false);
 
    % get lc

    % get group lc
                Ind = MMS.coneSearch(RA(idx{Isrc}),Dec(idx{Isrc}),6).Ind;

                lc = MMS.Data.MAG_PSF(:,Ind);
                [TypicalSD] = clusteredSD1(MMS,'Isrc',Ind);


                NanFlag = false;

                 if sum(isnan(lc))>0

                    NanFlag = true;
                    NaNTemp = zeros(1,Np);

                   % RES = ds{Ilc,"... "}{1}; %

           % t = datetime(MMS.JD,'convertfrom','jd') - seconds(10);

           % tt = datetime(RES.JD,'convertfrom','jd');

            [NanDex] = find( isnan(lc) == true);

            for I = 1: length(sum(isnan(lc)))
                
           %     [~,tmin] = min(abs(t(NanDex(I))-tt));
                lc(NanDex(I)) = 19.8 ;%RES.LimMag(tmin);
                NaNTemp(NanDex(I)) = 1;

            end

        end

        %% Detection method 1 (2 consecutive points) group sigma
         y_zp  =  lc;
         Med   = median(y_zp,'omitnan');
         % sigma = std(y_zp,'omitnan');
        [newM,newS] = SigmaClips(y_zp,'SigmaThreshold',3,'MeanClip',false);
    % [Threshold,CC] =  clusteredSD(MS,'MedInt',newM,'ExtData',true,'Color',Args.WD.Color(Args.wdIdx));
   % [Threshold,~] =  clusteredSD(MMS,'MedInt',newM,'ExtData',false);
   % threshold = Threshold*2.5;

        threshold = newS*2.5;
        MarkedEvents = [];
        Counter = Counter +1;
        for Ipt = 1 : length(y_zp) - 1
        
                if abs(y_zp(Ipt) -  newM) > threshold
            
                    if abs(y_zp(Ipt+1) - newM) > threshold
                
                        MarkedEvents = [MarkedEvents ; Ipt, Ipt+1];
                
                    end
                end
        end
    
Event = 0 ;
if ~isempty(MarkedEvents)
        Event = 1;
end


                    if Event > 0

                        Detection1 = [Detection1; {idx{Isrc}},{MarkedEvents},{lc'} ];
                        
                        pdetections1 = pdetections1 + 1/Nlc;

                        figure();
                        plot(lc);
                        set(gca,'YDir','reverse')

                        if NanFlag

                            Detection1 = [Detection1; {{Ilc},{MarkedEvents},{{lc},{NaNTemp}}} ];
                        
                          pdetections1 = pdetections1 + 1/Nlc;

                        figure();
                        plot(lc);
                        hold on
                        plot(lc(logical(NaNTemp)),'ko')
                        set(gca,'YDir','reverse')





                        end

                    end


                    %% Run mean filter
                   ResFilt = timeSeries.filter.runMeanFilter(lc , Args.runMeanFilterArgs{:}, 'WinSize',2);

                   Result.FlagRunMean = any(ResFilt.FlagCand, 1);
                    if Result.FlagRunMean > 0

                        Detection2 = [Detection2; {Ilc},{ResFilt.FlagCand},{lc'} ];
                        flag = 1;
                        %RMF_detections(Ifilt,1) = RMF_detections(Ifilt,1) + 1/Nlc;
                       

                    end

                    %% Area Detection


            
                    LC = MagToFlux(lc,'ZPflux',10000000000);
    
                    [D,S,dc] = detectEvents(LC,mean(LC),std(LC,'omitnan'),"GetDev",true,"Window",3,'Threshold',2.5);
    
    if sum(D) > 1
       
         Detection3 = [Detection3 ; {Ilc},{D'},{lc'}];
        % DetectionsMB1 = DetectionsMB1 + 1/Nlc;

    end



       

    end

  % else

   %     Contaminated = [Contaminated ; Ilc];
   % end
            end

waitbar(Ims/Isrc,h,sprintf('Counting Flags in LC %i / %i',Ims/Isrc))

    else

        EMS = EMS +1;

    end





      

    end


    %end









%%
%%



%%
h = waitbar(0,'Looking for events.....')
for Ilc = 1 : Nlc

    MS =  0;% MS of source i ds{Ilc,"Analyzed"}{1};



    if ~isempty(MS)
       Np = MS.Nepoch;

    Ind = MS.coneSearch(RA(Ilc),Dec(Ilc),6).Ind;

    if ~isempty(Ind)

    % clean MS

    MMS = MS.setBadPhotToNan('BadFlags',Args.BadFlags, 'MagField','MAG_PSF', 'CreateNewObj',true);
    R = lcUtil.zp_meddiff(MMS,'MagField',Args.MagField,'MagErrField',Args.MagErrField);
    [MMS,ApplyToMagFieldr] = applyZP(MMS, R.FitZP,'ApplyToMagField',Args.MagField);
    % Remove sources with NdetGood<MinNdet
    NdetGood = sum(~isnan(MMS.Data.MAG_PSF), 1);
    if NdetGood(Ind) < 6
        Lost(Ilc,1) =sum(isnan(MS.Data.MAG_PSF(:,Ind))) ;
        Lost(Ilc,2) = 1; 
     

    else
    Fndet    = NdetGood>5;
    %Result.Ndet     = sum(Fndet);
% good stars found
    MMS      = MMS.selectBySrcIndex(Fndet, 'CreateNewObj',false);
 
    % get lc

    % get group lc
        Ind = MMS.coneSearch(RA(Ilc),Dec(Ilc),6).Ind;

        lc = MMS.Data.MAG_PSF(:,Ind);
        [TypicalSD] = clusteredSD1(MMS,'Isrc',Ind);


            NanFlag = false;

        if sum(isnan(lc))>0

            NanFlag = true;
            NaNTemp = zeros(1,Np);

            RES = ds{Ilc,"... "}{1}; %

            t = datetime(MMS.JD,'convertfrom','jd') - seconds(10);

            tt = datetime(RES.JD,'convertfrom','jd');

            [NanDex] = find( isnan(lc) == true);

            for I = 1: length(sum(isnan(lc)))
                
                [~,tmin] = min(abs(t(NanDex(I))-tt));
                lc(NanDex(I)) = RES.LimMag(tmin);
                NaNTemp(NanDex(I)) = 1;

            end

        end

        %% Detection method 1 (2 consecutive points) group sigma
         y_zp  =  lc;
         Med   = median(y_zp,'omitnan');
         % sigma = std(y_zp,'omitnan');
        [newM,newS] = SigmaClips(y_zp,'SigmaThreshold',3,'MeanClip',false);
    % [Threshold,CC] =  clusteredSD(MS,'MedInt',newM,'ExtData',true,'Color',Args.WD.Color(Args.wdIdx));
   % [Threshold,~] =  clusteredSD(MMS,'MedInt',newM,'ExtData',false);
   % threshold = Threshold*2.5;

        threshold = newS*2.5;
        MarkedEvents = [];
        Counter = Counter +1;
        for Ipt = 1 : length(y_zp) - 1
        
                if abs(y_zp(Ipt) -  newM) > threshold
            
                    if abs(y_zp(Ipt+1) - newM) > threshold
                
                        MarkedEvents = [MarkedEvents ; Ipt, Ipt+1];
                
                    end
                end
        end
    
Event = 0 ;
if ~isempty(MarkedEvents)
        Event = 1;
end


                    if Event > 0

                          Detection1 = [Detection1; {Ilc},{MarkedEvents},{lc'} ];
                        
                        pdetections1 = pdetections1 + 1/Nlc;

                        figure();
                        plot(lc);
                        set(gca,'YDir','reverse')

                        if NanFlag

                            Detection1 = [Detection1; {{Ilc},{MarkedEvents},{{lc},{NaNTemp}}} ];
                        
                          pdetections1 = pdetections1 + 1/Nlc;

                        figure();
                        plot(lc);
                        hold on
                        plot(lc(logical(NaNTemp)),'ko')
                        set(gca,'YDir','reverse')





                        end

                    end


                    %% Run mean filter
                   ResFilt = timeSeries.filter.runMeanFilter(lc , Args.runMeanFilterArgs{:}, 'WinSize',2);

                   Result.FlagRunMean = any(ResFilt.FlagCand, 1);
                    if Result.FlagRunMean > 0

                        Detection2 = [Detection2; {Ilc},{ResFilt.FlagCand},{lc'} ];
                        flag = 1;
                        %RMF_detections(Ifilt,1) = RMF_detections(Ifilt,1) + 1/Nlc;
                       

                    end

                    %% Area Detection


            
                    LC = MagToFlux(lc,'ZPflux',10000000000);
    
                    [D,S,dc] = detectEvents(LC,mean(LC),std(LC,'omitnan'),"GetDev",true,"Window",3,'Threshold',2.5);
    
    if sum(D) > 1
       
         Detection3 = [Detection3 ; {Ilc},{D'},{lc'}];
        % DetectionsMB1 = DetectionsMB1 + 1/Nlc;

    end



       

    end

    else

        Contaminated = [Contaminated ; idx{Isrc}];
    end


waitbar(Ilc/Nlc,h,sprintf('Counting Flags in LC %i / %i',Ilc,Nlc))

    else

        EMS = EMS +1;

    end



end

close(h)





%%