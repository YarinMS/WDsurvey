% compare ZPmeddiff with lsq (1 and 2 iteration)


% A target defines a subframe 
%% List of targets
%% 270823

% field : 358+34
% coord : 358.881, 35.611

Targets1    = [

358.2490939340986	36.95602899310303	17.766068
359.6851110826381	35.56350936019282	18.70435
359.6496874215545	35.947638239844196	18.77262
358.81723529471816	36.048045855693054	16.934488
358.6261971650937	34.629180876873704	17.730215
358.60691617395423	36.080867682915624	17.409506
358.92623274836905	35.35949500332723	17.104704
358.47915664652015	36.1911456395325	17.282484
359.54269238125187	35.918701995030695	18.937252
358.4299172754524	36.374603327370025	17.795748
358.4737008898914	35.95696032498315	18.35812
358.1404232183327	36.324798719214535	17.94189
357.9510593069834	36.336222685272446	17.724937
357.8128762230127	35.86549520862897	18.908047


]

TargetsName1 = [
'WDJ235300.03+365723.82',
'WDJ235844.68+353353.83',
'WDJ235835.92+355652.22',
'WDJ235516.48+360253.89',
'WDJ235430.18+343745.73',
'WDJ235425.63+360451.07',
'WDJ235542.33+352134.38',
'WDJ235355.00+361128.46',
'WDJ235810.18+355507.50',
'WDJ235343.17+362228.63',
'WDJ235353.60+355725.51',
'WDJ235233.66+361929.47',
'WDJ235148.36+362011.25',
'WDJ235115.08+355156.23'


]


% Initilize WD object

e  = WD(Targets1(:,1),Targets1(:,2),Targets1(:,3),TargetsName1,'/last02e/data1/archive/LAST.01.02.01/2023/08/27/proc/000540v0')

e.LC_FP = [
18.02604
19.063189
19.274632
17.035667
17.766941
17.480482
17.069855
17.303087
19.040138
17.53455
18.366528
17.892187
17.673506
18.907557
];


ms = MS1(10)
% finding ZP for MAG_APER_3
R = lcUtil.zp_meddiff(ms,'MagField','MAG_APER_3','MagErrField','MAGERR_APER_3');
% finding ZP for MAG_PSF   ### please note that MAG_PSF dont have
%'MAgFieldERR' so I use MAGERR_APER_2.
Rpsf= lcUtil.zp_meddiff(ms,'MagField','MAG_PSF','MagErrField','MAGERR_PSF');
[MSaper,ApplyToMagFieldr] = applyZP(ms, R.FitZP,'ApplyToMagField','MAG_APER_3');
[MSpsf,ApplyToMagFieldr] = applyZP(ms, Rpsf.FitZP,'ApplyToMagField','MAG_PSF');
% get LC by index :
index_psf = MSpsf.coneSearch(obj.RA(j),obj.Dec(j)).Ind;

LgLbl{3} = sprintf('Background  ; Avg = %.3f ; SD = %.3f ; Scatter = %.3f ',[mean(BG), std(BG),std(BG)/mean(BG)])
LgLbl{4} = sprintf('3 arcsec Aper  ; Avg = %.3f ; SD = %.3f ;Scatter = %.3f',[mean(AA), std(AA),std(AA)/mean(AA)])
LgLbl{5} = sprintf('Signal  ; Avg = %.3f ;  SD = %.3f  ; Scatter = %.3f  ',[mean(S),  std(S), std(S)/mean(S)])
LgLbl{6} = sprintf('Cat PSF  ; Avg = %.3f ; SD = %.3f ; Scatter = %.3f',[mean(MSpsf.Data.FLUX_APER_3(:,index_psf)),std(MSpsf.Data.FLUX_APER_3(:,index_psf)),std(MSpsf.Data.FLUX_APER_3(:,index_psf))/mean(MSpsf.Data.FLUX_APER_3(:,index_psf))])
plot(BG,'-s')
hold on
plot(AA,'-o')
legend('BackGround','Aperture 3 arcsec ','Interpreter','latex')
ylabel('Electrons','Interpreter','latex')
xlabel('Frames','Interpreter','latex')
errorbar([1:20],S,S./SNR,'-*')
errorbar([1:20],MSpsf.Data.FLUX_APER_3(:,index_psf),MSpsf.Data.FLUX_APER_3(:,index_psf)./MSpsf.Data.FLUX_APER_3(:,index_psf),MSpsf.Data.SN_2(:,index_psf),'-.')
legend(LgLbl(3:6),'Location','best','Interpreter','latex')
B

e.LC_coadd = [
0.66524506
0.83859444
1.1449165
0.27044868
0.10054207
0.15999031
-0.15054321
0.002916336
0.20973015
0.17264175
-0.0855999
-0.1247921
-0.20863533
-0.096063614
]
% find their CropID and find them in catalog data
      % no lim mag calculations
[id,FieldId] = e.Coo_to_Subframe(e.Pathway,e);
e  = e.get_id(id(:,1));
e  = e.get_fieldID(FieldId);
[Index,cat_id] = e.find_in_cat(e);
e  = e.get_cat_id(cat_id);

% catalog extracion

[t_psf,y_psf,t_aper,y_aper,Info_psf,Info_aper, ... 
               flager,t_rms_aper,t_rms_psf,t_rms_flux,Rms_aper,Rms_psf, ... 
               rms_flux,t_flux,f_flux,total_rms_flux,magerr,magerrPSF] = e.get_LC_cat(e,20,30);
           
e.LC_psf   = {t_psf;y_psf;magerrPSF};
e.LC_aper  = {t_aper;y_aper;magerr};
e.Flux     = {t_flux;f_flux};
e.FluxRMS  = total_rms_flux;
e.InfoPsf  = Info_psf;
e.InfoAper = Info_aper;
%e.R      = {t_rms_aper Rms_aper ; t_rms_psf Rms_psf; t_rms_flux rms_flux };


%% choose a target to Forced phot 
for Itgt = 1 : numel(e.RA)
    
    if (e.CropID(Itgt) == 10) && (Itgt ~= 4)
        
        wdt = Itgt ;
        
       fprintf('Taking Target %s from SF 10\n ', e.Name(wdt,:))
       
       break;
       
    end
    
end


target = e.Name(wdt,:);

wdt = 12;

%% apply forced photometry
[AirMass,FP,MS,Robust_parameters] = e.Forced1(e,'Index',wdt,'FieldID',e.FieldID(wdt),'ID',e.CropID(wdt));

% COPY FP
MS = FP.copy();
% apply zp meddiff on copy
R = lcUtil.zp_meddiff(MS,'MagField','MAG_PSF','MagErrField','MAGERR_PSF')
                             
[MS,ApplyToMagFieldr] = applyZP(MS, R.FitZP,'ApplyToMagField','MAG_PSF');

                  
% plot RMS VS MAG of zp no zp 
%figure(1);
%subplot(2,2,1)

FP.plotRMS('FieldX','MAG_PSF','PlotColor','black')

hold on

MS.plotRMS('FieldX','MAG_PSF','PlotColor','red','PlotSymbol','o')


MS.sysrem('MagFields',{'MAG_PSF'},'MagErrfields',{'MAGERR_PSF'})
MS.plotRMS('FieldX','MAG_PSF','PlotColor','green','PlotSymbol','x')

MS.sysrem('MagFields',{'MAG_PSF'},'MagErrfields',{'MAGERR_PSF'})
MS.plotRMS('FieldX','MAG_PSF','PlotColor','blue')


legend('Raw product','ZP meddiff','Meddiff + SysRem','Meddiff + 2 SysRem','Location','best')
title('WD235516',...
    'Interpreter','latex')

xlim([10 ,20])
hold off

% detrend no ZP with simple model 

[D,ref,Refstars,Mod] =  lsqRelPhotByEran(FP,'Niter', 1);
d                = reshape(D.Resid,[FP.Nepoch,FP.Nsrc]);
ref_index        = cell2mat(Refstars);
[rms0,meanmag0]  = CalcRMS(FP.SrcData.phot_g_mean_mag,d,e,wdt,'Marker','xk','Predicted',false)
hold on
FP.plotRMS('FieldX','MAG_PSF','PlotColor','blue','PlotSymbol','o')
MS.plotRMS('FieldX','MAG_PSF','PlotColor','red')
semilogy(FP.SrcData.phot_g_mean_mag(ref_index),rms0(ref_index),'gx')
% plot targets you used for lsq
lg = legend('1 LSQ iteration','Raw product','ZPmeddiff','Used stars','Location','best')
lg.Interpreter= 'latex';
xlim([10 , 20])
hold off

[DD,reff,FR,Mod] =  lsqRelPhotByEranV4(FP,'Niter', 2,'obj',e,'wdt',wdt)
dd         = reshape(DD.Resid,[FP.Nepoch,FP.Nsrc])
model      = reshape(Mod,[FP.Nepoch,FP.Nsrc]);
[rms1,meanmag1]  = CalcRMS(FP.SrcData.phot_g_mean_mag,dd,e,wdt,'Marker','xk','Predicted',false)
hold on
FP.plotRMS('FieldX','MAG_PSF','PlotColor','blue','PlotSymbol','o')
MS.plotRMS('FieldX','MAG_PSF','PlotColor','red')
xlim([10 , 20])
ref_index        = FR;
semilogy(FP.SrcData.phot_g_mean_mag(ref_index),rms1(ref_index),'gx')
lg = legend('2 LSQ iteration','Raw product','ZPmeddiff','Used stars','Location','best')
lg.Interpreter= 'latex';

hold off



%% plot the model










%% plot light curves with model
dt = round(FP.JD(1))-0.5;

c = 0 ;
figure(2);

for i = 1 : length(ref_index)
ix = i ;
%%
subplot(3,1,1)
plot(FP.JD-dt,FP.Data.MAG_PSF(:,ref_index(ix)),'k.')
hold on 
plot(MS.JD-dt,MS.Data.MAG_PSF(:,ref_index(ix)),'ro')
LgLbl{1} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(:,ref_index(ix))))
LgLbl{2} = sprintf('ZP meddiff ; RobustSD : %.3f',RobustSD(MS.Data.MAG_PSF(:,ref_index(ix))))
legend(LgLbl(1:2),'Location','bestoutside','Interpreter','latex')
set(gca , 'YDir','reverse')
title(strcat('Relative calibration comparison. SF $$ \# \ $$' ,num2str(e.CropID(wdt))),'Interpreter','latex') 
xlabel(strcat('Source $$B_p$$ = ',num2str(e.LC_FP(wdt))),'Interpreter','latex') %FP.SrcData.phot_bp_mean_mag(ref_index(ix)))),'Interpreter','latex')

subplot(3,1,2)
plot(FP.JD-dt,FP.Data.MAG_PSF(:,ref_index(ix)),'k.')
hold on 
plot(FP.JD-dt,model(:,ref_index(ix)),'ro')
LgLbl{3} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(:,ref_index(ix))))
LgLbl{4} = sprintf('$$ ZP_i +M_j $$ ; RobustSD : %.3f',RobustSD(model(:,ref_index(ix))))
legend(LgLbl(3:4),'Location','bestoutside','Interpreter','latex')
set(gca , 'YDir','reverse')
xlabel(['JD - ',num2str(dt)],'Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')

subplot(3,1,3)
plot(FP.JD-dt,FP.Data.MAG_PSF(:,ref_index(ix)),'k.')
hold on 
plot(FP.JD-dt,dd(:,ref_index(ix)) - mean(dd(:,ref_index(ix)),'omitnan')+mean(FP.Data.MAG_PSF(:,ref_index(ix)),'omitnan'),'ro')
LgLbl{5} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(:,ref_index(ix))))
LgLbl{6} = sprintf('Residual + mean signal ; RobustSD : %.3f',RobustSD(dd(:,ref_index(ix))))
legend(LgLbl(5:6),'Location','bestoutside','Interpreter','latex')
set(gca , 'YDir','reverse')
ylabel('Residuals')
%%
set(gcf, 'Position', get(0, 'ScreenSize'));
pause(5);
c = c+1;
filename = ['~/Documents/WD_survey/270823/358+34/Detrend/target11_ref/',e.Name(wdt,:),'_LC_REF',num2str(c),'.png']
saveas(gcf, filename)
close ; 
%%
end




%% plot light curves
dt = round(FP.JD(1))-0.5;

c = 0 ;
figure(2);

for i = 1 : length(ref_index)
ix = i ;

subplot(3,1,1)
plot(FP.JD-dt,FP.Data.MAG_PSF(:,ref_index(ix)),'k.')
hold on 
plot(MS.JD-dt,MS.Data.MAG_PSF(:,ref_index(ix)),'ro')
LgLbl{1} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(:,ref_index(ix))))
LgLbl{2} = sprintf('ZP meddiff ; RobustSD : %.3f',RobustSD(MS.Data.MAG_PSF(:,ref_index(ix))))
legend(LgLbl(1:2),'Location','bestoutside','Interpreter','latex')
set(gca , 'YDir','reverse')
title(strcat('Relative calibration comparison. SF $$ \# \ $$' ,num2str(e.CropID(wdt))),'Interpreter','latex') 
xlabel(strcat('Source $$B_p$$ = ',num2str(FP.SrcData.phot_bp_mean_mag(ref_index(ix)))),'Interpreter','latex')

subplot(3,1,2)
plot(FP.JD-dt,FP.Data.MAG_PSF(:,ref_index(ix)),'k.')
hold on 
plot(FP.JD-dt,d(:,ref_index(ix)) - mean(d(:,ref_index(ix)),'omitnan')+mean(FP.Data.MAG_PSF(:,ref_index(ix)),'omitnan'),'ro')
LgLbl{3} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(:,ref_index(ix))))
LgLbl{4} = sprintf('1 LSQ Iter ; RobustSD : %.3f',RobustSD(d(:,ref_index(ix))))
legend(LgLbl(3:4),'Location','bestoutside','Interpreter','latex')
set(gca , 'YDir','reverse')
xlabel(['JD - ',num2str(dt)],'Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')

subplot(3,1,3)
plot(FP.JD-dt,FP.Data.MAG_PSF(:,ref_index(ix)),'k.')
hold on 
plot(FP.JD-dt,dd(:,ref_index(ix)) - mean(dd(:,ref_index(ix)),'omitnan')+mean(FP.Data.MAG_PSF(:,ref_index(ix)),'omitnan'),'ro')
LgLbl{5} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(:,ref_index(ix))))
LgLbl{6} = sprintf('2 LSQ Iter ; RobustSD : %.3f',RobustSD(dd(:,ref_index(ix))))
legend(LgLbl(5:6),'Location','bestoutside','Interpreter','latex')
set(gca , 'YDir','reverse')
%%
set(gcf, 'Position', get(0, 'ScreenSize'));
pause(5);
c = c+1;
filename = ['~/Documents/WD_survey/270823/358+34/Detrend/target11_ref/',e.Name(wdt,:),'_LC_REF',num2str(c),'.png']
saveas(gcf, filename)
close ; 
%%
end


%% RMS VS color VS pos

semilogy((FP.SrcData.phot_bp_mean_mag - FP.SrcData.phot_rp_mean_mag),rms1,'.')
xlabel(['$$ B_p - R_p$$'],'Interpreter','latex')
ylabel('RMS','Interpreter','latex')
title('RMS VS color','Interpreter','latex')
hold on 
semilogy((FP.SrcData.phot_bp_mean_mag(ref_index) - FP.SrcData.phot_rp_mean_mag(ref_index)),rms1(ref_index),'o')

legend('All sources','Stars used for calibration')

%% RMS VS position
figure;
 
logRMS = log10(rms1);

scatter(mean(FP.Data.X,'omitnan'), mean(FP.Data.Y,'omitnan'), 10, rms1, 'filled');
hold on
scatter(mean(FP.Data.X(:,1),'omitnan'), mean(FP.Data.Y(:,1),'omitnan'), 100, rms1(1), 'filled');


colormap('parula');
colorbar;
xlabel('X','Interpreter','latex');
ylabel('Y','Interpreter','latex');
title('Position VS RMS','Interpreter','latex');
%caxis([min(logRMS), max(logRMS)]);
ylabel(colorbar, 'RMS')
% plot all results 
subplot(2,2,2)

FP.plotRMS('FieldX','MAG_PSF')

hold on

MS.plotRMS('FieldX','MAG_PSF')

legend('Raw product','ZP meddiff')


% 2nd iteration cleaning

% 2nd iteration
[DD,reff] =  lsqRelPhotByEran(FP,'Niter', 2);



% find target within 150 pixels from target

Xi = median(FP.Data.X(:,1),'omitnan');
Yi = median(FP.Data.Y(:,1),'omitnan');
PixFlag = false(FP.Nsrc,1);
PixFlag(1) = true;
for i = 2 : FP.Nsrc
    
    
    X = median(FP.Data.X(:,i),'omitnan');
    Y = median(FP.Data.Y(:,i),'omitnan');
    
    Dist = sqrt((Xi-X)^2 + (Yi-Y)^2);
    
    if Dist < 150 
        
        PixFlag(i) = true;
        
    end
    
    
    
end


fprintf('\nFound %d sources within 150 pixels from the target\n',sum(PixFlag))

