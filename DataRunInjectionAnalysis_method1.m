%% Data run Injection analysis
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
Args.runMeanFilterArgs      = {'Threshold',3, 'StdFun','OutWin'};
Args.runMeanFilterWinSize   = [1 2 3 4 5 20];
Radii = linspace(3000e3,10*6000e3,10);
Semis = linspace(0.005,0.02,10);
SemiMajjors = Semis;
ProbMap = zeros(10,10)
%%
cc=0;
c0=0;
cms=0;
cms0=0;
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
TransitModel = big_list(Imod,:)';
lc_injected  = lc.*TransitModel;
[D,S,dc] = detectEvents(lc_injected,mean(lc_injected),std(lc_injected),"GetDev",true,"Window",3,'Threshold',3);


    Event = 0;
    if sum(D) > 0
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
                        cc= cc+1;
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
TransitModel = big_list(Imod,:)';
lc_injected  = lc.*TransitModel;
[D,S,dc] = detectEvents(lc_injected,mean(lc_injected),std(lc_injected),"GetDev",true,"Window",3,'Threshold',3);

    Event = 0 ;
    if sum(D) > 0
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
                        c0= c0+1;
                        Detected0 = [Detected0; {1}, {Ilc}, {Imod}, {radius_ind, Semi_ind},{D'}   ];
                       flag = 1;

                    end       % Found = sum(ResFilt.FlagCand)
        
        if flag > 0
            ProbMap(radius_ind,Semi_ind) =  ProbMap(radius_ind,Semi_ind) + 1/Nlc;
        end

        if Imod ==2
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
TransitModel = big_list(Imod,:)';
lc_injected  = lc.*TransitModel;
[D,S,dc] = detectEvents(lc_injected,mean(lc_injected),std(lc_injected),"GetDev",true,"Window",3,'Threshold',3);

    
    Event = 0 ;
    if sum(D) > 0
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
                        cms= cms+1;
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
TransitModel = big_list(Imod,:)';
lc_injected  = lc.*TransitModel;
[D,S,dc] = detectEvents(lc_injected,mean(lc_injected),std(lc_injected),"GetDev",true,"Window",3,'Threshold',3);

    
    Event = 0 ;
    if sum(D) > 0
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
                        cms0= cms0+1;

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
for I = 1 : c0


    Filter = Detected0{I,1} ; 

    if sum(Detected0{I,6}) >0  

       R_ind =  Detected0{I,4};
       a_ind = Detected0{I,5};

        PM10(R_ind,a_ind) =    PM10(R_ind,a_ind) +1

    end
end
for I = 1 : cc


    Filter = Detected{I,1} ; 

    if sum(Detected{I,6}) >0    

       R_ind =  Detected{I,4};
       a_ind = Detected{I,5};

        PM10(R_ind,a_ind) =    PM10(R_ind,a_ind) +1

    end
end

for I = 1 : cms0


    Filter = Detectedms0{I,1} ; 

    if sum(Detectedms0{I,6}) >0    

       R_ind =  Detectedms0{I,4};
       a_ind = Detectedms0{I,5};

        PM10(R_ind,a_ind) =    PM10(R_ind,a_ind) +1

    end
end
for I = 1 : cms


    Filter = Detectedms{I,1} ; 

    if sum(Detectedms{I,6}) >0   

       R_ind =  Detectedms{I,4};
       a_ind = Detectedms{I,5};

        PM10(R_ind,a_ind) =    PM10(R_ind,a_ind) +1

    end
end

%%

pm10 = PM10/239;
Filter = [];

for I = 1 : length(Detected0)


    Filter = [Filter; {find(Detected0{I,6}  > 0)}];


end
for I = 1 : length(Detected)


    Filter =[Filter;  {find(Detected{I,6}    > 0)}];

end

for I = 1 : length(Detectedms0)


     Filter = [Filter; {find(Detectedms0{I,6}  > 0)}];

end
for I = 1 : length(Detectedms)


    Filter = [Filter; {find(Detectedms{I,6}    > 0)}];


end


FAP = 0
for j = 1 :length(Filter)

        if ~isempty(Filter{j})
            FAP = FAP +1
        end

end




FAP/length(Filter)