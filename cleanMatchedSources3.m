function [mms,originalNans] = cleanMatchedSources3(ms, args)
% cleanMatchedSources gets an MS object, merges it. filtering sources with
% NaNs > 3*args.Nvisit (up to 3 nans per visit allowed). All surviving
% points NaN are going to limiting magnitude as an upper bound. Then, all
% bad flags goes to NaN and XP calibration is applied

    % Filter sources with sufficient detections
    if size(ms,2) > 1
        ms = mergeByCoo(ms, ms(args.mergeBy));
    end
    
     ind = ms.coneSearch(args.RA,args.Dec,6).Ind ; 
     % Consider all sources with all nans sources with NdetPts > args.Ndet. 
     NdetGood = sum(~isnan(ms.Data.MAG_PSF), 1);
     Fndet = NdetGood > (ms.Nepoch-0.80*ms.Nepoch);
     Fndet(ind) = true;
     ms = ms.selectBySrcIndex(Fndet, 'CreateNewObj', false);
     ms.sortData;
     ind = ms.coneSearch(args.RA,args.Dec,6).Ind ; % make sure ind is still on source.
   
     jd = ms.JD;
     limMag = args.LimMag;
     limMagt = args.catJD;
     [limMagt, sorted] = sort(args.catJD);
      limMag = args.LimMag(sorted);
            
    % Check if JD needs sorting
    if size(jd,1) == size(limMag,1)
        if mean(abs(jd - limMagt)) > 20 / (24 * 60)
            [limMagt, sorted] = sort(args.catJD);
            limMag = args.LimMag(sorted);
            
            fprintf('\nSorted JD');
            
            % Double-check after sorting
            if mean(abs(jd - limMagt)) > 20 / (24 * 60)
               % error('\nProblem with JD and lim mag JD. Please check.\n');
            end
        end
    end
    
    % Move NaN points (not bad flags) to the limiting magnitude
    % NaN --> limiting magnitude = no detection + all flags ==> no det +
    % not bad flags (but NaNs)
    nanIdx = isnan(ms.Data.MAG_PSF);
    originalNans = isnan(ms.Data.MAG_PSF(:,ind));
    if size(jd,1) == size(limMag,1)
    for i = 1 : size(nanIdx,1)
        
        if sum(nanIdx(i,:)) > 0
            nanSrc = nanIdx(i,:);

            ms.Data.MAG_PSF(i,nanSrc) = limMag(i); 
            ms.Data.MAG_APER_3(i,nanSrc) = limMag(i);
            ms.Data.MAG_APER_2(i,nanSrc) = limMag(i);
        end
    end
    end
    
    % Now set bad flag points to NaN in all apertures
    mms = ms.setBadPhotToNan('BadFlags', args.BadFlags, 'MagField', 'MAG_PSF', 'CreateNewObj', true);
    nans = isnan(mms.Data.MAG_PSF);
    mms.Data.MAG_APER_3(nans) = nan;
    mms.Data.MAG_APER_2(nans) = nan;
    ind = mms.coneSearch(args.RA,args.Dec,6).Ind ; 
    NdetGood = sum(~isnan(mms.Data.MAG_PSF), 1);
    Fndet = NdetGood > (mms.Nepoch-0.80*ms.Nepoch);
    Fndet(ind) = true;
    mms = mms.selectBySrcIndex(Fndet, 'CreateNewObj', false);
    % Apply zero point correction

    r = lcUtil.zp_meddiff(mms, 'MagField', {'MAG_PSF'}, 'MagErrField', {'MAGERR_PSF'});
    [mms, ~] = applyZP(mms, r.FitZP, 'ApplyToMagField', 'MAG_PSF');

    r = lcUtil.zp_meddiff(mms, 'MagField', {'MAG_APER_3'}, 'MagErrField', {'MAGERR_APER_3'});
    [mms, ~] = applyZP(mms, r.FitZP, 'ApplyToMagField', 'MAG_APER_2');
    [mms, ~] = applyZP(mms, r.FitZP, 'ApplyToMagField', 'MAG_APER_3');
    
end