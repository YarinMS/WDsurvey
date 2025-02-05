pattern= '4Cp2750'
categorizedFiles = Util.categorizeFilesBySubframe('~/marvin/LAST.01.05.01/2024/',pattern)


WData = struct();
%%
%% 
% for each subframe. create an MS obsect from all files
for S = 24
    MS = [];
    cropID = sprintf('Subframe_%02d',S);
    allFiles = categorizedFiles.(cropID);
    for If = 1: length(allFiles)
        try
            MS = [MS MatchedSources.read(allFiles{If})];
        catch
            MS = MS;
            end
        end
% some matchedosurced readList.

% merge MS
ms = mergeByCoo(MS,MS(1))
% process MS
ms.bestMag;

 % Consider all sources with NdetPts > args.Ndet measurements then NaNs. 
 NdetGood = sum(~isnan(ms.Data.MAG_BEST), 1);
 Fndet = NdetGood >= (0.70*ms.Nepoch);

 ms = ms.selectBySrcIndex(Fndet, 'CreateNewObj', false);
 ms.sortData;
 


% Now set bad flag points to NaN in all apertures
mms = ms.setBadPhotToNan('BadFlags', {'Saturated','Negative'}, 'MagField', 'MAG_PSF', 'CreateNewObj', true);

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
% now that you have matched sources combined for every subframe. look for
% WDs in the subframe of sources 

% new sources??
    mms.bestMag;
    Coords = [mean(mms.Data.RA,'omitnan')', mean(mms.Data.Dec,'omitnan')']


    for Is = 1 : height(Coords)

        WD = isWD(MS,Coords(Is,1),Coords(Is,2))
        if ~isempty(WD.Table)
            WDID = sprintf('WD_%i_%s_%i',Is,pattern,S)
            WData.(WDID) = {};
            WData.(WDID).Gaia = WD.Table;
            Idx = mms.coneSearch(Coords(Is,1),Coords(Is,2))
            WData.(WDID).LC = mms.Data.MAG_BEST(:,Idx.Ind);
  
            figure();
            plot(mms.JD,mms.Data.MAG_BEST(:,Idx.Ind),'k.')
            title([WDID,' ', sprintf('G = %.3f B_p-R_p = %.3f',WD.Table.Gmag,WD.Table.BPmag - WD.Table.RPmag)])
        end
    end

end

% cross al good targets with WDcat with Pwd > 0 
%
% Noqw you know which of the sources are WDS. 
% plot LC of WD together with its pwd its bp-rp its gmag its bp mag 
% store the image 


%%
r_pairwise = corr(v1, v2, 'Rows', 'pairwise');
disp(['Pearson correlation (pairwise NaN handling): ', num2str(r_pairwise)]);


%% GitHub Issue

% find which dates are relavents

% Create smaller MSs


% with smaller MSs:

ms1 = mergeByCoo(MS(end-10:end),MS(end-1));

ms.bestMag;

 % Consider all sources with NdetPts > args.Ndet measurements then NaNs. 
 NdetGood = sum(~isnan(ms.Data.MAG_BEST), 1);
 Fndet = NdetGood >= (0.70*ms.Nepoch);

 ms = ms.selectBySrcIndex(Fndet, 'CreateNewObj', false);
 ms.sortData;
 


% Now set bad flag points to NaN in all apertures
mms = ms.setBadPhotToNan('BadFlags', {'Saturated','Negative'}, 'MagField', 'MAG_PSF', 'CreateNewObj', true);

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
% now that you have matched sources combined for every subframe. look for
% WDs in the subframe of sources 

% new sources??
    mms.bestMag;
    Coords = [mean(mms.Data.RA,'omitnan')', mean(mms.Data.Dec,'omitnan')']

%%
    for Is = 1 : height(Coords)

        WD = isWD(MS,Coords(Is,1),Coords(Is,2))
        if ~isempty(WD.Table)
            WDID = sprintf('WD_%i_%s_%i',Is,pattern,S)
            WData.(WDID) = {};
            WData.(WDID).Gaia = WD.Table;
            Idx = mms.coneSearch(Coords(Is,1),Coords(Is,2))
            WData.(WDID).LC = mms.Data.MAG_BEST(:,Idx.Ind);
  
            figure();
            plot(mms.JD,mms.Data.MAG_BEST(:,Idx.Ind),'k.')
            title([WDID,' ', sprintf('G = %.3f B_p-R_p = %.3f',WD.Table.Gmag,WD.Table.BPmag - WD.Table.RPmag)])
        end
    end
%%