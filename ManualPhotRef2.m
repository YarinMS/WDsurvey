% manual phot
%% target


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



y =[
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

s = y - 18*bkg;
Snr = s./sqrt(s + 18*(bkg+25))


%%
Aper2 = [
4031.5846	;3996.6953	;3718.7548;4028.4979	;4154.528	;
4034.6082	;4119.036;4107.3839;3686.4736	;4089.0752;
3997.0652	;4601.2322;4155.0562	;4144.8532;4149.104;
4130.5913;4043.6493	;4167.7695;4128.8119;4084.2959	

];

BG2 = [139.175;137.616;139.321	;139.07;140.825;
141.479	;139.613;138.716	;138.615;138.206	;
141.494;140.689	;140.032;135.273;137.841;
141.015;138.071	;136.845 ;138.647	;140.158
];
Sref2   = Aper2 - 18*BG2 ;
SnrRef2 =  Sref2./sqrt(Sref2 + 18*(BG2+25))



%%
PathToDir = '/last02e/data2/archive/LAST.01.02.02/2023/08/22/proc/232115v0';
SaveTo    = '~/Documents/WD_survey/261123/RefStars/';

%%
% for ref Stars



Targets3    = [   
356.9827057548486	34.06205053195075	16.98105


]

TargetsName3 = [
'Ref2'
]


% Initilize WD object

r2  = WD(Targets3(:,1),Targets3(:,2),Targets3(:,3),TargetsName3,PathToDir)




% first lim mag calculations
[id,FieldId] = r2.Coo_to_Subframe(r2.Pathway,r2);
r2  = r2.get_id(id(:,1));
r2  = r2.get_fieldID(FieldId);
[Index,cat_id] = r2.find_in_cat(r2);
r2  = r2.get_cat_id(cat_id);
%e  = e.get_LC
%% catalog extracion

       % folders :
       
       cd(PathToDir);
       MS2 = MatchedSources.read_rdir('*_sci_merged_MergedMat_*.hdf5');
       
                            ms2 =  MS2(r2.CatID);
                            Nobs = numel(ms2.JD);


                            % finding ZP for MAG_APER_3
                            R2 = lcUtil.zp_meddiff(ms2,'MagField','FLUX_APER_3','MagErrField','MAGERR_APER_3');

                            % finding ZP for MAG_PSF   ### please note that MAG_PSF dont have
                            %'MAgFieldERR' so I use MAGERR_APER_2.
                            Rpsf= lcUtil.zp_meddiff(ms2,'MagField','MAG_PSF','MagErrField','MAGERR_PSF');



                            [MSaper,ApplyToMagFieldr] = applyZP(ms2, R2.FitZP,'ApplyToMagField','FLUX_APER_3');

                            [MSpsf,ApplyToMagFieldr] = applyZP(ms2, Rpsf.FitZP,'ApplyToMagField','MAG_PSF');
          
                           
                            % get LC by index :
          
                             index_psf = MSpsf.coneSearch(r2.RA,r2.Dec).Ind;
     
                             coord_psf =  r2.get_Coord(MSpsf,index_psf);
          
                             index_aper3 = MSaper.coneSearch(r2.RA,r2.Dec).Ind;
          
                             coord_aper3 =  r2.get_Coord(MSaper,index_aper3);
          
          
          
          
          
                              [t1,y1] = MSaper.getLC_ind(index_aper3,{'MAG_APER_3'});
                              [t2,y2] = MSpsf.getLC_ind(index_psf,{'MAG_PSF'});
                              [t3,f2] = MSaper.getLC_ind(index_psf,{'FLUX_APER_3'});
                              
                              y_aper3    = MSaper.Data.FLUX_APER_3(:,index_psf);
                              yerr_aper3 = y_aper3./MSaper.Data.SN_3(:,index_aper3);
                              avg_aper3  =  mean(y_aper3);
                              sd_aper3   = RobustSD(y_aper3);
                              Scatter_aper3 = sd_aper3/avg_aper3 ; 
                              
     %% plot for cat data                          
                              
errorbar([1:20],MSpsf.Data.FLUX_APER_3(:,index_psf),MSpsf.Data.FLUX_APER_3(:,index_psf)./MSpsf.Data.SN_3(:,index_psf),'-.')
hold on
errorbar([1:20],y_aper3,yerr_aper3,'-s','Color','red')
%% Forced photomtery extraction


fn  = FileNames.generateFromFileName('*proc_Image_1.fits');
FN  = fn.selectBy('CropID',r2.CropID);
AI = AstroImage.readFileNamesObj(FN);
fprintf('\nPreforming forced phot on %d images \n',length(AI))

                  tic;
                  FP_ref2 = imProc.sources.forcedPhot(AI,'Coo',[r2.RA r2.Dec],'ColNames',{'RA','Dec','X','Y','Xstart','Ystart','Chi2dof','FLUX_PSF','FLUXERR_PSF','MAG_PSF','MAGERR_PSF','BACK_ANNULUS', 'STD_ANNULUS','FLUX_APER','FLAG_POS','FLAGS'});
                  to     = toc;

                  fprintf('\nFinished analyazing %s', r2.Name(1,:))
                  fprintf('\nFor subframe # %d',r2.CropID)
                  fprintf([' \n only "',num2str(to) ,'" s'])
                  %PF = FP;
                  FileName = [SaveTo,r2.Name(1,:),'_FP0.mat'];
                  save(FileName,'FP', '-nocompression', '-v7.3')

FP3_ref = FP_ref2.copy()
FP2_ref = FP_ref2.copy()
Rz_ref = lcUtil.zp_meddiff(FP3_ref,'MagField','FLUX_PSF','MagErrField','FLUXERR_PSF')
RZ_ref = lcUtil.zp_meddiff(FP2_ref,'MagField','FLUX_APER_2','MagErrField','FLUXERR_PSF')                 
[FP3_ref,ApplyToMagFieldr] = applyZP(FP3_ref, Rz_ref.FitZP,'ApplyToMagField','FLUX_PSF');
[FP2_ref,ApplyToMagFieldr] = applyZP(FP2_ref, RZ_ref.FitZP,'ApplyToMagField','FLUX_APER_2');

FP1_ref = FP_ref2.copy()
FP4_ref = FP_ref2.copy()
R1_ref = lcUtil.zp_meddiff(FP1_ref,'MagField','FLUX_APER_1','MagErrField','FLUXERR_PSF')
R4_ref = lcUtil.zp_meddiff(FP4_ref,'MagField','FLUX_APER_3','MagErrField','FLUXERR_PSF')                 
[FP1_ref,ApplyToMagFieldr] = applyZP(FP1_ref, R1_ref.FitZP,'ApplyToMagField','FLUX_APER_1');
[FP4_ref,ApplyToMagFieldr] = applyZP(FP4_ref, R4_ref.FitZP,'ApplyToMagField','FLUX_APER_3');


%%
figure(7);
subplot(2,2,1)
% FLUX PSF
fp_ref2  = FP3_ref.Data.FLUX_PSF(Sorted,1) ;

[~,Sorted] = sort(FP3_ref.JD)
errorbar([1:20],FP3_ref.Data.FLUX_PSF(Sorted,1),...
    FP3_ref.Data.FLUX_PSF(Sorted,1).*FP3_ref.Data.FLUXERR_PSF(Sorted,1),'-x','Color',[0.8500 0.3250 0.1980]')
hold on
errorbar([1:20],Sref2,...
    Sref2./SnrRef2,'-+','Color',[0.0900 0.64250 0.680])
title(sprintf('%s Gaia $B_p$ = %.2f',r2.Name(1,:),r2.Mag),'Interpreter','latex')
Lg{1} = sprintf('Forced Phot PSF ; Scatter : %.3f \\%%',100*RobustSD(fp_ref2)/mean(fp_ref2))
Lg{2} = sprintf('3 arcsec Aper Phot ; Scatter : %.3f \\%%',100*RobustSD(Sref2)/mean(Sref2))
xlabel('Frame','Interpreter','latex')
ylabel('Counts','Interpreter','latex')


legend(Lg(1:2),'Interpreter','latex','Location','best')
subplot(2,2,2)
% FLUX APER1
fp1_ref2  = FP1_ref.Data.FLUX_APER_1(Sorted,1) ;

[~,Sorted] = sort(FP1_ref.JD)
plot([1:20],fp1_ref2,...
   '-x','Color',[0.8500 0.3250 0.1980]')
hold on
plot([1:20],Sref2,...
    '-+','Color',[0.0900 0.64250 0.680])
xlabel('Frame','Interpreter','latex')
ylabel('Counts','Interpreter','latex')
title('FLUX APER 1','Interpreter','latex')

Lg{3} = sprintf('Forced Phot APER 1 ; Scatter : %.3f \\%%',100*RobustSD(fp1_ref2)/mean(fp1_ref2))
legend(Lg([ 3 2 ]),'Interpreter','latex','Location','best')

subplot(2,2,3)
% FLUX APER2
fp2_ref2  = FP2_ref.Data.FLUX_APER_2(Sorted,1) ;

[~,Sorted] = sort(FP2_ref.JD)
plot([1:20],fp2_ref2,...
   '-x','Color',[0.8500 0.3250 0.1980]')
hold on
plot([1:20],Sref2,...
    '-+','Color',[0.0900 0.64250 0.680])

Lg{4} = sprintf('Forced Phot APER 2 ; Scatter : %.3f \\%%',100*RobustSD(fp2_ref2)/mean(fp2_ref2))
legend(Lg([4 2]),'Interpreter','latex','Location','best')
xlabel('Frame','Interpreter','latex')
ylabel('Counts','Interpreter','latex')
title('FLUX APER 2','Interpreter','latex')
subplot(2,2,4)
% FLUX APER3
fp3_ref2  = FP4_ref.Data.FLUX_APER_3(Sorted,1) ;

[~,Sorted] = sort(FP4_ref.JD)
plot([1:20],fp3_ref2,...
   '-x','Color',[0.8500 0.3250 0.1980]')
hold on
plot([1:20],Sref2,...
    '-+','Color',[0.0900 0.64250 0.680])

Lg{5} = sprintf('Forced Phot APER 3 ; Scatter : %.3f \\%%',100*RobustSD(fp3_ref2)/mean(fp3_ref2))
legend(Lg([5 2]),'Interpreter','latex','Location','best')
xlabel('Frame','Interpreter','latex')
ylabel('Counts','Interpreter','latex')
title('FLUX APER 3','Interpreter','latex')
%% plot signal + background

 plot(Aper2,'o-')
 
 hold on
 plot(18* BG2 , '-s')
 Lg{6} = sprintf('Aperture : Bkg + signal  ; Scatter : %.3f \\%%',100*RobustSD(18*Aper2)/mean(18*Aper2))
plot([1:20],Sref2,...
    '-+','Color',[0.0900 0.64250 0.680])
 Lg{7} = sprintf('Background  ; Scatter : %.3f \\%%',100*RobustSD(18*BG2)/mean(18*BG2))
legend(Lg([6 7 2]),'Interpreter','latex','Location','best')


xlabel('Frame','Interpreter','latex')
ylabel('Counts','Interpreter','latex')
title(' Manual Photomotery , Aperture Radius = 3 arcsec ' ,'Interpreter','latex')
%% Catalog plot

% Flux Aper 3

[~,Sorted2] = sort (MSaper.JD) ;
y_cat       = MSaper.Data.FLUX_APER_3(Sorted2,index_aper3) ;
sd1 = RobustSD(y_cat);
figure(18);
errorbar([1:20],y_cat,y_cat./MSaper.Data.SN_3(Sorted2,index_aper3),'Color','#7E2F8E')
hold on


plot([1:20],fp3_ref2,...
   '-x','Color',[0.8500 0.3250 0.1980]')
errorbar([1:20],Sref2,...
    Sref2./SnrRef2,'-+','Color',[0.0900 0.64250 0.680])
 Lg{8} = sprintf('Catalog APER 3  ; Scatter : %.3f \\%%',100*sd1/mean(y_cat))
legend(Lg([8 5 2]),'Interpreter','latex','Location','best')
title('Flux Aper 3 and manual phot','Interpreter','latex')



%% FLUX VS  Forced flux

figure(19);
plot([1:20],y_cat,'-+')
hold on
plot([1:20],fp3_ref2,...
   '-x','Color',[0.8500 0.3250 0.1980]')
 %Lg{8} = sprintf('Aperture : Bkg + signal  ; Scatter : %.3f \\%%',100*sd1/mean(y_cat))
legend(Lg([8 5]),'Interpreter','latex','Location','best')


%%

[t_psf,y_psf,t_aper,y_aper,Info_psf,Info_aper, ... 
               flager,t_rms_aper,t_rms_psf,t_rms_flux,Rms_aper,Rms_psf, ... 
               rms_flux,t_flux,f_flux,total_rms_flux,magerr,magerrPSF] = r2.get_LC_cat(r2,20,30);
           
r2.LC_psf   = {t_psf;y_psf;magerrPSF};
r2.LC_aper  = {t_aper;y_aper;magerr};
r2.Flux     = {t_flux;f_flux};
r2.FluxRMS  = total_rms_flux;
r2.InfoPsf  = Info_psf;
r2.InfoAper = Info_aper;
r2.RMS      = {t_rms_aper Rms_aper ; t_rms_psf Rms_psf; t_rms_flux rms_flux };
