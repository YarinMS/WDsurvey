% manual phot
%% target

y =  [23600.68	;23600.931; 23737.847;23898.694; 23766.431;
            23927.008 ; 24187.474 ; 23969.264	;23971.595;23559.018;
            23884.505	;23791.552	;24018.605 ; 24097.901 ; 23984.44 ; 
            24107.128	;23594.814 ; 23879.099	 ; 23679.573 ; 23942.32]

bkg =  112*[ 205.253	; 204.551 ; 203.553 ; 204.226 ; 204.565; 
        203.493	; 205.231 ; 204.508 ; 204.245 ; 204.723	;
        204.884 ; 204.642 ; 205.102 ; 205.157 ; 203.996;
        205.078 ; 205.158 ; 204.863 ; 203.775 ; 203.973]
s = y - bkg;
Snr = s./sqrt(s + (bkg+112*25))

%%


S1   = s
Snr1 =  Snr



%%
PathToDir = '/last04e/data1/archive/LAST.01.04.01/2023/08/22/proc/Exp/200441v0';
SaveTo    = '~/Documents/WD/021223/';

%%
% for ref Stars




% Initilize WD object

%Star1  = WD(Targets4(:,1),Targets4(:,2),Targets4(:,3),TargetsName4,PathToDir)

Star1  = e;


% first lim mag calculations
[id,FieldId] = Star1.Coo_to_Subframe(Star1.Pathway,Star1);
Star1  = Star1.get_id(id(:,1));
Star1  = Star1.get_fieldID(FieldId);
[Index,cat_id] = Star1.find_in_cat(Star1);
Star1  = Star1.get_cat_id(cat_id);
%e  = e.get_LC
%% catalog extracion

       % folders :
       
       cd(PathToDir);
       MSStar = MatchedSources.read_rdir('*_sci_merged_MergedMat_*.hdf5');
 
                            msStar =  MSStar(Star1.CatID);
                            Nobs = numel(msStar.JD);


                            % finding ZP for MAG_APER_3
                            %R3S = lcUtil.zp_meddiff(msStar,'MagField','FLUX_APER_3','MagErrField','MAGERR_APER_3');

                            % finding ZP for MAG_PSF   ### please note that MAG_PSF dont have
                            %'MAgFieldERR' so I use MAGERR_APER_2.
                            RpsfS= lcUtil.zp_meddiff(msStar,'MagField','MAG_PSF','MagErrField','MAGERR_PSF');



                            %[MSaperS,ApplyToMagFieldr] = applyZP(msStar, R3S.FitZP,'ApplyToMagField','FLUX_APER_3');

                            %[MSpsfS,ApplyToMagFieldr] = applyZP(msStar, RpsfS.FitZP,'ApplyToMagField','MAG_PSF');
          
                             MSpsfS = msStar;
                             MSaperS = msStar;
                            % get LC by index :
          
                             index_psf3 = MSpsfS.coneSearch(Star1.RA,Star1.Dec).Ind;
     
                             coord_psf =  Star1.get_Coord(MSpsfS,index_psf3);
          
                             index_aper33 = MSaperS.coneSearch(Star1.RA,Star1.Dec).Ind;
          
                             coord_aper3 =  Star1.get_Coord(MSaperS,index_aper33);
          
          
          
          
          
                              [t1,y1] = MSaperS.getLC_ind(index_aper33,{'MAG_APER_3'});
                              [t2,y2] = MSpsfS.getLC_ind(index_psf3,{'MAG_PSF'});
                              [t3,f2] = MSaperS.getLC_ind(index_psf3,{'FLUX_APER_3'});
                              
                              y_aper3S    = MSaperS.Data.FLUX_APER_3(:,index_psf3);
                              yerr_aper3 = y_aper3S./MSaperS.Data.SN_3(:,index_aper33);
                              avg_aper3  =  mean(y_aper3S);
                              sd_aper3   = RobustSD(y_aper3S);
                              Scatter_aper3 = sd_aper3/avg_aper3 ; 
                              
     %% plot for cat data                          
                              
errorbar([1:20],MSpsfS.Data.FLUX_APER_3(:,index_psf3),MSpsfS.Data.FLUX_APER_3(:,index_psf3)./MSpsfS.Data.SN_3(:,index_psf3),'-.')
hold on
errorbar([1:20],y_aper3S,yerr_aper3,'-s','Color','red')
%% Forced photomtery extraction


fn  = FileNames.generateFromFileName('*proc_Image_1.fits');
FN  = fn.selectBy('CropID',Star1.CropID);
AI = AstroImage.readFileNamesObj(FN);
fprintf('\nPreforming forced phot on %d images \n',length(AI))

                  tic;
                  FP_S = imProc.sources.forcedPhot(AI,'Coo',[e2.RA e2.Dec],'ColNames',{'RA','Dec','X','Y','Xstart','Ystart','Chi2dof','FLUX_PSF','FLUXERR_PSF','MAG_PSF','MAGERR_PSF','BACK_ANNULUS', 'STD_ANNULUS','FLUX_APER','FLAG_POS','FLAGS'});
                  to     = toc;

                  fprintf('\nFinished analyazing %s', Star1.Name(1,:))
                  fprintf('\nFor subframe # %d',Star1.CropID)
                  fprintf([' \n only "',num2str(to) ,'" s'])
                  %PF = FP;
                  FileName = [SaveTo,Star1.Name(1,:),'_FP0.mat'];
                  save(FileName,'FP_S', '-nocompression', '-v7.3')

%FP_S = FP_S.copy()
%FP2_S = FP_S.copy()
%Rz_S = lcUtil.zp_meddiff(FP_S,'MagField','FLUX_PSF','MagErrField','FLUXERR_PSF')
%RZ_S = lcUtil.zp_meddiff(FP2_S,'MagField','FLUX_APER_2','MagErrField','FLUXERR_PSF')                 
%[FP_S,ApplyToMagFieldr] = applyZP(FP_S, Rz_S.FitZP,'ApplyToMagField','FLUX_PSF');
%[FP2_S,ApplyToMagFieldr] = applyZP(FP2_S, RZ_S.FitZP,'ApplyToMagField','FLUX_APER_2');

%FP1_S = FP_S.copy()
%FP4_S = FP_S.copy()
%R1_S = lcUtil.zp_meddiff(FP1_S,'MagField','FLUX_APER_1','MagErrField','FLUXERR_PSF')
%R4_S = lcUtil.zp_meddiff(FP4_S,'MagField','FLUX_APER_3','MagErrField','FLUXERR_PSF')                 
%[FP1_S,ApplyToMagFieldr] = applyZP(FP1_S, R1_S.FitZP,'ApplyToMagField','FLUX_APER_1');
%[FP4_S,ApplyToMagFieldr] = applyZP(FP4_S, R4_S.FitZP,'ApplyToMagField','FLUX_APER_3');


%%

[~,Sorted] = sort(FP_S.JD)
figure(7);
subplot(2,2,1)
% FLUX PSF
fp_S  = FP_S.Data.FLUX_PSF(Sorted,1) ;

errorbar([1:20],FP_S.Data.FLUX_PSF(Sorted,1),...
    FP_S.Data.FLUX_PSF(Sorted,1).*FP_S.Data.FLUXERR_PSF(Sorted,1),'-x','Color',[0.8500 0.3250 0.1980]')
hold on
errorbar([1:20],S1,...
    S1./Snr1,'-+','Color',[0.0900 0.64250 0.680])
title(sprintf('%s Gaia $B_p$ = %.2f',Star1.Name(1,:),Star1.Mag),'Interpreter','latex')
Lg{1} = sprintf('Forced Phot PSF ; Scatter : %.3f \\%%',100*RobustSD(fp_S)/mean(fp_S))
Lg{2} = sprintf('7.56 arcsec Aper Phot ; Scatter : %.3f \\%%',100*RobustSD(S1)/mean(S1))
xlabel('Frame','Interpreter','latex')
ylabel('Counts','Interpreter','latex')


legend(Lg(1:2),'Interpreter','latex','Location','best')
subplot(2,2,2)
% FLUX APER1
fp1_S  = FP_S.Data.FLUX_APER_1(Sorted,1) ;

[~,Sorted] = sort(FP_S.JD)
plot([1:20],fp1_S,...
   '-x','Color',[0.8500 0.3250 0.1980]')
hold on
plot([1:20],S1,...
    '-+','Color',[0.0900 0.64250 0.680])
xlabel('Frame','Interpreter','latex')
ylabel('Counts','Interpreter','latex')
title('FLUX APER 1','Interpreter','latex')

Lg{3} = sprintf('Forced Phot APER 1 ; Scatter : %.3f \\%%',100*RobustSD(fp1_S)/mean(fp1_S))
legend(Lg([ 3 2 ]),'Interpreter','latex','Location','best')

subplot(2,2,3)
% FLUX APER2
fp2_S  = FP_S.Data.FLUX_APER_2(Sorted,1) ;

[~,Sorted] = sort(FP_S.JD)
plot([1:20],fp2_S,...
   '-x','Color',[0.8500 0.3250 0.1980]')
hold on
plot([1:20],S1,...
    '-+','Color',[0.0900 0.64250 0.680])

Lg{4} = sprintf('Forced Phot APER 2 ; Scatter : %.3f \\%%',100*RobustSD(fp2_S)/mean(fp2_S))
legend(Lg([4 2]),'Interpreter','latex','Location','best')
xlabel('Frame','Interpreter','latex')
ylabel('Counts','Interpreter','latex')
title('FLUX APER 2','Interpreter','latex')
subplot(2,2,4)
% FLUX APER3
fp3_S  = FP_S.Data.FLUX_APER_3(Sorted,1) ;

[~,Sorted] = sort(FP_S.JD)
plot([1:20],fp3_S,...
   '-x','Color',[0.8500 0.3250 0.1980]')
hold on
plot([1:20],S1,...
    '-+','Color',[0.0900 0.64250 0.680])

Lg{5} = sprintf('Forced Phot APER 3 ; Scatter : %.3f \\%%',100*RobustSD(fp3_S)/mean(fp3_S))
legend(Lg([5 2]),'Interpreter','latex','Location','best')
xlabel('Frame','Interpreter','latex')
ylabel('Counts','Interpreter','latex')
title('FLUX APER 3','Interpreter','latex')
%% plot  background

 

 plot(bkg./112 , '-s')
 %Lg{6} = sprintf('Aperture : Bkg + signal  ; Scatter : %.3f \\%%',100*RobustSD(18*Aper3)/mean(18*Aper3))
hold on
plot([1:20], FP_S.Data.BACK_ANNULUS(:,1),...
    '-o','Color',[0 0 0])
plot([1:20],msStar.Data.BACK_ANNULUS(:,index_psf3),...
    '-X','Color',[0.75 0.25 0.25])
 
 Lg{7} = sprintf('Manual Background  ; Scatter : %.3f \\%%',100*RobustSD(bkg./112)/mean(bkg./112))
 background_forced = FP_S.Data.BACK_ANNULUS(:,1);
 background_cat = msStar.Data.BACK_ANNULUS(:,index_psf3)
 Lg{11} = sprintf('Forced Photometry Background  ; Scatter : %.3f \\%%',100*RobustSD( background_forced)/mean( background_forced))
 Lg{12} = sprintf('Catalog Background  ; Scatter : %.3f \\%%',100*RobustSD( background_cat)/mean( background_cat))

 
 legend(Lg([ 7 11 12]),'Interpreter','latex','Location','best')
xlabel('Frame','Interpreter','latex')
ylabel('Counts','Interpreter','latex')
title(' Background comparison' ,'Interpreter','latex')


%% Catalog plot

% Flux Aper 3

[~,Sorted2] = sort (MSaperS.JD) ;
y_cat       = msStar.Data.FLUX_APER_3(Sorted2,index_aper33) ;
sd1 = RobustSD(y_cat);
figure(18);
errorbar([1:20],y_cat,y_cat./MSaperS.Data.SN_3(Sorted2,index_aper33),'-s','Color','#7E2F8E')
hold on
plot([1:20],fp3_S,...
   '-x','Color',[0.1 0.1 0.1]')
 %plot(18* bkg , 'k-s')
%plot([1:20],fp3_S,...
%   '-x','Color',[0.8500 0.3250 0.1980]')
errorbar([1:20],S1,...
    S1./Snr1,'-o','Color',[0.0900 0.64250 0.680])
 Lg{8} = sprintf('Catalog APER 3  ; Scatter : %.3f \\%%',100*sd1/mean(y_cat))
legend(Lg([8 5 2]),'Interpreter','latex','Location','best')
title('Flux Aper 3 and manual phot','Interpreter','latex')




%% AstroCatlaog
AC=AstroCatalog('*015_sci_proc_Cat*','HDU',2)
AC.convertCooUnits('deg')
% find index psf  :



LC = [];
LCErr = []; 
for Iimg =  1 :20
    
    [RA, Dec] = AC(Iimg).getLonLat('deg');
    [~,inx_cat] = min(abs(RA - Star1.RA))
    [~,inx_cat1] = min(sqrt((Dec - Star1.Dec).^2 + (RA - Star1.RA).^2));
    

        LC = [LC ; AC(Iimg).Catalog(inx_cat1,47)];
        LCErr = [LCErr ; AC(Iimg).Catalog(inx_cat1,19)];

end

figure()
plot(LC,'-o')

% Flux PSF
figure(188);
plot([1:20],LC,'-s','Color','#7E2F8E')
hold on
plot([1:20],fp_S,...
   '-x','Color',[0.1 0.1 0.1]')
 %plot(18* bkg , 'k-s')
%plot([1:20],fp3_S,...
%   '-x','Color',[0.8500 0.3250 0.1980]')
errorbar([1:20],S1,...
    S1./Snr1,'-o','Color',[0.0900 0.64250 0.680])
 Lg{13} = sprintf('Catalog PSF  ; Scatter : %.3f \\%%',100*RobustSD(LC)/mean(LC))
legend(Lg([13 1 2]),'Interpreter','latex','Location','best')
title('Flux PSF and manual phot','Interpreter','latex')



%% lim mag over error

Aper3Err = msStar.Data.FLUXERR_APER_3(indexaper33)

figure(222);

plot(Aper3Err,limmag2(1:20,12))





%% FLUX VS  Forced flux

figure(19);
plot([1:20],y_cat,'-o')
hold on
plot([1:20],fp3_S,...
   '-x','Color',[0.8500 0.3250 0.1980]')
 %Lg{8} = sprintf('Aperture : Bkg + signal  ; Scatter : %.3f \\%%',100*sd1/mean(y_cat))
legend(Lg([8 5]),'Interpreter','latex','Location','best')


