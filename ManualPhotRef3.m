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

Aper3 = [ 
15179.641	;15149.853;15579.617	;15241.648	;15223.407;
15377.03	; 15202.97;15112.681;15218.028	; 15428.318	;
15262.65	; 15282.052; 15561.145	; 	15736.015	; 15426.202	;
15358.322; 15616.33	; 15194.579	; 15504.362	; 15543.775	
]

BG3 = [
  133.579; 134.575;133.088;133.982; 131.795 ;
133.893;133.664; 134.131;133.38;135.174;
135.62;134.125;134.871;134.255;134.505;
134.603;134.579;134.719;132.61;135.922];

Sref3   = Aper3 - 50*BG3 ;
SnrRef3 =  Sref3./sqrt(Sref3 + 50*(BG3+25))



%%
PathToDir = '/last02e/data2/archive/LAST.01.02.02/2023/08/22/proc/232115v0';
SaveTo    = '~/Documents/WD_survey/261123/RefStars/';

%%
% for ref Stars



Targets4    = [   
357.04421004865196	34.0359356414428	15.458928


]

TargetsName4 = [
'Ref3'
]


% Initilize WD object

r3  = WD(Targets4(:,1),Targets4(:,2),Targets4(:,3),TargetsName4,PathToDir)




% first lim mag calculations
[id,FieldId] = r3.Coo_to_Subframe(r3.Pathway,r3);
r3  = r3.get_id(id(:,1));
r3  = r3.get_fieldID(FieldId);
[Index,cat_id] = r3.find_in_cat(r3);
r3  = r3.get_cat_id(cat_id);
%e  = e.get_LC
%% catalog extracion

       % folders :
       
       cd(PathToDir);
       MS3 = MatchedSources.read_rdir('*_sci_merged_MergedMat_*.hdf5');
       
                            ms3 =  MS3(r3.CatID);
                            Nobs = numel(ms3.JD);


                            % finding ZP for MAG_APER_3
                            R3 = lcUtil.zp_meddiff(ms3,'MagField','FLUX_APER_3','MagErrField','MAGERR_APER_3');

                            % finding ZP for MAG_PSF   ### please note that MAG_PSF dont have
                            %'MAgFieldERR' so I use MAGERR_APER_2.
                            Rpsf= lcUtil.zp_meddiff(ms3,'MagField','MAG_PSF','MagErrField','MAGERR_PSF');



                            [MSaper3,ApplyToMagFieldr] = applyZP(ms3, R3.FitZP,'ApplyToMagField','FLUX_APER_3');

                            [MSpsf3,ApplyToMagFieldr] = applyZP(ms3, Rpsf.FitZP,'ApplyToMagField','MAG_PSF');
          
                           
                            % get LC by index :
          
                             index_psf3 = MSpsf3.coneSearch(r3.RA,r3.Dec).Ind;
     
                             coord_psf =  r3.get_Coord(MSpsf3,index_psf3);
          
                             index_aper33 = MSaper3.coneSearch(r3.RA,r3.Dec).Ind;
          
                             coord_aper3 =  r3.get_Coord(MSaper3,index_aper33);
          
          
          
          
          
                              [t1,y1] = MSaper3.getLC_ind(index_aper33,{'MAG_APER_3'});
                              [t2,y2] = MSpsf3.getLC_ind(index_psf3,{'MAG_PSF'});
                              [t3,f2] = MSaper3.getLC_ind(index_psf3,{'FLUX_APER_3'});
                              
                              y_aper3    = MSaper3.Data.FLUX_APER_3(:,index_psf3);
                              yerr_aper3 = y_aper3./MSaper3.Data.SN_3(:,index_aper33);
                              avg_aper3  =  mean(y_aper3);
                              sd_aper3   = RobustSD(y_aper3);
                              Scatter_aper3 = sd_aper3/avg_aper3 ; 
                              
     %% plot for cat data                          
                              
errorbar([1:20],MSpsf3.Data.FLUX_APER_3(:,index_psf3),MSpsf3.Data.FLUX_APER_3(:,index_psf3)./MSpsf3.Data.SN_3(:,index_psf3),'-.')
hold on
errorbar([1:20],y_aper3,yerr_aper3,'-s','Color','red')
%% Forced photomtery extraction


fn  = FileNames.generateFromFileName('*proc_Image_1.fits');
FN  = fn.selectBy('CropID',r3.CropID);
AI = AstroImage.readFileNamesObj(FN);
fprintf('\nPreforming forced phot on %d images \n',length(AI))

                  tic;
                  FP_ref3 = imProc.sources.forcedPhot(AI,'Coo',[r3.RA r3.Dec],'ColNames',{'RA','Dec','X','Y','Xstart','Ystart','Chi2dof','FLUX_PSF','FLUXERR_PSF','MAG_PSF','MAGERR_PSF','BACK_ANNULUS', 'STD_ANNULUS','FLUX_APER','FLAG_POS','FLAGS'});
                  to     = toc;

                  fprintf('\nFinished analyazing %s', r3.Name(1,:))
                  fprintf('\nFor subframe # %d',r3.CropID)
                  fprintf([' \n only "',num2str(to) ,'" s'])
                  %PF = FP;
                  FileName = [SaveTo,r3.Name(1,:),'_FP0.mat'];
                  save(FileName,'FP', '-nocompression', '-v7.3')

FP3_ref3 = FP_ref3.copy()
FP2_ref3 = FP_ref3.copy()
Rz_ref3 = lcUtil.zp_meddiff(FP3_ref3,'MagField','FLUX_PSF','MagErrField','FLUXERR_PSF')
RZ_ref3 = lcUtil.zp_meddiff(FP2_ref3,'MagField','FLUX_APER_2','MagErrField','FLUXERR_PSF')                 
[FP3_ref3,ApplyToMagFieldr] = applyZP(FP3_ref3, Rz_ref3.FitZP,'ApplyToMagField','FLUX_PSF');
[FP2_ref3,ApplyToMagFieldr] = applyZP(FP2_ref3, RZ_ref3.FitZP,'ApplyToMagField','FLUX_APER_2');

FP1_ref3 = FP_ref3.copy()
FP4_ref3 = FP_ref3.copy()
R1_ref3 = lcUtil.zp_meddiff(FP1_ref3,'MagField','FLUX_APER_1','MagErrField','FLUXERR_PSF')
R4_ref3 = lcUtil.zp_meddiff(FP4_ref3,'MagField','FLUX_APER_3','MagErrField','FLUXERR_PSF')                 
[FP1_ref3,ApplyToMagFieldr] = applyZP(FP1_ref3, R1_ref3.FitZP,'ApplyToMagField','FLUX_APER_1');
[FP4_ref3,ApplyToMagFieldr] = applyZP(FP4_ref3, R4_ref3.FitZP,'ApplyToMagField','FLUX_APER_3');


%%
figure(7);
subplot(2,2,1)
% FLUX PSF
fp_ref3  = FP3_ref3.Data.FLUX_PSF(Sorted,1) ;

[~,Sorted] = sort(FP3_ref3.JD)
errorbar([1:20],FP3_ref3.Data.FLUX_PSF(Sorted,1),...
    FP3_ref3.Data.FLUX_PSF(Sorted,1).*FP3_ref3.Data.FLUXERR_PSF(Sorted,1),'-x','Color',[0.8500 0.3250 0.1980]')
hold on
errorbar([1:20],Sref3,...
    Sref3./SnrRef3,'-+','Color',[0.0900 0.64250 0.680])
title(sprintf('%s Gaia $B_p$ = %.2f',r3.Name(1,:),r3.Mag),'Interpreter','latex')
Lg{1} = sprintf('Forced Phot PSF ; Scatter : %.3f \\%%',100*RobustSD(fp_ref3)/mean(fp_ref3))
Lg{2} = sprintf('5 arcsec Aper Phot ; Scatter : %.3f \\%%',100*RobustSD(Sref3)/mean(Sref3))
xlabel('Frame','Interpreter','latex')
ylabel('Counts','Interpreter','latex')


legend(Lg(1:2),'Interpreter','latex','Location','best')
subplot(2,2,2)
% FLUX APER1
fp1_ref3  = FP1_ref3.Data.FLUX_APER_1(Sorted,1) ;

[~,Sorted] = sort(FP1_ref3.JD)
plot([1:20],fp1_ref3,...
   '-x','Color',[0.8500 0.3250 0.1980]')
hold on
plot([1:20],Sref3,...
    '-+','Color',[0.0900 0.64250 0.680])
xlabel('Frame','Interpreter','latex')
ylabel('Counts','Interpreter','latex')
title('FLUX APER 1','Interpreter','latex')

Lg{3} = sprintf('Forced Phot APER 1 ; Scatter : %.3f \\%%',100*RobustSD(fp1_ref3)/mean(fp1_ref3))
legend(Lg([ 3 2 ]),'Interpreter','latex','Location','best')

subplot(2,2,3)
% FLUX APER2
fp2_ref3  = FP2_ref3.Data.FLUX_APER_2(Sorted,1) ;

[~,Sorted] = sort(FP2_ref3.JD)
plot([1:20],fp2_ref3,...
   '-x','Color',[0.8500 0.3250 0.1980]')
hold on
plot([1:20],Sref3,...
    '-+','Color',[0.0900 0.64250 0.680])

Lg{4} = sprintf('Forced Phot APER 2 ; Scatter : %.3f \\%%',100*RobustSD(fp2_ref3)/mean(fp2_ref3))
legend(Lg([4 2]),'Interpreter','latex','Location','best')
xlabel('Frame','Interpreter','latex')
ylabel('Counts','Interpreter','latex')
title('FLUX APER 2','Interpreter','latex')
subplot(2,2,4)
% FLUX APER3
fp3_ref3  = FP4_ref3.Data.FLUX_APER_3(Sorted,1) ;

[~,Sorted] = sort(FP4_ref3.JD)
plot([1:20],fp3_ref3,...
   '-x','Color',[0.8500 0.3250 0.1980]')
hold on
plot([1:20],Sref3,...
    '-+','Color',[0.0900 0.64250 0.680])

Lg{5} = sprintf('Forced Phot APER 3 ; Scatter : %.3f \\%%',100*RobustSD(fp3_ref3)/mean(fp3_ref3))
legend(Lg([5 2]),'Interpreter','latex','Location','best')
xlabel('Frame','Interpreter','latex')
ylabel('Counts','Interpreter','latex')
title('FLUX APER 3','Interpreter','latex')
%% plot signal + background

 plot(Aper3,'ko-')
 
 hold on
 plot(50* BG3 , '-s')
 Lg{6} = sprintf('Aperture : Bkg + signal  ; Scatter : %.3f \\%%',100*RobustSD(18*Aper3)/mean(18*Aper3))
plot([1:20],Sref3,...
    '-+','Color',[0.0900 0.64250 0.680])
 Lg{7} = sprintf('Background  ; Scatter : %.3f \\%%',100*RobustSD(18*BG3)/mean(18*BG3))
legend(Lg([6 7 2]),'Interpreter','latex','Location','best')

xlabel('Frame','Interpreter','latex')
ylabel('Counts','Interpreter','latex')
title(' Manual Photomotery , Aperture Radius = 5 arcsec ' ,'Interpreter','latex')

%% Catalog plot

% Flux Aper 3

[~,Sorted2] = sort (MSaper3.JD) ;
y_cat3       = MSaper3.Data.FLUX_APER_3(Sorted2,index_aper33) ;
sd1 = RobustSD(y_cat3);
figure(18);
errorbar([1:20],y_cat3,y_cat3./MSaper3.Data.SN_3(Sorted2,index_aper33),'-s','Color','#7E2F8E')
hold on


plot([1:20],fp3_ref3,...
   '-x','Color',[0.8500 0.3250 0.1980]')
errorbar([1:20],Sref3,...
    Sref3./SnrRef3,'-o','Color',[0.0900 0.64250 0.680])
 Lg{8} = sprintf('Catalog APER 3  ; Scatter : %.3f \\%%',100*sd1/mean(y_cat3))
legend(Lg([8 5 2]),'Interpreter','latex','Location','best')
title('Flux Aper 3 and manual phot','Interpreter','latex')



%% FLUX VS  Forced flux

figure(19);
plot([1:20],y_cat3,'-o')
hold on
plot([1:20],fp3_ref3,...
   '-x','Color',[0.8500 0.3250 0.1980]')
 %Lg{8} = sprintf('Aperture : Bkg + signal  ; Scatter : %.3f \\%%',100*sd1/mean(y_cat))
legend(Lg([8 5]),'Interpreter','latex','Location','best')

