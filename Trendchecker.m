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


bkg =[

                   133.416
                   133.618
                   135.602
                   134.269
                   136.309
                   135.484
                   134.221
                   134.734
                   132.467
                   135.093
                   136.185
                   135.204
                     135.8
                   134.065
                   133.293
                   135.923
                   134.097
                   136.071
                    132.28
                   133.887


]


y = [

                 3034.9886
                 3050.6709
                 2935.1918
                 2907.4357
                 3093.4384
                      2956
                      3054
                 3024.6007
                 2925.6317
                 2836.8496
                 3007.5099
                 3059.8146
                 3064.4261
                 3062.1265
                 2994.5477
                  2963.441
                 2963.6295
                 3070.9438
                 3004.3816
                  2928.597
]





s =[

                  633.5006
                  645.5469
                  494.3558
                  490.5937
                  639.8764
                   517.288
                   638.022
                  599.3887
                  541.2257
                  405.1756
                  556.1799
                  626.1426
                  620.0261
                  648.9565
                  595.2737
                   516.827
                  549.8835
                  621.6658
                  623.3416
                   518.631



]

snr = [
          22.5116489255808
          22.7643494286221
           19.316701759198
          19.2447007172413
          22.6063048316298
          19.8696671545834
          22.5964542567219
          21.7546731149183
          20.4755373474493
          17.0418152618637
          20.7656355718382
          22.3288443130063
          22.1887486543247
           22.829906264388
          21.6848212143494
          19.8522817767447
          20.6515923186075
          22.2202581284448
          22.3103215337523
          19.9249873003931

]

Targets2    = [
355.95963749653237	32.545915834271376	12.966921
356.4360575211984	34.18134734187404	18.028858
357.3592105622017	33.58336931427102	16.824327
356.08191659487477	34.124560965584266	18.991856
357.3609283079529	33.849691894763524	18.721958
356.8201459425641	34.03249578681111	17.828075
355.9757638333049	31.461820549468484	18.071423
357.7784948241913	32.30777095056558	18.955025
]
TargetsName2 = [
'WDJ234350.72+323246.73',
'WDJ234544.58+341050.85',
'WDJ234926.19+333504.32',
'WDJ234419.71+340729.22',
'WDJ234926.58+335058.73',
'WDJ234716.83+340157.33',
'WDJ234354.19+312742.57',
'WDJ235106.81+321828.52'
]
% Initilize WD object
e2  = WD(Targets2(:,1),Targets2(:,2),Targets2(:,3),TargetsName2,'/last02e/data1/archive/LAST.01.02.01/2023/08/27/proc/000540v0')
% first lim mag calculations
[id,FieldId] = e2.Coo_to_Subframe(e2.Pathway,e2);
e2  = e2.get_id(id(:,1));
e2  = e2.get_fieldID(FieldId);
[Index,cat_id] = e2.find_in_cat(e2);
e2  = e2.get_cat_id(cat_id);
e2  = WD(Targets2(:,1),Targets2(:,2),Targets2(:,3),TargetsName2,'/last02e/data2/archive/LAST.01.02.02/2023/08/22/proc/000525v0')
% first lim mag calculations
[id,FieldId] = e2.Coo_to_Subframe(e2.Pathway,e2);
e2  = e2.get_id(id(:,1));
e2  = e2.get_fieldID(FieldId);
[Index,cat_id] = e2.find_in_cat(e2);
e2  = e2.get_cat_id(cat_id);
wdt = 6
format longg
e.RA
e2.RA
e2.Dec
e2.Mag
e2.RA(6)
e2.Dec(6)


MS1 = MatchedSources.read_rdir('*_sci_merged_MergedMat_*.hdf5');

ms = MS1(12)
% finding ZP for MAG_APER_3
R = lcUtil.zp_meddiff(ms,'MagField','MAG_APER_3','MagErrField','MAGERR_APER_3');
% finding ZP for MAG_PSF   ### please note that MAG_PSF dont have
%'MAgFieldERR' so I use MAGERR_APER_2.
Rpsf= lcUtil.zp_meddiff(ms,'MagField','MAG_PSF','MagErrField','MAGERR_PSF');
[MSaper,ApplyToMagFieldr] = applyZP(ms, R.FitZP,'ApplyToMagField','MAG_APER_3');
[MSpsf,ApplyToMagFieldr] = applyZP(ms, Rpsf.FitZP,'ApplyToMagField','MAG_PSF');
% get LC by index :
index_psf = MSpsf.coneSearch(e2.RA(6),e2.Dec(6)).Ind;














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
index_aper = MSaper.coneSearch(e2.RA(6),e2.Dec(6)).Ind;
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





LgLbl2{3} = sprintf('Background  ; Avg = %.3f ; SD = %.3f ; Scatter = %.3f ',[mean(18*bkg), std(18*bkg),std(18*bkg)/mean(18*bkg)])
LgLbl2{4} = sprintf('3 arcsec Aper  ; Avg = %.3f ; SD = %.3f ;Scatter = %.3f',[mean(y), std(y),std(y)/mean(y)])
LgLbl2{5} = sprintf('Signal  ; Avg = %.3f ;  SD = %.3f  ; Scatter = %.3f  ',[mean(s),  std(s), std(s)/mean(s)])
LgLbl2{6} = sprintf('Cat PSF  ; Avg = %.3f ; SD = %.3f ; Scatter = %.3f',[mean(MSpsf.Data.FLUX_APER_3(:,index_psf)),std(MSpsf.Data.FLUX_APER_3(:,index_psf)),std(MSpsf.Data.FLUX_APER_3(:,index_psf))/mean(MSpsf.Data.FLUX_APER_3(:,index_psf))])
plot(18*bkg,'-s')
hold on
plot(y,'-o')
legend('BackGround','Aperture 3 arcsec ','Interpreter','latex')
ylabel('Electrons','Interpreter','latex')
xlabel('Frames','Interpreter','latex')
title('B_p = 17.89','Interpreter','latex')
errorbar([1:20],s,s./snr,'-*')



errorbar([1:20],MSpsf.Data.FLUX_APER_3(:,index_psf),MSpsf.Data.FLUX_APER_3(:,index_psf)./MSpsf.Data.FLUX_APER_3(:,index_psf),MSpsf.Data.SN_2(:,index_psf),'-.')


errorbar([1:20],MSaper.Data.FLUX_APER_3(:,index_aper),MSaper.Data.FLUX_APER_3(:,index_aper)./MSaper.Data.FLUX_APER_3(:,index_aper),MSaper.Data.SN_2(:,index_aper),'+')



legend(LgLbl2(3:6),'Location','best','Interpreter','latex')


















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
               rms_flux,t_flux,f_flux,total_rms_flux,magerr,magerrPSF] = e2.get_LC_cat(e,20,30);
           
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

