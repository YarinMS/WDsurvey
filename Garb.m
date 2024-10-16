
AI = loadFilesForPhotometry(pwd, 13)
tic ;
FP = imProc.sources.forcedPhot(AI,'Coo',[26.682 33.323],'ColNames',{'RA','Dec','X','Y','Xstart','Ystart','Chi2dof','FLUX_PSF','FLUXERR_PSF','MAG_PSF','MAGERR_PSF','BACK_ANNULUS', 'STD_ANNULUS','FLUX_APER','FLAG_POS','FLAGS'});
to     = toc

r = lcUtil.zp_meddiff(FP, 'MagField',{'MAG_PSF'}, 'MagErrField',{'MAGERR_PSF'});
            [mms, ~] = applyZP(FP, r.FitZP, 'ApplyToMagField',{'MAG_PSF'});
            
            
T = datetime(FP.JD,'convertfrom','jd');
figure(); plot(T,FP.Data.MAG_PSF(:,1),'-ok') ; set(gca,'YDir','reverse')

hold on; plot(T,mms.Data.MAG_PSF(:,1),'-or') ; 