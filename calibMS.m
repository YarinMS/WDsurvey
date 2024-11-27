function mms = calibMS(ms,Args)

arguments
    ms 
    Args.BadFlags = {'Saturated', 'Negative', 'NaN', 'Spike', 'Hole', 'NearEdge'};
    Args.MinDet   = 0.15*ms.Nepoch;
end


% Setting bad Photometry to NaN.

mms = ms.setBadPhotToNan('BadFlags', Args.BadFlags, 'MagField', 'MAG_PSF', 'CreateNewObj', true);

% Consider all sources with all nans sources with NdetPts > args.Ndet. 
NdetGood = sum(~isnan(mms.Data.MAG_PSF), 1);
Fndet = NdetGood > Args.MinDet; % Allow for 15% no detections per source.
mms = mms.selectBySrcIndex(Fndet, 'CreateNewObj', false);
% use bestMag to get the best photometry for a source ( aper 3 / psf)
%mms.bestMag


% Apply zero point correction to mag fields
try
r = lcUtil.zp_meddiff(mms, 'MagField', {'MAG_BEST'}, 'MagErrField', {'MAGERR_PSF'});
[mms, ~] = applyZP(mms, r.FitZP, 'ApplyToMagField', 'MAG_BEST');


%% you can apply zp correction to every mag field in MS
r = lcUtil.zp_meddiff(mms, 'MagField', {'MAG_PSF'}, 'MagErrField', {'MAGERR_PSF'});
[mms, ~] = applyZP(mms, r.FitZP, 'ApplyToMagField', 'MAG_PSF');

r = lcUtil.zp_meddiff(mms, 'MagField', {'MAG_APER_3'}, 'MagErrField', {'MAGERR_APER_3'});
[mms, ~] = applyZP(mms, r.FitZP, 'ApplyToMagField', 'MAG_APER_2');
[mms, ~] = applyZP(mms, r.FitZP, 'ApplyToMagField', 'MAG_APER_3');

catch
    mms = mms
end



end