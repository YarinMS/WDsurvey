%% First run with MSs.
%
%


%
%

% cd('/Users/yarinms/Documents/Master/WhiteDwarfs/Codes')
%%
%cd('~/Downloads/')
%data = load('data20S.mat');


%big_list = data.big_list1;
%
%PS  = load('Para20S.mat');

%Paraspace = PS.big_list1;
%%

Args.SearchRadius        = 3;
Args.SearchRadiusUnits   = 'arcsec';


Args.FieldMag            = 'MAG_BEST';
Args.FieldMagErr         = 'MAGERR_PSF';

Args.MedDiffZP    = true;

Args.BadFlags            = {'Overlap','NearEdge','CR_DeltaHT','Saturated','NaN','Negative'};

Args.MinNdet             = 14;

Args.FieldRA             = 'RA';
Args.FieldDec            = 'Dec';
Args.FieldChi2           = 'PSF_CHI2DOF';
Args.FieldSN             = 'SN_3'


Args.MinCorr                = 3./sqrt(14-3);
Args.runMeanFilterArgs      = {'Threshold',5, 'StdFun','OutWin'};
Args.runMeanFilterWinSize   = [1 2 3 4 5 20];
Radii = linspace(3000e3,10*6000e3,10);
Semis = linspace(0.005,0.02,10);
SemiMajjors = Semis;
ProbMap = zeros(10,10)
%%
MS.bestMag;
Nmodels = length(big_list);
%light_curves = BootstrapLC;
Detected = [];
FlagedPoints = {};
FoundToInject = [];
SampleSD = [];
h = waitbar(0, 'Please wait...');
C = 0;
for Imod = 1: Nmodels

     waitbar(Imod / Nmodels, h, sprintf('Progress: %d%%', floor(Imod / Nmodels * 100)));
    


    radius_ind = Paraspace(Imod,1)+1 ; 
    Semi_ind   = Paraspace(Imod,2) +1 ;
    fprintf('Injecting Model r = %.3f R_earth ; a = %.3f',Radii(radius_ind)/6387e3,SemiMajjors(Semi_ind))


    if radius_ind == 5
        if Semi_ind ==2
            c = 5;

        end

    end
    %fprintf('\nInjecting Model r = %.3f R_earth ; a = %.3f',Radii(radius_ind)/6387e3,SemiMajjors(Semi_ind))
    fprintf('\nModel # %i \n',Imod)

    LCmodel    = big_list(Imod,:);


    deltamag = -2.5*log10(LCmodel);

    deltamag(deltamag > 3.5) =15;
    Nlc = length(MS);
    F =0;

for Ilc = 1 :Nlc


if MS(Ilc).Nepoch == 20


        %Clean it.
% Flags This is a FUCKING MUST!!!!!!!!!!!!!!!!
% set to NaN photometry with bad flags
MMS = MS(Ilc).setBadPhotToNan('BadFlags',Args.BadFlags, 'MagField','MAG_PSF', 'CreateNewObj',true);
        
% Remove sources with NdetGood<MinNdet
NdetGood = sum(~isnan(MMS.Data.MAG_PSF), 1);
Fndet    = NdetGood>19;
Result.Ndet     = sum(Fndet);


 % good stars found

  MMS      = MMS.selectBySrcIndex(Fndet, 'CreateNewObj',false);
  %ms       = MS.selectBySrcIndex(Fndet, 'CreateNewObj',false);
            
% Find Targets
flag1 = mean(MMS.Data.MAG_PSF,'omitnan') > 18.5;
indices = find(flag1 == 1);
flag2   = mean(MMS.Data.MAG_PSF(:,indices),'omitnan') < 18.6;

Index = indices(flag2);

if ~isempty(Index)

F = F +1;
%indices = find(flag1 == 1);

% Randomly select one of these indices
%random_index = indices(randi(length(indices)))
random_index = Index(1);

indexes = randperm(length(MMS.Data.MAG_PSF(:,random_index)));

% Scramble vector based on random indexes
%bootstrapped_vector = vector(indexes);
  %
 C=C+1; 
LC = MMS.Data.MAG_PSF(indexes,random_index);
if Imod == 1

SampleSD = [SampleSD; std(LC,'omitnan')];

end

Inject_ind = deltamag >0;

        LC_injected = LC;
       
        LC_injected(Inject_ind) = median(LC,'omitnan') + deltamag(Inject_ind)' + std(LC,'omitnan')*randn(sum(Inject_ind),1);
        

        FixVal = LC_injected > 19.5;
        LC_injected(FixVal) = 19.8;


MMS.Data.MAG_PSF(:,random_index) = LC_injected;        


  %
Rzp = lcUtil.zp_meddiff(MMS, 'MagField','MAG_PSF', 'MagErrField','MAGERR_PSF');
MMS.applyZP(Rzp.FitZP);
%

    y_zp  = LC;
    Med   = median(y_zp,'omitnan');
    sigma = std(y_zp,'omitnan');
    [newM,newS] = SigmaClips(y_zp,'SigmaThreshold',3,'MeanClip',false);
    % [Threshold,CC] =  clusteredSD(MS,'MedInt',newM,'ExtData',true,'Color',Args.WD.Color(Args.wdIdx));
    [Threshold,~] =  clusteredSD(MMS,'MedInt',newM,'ExtData',false);
    threshold = Threshold*2.5;
    MarkedEvents = [];
    
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
     %   [Event] = detect_events(LC_injected,'errors',errors{lc_ind(Ilc)},'times',times{lc_ind(Ilc)}, 'plot',false,...
      %      'title',sprintf('$R_p$ = %.3f $R_{\\oplus}$ ; $a$ = %.3f ; $\\Delta Mag$ = %.3f ; $\\delta_{flux} = %.3f$',Radii(radius_ind)/(6387e3),SemiMajjors(Semi_ind),max(LC_injected - mean(LC_injected)),...
       %         1 - min(LCmodel)),'Model',deltamag);
            flag = 0;
  %          Nfilt = length(Args.runMeanFilterWinSize);
   %         for Ifilt=1:1:Nfilt

    %            ResFilt = timeSeries.filter.runMeanFilter(MMS.Data.MAG_PSF(:,random_index) , Args.runMeanFilterArgs{:}, 'WinSize',Args.runMeanFilterWinSize(Ifilt));
     %           if Ifilt==1
      %              Result.FlagRunMean = any(ResFilt.FlagCand, 1);
                    if Event > 0

                        Detected = [Detected; {1}, {Ilc}, {Imod}, {radius_ind, Semi_ind}   ];
                       flag = 1;

                    end
       % Found = sum(ResFilt.FlagCand)
        
        if flag > 0
            ProbMap(radius_ind,Semi_ind) =  ProbMap(radius_ind,Semi_ind) + 1/Nlc;
        end

        if Imod ==42
            if Ilc == 26
                c = 5;  
            end


        end



   
        
    end





end


end
FoundToInject = [FoundToInject ; F];
end

close(h);

%% Detected Analysis
PM2= zeros(10,10)
PM3=PM2;
PM4=PM3;
PM5=PM2;


for I = 1 : length(Detected)


    Filter = Detected{I,1} ; 

    if Filter == 2  

       R_ind =  Detected{I,4};
       a_ind = Detected{I,5};

        PM2(R_ind,a_ind) =    PM2(R_ind,a_ind) +1

    end

    if Filter == 3

       R_ind =  Detected{I,4};
       a_ind = Detected{I,5};

        PM3(R_ind,a_ind) =    PM3(R_ind,a_ind) +1

    end

    if Filter == 4

               R_ind =  Detected{I,4};
       a_ind = Detected{I,5};

        PM4(R_ind,a_ind) =    PM4(R_ind,a_ind) +1

    end

    if Filter == 5
               R_ind =  Detected{I,4};
       a_ind = Detected{I,5};

        PM5(R_ind,a_ind) =    PM5(R_ind,a_ind) +1

    end




end




%%
count = 0 
for Ilc = 1 : Nlc

    if MS(Ilc).Nepoch == 20
        count = count +1;


end
end


%%

pm2 = PM2/mean(FoundToInject)

pm3 = PM3/mean(FoundToInject)
pm4 = PM4/mean(FoundToInject)
pm5 = PM5/mean(FoundToInject)

%%
fprintf('Moves to indes 2 on MS')
pause(1)

Detected0 = [];
FlagedPoints = {};
FoundToInject0 = [];

h = waitbar(0, 'Please wait...');
for Imod = 1: Nmodels

     waitbar(Imod / Nmodels, h, sprintf('Progress: %d%%', floor(Imod / Nmodels * 100)));
    


    radius_ind = Paraspace(Imod,1)+1 ; 
    Semi_ind   = Paraspace(Imod,2) +1 ;
    fprintf('Injecting Model r = %.3f R_earth ; a = %.3f',Radii(radius_ind)/6387e3,SemiMajjors(Semi_ind))


    if radius_ind == 5
        if Semi_ind ==2
            c = 5;

        end

    end
    %fprintf('\nInjecting Model r = %.3f R_earth ; a = %.3f',Radii(radius_ind)/6387e3,SemiMajjors(Semi_ind))
    fprintf('\nModel # %i \n',Imod)

    LCmodel    = big_list(Imod,:);


    deltamag = -2.5*log10(LCmodel);

    deltamag(deltamag > 3.5) =15;
    Nlc = length(MS);
    F =0;

for Ilc = 1 :Nlc


if MS(Ilc).Nepoch == 20


        %Clean it.
% Flags This is a FUCKING MUST!!!!!!!!!!!!!!!!
% set to NaN photometry with bad flags
MMS = MS(Ilc).setBadPhotToNan('BadFlags',Args.BadFlags, 'MagField','MAG_PSF', 'CreateNewObj',true);
        
% Remove sources with NdetGood<MinNdet
NdetGood = sum(~isnan(MMS.Data.MAG_PSF), 1);
Fndet    = NdetGood>19;
Result.Ndet     = sum(Fndet);


 % good stars found

  MMS      = MMS.selectBySrcIndex(Fndet, 'CreateNewObj',false);
  %ms       = MS.selectBySrcIndex(Fndet, 'CreateNewObj',false);
            
% Find Targets
flag1 = mean(MMS.Data.MAG_PSF,'omitnan') > 18.5;
indices = find(flag1 == 1);
flag2   = mean(MMS.Data.MAG_PSF(:,indices),'omitnan') < 18.6;

Index = indices(flag2);

if ~isempty(Index)

F = F +1;
%indices = find(flag1 == 1);

% Randomly select one of these indices
%random_index = indices(randi(length(indices)))
random_index = Index(2);

indexes = randperm(length(MMS.Data.MAG_PSF(:,random_index)));

% Scramble vector based on random indexes
%bootstrapped_vector = vector(indexes);
  %
   C=C+1;
LC = MMS.Data.MAG_PSF(indexes,random_index);
if Imod == 1

SampleSD = [SampleSD; std(LC,'omitnan')];

end


Inject_ind = deltamag >0;

        LC_injected = LC;
       
        LC_injected(Inject_ind) = median(LC,'omitnan') + deltamag(Inject_ind)' + std(LC,'omitnan')*randn(sum(Inject_ind),1);
        

        FixVal = LC_injected > 19.5;
        LC_injected(FixVal) = 19.8;


MMS.Data.MAG_PSF(:,random_index) = LC_injected;        


  %
Rzp = lcUtil.zp_meddiff(MMS, 'MagField','MAG_PSF', 'MagErrField','MAGERR_PSF');
MMS.applyZP(Rzp.FitZP);
%

     
      y_zp  = LC;
    Med   = median(y_zp,'omitnan');
    sigma = std(y_zp,'omitnan');
    [newM,newS] = SigmaClips(y_zp,'SigmaThreshold',3,'MeanClip',false);
    % [Threshold,CC] =  clusteredSD(MS,'MedInt',newM,'ExtData',true,'Color',Args.WD.Color(Args.wdIdx));
    [Threshold,~] =  clusteredSD(MMS,'MedInt',newM,'ExtData',false);
    threshold = Threshold*2.5;
    MarkedEvents = [];
    
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
     %   [Event] = detect_events(LC_injected,'errors',errors{lc_ind(Ilc)},'times',times{lc_ind(Ilc)}, 'plot',false,...
      %      'title',sprintf('$R_p$ = %.3f $R_{\\oplus}$ ; $a$ = %.3f ; $\\Delta Mag$ = %.3f ; $\\delta_{flux} = %.3f$',Radii(radius_ind)/(6387e3),SemiMajjors(Semi_ind),max(LC_injected - mean(LC_injected)),...
       %         1 - min(LCmodel)),'Model',deltamag);
            flag = 0;
  %          Nfilt = length(Args.runMeanFilterWinSize);
   %         for Ifilt=1:1:Nfilt

    %            ResFilt = timeSeries.filter.runMeanFilter(MMS.Data.MAG_PSF(:,random_index) , Args.runMeanFilterArgs{:}, 'WinSize',Args.runMeanFilterWinSize(Ifilt));
     %           if Ifilt==1
      %              Result.FlagRunMean = any(ResFilt.FlagCand, 1);
                    if Event > 0

                        Detected0 = [Detected0; {1}, {Ilc}, {Imod}, {radius_ind, Semi_ind}   ];
                       flag = 1;

                    end       % Found = sum(ResFilt.FlagCand)
        
        if flag > 0
            ProbMap(radius_ind,Semi_ind) =  ProbMap(radius_ind,Semi_ind) + 1/Nlc;
        end

        if Imod ==42
            if Ilc == 26
                c = 5;  
            end


        end



   
        
    end





end


end
FoundToInject0 = [FoundToInject0 ; F];
end

close(h);

%% Detected Analysis
PM20= zeros(10,10)
PM30=PM20;
PM40=PM30;
PM50=PM20;


for I = 1 : length(Detected0)


    Filter = Detected0{I,1} ; 

    if Filter == 2  

       R_ind =  Detected0{I,4};
       a_ind = Detected0{I,5};

        PM20(R_ind,a_ind) =    PM20(R_ind,a_ind) +1

    end

    if Filter == 3

       R_ind =  Detected0{I,4};
       a_ind = Detected0{I,5};

        PM30(R_ind,a_ind) =    PM30(R_ind,a_ind) +1

    end

    if Filter == 4

               R_ind =  Detected0{I,4};
       a_ind = Detected0{I,5};

        PM40(R_ind,a_ind) =    PM40(R_ind,a_ind) +1

    end

    if Filter == 5
               R_ind =  Detected0{I,4};
       a_ind = Detected0{I,5};

        PM50(R_ind,a_ind) =    PM50(R_ind,a_ind) +1

    end




end




%%
count = 0 
for Ilc = 1 : Nlc

    if MS(Ilc).Nepoch == 20
        count = count +1;


end
end


%%

pm20 = PM20/mean(FoundToInject0)

pm30 = PM30/mean(FoundToInject0)
pm40 = PM40/mean(FoundToInject0)
pm50 = PM50/mean(FoundToInject0)

%%
fprintf('move to ms index 1 & 2')
pause(1)
%%
ms = ms ;
ms.bestMag;
Nmodels = length(big_list);
%light_curves = BootstrapLC;
Detectedms = [];
FlagedPoints = {};
FoundToInjectms = [];

h = waitbar(0, 'Please wait...');
for Imod = 1: Nmodels

     waitbar(Imod / Nmodels, h, sprintf('Progress: %d%%', floor(Imod / Nmodels * 100)));
    


    radius_ind = Paraspace(Imod,1)+1 ; 
    Semi_ind   = Paraspace(Imod,2) +1 ;
    fprintf('Injecting Model r = %.3f R_earth ; a = %.3f',Radii(radius_ind)/6387e3,SemiMajjors(Semi_ind))


    if radius_ind == 5
        if Semi_ind ==2
            c = 5;

        end

    end
    %fprintf('\nInjecting Model r = %.3f R_earth ; a = %.3f',Radii(radius_ind)/6387e3,SemiMajjors(Semi_ind))
    fprintf('\nModel # %i \n',Imod)

    LCmodel    = big_list(Imod,:);


    deltamag = -2.5*log10(LCmodel);

    deltamag(deltamag > 3.5) =15;
    Nlc = length(ms);
    F =0;

for Ilc = 1 :Nlc


if ms(Ilc).Nepoch == 20


        %Clean it.
% Flags This is a FUCKING MUST!!!!!!!!!!!!!!!!
% set to NaN photometry with bad flags
MMS = ms(Ilc).setBadPhotToNan('BadFlags',Args.BadFlags, 'MagField','MAG_PSF', 'CreateNewObj',true);
        
% Remove sources with NdetGood<MinNdet
NdetGood = sum(~isnan(MMS.Data.MAG_PSF), 1);
Fndet    = NdetGood>19;
Result.Ndet     = sum(Fndet);


 % good stars found

  MMS      = MMS.selectBySrcIndex(Fndet, 'CreateNewObj',false);
  %ms       = MS.selectBySrcIndex(Fndet, 'CreateNewObj',false);
            
% Find Targets
flag1 = mean(MMS.Data.MAG_PSF,'omitnan') > 18.5;
indices = find(flag1 == 1);
flag2   = mean(MMS.Data.MAG_PSF(:,indices),'omitnan') < 18.6;

Index = indices(flag2);

if length(Index) > 2

F = F +1;
%indices = find(flag1 == 1);

% Randomly select one of these indices
%random_index = indices(randi(length(indices)))
random_index = Index(2);

indexes = randperm(length(MMS.Data.MAG_PSF(:,random_index)));

% Scramble vector based on random indexes
%bootstrapped_vector = vector(indexes);
  %
   C=C+1;
LC = MMS.Data.MAG_PSF(indexes,random_index);
if Imod == 1

SampleSD = [SampleSD; std(LC,'omitnan')];

end


Inject_ind = deltamag >0;

        LC_injected = LC;
       
        LC_injected(Inject_ind) = median(LC,'omitnan') + deltamag(Inject_ind)' + std(LC,'omitnan')*randn(sum(Inject_ind),1);
        

        FixVal = LC_injected > 19.5;
        LC_injected(FixVal) = 19.8;


MMS.Data.MAG_PSF(:,random_index) = LC_injected;        


  %
Rzp = lcUtil.zp_meddiff(MMS, 'MagField','MAG_PSF', 'MagErrField','MAGERR_PSF');
MMS.applyZP(Rzp.FitZP);
%

     
        

        
   y_zp  = LC;
    Med   = median(y_zp,'omitnan');
    sigma = std(y_zp,'omitnan');
    [newM,newS] = SigmaClips(y_zp,'SigmaThreshold',3,'MeanClip',false);
    % [Threshold,CC] =  clusteredSD(MS,'MedInt',newM,'ExtData',true,'Color',Args.WD.Color(Args.wdIdx));
    [Threshold,~] =  clusteredSD(MMS,'MedInt',newM,'ExtData',false);
    threshold = Threshold*2.5;
    MarkedEvents = [];
    
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
     %   [Event] = detect_events(LC_injected,'errors',errors{lc_ind(Ilc)},'times',times{lc_ind(Ilc)}, 'plot',false,...
      %      'title',sprintf('$R_p$ = %.3f $R_{\\oplus}$ ; $a$ = %.3f ; $\\Delta Mag$ = %.3f ; $\\delta_{flux} = %.3f$',Radii(radius_ind)/(6387e3),SemiMajjors(Semi_ind),max(LC_injected - mean(LC_injected)),...
       %         1 - min(LCmodel)),'Model',deltamag);
            flag = 0;
  %          Nfilt = length(Args.runMeanFilterWinSize);
   %         for Ifilt=1:1:Nfilt

    %            ResFilt = timeSeries.filter.runMeanFilter(MMS.Data.MAG_PSF(:,random_index) , Args.runMeanFilterArgs{:}, 'WinSize',Args.runMeanFilterWinSize(Ifilt));
     %           if Ifilt==1
      %              Result.FlagRunMean = any(ResFilt.FlagCand, 1);
                    if Event > 0

                        Detectedms = [Detectedms; {1}, {Ilc}, {Imod}, {radius_ind, Semi_ind}   ];
                       flag = 1;

                    end
       % Found = sum(ResFilt.FlagCand)
        
        if flag > 0
            ProbMap(radius_ind,Semi_ind) =  ProbMap(radius_ind,Semi_ind) + 1/Nlc;
        end

        if Imod ==42
            if Ilc == 26
                c = 5;  
            end


        end



   
        
    end





end


end
FoundToInjectms = [FoundToInjectms ; F];
end

close(h);

%% Detected Analysis
PM2ms= zeros(10,10)
PM3ms=PM2ms;
PM4ms=PM3ms;
PM5ms=PM2ms;


for I = 1 : length(Detectedms)


    Filter = Detectedms{I,1} ; 

    if Filter == 2  

       R_ind =  Detectedms{I,4};
       a_ind = Detectedms{I,5};

        PM2ms(R_ind,a_ind) =    PM2ms(R_ind,a_ind) +1

    end

    if Filter == 3

       R_ind =  Detectedms{I,4};
       a_ind = Detectedms{I,5};

        PM3ms(R_ind,a_ind) =    PM3ms(R_ind,a_ind) +1

    end

    if Filter == 4

               R_ind =  Detectedms{I,4};
       a_ind = Detectedms{I,5};

        PM4ms(R_ind,a_ind) =    PM4ms(R_ind,a_ind) +1

    end

    if Filter == 5
               R_ind =  Detectedms{I,4};
       a_ind = Detectedms{I,5};

        PM5ms(R_ind,a_ind) =    PM5ms(R_ind,a_ind) +1

    end




end




%%
count = 0 
for Ilc = 1 : Nlc

    if ms(Ilc).Nepoch == 20
        count = count +1;


end
end


%%

pm20ms = PM2ms/mean(FoundToInjectms)

pm30ms = PM3ms/mean(FoundToInjectms)
pm40ms = PM4ms/mean(FoundToInjectms)
pm50ms = PM5ms/mean(FoundToInjectms)





%%





%%

ms.bestMag;
Nmodels = length(big_list);
%light_curves = BootstrapLC;
Detectedms0 = [];
FlagedPoints = {};
FoundToInjectms0 = [];
h = waitbar(0, 'Please wait...');
for Imod = 1: Nmodels

     waitbar(Imod / Nmodels, h, sprintf('Progress: %d%%', floor(Imod / Nmodels * 100)));
    


    radius_ind = Paraspace(Imod,1)+1 ; 
    Semi_ind   = Paraspace(Imod,2) +1 ;
    fprintf('Injecting Model r = %.3f R_earth ; a = %.3f',Radii(radius_ind)/6387e3,SemiMajjors(Semi_ind))


    if radius_ind == 5
        if Semi_ind ==2
            c = 5;

        end

    end
    %fprintf('\nInjecting Model r = %.3f R_earth ; a = %.3f',Radii(radius_ind)/6387e3,SemiMajjors(Semi_ind))
    fprintf('\nModel # %i \n',Imod)

    LCmodel    = big_list(Imod,:);


    deltamag = -2.5*log10(LCmodel);

    deltamag(deltamag > 3.5) =15;
    Nlc = length(ms);
    F =0;

for Ilc = 1 :Nlc


if ms(Ilc).Nepoch == 20


        %Clean it.
% Flags This is a FUCKING MUST!!!!!!!!!!!!!!!!
% set to NaN photometry with bad flags
MMS = ms(Ilc).setBadPhotToNan('BadFlags',Args.BadFlags, 'MagField','MAG_PSF', 'CreateNewObj',true);
        
% Remove sources with NdetGood<MinNdet
NdetGood = sum(~isnan(MMS.Data.MAG_PSF), 1);
Fndet    = NdetGood>19;
Result.Ndet     = sum(Fndet);


 % good stars found

  MMS      = MMS.selectBySrcIndex(Fndet, 'CreateNewObj',false);
  %ms       = MS.selectBySrcIndex(Fndet, 'CreateNewObj',false);
            
% Find Targets
flag1 = mean(MMS.Data.MAG_PSF,'omitnan') > 18.5;
indices = find(flag1 == 1);
flag2   = mean(MMS.Data.MAG_PSF(:,indices),'omitnan') < 18.6;

Index = indices(flag2);

if ~isempty(Index)

F = F +1;
%indices = find(flag1 == 1);

% Randomly select one of these indices
%random_index = indices(randi(length(indices)))
random_index = Index(1);

indexes = randperm(length(MMS.Data.MAG_PSF(:,random_index)));

% Scramble vector based on random indexes
%bootstrapped_vector = vector(indexes);
  %
   C=C+1;
LC = MMS.Data.MAG_PSF(indexes,random_index);


Inject_ind = deltamag >0;

        LC_injected = LC;
       
        LC_injected(Inject_ind) = median(LC,'omitnan') + deltamag(Inject_ind)' + std(LC,'omitnan')*randn(sum(Inject_ind),1);
        

        FixVal = LC_injected > 19.5;
        LC_injected(FixVal) = 19.8;


MMS.Data.MAG_PSF(:,random_index) = LC_injected;        


  %
Rzp = lcUtil.zp_meddiff(MMS, 'MagField','MAG_PSF', 'MagErrField','MAGERR_PSF');
MMS.applyZP(Rzp.FitZP);
%

     
        

   y_zp  = LC;
    Med   = median(y_zp,'omitnan');
    sigma = std(y_zp,'omitnan');
    [newM,newS] = SigmaClips(y_zp,'SigmaThreshold',3,'MeanClip',false);
    % [Threshold,CC] =  clusteredSD(MS,'MedInt',newM,'ExtData',true,'Color',Args.WD.Color(Args.wdIdx));
    [Threshold,~] =  clusteredSD(MMS,'MedInt',newM,'ExtData',false);
    threshold = Threshold*2.5;
    MarkedEvents = [];
    
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
     %   [Event] = detect_events(LC_injected,'errors',errors{lc_ind(Ilc)},'times',times{lc_ind(Ilc)}, 'plot',false,...
      %      'title',sprintf('$R_p$ = %.3f $R_{\\oplus}$ ; $a$ = %.3f ; $\\Delta Mag$ = %.3f ; $\\delta_{flux} = %.3f$',Radii(radius_ind)/(6387e3),SemiMajjors(Semi_ind),max(LC_injected - mean(LC_injected)),...
       %         1 - min(LCmodel)),'Model',deltamag);
            flag = 0;
  %          Nfilt = length(Args.runMeanFilterWinSize);
   %         for Ifilt=1:1:Nfilt

    %            ResFilt = timeSeries.filter.runMeanFilter(MMS.Data.MAG_PSF(:,random_index) , Args.runMeanFilterArgs{:}, 'WinSize',Args.runMeanFilterWinSize(Ifilt));
     %           if Ifilt==1
      %              Result.FlagRunMean = any(ResFilt.FlagCand, 1);
                    if Event > 0

                        Detectedms0 = [Detectedms0; {1}, {Ilc}, {Imod}, {radius_ind, Semi_ind}   ];
                       flag = 1;

                    end

       % Found = sum(ResFilt.FlagCand)
        
        if flag > 0
            ProbMap(radius_ind,Semi_ind) =  ProbMap(radius_ind,Semi_ind) + 1/Nlc;
        end

        if Imod ==42
            if Ilc == 26
                c = 5;  
            end


        end



   
        
    end





end


end
FoundToInjectms0 = [FoundToInjectms0 ; F];
end

close(h);

%% Detected Analysis





%%
count = 0 
for Ilc = 1 : Nlc

    if ms(Ilc).Nepoch == 20
        count = count +1;


end
end


%%

pm20ms0 = PM20ms0/mean(FoundToInjectms0)

pm30ms0 = PM30ms0/mean(FoundToInjectms0)
pm40ms0 = PM40ms0/mean(FoundToInjectms0)
pm50ms0 = PM50ms0/mean(FoundToInjectms0)





figure('color','white')

hist(SampleSD,30)

%%
PM10 = zeros(10,10)
for I = 1 : length(Detected0)


    Filter = Detected0{I,1} ; 

    if Filter == 1  

       R_ind =  Detected0{I,4};
       a_ind = Detected0{I,5};

        PM10(R_ind,a_ind) =    PM10(R_ind,a_ind) +1

    end
end
for I = 1 : length(Detected)


    Filter = Detected{I,1} ; 

    if Filter == 1  

       R_ind =  Detected{I,4};
       a_ind = Detected{I,5};

        PM10(R_ind,a_ind) =    PM10(R_ind,a_ind) +1

    end
end

for I = 1 : length(Detectedms0)


    Filter = Detectedms0{I,1} ; 

    if Filter == 1  

       R_ind =  Detectedms0{I,4};
       a_ind = Detectedms0{I,5};

        PM10(R_ind,a_ind) =    PM10(R_ind,a_ind) +1

    end
end
for I = 1 : length(Detectedms)


    Filter = Detectedms{I,1} ; 

    if Filter == 1  

       R_ind =  Detectedms{I,4};
       a_ind = Detectedms{I,5};

        PM10(R_ind,a_ind) =    PM10(R_ind,a_ind) +1

    end
end

%%

pm10 = PM10/244

