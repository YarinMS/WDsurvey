
ra = 26.682; dec = 33.323;

Path = pwd;
AI = loadFilesForPhotometry(pwd, 13)
tic ;
FP = imProc.sources.forcedPhot(AI,'Coo',[26.682 33.323],'ColNames',{'RA','Dec','X','Y','Xstart','Ystart','Chi2dof','FLUX_PSF','FLUXERR_PSF','MAG_PSF','MAGERR_PSF','BACK_ANNULUS', 'STD_ANNULUS','FLUX_APER','FLAG_POS','FLAGS'});
to     = toc;




% Get lim mag, fwhm and JD from HEADER 
limMag = arrayfun(@(x) x.Key.LIMMAG, AI)'; 
airmass = arrayfun(@(x) x.Key.AIRMASS, AI)'; 
JD     = arrayfun(@(x) x.Key.JD, AI)'; 
FWHM   = arrayfun(@(x) x.Key.FWHM, AI)';


%% Save FP ? etract kc ?


% # Nans.
nNans = sum(isnan(FP.Data.MAG_PSF(:,1)));
% # ZP
mms = FP.setBadPhotToNan('BadFlags', {'Saturated', 'Negative', 'NaN', 'Spike', 'Hole', 'NearEdge'}, 'MagField', 'MAG_PSF', 'CreateNewObj', true);
r = lcUtil.zp_meddiff(mms, 'MagField',{'MAG_PSF'}, 'MagErrField',{'MAGERR_PSF'});
[ms, ~] = applyZP(mms, r.FitZP, 'ApplyToMagField',{'MAG_PSF'});
% Clean Nans
NdetGood = sum(~isnan(ms.Data.MAG_PSF), 1);
Fndet = NdetGood > ms.Nepoch - 4;
Fndet(1) = 1;
ms = ms.selectBySrcIndex(Fndet, 'CreateNewObj', false);

%% # Target LC : 

lcData.lc = ms.Data.MAG_PSF(:,1);
lcData.JD = ms.JD;
lcData.limMag = limMag;
lcData.catJD = JD;
[~,fname,~] = fileparts(AI(1).Key.FILENAME);
part = strsplit(fname,'_');
lcData.Tel = part{1};
lcData.Date = part{2};
lcData.Table.RA = ra;
lcData.Table.Dec = dec;
lcData.Table.Gmag = 0;

% # Control group ?
lcData.Ctrl = WDtransits3.getCloseControl(ms, 1,{},ra,dec);
 enssembeleLC = lcData.Ctrl.medLc;
deltaMag = lcData.lc-enssembeleLC;
relFlux = 10.^(-0.4*(deltaMag));
lcData.relFlux = relFlux/median(relFlux,'omitnan');

% # Detection ?
lcData.typicalSD = std(lcData.lc,'omitnan');
lcData.typScatter = std(lcData.relFlux,'omitnan');
lcData.nanIndices = isnan(lcData.lc);
args.Ndet = sum(~isnan(lcData.lc));
args.Nvisits = 100000; % just to handle every lightcurve.
args.runMeanFilterArgs =  {'Threshold', 5, 'StdFun', 'OutWin'};
results  = WDtransits3.detectTransits(lcData, args);

%% # Plot Result. maybe should be a function.
% Check if any detection method found events

results = {results};
Iwd = 1; Ibatch = 1;

Detected = ~isempty(results{Iwd,Ibatch}.detection1.events) || ...
           ~isempty(results{Iwd,Ibatch}.detection2.events) ;
       
FluxDetected = ~isempty(results{Iwd,Ibatch}.detection1flux.events) || ...
           ~isempty(results{Iwd,Ibatch}.detection2flux.events) ;

       
% Determine which detection methods were successful
Methods = [~isempty(results{Iwd,Ibatch}.detection1.events), ...
           ~isempty(results{Iwd,Ibatch}.detection2.events),];% ...
           %sum(results{Iwd,Ibatch}.detection3.events) > 0];

FluxMethods = [~isempty(results{Iwd,Ibatch}.detection1flux.events), ...
           ~isempty(results{Iwd,Ibatch}.detection2flux.events),];   
                   
figure();
WDtransits3.plotLightCurve(results, Iwd, Ibatch, lcData, Methods,lcData.relFlux, FluxMethods)                

% # Save both plot and lcData in an accessible place. WITH all available
% information




            
            
T = datetime(FP.JD,'convertfrom','jd');
figure(); plot(T,FP.Data.MAG_PSF(:,1),'-ok') ; set(gca,'YDir','reverse')

hold on; plot(T,mms.Data.MAG_PSF(:,1),'-or') ; 