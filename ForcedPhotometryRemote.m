function ForcedPhotometryRemote(cropID, ra, dec)
    addpath('~/Documents/WDsurvey/');
    rePath = '/last05w/data2/archive/LAST.01.05.04_re/2024/11/28/proc/';
    matFilePath = '~/Documents/WD_survey/TempMarvinRun/81.126996_42.747260_LAST.01.05.04_2024-11-28_2_1304.WD_Row387.mat';
    removePath = '/last05w/data2/archive/LAST.01.05.04_re/2024/11/28/';
    AI = loadFilesForPhotometry(rePath, cropID);
    FP = imProc.sources.forcedPhot(AI, 'Coo', [ra, dec], ...
        'ColNames', {'RA', 'Dec', 'X', 'Y', 'Xstart', 'Ystart', 'Chi2dof', ...
        'FLUX_PSF', 'FLUXERR_PSF', 'MAG_PSF', 'MAGERR_PSF', 'BACK_ANNULUS', ...
        'STD_ANNULUS', 'FLUX_APER', 'FLAG_POS', 'FLAGS'}, ...
        'MomentMaxIter', 10, 'UseMomCoo', true, 'HeaderZP', true, 'ReconstructPSF', false);
    mms = FP.setBadPhotToNan('BadFlags', {'Saturated', 'Negative', 'NaN', 'Spike', 'Hole', 'NearEdge'}, ...
        'MagField', 'MAG_PSF', 'CreateNewObj', true);

    FP
    r = lcUtil.zp_meddiff(mms, 'MagField', {'MAG_PSF'}, 'MagErrField', {'MAGERR_PSF'}, 'MinNsrc', 1);
    [ms, ~] = applyZP(mms, r.FitZP, 'ApplyToMagField', {'MAG_PSF'});

    % Filter detections
    NdetGood = sum(~isnan(ms.Data.MAG_PSF), 1);
    Fndet = NdetGood > ms.Nepoch - 4;
    Fndet(1) = 1;
    ms = ms.selectBySrcIndex(Fndet, 'CreateNewObj', false);

    save(matFilePath, 'ms');
    fprintf('Complete')
    rmdir(removePath, 's');
end
