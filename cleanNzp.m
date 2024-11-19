function [mms] = cleanNzp(ms,args)
% cleanMatchedSources gets an MS object, merges it. filtering sources with
% NaNs > 3*args.Nvisit (up to 3 nans per visit allowed). All surviving
% points NaN are going to limiting magnitude as an upper bound. Then, all
% bad flags goes to NaN and XP calibration is applied

    % Filter sources with sufficient detections
    if size(ms,2) > 1
        ms = mergeByCoo(ms, ms(1));
    end
    
    try
        
        ms.bestMag;
        
    catch
        
        ms.Data.MAG_BEST = ms.Data.MAG_PSF;
        
    end
    
     
     % Consider all sources with NdetPts > args.Ndet measurements then NaNs. 
     NdetGood = sum(~isnan(ms.Data.MAG_BEST), 1);
     Fndet = NdetGood >= (ms.Nepoch-0.95*ms.Nepoch);

     ms = ms.selectBySrcIndex(Fndet, 'CreateNewObj', false);
     ms.sortData;
     
    
    
    % Now set bad flag points to NaN in all apertures
    mms = ms.setBadPhotToNan('BadFlags', args.BadFlags, 'MagField', 'MAG_PSF', 'CreateNewObj', true);
    nans = isnan(mms.Data.MAG_PSF);
    mms.Data.MAG_APER_3(nans) = nan;
    mms.Data.MAG_APER_2(nans) = nan;
    mms.Data.MAG_BEST(nans) = nan;
 
    NdetGood = sum(~isnan(mms.Data.MAG_PSF), 1);
    Fndet = NdetGood >= (mms.Nepoch-0.95*mms.Nepoch);
  
    mms = mms.selectBySrcIndex(Fndet, 'CreateNewObj', false);
    % Apply zero point correction

    r = lcUtil.zp_meddiff(mms, 'MagField', {'MAG_PSF'}, 'MagErrField', {'MAGERR_PSF'});
    [mms, ~] = applyZP(mms, r.FitZP, 'ApplyToMagField', 'MAG_PSF');

    r = lcUtil.zp_meddiff(mms, 'MagField', {'MAG_APER_3'}, 'MagErrField', {'MAGERR_APER_3'});
    [mms, ~] = applyZP(mms, r.FitZP, 'ApplyToMagField', 'MAG_APER_2');
    [mms, ~] = applyZP(mms, r.FitZP, 'ApplyToMagField', 'MAG_APER_3');

     r = lcUtil.zp_meddiff(mms, 'MagField', {'MAG_BEST'}, 'MagErrField', {'MAGERR_APER_3'});
    [mms, ~] = applyZP(mms, r.FitZP, 'ApplyToMagField', 'MAG_BEST');
    
end