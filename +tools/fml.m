%%
Lo = {};
G =0;
Detection1 = [];
pdetections1 = 0;
Detection2 = [];
pdetections2 = 0;
Detection3 = [];
pdetections3 = 0;
EMS = 0;

Nlc = 22;

h = waitbar(0,'Looking for events.....')
for Isrc = 1 :numel(RA)


    MS = mss{idx{Isrc},1};
    RES = mss{idx{Isrc},2};

    %MS = [MS];

    for Ims = 1 : numel(MS)
        % analyze light curve.
        ms = MS(Ims);

        if ~isempty(MS)
            Np = ms.Nepoch;

            Ind =ms.coneSearch(RA(idx{Isrc}),Dec(idx{Isrc}),6).Ind;

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
            G=G+1;
       
     

            else
            Fndet    = NdetGood >= 16;
            if NdetGood(Ind) < 16
            Lost(Isrc,1) =sum(isnan(MMS.Data.MAG_PSF(:,Ind))) ;
            Lost(Isrc,2) = 1; 
            Lost(Isrc,3) = Ims; 
            Lo{end+1}= sprintf('in Visit %i the source has %i detections',Ims,NdetGood(Ind) );
            else

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

            for I = 1: (sum(isnan(lc)))
                
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

        threshold = 2.5*TypicalSD; %newS*2.5;
        MarkedEvents = [];
       % Counter = Counter +1;
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

                        if ~NanFlag

                        Detection1 = [Detection1; {idx{Isrc}},{MarkedEvents},{lc'} ];
                        
                        pdetections1 = pdetections1 + 1/Nlc;

                        figure();
                        plot(lc,'.r-');
                        set(gca,'YDir','reverse')
                        end

                        if NanFlag

                            Detection1 = [Detection1; {{idx{Isrc}},{MarkedEvents},{{lc},{NaNTemp}}} ];
                        
                          pdetections1 = pdetections1 + 1/Nlc;
V = [1:20];
                        figure();
                        plot(lc);
                        hold on
                        plot(V(logical(NaNTemp)),lc(logical(NaNTemp)),'ko')
                        set(gca,'YDir','reverse')





                        end

                    end


                    %% Run mean filter
                   ResFilt = timeSeries.filter.runMeanFilter(lc , Args.runMeanFilterArgs{:}, 'WinSize',2);

                   Result.FlagRunMean = any(ResFilt.FlagCand, 1);
                    if Result.FlagRunMean > 0

                        Detection2 = [Detection2; {idx{Isrc}},{ResFilt.FlagCand},{lc'} ];
                        flag = 1;
                        %RMF_detections(Ifilt,1) = RMF_detections(Ifilt,1) + 1/Nlc;
                       

                    end

                    %% Area Detection


            
                    LC = MagToFlux(lc,'ZPflux',10000000000);
    
                    [D,S,dc] = detectEvents(LC,mean(LC),std(LC,'omitnan'),"GetDev",true,"Window",3,'Threshold',2.5);
    
    if sum(D) > 1
       
         Detection3 = [Detection3 ; {idx{Isrc}},{D'},{lc'}];
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

    end
end
