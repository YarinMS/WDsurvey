%% Test to Detect Events
%% Load transit models. 
cd('~/Downloads/')
data = load('data20S.mat');


big_list = data.big_list1;

%
PS  = load('Para20S.mat');

Paraspace = PS.big_list1;

%% Plot models
figure('Color','white')

hold on
for i = 1:100

    if mod(i,5) == 0
        PlotModel(big_list,Imod=i)
    end

end


%%






%% Simulated data first
% 1. No noise
ms = 17*ones(20,1000); 
ms(10:14,14) = 17.9;
fs = MagToFlux(ms,"ZPflux",1000000000);
tic;
d= [];
s= [];
DC = {};
for Ilc = 1 : length(ms)

    [D,S,dc] = detectEvents(fs(:,Ilc),mean(fs(:,Ilc)),std(fs(:,Ilc)),"GetDev",true);

    d = [d;D'];
    s = [s;S'];

    DC{end+1} = dc;



end


t = toc
% works as expected.

% Recover one transit from a visit:
%% Load an MS
ms = MS(14); % adjust by a function that gets a path to N visits.
Args.Ndet = 19;

%% Clean MS
% At the moment considering only no Nan's

% set to NaN photometry with bad flags
MMS = ms.setBadPhotToNan('BadFlags',Args.BadFlags, 'MagField','MAG_PSF', 'CreateNewObj',true);
        
% Remove sources with NdetGood<MinNdet
NdetGood = sum(~isnan(MMS.Data.MAG_PSF), 1);
Fndet    = NdetGood>Args.Ndet ;
Result.Ndet     = sum(Fndet);


 % good stars found

  MMS      = MMS.selectBySrcIndex(Fndet, 'CreateNewObj',false);
%% Single Injection (BeforeZP)
% Find Targets
flag1 = mean(MMS.Data.MAG_PSF,'omitnan') > 18.5;
indices = find(flag1 == 1);
flag2   = mean(MMS.Data.MAG_PSF(:,indices),'omitnan') < 18.6;

Index = indices(flag2);

if ~isempty(Index)

%F = F +1;
%indices = find(flag1 == 1);

% Randomly select one of these indices
%random_index = indices(randi(length(indices)))
random_index = Index(1);

indexes = randperm(length(MMS.Data.MAG_PSF(:,random_index)));

% Scramble vector based on random indexes

  
% C=C+1; 

LC = MMS.Data.MAG_PSF(indexes,random_index);
lc = MagToFlux(LC,'ZPflux',10000000000);
TransitModel = big_list(42,:)';
lc_injected  = lc.*TransitModel;


% No shift to flux what about implications on limiting magnitudes. 

%Inject_ind = deltamag >0;

 %       LC_injected = LC;
       
  %      LC_injected(Inject_ind) = median(LC,'omitnan') + deltamag(Inject_ind)' + std(LC,'omitnan')*randn(sum(Inject_ind),1);
        

   %     FixVal = LC_injected > 19.5;
    %    LC_injected(FixVal) = 19.8;


% MMS.Data.MAG_PSF(:,random_index) = LC_injected;        







end




lc_injected = lc;

 [D,S,dc] = detectEvents(lc_injected,mean(lc_injected),std(lc_injected),"GetDev",true);

 figure('color','white')
 plot(lc,'o')
 hold on 
 plot(lc_injected)



 %%
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



    %fprintf('\nInjecting Model r = %.3f R_earth ; a = %.3f',Radii(radius_ind)/6387e3,SemiMajjors(Semi_ind))
    fprintf('\nModel # %i \n',Imod)

    LCmodel    = big_list(Imod,:);

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
lc = MagToFlux(LC,'ZPflux',10000000000);
TransitModel = big_list(42,:)';
lc_injected  = lc.*TransitModel;
[D,S,dc] = detectEvents(lc_injected,mean(lc_injected),std(lc_injected),"GetDev",true);



    if ~isempty(D)
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

                        Detected = [Detected; {1}, {Ilc}, {Imod}, {radius_ind, Semi_ind} ,{D'}  ];
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




%%


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
lc = MagToFlux(LC,'ZPflux',10000000000);
TransitModel = big_list(42,:)';
lc_injected  = lc.*TransitModel;
[D,S,dc] = detectEvents(lc_injected,mean(lc_injected),std(lc_injected),"GetDev",true);

    Event = 0 ;
    if ~isempty(D)
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

                        Detected0 = [Detected0; {1}, {Ilc}, {Imod}, {radius_ind, Semi_ind},{D'}   ];
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
lc = MagToFlux(LC,'ZPflux',10000000000);
TransitModel = big_list(42,:)';
lc_injected  = lc.*TransitModel;
[D,S,dc] = detectEvents(lc_injected,mean(lc_injected),std(lc_injected),"GetDev",true);

    
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

                        Detectedms = [Detectedms; {1}, {Ilc}, {Imod}, {radius_ind, Semi_ind} ,{D'}  ];
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
lc = MagToFlux(LC,'ZPflux',10000000000);
TransitModel = big_list(42,:)';
lc_injected  = lc.*TransitModel;
[D,S,dc] = detectEvents(lc_injected,mean(lc_injected),std(lc_injected),"GetDev",true);

    
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

                        Detectedms0 = [Detectedms0; {1}, {Ilc}, {Imod}, {radius_ind, Semi_ind},{D'}   ];
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

