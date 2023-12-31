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
S1 = s;
%%
PathToDir = '/last02e/data2/archive/LAST.01.02.02/2023/08/22/proc/232115v0';
SaveTo    = '~/Documents/WD_survey/261123/RefStars/';

%%
% for ref Stars



Targets2    = [   
356.735360302051	34.06967045059535	13.5590925

]

TargetsName2 = [
'Ref1'
]


% Initilize WD object

r1  = WD(Targets2(:,1),Targets2(:,2),Targets2(:,3),TargetsName2,PathToDir)




% first lim mag calculations
[id,FieldId] = r1.Coo_to_Subframe(r1.Pathway,r1);
r1  = r1.get_id(id(:,1));
r1  = r1.get_fieldID(FieldId);
[Index,cat_id] = r1.find_in_cat(r1);
r1  = r1.get_cat_id(cat_id);
%e  = e.get_LC
%% catalog extracion

       % folders :
       
       cd(PathToDir);
       MS1 = MatchedSources.read_rdir('*_sci_merged_MergedMat_*.hdf5');
       
                            ms =  MS1(r1.CatID);
                            Nobs = numel(ms.JD);


                            % finding ZP for MAG_APER_3
                            R = lcUtil.zp_meddiff(ms,'MagField','MAG_APER_3','MagErrField','MAGERR_APER_3');

                            % finding ZP for MAG_PSF   ### please note that MAG_PSF dont have
                            %'MAgFieldERR' so I use MAGERR_APER_2.
                            Rpsf= lcUtil.zp_meddiff(ms,'MagField','MAG_PSF','MagErrField','MAGERR_PSF');



                            [MSaper,ApplyToMagFieldr] = applyZP(ms, R.FitZP,'ApplyToMagField','MAG_APER_3');

                            [MSpsf,ApplyToMagFieldr] = applyZP(ms, Rpsf.FitZP,'ApplyToMagField','MAG_PSF');
          
                           
                            % get LC by index :
          
                             index_psf = MSpsf.coneSearch(r1.RA,r1.Dec).Ind;
     
                             coord_psf =  r1.get_Coord(MSpsf,index_psf);
          
                             index_aper3 = MSaper.coneSearch(r1.RA,r1.Dec).Ind;
          
                             coord_aper3 =  r1.get_Coord(MSaper,index_aper3);
          
          
          
          
          
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
FN  = fn.selectBy('CropID',r1.CropID);
AI = AstroImage.readFileNamesObj(FN);
fprintf('\nPreforming forced phot on %d images \n',length(AI))

                  tic;
                  FP     = imProc.sources.forcedPhot(AI,'Coo',[r1.RA r1.Dec],'ColNames',{'RA','Dec','X','Y','Xstart','Ystart','Chi2dof','FLUX_PSF','FLUXERR_PSF','MAG_PSF','MAGERR_PSF','BACK_ANNULUS', 'STD_ANNULUS','FLUX_APER','FLAG_POS','FLAGS'});
                  to     = toc;

                  fprintf('\nFinished analyazing %s', r1.Name(1,:))
                  fprintf('\nFor subframe # %d',r1.CropID)
                  fprintf([' \n only "',num2str(to) ,'" s'])
                  %PF = FP;
                  FileName = [SaveTo,r1.Name(1,:),'_FP0.mat'];
                  save(FileName,'FP', '-nocompression', '-v7.3')

FP3 = FP.copy()
FP2 = FP.copy()
Rz = lcUtil.zp_meddiff(FP3,'MagField','FLUX_PSF','MagErrField','FLUXERR_PSF')
RZ = lcUtil.zp_meddiff(FP2,'MagField','FLUX_APER_2','MagErrField','FLUXERR_PSF')                 
[FP3,ApplyToMagFieldr] = applyZP(FP3, Rz.FitZP,'ApplyToMagField','FLUX_PSF');
[FP2,ApplyToMagFieldr] = applyZP(FP2, RZ.FitZP,'ApplyToMagField','FLUX_APER_2');

FP1 = FP.copy()
FP4 = FP.copy()
R1 = lcUtil.zp_meddiff(FP1,'MagField','FLUX_APER_1','MagErrField','FLUXERR_PSF')
R4 = lcUtil.zp_meddiff(FP4,'MagField','FLUX_APER_3','MagErrField','FLUXERR_PSF')                 
[FP1,ApplyToMagFieldr] = applyZP(FP1, R1.FitZP,'ApplyToMagField','FLUX_APER_1');
[FP4,ApplyToMagFieldr] = applyZP(FP4, R4.FitZP,'ApplyToMagField','FLUX_APER_3');


%%
S1 = Aper1-BG1;
Snr1 = S1./sqrt(S1 + 18*(BG1+25))
figure(7);
subplot(2,2,1)
% FLUX PSF
fp  = FP3.Data.FLUX_PSF(Sorted,1) ;

[~,Sorted] = sort(FP3.JD)
errorbar([1:20],FP3.Data.FLUX_PSF(Sorted,1),...
    FP3.Data.FLUX_PSF(Sorted,1).*FP3.Data.FLUXERR_PSF(Sorted,1),'-x','Color',[0.8500 0.3250 0.1980]')
hold on
errorbar([1:20],S1,...
    S1./snr1,'-+','Color',[0.0900 0.64250 0.680])
title(sprintf('%s Gaia $B_p$ = %.2f',r1.Name(1,:),r1.Mag),'Interpreter','latex')
Lg{1} = sprintf('Forced Phot PSF ; Scatter : %.3f \\%%',100*RobustSD(fp)/mean(fp))
Lg{2} = sprintf('3 arcsec Aper Phot ; Scatter : %.3f \\%%',100*RobustSD(S1)/mean(S1))

legend(Lg(1:2),'Interpreter','latex','Location','best')
subplot(2,2,2)
% FLUX APER1
fp1  = FP1.Data.FLUX_APER_1(Sorted,1) ;

[~,Sorted] = sort(FP1.JD)
plot([1:20],fp1,...
   '-x','Color',[0.8500 0.3250 0.1980]')
hold on
plot([1:20],S1,...
    '-+','Color',[0.0900 0.64250 0.680])

Lg{3} = sprintf('Forced Phot APER 1 ; Scatter : %.3f \\%%',100*RobustSD(fp1)/mean(fp1))
legend(Lg([ 3 2 ]),'Interpreter','latex','Location','best')

subplot(2,2,3)
% FLUX APER2
fp2  = FP2.Data.FLUX_APER_2(Sorted,1) ;

[~,Sorted] = sort(FP2.JD)
plot([1:20],fp2,...
   '-x','Color',[0.8500 0.3250 0.1980]')
hold on
plot([1:20],S1,...
    '-+','Color',[0.0900 0.64250 0.680])

Lg{4} = sprintf('Forced Phot APER 2 ; Scatter : %.3f \\%%',100*RobustSD(fp2)/mean(fp2))
legend(Lg([4 2]),'Interpreter','latex','Location','best')

subplot(2,2,4)
% FLUX APER3
fp3  = FP4.Data.FLUX_APER_3(Sorted,1) ;

[~,Sorted] = sort(FP4.JD)
plot([1:20],fp3,...
   '-x','Color',[0.8500 0.3250 0.1980]')
hold on
plot([1:20],S1,...
    '-+','Color',[0.0900 0.64250 0.680])

Lg{5} = sprintf('Forced Phot APER 3 ; Scatter : %.3f \\%%',100*RobustSD(fp3)/mean(fp3))
legend(Lg([5 2]),'Interpreter','latex','Location','best')
%% plot signal + background


 plot(Aper1,'o-')
 
 hold on
 plot(18* BG , '-s')
 Lg{6} = sprintf('Aperture : Bkg + signal  ; Scatter : %.3f \\%%',100*RobustSD(18*Aper1)/mean(18*Aper1))

 Lg{7} = sprintf('Aperture : Bkg + signal  ; Scatter : %.3f \\%%',100*RobustSD(18*BG)/mean(18*BG))
legend(Lg([6 7]),'Interpreter','latex','Location','best')


%% Catalog plot

% Flux Aper 3

[~,Sorted2] = sort (MSaper.JD) ;
y_cat       = MSaper.Data.FLUX_APER_3(Sorted2,index_aper3) ;
sd1 = RobustSD(y_cat);
figure(18);
errorbar([1:20],y_cat,y_cat./MSaper.Data.SN_3(Sorted2,index_aper3))
hold on
errorbar([1:20],S1,...
    S1./snr1,'-+','Color',[0.0900 0.64250 0.680])
 Lg{8} = sprintf('Catalog APER 3  ; Scatter : %.3f \\%%',100*sd1/mean(y_cat))
legend(Lg([8 2]),'Interpreter','latex','Location','best')
title('Flux Aper 3 VS manual phot')

%% FLUX VS  Forced flux

figure(19);
plot([1:20],y_cat,'-+')
hold on
plot([1:20],fp3,...
   '-x','Color',[0.8500 0.3250 0.1980]')
 %Lg{8} = sprintf('Aperture : Bkg + signal  ; Scatter : %.3f \\%%',100*sd1/mean(y_cat))
legend(Lg([8 5]),'Interpreter','latex','Location','best')


%%

[t_psf,y_psf,t_aper,y_aper,Info_psf,Info_aper, ... 
               flager,t_rms_aper,t_rms_psf,t_rms_flux,Rms_aper,Rms_psf, ... 
               rms_flux,t_flux,f_flux,total_rms_flux,magerr,magerrPSF] = r1.get_LC_cat(r1,20,30);
           
r1.LC_psf   = {t_psf;y_psf;magerrPSF};
r1.LC_aper  = {t_aper;y_aper;magerr};
r1.Flux     = {t_flux;f_flux};
r1.FluxRMS  = total_rms_flux;
r1.InfoPsf  = Info_psf;
r1.InfoAper = Info_aper;
r1.RMS      = {t_rms_aper Rms_aper ; t_rms_psf Rms_psf; t_rms_flux rms_flux };
