%% color term

%% Apply Forced Photometry
WDInx = 1;

[AirMass,FP,MS,Robust_parameters] = e.Forced1(e,'Index',WDInx,'FieldID',e.FieldID(WDInx),'ID',e.CropID(WDInx));

%% COPY FP (for ZP mediff comparison)
MS = FP.copy();
% apply zp meddiff on copy
R = lcUtil.zp_meddiff(MS,'MagField','MAG_PSF','MagErrField','MAGERR_PSF');
                             
[MS,ApplyToMagFieldr] = applyZP(MS, R.FitZP,'ApplyToMagField','MAG_PSF');

%%

% run lsq detrend
StartInd = 1;
EndInd   = length(FP.JD);




        [H,CN] = imUtil.calib.calibDesignMatrix(7, 5, 'Sparse',Args.Sparse,...
                                                               'ZP_PrefixName',Args.ZP_PrefixName,...
                                                               'MeanMag_PrefixName',Args.MeanMag_PrefixName,...
                                                               'StarProp',{[0.2 0.6 -0.1 0.36 1.05]'},...
                                                               'StarPropNames','color',...
                                                               'ImageProp',Args.ImageProp,...
                                                               'ImagePropNames',Args.ImagePropNames,...
                                                               'AddCalibBlock',AddCalibBlock);




Color = {FP.SrcData.phot_bp_mean_mag - FP.SrcData.phot_rp_mean_mag } ; 
Color{1}(1) = e.LC_coadd 
[Res,Model,GoodFlagSources] = lsqRelPhotByEranSlices(FP,'StartInd',StartInd,'EndInd',EndInd,...
        'Niter', 2,'obj',e,'wdt',WDInx,'StarProp',Color,'StarPropNames','Color')
    r     = reshape(Res.Resid,[EndInd - StartInd + 1,FP.Nsrc]);
    model = reshape(Model,[EndInd - StartInd + 1,FP.Nsrc]);
    [rms1,meanmag1]  = CalcRMS(MS.SrcData.phot_g_mean_mag,r,e,WDInx,'Marker','xk','Predicted',true)
    FP.plotRMS('Fieldx','MAG_PSF','PlotColor',"#7E2F8E"','PlotSymbol','*') 
    hold on
    MS.plotRMS('Fieldx','MAG_PSF','PlotColor','#77AC30','PlotSymbol','x')
    hold on
    semilogy(median(MS.Data.MAG_PSF,'omitnan'),rms1,'o','Color','#D95319')
xlim([10 20])
legend('Uncalibrated','ZP mediff','$$ Zp_i +M_j + \beta(B_p-R_p)_j$$','Interpreter','latex')