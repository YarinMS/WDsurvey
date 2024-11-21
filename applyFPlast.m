function [FP,results,lcData] = applyFPlast(AI,wdTable,Iwd,momentMaxIter)
    ra  = wdTable.RA(Iwd);
    dec = wdTable.Dec(Iwd);


       FP = imProc.sources.forcedPhot(AI, 'Coo', [ra, dec], ...
        'ColNames', {'RA', 'Dec', 'X', 'Y', 'Xstart', 'Ystart', 'Chi2dof', 'FLUX_PSF', 'FLUXERR_PSF', 'MAG_PSF', 'MAGERR_PSF', 'BACK_ANNULUS',...
        'STD_ANNULUS', 'FLUX_APER', 'FLAG_POS', 'FLAGS'},...
        'MomentMaxIter',momentMaxIter,'UseMomCoo',true,'HeaderZP',true,'ReconstructPSF',true,'constructPSFArgs' , {'RepopulatePSF' true 'ThresholdPSF' 20 'RangeSN' [50,1000] 'RadiusPSF' 6} );
        
   
    
    %limMag = arrayfun(@(x) x.Key.LIMMAG, AI)';
    %airmass = arrayfun(@(x) x.Key.AIRMASS, AI)';
    %JD = arrayfun(@(x) x.Key.JD, AI)';
    %FWHM = arrayfun(@(x) x.Key.FWHM, AI)';
    
    obsData      = extractObservationData(AI);

                
    
     limMag  = obsData.LimMag;
     airmass = obsData.airmass;
     JD      = obsData.catJD;
     FWHM    = obsData.FWHM;
   
    mms = FP.setBadPhotToNan('BadFlags', {'Saturated', 'Negative', 'NaN', 'Spike', 'Hole', 'NearEdge'}, 'MagField', 'MAG_PSF', 'CreateNewObj', true);
    
    if all(all(FP.Data.MAG_PSF(~isnan(FP.Data.MAG_PSF(:,:))) == 25))
        lcData= 'FailedFP';
        results = 'Failed FP';
        return
    end
    if all(FP.Data.MAG_PSF(~isnan(FP.Data.MAG_PSF(:,1)),1) == 25)
        lcData= 'FailedFP';
        results = 'Failed FP';
        return
    end
    
    
    r = lcUtil.zp_meddiff(mms, 'MagField', {'MAG_PSF'}, 'MagErrField', {'MAGERR_PSF'},'MinNsrc',1);
    [ms, ~] = applyZP(mms, r.FitZP, 'ApplyToMagField', {'MAG_PSF'});
    NdetGood = sum(~isnan(ms.Data.MAG_PSF), 1);
    Fndet = NdetGood > ms.Nepoch - 4;
    Fndet(1) = 1;
    ms = ms.selectBySrcIndex(Fndet, 'CreateNewObj', false);
    FP = ms;
    lcData.lc = ms.Data.MAG_PSF(:,1);
    lcData.JD = ms.JD;
    

    
    
    lcData.limMag = limMag;
    lcData.catJD = JD;
    lcData.Airmass = airmass;

    lcData.FWHM = FWHM;
    lcData.Table.FieldID = AI(1).HeaderData.Key.FIELDID;
    lcData.Table.Subframe = AI(1).HeaderData.Key.CROPID;
    lcData.Table.Airmass = median(airmass,'omitnan');
    lcData.Table.fwhm  = median(FWHM,'omitnan');
    lcData.Table.RA = ra;
    lcData.Table.Dec = dec;
    lcData.Table.Gmag = wdTable.Gmag(Iwd);
    lcData.Table.BpRp = wdTable.BPmag(Iwd) - wdTable.RPmag(Iwd);
    lcData.Table.Pwd = wdTable.Pwd(Iwd);
    lcData.Table.AbsMag = wdTable.Gmag(Iwd) - (5.*log10(1000./wdTable.Plx(Iwd))-5);
    
    
    [~, fname, ~] = fileparts(AI(1).Key.FILENAME);
    part = strsplit(fname, '_');
    lcData.Tel = part{1};
    lcData.Date = part{2};
    lcData.Ctrl = WDtransits3.getCloseControl(ms, 1, {}, ra, dec);
    enssembeleLC = lcData.Ctrl.medLc;
    deltaMag = lcData.lc - enssembeleLC;
    relFlux = 10.^(-0.4 * deltaMag);
    lcData.relFlux = relFlux / median(relFlux, 'omitnan');
    lcData.typicalSD = std(lcData.lc, 'omitnan');
    lcData.typScatter = std(lcData.relFlux, 'omitnan');
    lcData.nanIndices = isnan(lcData.lc);
    args.Ndet = sum(~isnan(lcData.lc));
    args.Nvisits = 100000;
    args.runMeanFilterArgs = {'Threshold', 6, 'StdFun', 'OutWin'};
    results = WDtransits3.detectTransits(lcData, args);

    
    results.res.Detected = ~isempty(results.detection1.events) || ~isempty(results.detection2.events);
    results.res.FluxDetected = ~isempty(results.detection1flux.events) || ~isempty(results.detection2flux.events);
    results.res.Methods = [~isempty(results.detection1.events), ~isempty(results.detection2.events)];
    results.res.FluxMethods = [~isempty(results.detection1flux.events), ~isempty(results.detection2flux.events)];
    
   % figure()
   % WDtransits3.plotLightCurve({results}, 1, 1, lcData, results.res.Methods, lcData.relFlux, results.res.FluxMethods);


end