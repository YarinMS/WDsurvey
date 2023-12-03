function [Target,ms,index_psf] = Ndirs(Target,Args)
% Get a target and extract its  photometry catalog 
% And via Forced photometry.
% Calc RobustSD per aperture
% Subplot all together
%   Initilize Target object as
%   Target = {};
%   Target.PathToDir = '...'
%   Target.RA = 1;
%   Target.Dec = 1;
%   Target.Bp  = 1;
%   etc....


arguments
    Target 
    Args.Ndir = 1 ;
    
end

%% Catalog loop
       cd(Target.PathToDir);
       
       mS = MatchedSources.read_rdir('*_sci_merged_MergedMat_*.hdf5');

       cd('../')

       mS2 = MatchedSources.read_rdir('*_sci_merged_MergedMat_*.hdf5','OrderPart' , 'CropID');

       fprintf('finished creating the matched sources objects  \n')
       
       
       ms =  mergeByCoo(mS2(:,Target.CatID),mS(Target.CatID));
       
       ms_mag3 = ms.copy();
       ms_mag2 = ms.copy();
       ms_psf = ms.copy();
       ms_flux3  = ms.copy(); 
      
                            


        %                    % finding ZP for MAG_APER_3
                          %  R = lcUtil.zp_meddiff(ms_mag3,'MagField','MAG_APER_3','MagErrField','MAGERR_APER_3');

                            % finding ZP for MAG_PSF   ### please note that MAG_PSF dont have
                            
         %                   Rpsf= lcUtil.zp_meddiff(ms_magPSF,'MagField','MAG_PSF','MagErrField','MAGERR_PSF');



          %                  [MS_mag3,ApplyToMagFieldr] = applyZP(ms_mag3, R.FitZP,'ApplyToMagField','MAG_APER_3');

           %                 [MSpsf,ApplyToMagFieldr] = applyZP(ms_magPSF, Rpsf.FitZP,'ApplyToMagField','MAG_PSF');
 
                            % finding ZP for MAG_APER_3
            %                RFlux3 = lcUtil.zp_meddiff(ms_flux3,'MagField','FLUX_APER_3','MagErrField','MAGERR_PSF');

                            % finding ZP for MAG_PSF   ### please note that MAG_PSF dont have
                            %'MAgFieldERR' so I use MAGERR_APER_2.
             %               Rmag2= lcUtil.zp_meddiff(ms_mag2,'MagField','MAG_APER_2','MagErrField','MAGERR_PSF');



              %              [MS_flux3,ApplyToMagFieldr] = applyZP(ms_flux3, RFlux3.FitZP,'ApplyToMagField','FLUX_APER_3');

               %             [MS_mag2,ApplyToMagFieldr] = applyZP(ms, Rmag2.FitZP,'ApplyToMagField','MAG_APEr_2');
          
                            
                            
          
                             % get LC by index :
                             %MS_mag3 = ms;
                             %MS_Flux3 = ms;
          
    
                             
                             
                             index_psf = ms_mag3.coneSearch(Target.RA,Target.Dec).Ind;
                         %% extract flux
                             
                         %% AstroCatlaog
                         
                          cd(Target.Pathway)
                          cd ../
             
                          directory = dir;
                          LC = []
            
                          for i = 3 : length(directory)
               
                                 cd(directory(i).name)
       
                                AC=AstroCatalog('*012_sci_proc_Cat*','HDU',2)
                                AC.convertCooUnits('deg')
                                i
% find index psf  :

                                 for Iimg =  1 :20
    
                                         [RA, Dec] = AC(Iimg).getLonLat('deg');

                                         [~,inx_cat1] = min(sqrt((Dec - Target.Dec).^2 + (RA - Target.RA).^2));
    

                                          LC = [LC ; AC(Iimg).Catalog(inx_cat1,47)];
  

                                 end
                                    cd ../
                          end
                             
                             
                             
                             %% plot cat data
                             
                             t0 = ceil(ms_flux3.JD(1)) -0.5 ; 
                             figure();
                             
                             subplot(2,1,1)
     
                             plot(ms_flux3.JD - t0,ms_flux3.Data.FLUX_APER_3(:,index_psf),'k-o')
                             hold on
                             plot(ms_flux3.JD - t0,LC,'r-s')

                             LG{20} = sprintf('Flux PSF  %s ; %.0f frames ; RobustSD = %.3f %',Target.Name ,20*Args.Ndir,RobustSD(LC)/mean(LC,'omitnan'))
                             LG{1} = sprintf('Flux Aper 3  %s ; %.0f frames ; RobustSD = %.3f %',Target.Name ,20*Args.Ndir,RobustSD(ms_flux3.Data.FLUX_APER_3(:,index_psf))/mean(ms_flux3.Data.FLUX_APER_3(:,index_psf),'omitnan'))
                             xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
                             ylabel(['Counts'],'Interpreter','latex')
                             legend(LG([1 20]),'Interpreter','latex','Location','best')
                             title('FLUX fields (Catalog)','Interpreter','latex')
                    
                      

                             
                             subplot(2,1,2)
                             plot(ms_mag3.JD-t0,ms_mag3.Data.MAG_APER_3(:,index_psf)','-s')
                             LG{2} = sprintf('MAG APER 3  %s ; %.0f frames ; RobustSD = %.3f %',Target.Name ,20*Args.Ndir,RobustSD(ms_mag3.Data.MAG_APER_3(:,index_psf))) ; 
                             hold on
                             legend(LG(2))
                             plot(ms_mag2.JD-t0,ms_mag2.Data.MAG_APER_2(:,index_psf)','-s')
                             LG{3} = sprintf('MAG APER 2 ; %s for %.0f frames ; RobustSD = %.3f',Target.Name ,20*Args.Ndir,RobustSD(ms_mag2.Data.MAG_APER_2(:,index_psf))) ; 
                             plot(ms_psf.JD - t0,ms_psf.Data.MAG_PSF(:,index_psf),'-x')
                             LG{4} = sprintf('MAG PSF  %s ;  %.0f frames ; RobustSD = %.3f',Target.Name ,20*Args.Ndir,RobustSD(ms_psf.Data.MAG_PSF(:,index_psf))) ; 
                             legend(LG(2:4),'Interpreter','latex','Location','best')
                             set(gca,'YDir','reverse')
                             xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
                             ylabel(['Inst Mag'],'Interpreter','latex')
                             title('MAG fields (Catalog)','Interpreter','latex')
                             
                             
                             %% save to
                             set(gcf, 'Position', get(0, 'ScreenSize'));

                             filename = ['~/Documents/WD_survey/261123/RefStars/Series/',num2str(Args.Ndir),'_frames_cat.png']
                             saveas(gcf, filename)
          
          

                             %% Forced section

              AI = [];
              
              cd(Target.PathToDir)
              
              cd ../
             

              directories = dir;
              counter = 0 ;
%%
              for i = 3 : length(directories)
    
                   cd(directories(i).name)
    
    
                   fn  = FileNames.generateFromFileName('*proc_Image_1.fits');
                       
               if ~ ismissing(Target.CatID) 
              
               
    
                    if ~isempty(fn.selectBy('FieldID',char((Target.FieldID))).FieldID)
        
        
                        if Target.CatID > 0 
                   
                            FN  = fn.selectBy('CropID',Target.CatID);
    
                            AI  = [AI AstroImage.readFileNamesObj(FN)];
                       
                            flag = true;
                       
                        else
                            fprintf('Object dont have a CropID \n')
                       
                            flag = flase;
                            break;
                       
                        end
                    end
                    
               else
                   
                   fprintf('Object might not be in field \n directory # %s \n',directories(i).name)
                   %fprintf('RA  %d', obj.RA(Args.Index))
                   %fprintf('\n Dec %d ', obj.Dec(Args.Index))
                   flag = false;
                   counter = counter + 1 ;
                   %break;
                   
               end
               cd ../
    
              end
%%                             
                             
                  Target = Target;
                  
                  tic;
                  ForcedPhot = imProc.sources.forcedPhot(AI,'Coo',[Target.RA Target.Dec],'ColNames',{'RA','Dec','X','Y','Xstart','Ystart','Chi2dof','FLUX_PSF','FLUXERR_PSF','MAG_PSF','MAGERR_PSF','BACK_ANNULUS', 'STD_ANNULUS','FLUX_APER','FLAG_POS','FLAGS'});
                  to     = toc;

                  fprintf('\nFinished analyazing %s', Target.Name(1,:))
                  fprintf('\nFor subframe # %d',Target.CatID)
                  fprintf([' \n only "',num2str(to) ,'" s'])
                  %PF = FP;
%                  FileName = [SaveTo,Target.Name(1,:),'_FP0.mat'];
%                  save(FileName,'ForcedPhot', '-nocompression', '-v7.3')

                  
                  %%
FP3_ref = ForcedPhot.copy()
FP2_ref = ForcedPhot.copy()
Rz_ref = lcUtil.zp_meddiff(FP3_ref,'MagField','FLUX_PSF','MagErrField','FLUXERR_PSF')
RZ_ref = lcUtil.zp_meddiff(FP2_ref,'MagField','FLUX_APER_2','MagErrField','FLUXERR_PSF')                 
[FP3_ref,ApplyToMagFieldr] = applyZP(FP3_ref, Rz_ref.FitZP,'ApplyToMagField','FLUX_PSF');
[FP2_ref,ApplyToMagFieldr] = applyZP(FP2_ref, RZ_ref.FitZP,'ApplyToMagField','FLUX_APER_2');

FP1_ref = ForcedPhot.copy()
FP4_ref = ForcedPhot.copy()
R1_ref = lcUtil.zp_meddiff(FP1_ref,'MagField','FLUX_APER_1','MagErrField','FLUXERR_PSF')
R4_ref = lcUtil.zp_meddiff(FP4_ref,'MagField','FLUX_APER_3','MagErrField','FLUXERR_PSF')                 
[FP1_ref,ApplyToMagFieldr] = applyZP(FP1_ref, R1_ref.FitZP,'ApplyToMagField','FLUX_APER_1');
[FP4_ref,ApplyToMagFieldr] = applyZP(FP4_ref, R4_ref.FitZP,'ApplyToMagField','FLUX_APER_3');




%%


%%
figure(7);
subplot(2,2,1)
[~,Sorted] = sort(FP3_ref.JD)

% FLUX PSF
fp_ref2  = FP3_ref.Data.FLUX_PSF(Sorted,1) ;

errorbar([1:Args.Ndir*20],FP3_ref.Data.FLUX_PSF(Sorted,1),...
    FP3_ref.Data.FLUX_PSF(Sorted,1).*FP3_ref.Data.FLUXERR_PSF(Sorted,1),'-x','Color',[0.8500 0.3250 0.1980]')
%hold on
%errorbar([1:20],Sref2,...
%    Sref2./SnrRef2,'-+','Color',[0.0900 0.64250 0.680])
title(sprintf('%s Gaia $B_p$ = %.2f',Target.Name(1,:),Target.Mag),'Interpreter','latex')
Lg{4} = sprintf('Forced Phot PSF ; Scatter : %.3f \\%%',100*RobustSD(fp_ref2)/mean(fp_ref2))
%Lg{2} = sprintf('3 arcsec Aper Phot ; Scatter : %.3f \\%%',100*RobustSD(Sref2)/mean(Sref2))
xlabel('Frame','Interpreter','latex')
ylabel('Counts','Interpreter','latex')


legend(Lg(4),'Interpreter','latex','Location','best')
subplot(2,2,2)
% FLUX APER1
fp1_ref2  = FP1_ref.Data.FLUX_APER_1(Sorted,1) ;

[~,Sorted] = sort(FP1_ref.JD)
plot([1:Args.Ndir*20],fp1_ref2,...
   '-x','Color',[0.8500 0.3250 0.1980]')
%hold on
%plot([1:20],Sref2,...
%    '-+','Color',[0.0900 0.64250 0.680])
xlabel('Frame','Interpreter','latex')
ylabel('Counts','Interpreter','latex')
title('FLUX APER 1','Interpreter','latex')

Lg{5} = sprintf('Forced Phot APER 1 ; Scatter : %.3f \\%%',100*RobustSD(fp1_ref2)/mean(fp1_ref2))
legend(Lg([ 5 ]),'Interpreter','latex','Location','best')

subplot(2,2,3)
% FLUX APER2
fp2_ref2  = FP2_ref.Data.FLUX_APER_2(Sorted,1) ;

[~,Sorted] = sort(FP2_ref.JD)
plot([1:Args.Ndir*20],fp2_ref2,...
   '-x','Color',[0.8500 0.3250 0.1980]')
hold on
%plot([1:20],Sref2,...
%    '-+','Color',[0.0900 0.64250 0.680])

Lg{6} = sprintf('Forced Phot APER 2 ; Scatter : %.3f \\%%',100*RobustSD(fp2_ref2)/mean(fp2_ref2))
legend(Lg([6]),'Interpreter','latex','Location','best')
xlabel('Frame','Interpreter','latex')
ylabel('Counts','Interpreter','latex')
title('FLUX APER 2','Interpreter','latex')
subplot(2,2,4)
% FLUX APER3
fp3_ref2  = FP4_ref.Data.FLUX_APER_3(Sorted,1) ;

[~,Sorted] = sort(FP4_ref.JD)
plot([1:Args.Ndir*20],fp3_ref2,...
   '-x','Color',[0.8500 0.3250 0.1980]')
%hold on
%plot([1:20],Sref2,...
%    '-+','Color',[0.0900 0.64250 0.680])

Lg{7} = sprintf('Forced Phot APER 3 ; Scatter : %.3f \\%%',100*RobustSD(fp3_ref2)/mean(fp3_ref2))
legend(Lg([7]),'Interpreter','latex','Location','best')
xlabel('Frame','Interpreter','latex')
ylabel('Counts','Interpreter','latex')
title(['FLUX APER 3 Nepoch = ',num2str(Args.Ndir*20)],'Interpreter','latex')


                             set(gcf, 'Position', get(0, 'ScreenSize'));

                             filename = ['~/Documents/WD_survey/261123/RefStars/Series/',num2str(Args.Ndir),'_frames_Forced.png']
                             saveas(gcf, filename)


end

