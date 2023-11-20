% compare ZPmeddiff with lsq (1 and 2 iteration)


% A target defines a subframe 
%% List of targets
%% 270823

% field : 358+34
% coord : 358.881, 35.611

Targets1    = [
    
358.2490957110293	36.956030015414214	17.766068
359.68511291074407	35.56351186545541	18.70435
359.64968737222955	35.94763859011489	18.77262
358.81723780295493	36.04804630014442	16.934488
358.6261963706165	34.62918120298527	17.730215
358.60691592710907	36.08086765592638	17.409506
358.9262330289217	35.35949509780521	17.104704
358.47915664031876	36.19114580288572	17.282484
359.5426919227249	35.91870208333357	18.937252
358.42991719218435	36.37460335780781	17.795748
358.4737002248643	35.956960544020575	18.35812
358.14042291019064	36.324798811716654	17.94189
357.95106006323556	36.33622309276605	17.724937
357.81287618304833	35.86549542303695	18.908047


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
'WDJ235115.08+355156.23',
]


% Initilize WD object

e1  = WD(Targets1(:,1),Targets1(:,2),Targets1(:,3),TargetsName1,'/last02e/data1/archive/LAST.01.02.01/2023/08/27/proc/000540v0')

e1.LC_FP = [
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

e1.LC_coadd = [
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
[id,FieldId] = e1.Coo_to_Subframe(e1.Pathway,e1);
e1  = e1.get_id(id(:,1));
e1  = e1.get_fieldID(FieldId);
[Index,cat_id] = e1.find_in_cat(e1);
e1  = e1.get_cat_id(cat_id);

% catalog extracion

[t_psf,y_psf,t_aper,y_aper,Info_psf,Info_aper, ... 
               flager,t_rms_aper,t_rms_psf,t_rms_flux,Rms_aper,Rms_psf, ... 
               rms_flux,t_flux,f_flux,total_rms_flux,magerr,magerrPSF] = e1.get_LC_cat(e1,20,30);
           
e1.LC_psf   = {t_psf;y_psf;magerrPSF};
e1.LC_aper  = {t_aper;y_aper;magerr};
e1.Flux     = {t_flux;f_flux};
e1.FluxRMS  = total_rms_flux;
e1.InfoPsf  = Info_psf;
e1.InfoAper = Info_aper;
e1.RMS      = {t_rms_aper Rms_aper ; t_rms_psf Rms_psf; t_rms_flux rms_flux };


%% choose a target to Forced phot 
for Itgt = 1 : numel(e1.RA)
    
    if (e1.CropID(Itgt) == 10) && (Itgt ~= 4)
        
        wdt = Itgt ;
        
       fprintf('Taking Target %s from SF 10\n ', e1.Name(wdt,:))
       
       break;
       
    end
    
end


target = e1.Name(wdt,:);

wdt = 12;

%% apply forced photometry
[AirMass,FP,MS,Robust_parameters] = e1.Forced1(e1,'Index',wdt,'FieldID',e1.FieldID(wdt),'ID',e1.CropID(wdt));

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
[rms0,meanmag0]  = CalcRMS(FP.SrcData.phot_g_mean_mag,d,e1,wdt,'Marker','xk','Predicted',false)
hold on
FP.plotRMS('FieldX','MAG_PSF','PlotColor','blue','PlotSymbol','o')
MS.plotRMS('FieldX','MAG_PSF','PlotColor','red')
semilogy(FP.SrcData.phot_g_mean_mag(ref_index),rms0(ref_index),'gx')
% plot targets you used for lsq
lg = legend('1 LSQ iteration','Raw product','ZPmeddiff','Used stars','Location','best')
lg.Interpreter= 'latex';
xlim([10 , 20])
hold off

[DD,reff,FR,Mod] =  lsqRelPhotByEranV4(FP,'Niter', 2,'obj',e1,'wdt',wdt)
dd         = reshape(DD.Resid,[FP.Nepoch,FP.Nsrc])
model      = reshape(Mod,[FP.Nepoch,FP.Nsrc]);
[rms1,meanmag1]  = CalcRMS(FP.SrcData.phot_g_mean_mag,dd,e1,wdt,'Marker','xk','Predicted',false)
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
title(strcat('Relative calibration comparison. SF $$ \# \ $$' ,num2str(e1.CropID(wdt))),'Interpreter','latex') 
xlabel(strcat('Source $$B_p$$ = ',num2str(e1.LC_FP(wdt))),'Interpreter','latex') %FP.SrcData.phot_bp_mean_mag(ref_index(ix)))),'Interpreter','latex')

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
filename = ['~/Documents/WD_survey/270823/358+34/Detrend/target11_ref/',e1.Name(wdt,:),'_LC_REF',num2str(c),'.png']
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
title(strcat('Relative calibration comparison. SF $$ \# \ $$' ,num2str(e1.CropID(wdt))),'Interpreter','latex') 
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
filename = ['~/Documents/WD_survey/270823/358+34/Detrend/target11_ref/',e1.Name(wdt,:),'_LC_REF',num2str(c),'.png']
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

