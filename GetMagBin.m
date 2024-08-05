function [LCs] = GetMagBin(MS,Args)

arguments
    MS MatchedSources
    Args.MagMax   = 18.6;
    Args.MagMin   = 18.5;
    Args.ApplyZP  = true;
    Args.BadFlags = {'Overlap','NearEdge','CR_DeltaHT','Saturated','NaN','Negative'};
    Args.Ndet     =19;
end

MMS = MS.setBadPhotToNan('BadFlags',Args.BadFlags, 'MagField','MAG_PSF', 'CreateNewObj',true);
        
% Remove sources with NdetGood<MinNdet
NdetGood = sum(~isnan(MMS.Data.MAG_PSF), 1);
Fndet    = NdetGood>Args.Ndet;
Result.Ndet     = sum(Fndet);


if Result.Ndet == 0
    LCs = [];
    return
end



% good stars found
MMS      = MMS.selectBySrcIndex(Fndet, 'CreateNewObj',false);


if Args.ApplyZP

    Rzp = lcUtil.zp_meddiff(MMS, 'MagField','MAG_PSF', 'MagErrField','MAGERR_PSF');
    
    MMS.applyZP(Rzp.FitZP);

end

flag1 = mean(MMS.Data.MAG_PSF,'omitnan') > Args.MagMin;
indices = find(flag1 == 1);
flag2   = mean(MMS.Data.MAG_PSF(:,indices),'omitnan') < Args.MagMax;
Index = indices(flag2);

LCs = MMS.Data.MAG_PSF(:,Index)
end