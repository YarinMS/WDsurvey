% plot all together
% RMS plot

MSpsf.plotRMS('FieldX','MAG_PSF','PlotSymbol','o','PlotColor','#EDB120')
hold on
MSaper.plotRMS('FieldX','MAG_APER_3','PlotSymbol','o','PlotColor','#D95319')
FP2.plotRMS('FieldX','MAG_PSF','PlotSymbol','o','PlotColor','#0072BD')
legend('Mag PSF','Mag Aper 3','Forced Phot uncalibrated','Interpreter','latex','Location','best')
title('RMS Vs MAG for 200 epochs (Forced Phot product)[$$01.02.02\_20230822\_017$$]','Interpreter','latex')
xlim([10,20])

hold off

    % run lsq detrend
    [R,Model,GoodFlagSources] = lsqRelPhotByEranSlices(FP2,'StartInd',1,'EndInd',length(FP2.JD),...
        'Niter', 2,'obj',obj,'wdt',wdt)
    r     = reshape(R.Resid,[FP2.Nepoch,FP2.Nsrc]);
    model = reshape(Model,[FP2.Nepoch,FP2.Nsrc]);

    [rms1,meanmag1]  = CalcRMS(FP2.SrcData.phot_g_mean_mag,r,obj,wdt,'Marker','xk','Predicted',false)
close;
    
Xaxis = median(FP2.Data.MAG_PSF,'omitnan')
hold on
MSpsf.plotRMS('FieldX','MAG_PSF','PlotSymbol','o','PlotColor','#EDB120')

MSaper.plotRMS('FieldX','MAG_APER_3','PlotSymbol','o','PlotColor','#D95319')
%FP2.plotRMS('FieldX','MAG_PSF','PlotSymbol','o','PlotColor','#0072BD')

title('RMS Vs MAG for 200 epochs [$$01.02.01\_20230827\_010$$]','Interpreter','latex')
xlim([10,20])

FP3 = FP2.copy()
Rz = lcUtil.zp_meddiff(FP3,'MagField','MAG_PSF','MagErrField','MAGERR_PSF')
                  
[FP3,ApplyToMagFieldr] = applyZP(FP3, Rz.FitZP,'ApplyToMagField','MAG_PSF');
           
FP3.plotRMS('FieldX','MAG_PSF','PlotSymbol','o','PlotColor','#7E2F8E')
semilogy(Xaxis,rms1,'o','Color','#77AC30')
legend('Mag PSF','Mag Aper 3','Forced Phot + ZP meddiff','Forced Phot + lsq','Mean Mag = 17.15','RMS = 0.06','Interpreter','latex','Location','best')


% you need FP2 for the color term change
StartInd = 1;
EndInd   = length(FP2.JD);
WDInx = 1

Color = {FP2.SrcData.phot_bp_mean_mag - FP2.SrcData.phot_rp_mean_mag } ; 
Color{1}(1) = obj.LC_coadd 

% run lsq detrend
    [R2,Model2,GoodFlagSources2] = lsqRelPhotByEranSlicesV2(FP2,'StartInd',1,'EndInd',length(FP2.JD),...
        'Niter', 2,'obj',obj,'wdt',wdt)
    [Res2,Model2,GoodFlagSources2] = lsqRelPhotByEranSlicesV2(FP2,'StartInd',StartInd,'EndInd',EndInd,...
        'Niter', 2,'obj',obj,'wdt',WDInx,'StarProp',Color,'StarPropNames','Color')
    
    r2     = reshape(Res2.Resid,[FP2.Nepoch,FP2.Nsrc]);
    model2 = reshape(Model2,[FP2.Nepoch,FP2.Nsrc]);

    [rms1,meanmag1]  = CalcRMS(FP2.SrcData.phot_g_mean_mag,r2,obj,wdt,'Marker','xk','Predicted',false)
close;
 [rms1,meanmag1]  = CalcRMS(MS.SrcData.phot_g_mean_mag,r,e,WDInx,'Marker','xk','Predicted',true)
    FP2.plotRMS('Fieldx','MAG_PSF','PlotColor',"#7E2F8E"','PlotSymbol','*') 
    hold on
   FP3.plotRMS('Fieldx','MAG_PSF','PlotColor','#77AC30','PlotSymbol','x')
    hold on
    semilogy(median(FP2.Data.MAG_PSF,'omitnan'),rms1,'o','Color','#D95319')
xlim([10 20])










subplot(3,1,1)

t0 = round(FP2.JD(1))-0.5
plot(t1-t0,y1,'o','Color',"#D95319")
xlabel(sprintf('JD - %d',t0),'Interpreter' ,'latex')
ylabel('Inst Mag','Interpreter' ,'latex')
set(gca , 'YDir','reverse')
title(sprintf('200 epochs Light Curve. Gaia G mag = $$ %.2f$$',obj.Mag(1)),'Interpreter','latex')
legend(sprintf('Aper 3 RMS = %.3f',total_rms_aper3),'Interpreter','latex')
%ylim([m-3*SD,m+3*SD])
subplot(3,1,2)
plot(t2-t0,y2,'o','Color',"#D95319")
xlabel(sprintf('JD - %d',t0),'Interpreter' ,'latex')
ylabel('Inst Mag','Interpreter' ,'latex')
legend(sprintf('PSF RMS = %.3f',total_rms_psf),'Interpreter','latex')
set(gca , 'YDir','reverse')
subplot(3,1,3)
plot(FP2.JD-t0,r(:,1) - mean(r(:,1),'omitnan')+mean(FP2.Data.MAG_PSF(:,1),'omitnan'),'o','Color',"#D95319")

LgLbl{5} = sprintf('Residual + mean signal ; RobustSD : %.3f',RobustSD(r(:,1)))
xlabel(sprintf('JD - %d',t0),'Interpreter' ,'latex')
ylabel('Inst Mag','Interpreter' ,'latex')
legend(LgLbl(5),'Location','best','Interpreter','latex')
   
    LgLbl{5} = sprintf('ZP ; RobustSD : %.3f',RobustSD(FP3.Data.MAG_PSF(:,1)))
%ylim([m2-3*SD,m2+3*SD])

Coord = [median(FP2.Data.RA,'omitnan')'  median(FP2.Data.Dec,'omitnan')'] ; 
size(Coord)

MSpsf.coneSearch(Coord(:,1),Coord(:,2))