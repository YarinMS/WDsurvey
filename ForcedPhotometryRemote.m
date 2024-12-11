function ForcedPhotometryRemote(cropID, ra, dec)
    addpath('~/Documents/WDsurvey/');
    rePath = '/last01w/data1/archive/LAST.01.01.03_re/2024/10/22/proc/';
    matFilePath = '~/Documents/WD_survey/TempMarvinRun/26.116749_37.981503_LAST.01.01.03_2024-10-22_10_1403.mat';
    removePath = '/last01w/data1/archive/LAST.01.01.03_re/2024/10/22/';
    AI = loadFilesForPhotometry(rePath, cropID);
    FP = imProc.sources.forcedPhot(AI, 'Coo', [ra, dec], ...
        'ColNames', {'RA', 'Dec', 'X', 'Y', 'Xstart', 'Ystart', 'Chi2dof', ...
        'FLUX_PSF', 'FLUXERR_PSF', 'MAG_PSF', 'MAGERR_PSF', 'BACK_ANNULUS', ...
        'STD_ANNULUS', 'FLUX_APER', 'FLAG_POS', 'FLAGS'}, ...
        'MomentMaxIter', 10, 'UseMomCoo', true, 'HeaderZP', true, 'ReconstructPSF', false, ...
        'constructPSFArgs', {'RepopulatePSF', true, 'ThresholdPSF', 20, ...
        'RangeSN', [50, 1000], 'RadiusPSF', 6});

    mms = FP.setBadPhotToNan('BadFlags', {'Saturated', 'Negative', 'NaN', 'Spike', 'Hole', 'NearEdge'}, ...
        'MagField', 'MAG_PSF', 'CreateNewObj', true);

    r = lcUtil.zp_meddiff(mms, 'MagField', {'MAG_PSF'}, 'MagErrField', {'MAGERR_PSF'}, 'MinNsrc', 1);
    [ms, ~] = applyZP(mms, r.FitZP, 'ApplyToMagField', {'MAG_PSF'});

    % Filter detections
    NdetGood = sum(~isnan(ms.Data.MAG_PSF), 1);
    Fndet = NdetGood > ms.Nepoch - 4;
    Fndet(1) = 1;
    ms = ms.selectBySrcIndex(Fndet, 'CreateNewObj', false);

    save(matFilePath, 'ms');
end
