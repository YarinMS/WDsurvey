function [wd] = GetDataV4(wd,Args)
% V# works good without RMS cleaning !!!
% GetData applies all functions in the WD class.
% Using a path for the processed images and target list [RA DEC MAG] as input 
%
% 1. Find the subframe of every source from the list, also if it is
% overlapping between frames

% 2. Get Limiting Magnitude of the subframe over the observation 

% Get forced photometry

% 3. Filter measurements that has a 1-sigma error bar larger than 0.2 Mag
% Which is smaller than SNR 5

% 4.  Use MS.searchFlags to filter bad measurements


% 5. plot ForcedPhot LC (with and without ZP) together with LimMag

% 6. plot LC after 1 and 2 SysRem iterations.

% 7. store all MatchedSources results for further analysis


% Example:
% A WD obbject must be initilized  together with a path:
% example  = WD(targets_ra,targets_dec,targets_mag,targets_name,'/last03e/data1/archive/LAST.01.03.01/2023/10/25/proc/1')
% FP = GetData(example)


%%
arguments
    wd
    Args.time_1immag = {};
    Args.limmag      = {};
    Args.SaveTo      = '/home/ocs/Documents/WD_survey/210823/'
    
    
    
end





%% Get Forced

Nobj = numel(wd.RA);

for Iobj = 1 : Nobj
    
    
    if wd.CropID(Iobj) > 0 
           
       tic;
       [FP,MS,Robust,minxy,ID] = wd.ForcedMS(wd,'Index',Iobj)
       tocs     = toc;
       fprintf('\nfinished ForcedPhot for WD #%d , %s',Iobj,wd.Name(Iobj,:))
       fprintf([' \n only ',num2str(tocs) ,' s'])
       
       %% cleaning FP and MS
       
       % clean targets with magnitude higher than 25
       FP = CleanByMag(FP,27);
      % MS = CleanByMag(MS,27);
       
       %figure();
       %FP.plotRMS
       %hold on
       %MS.plotRMS
   %    [fp,m,dm,c1] = CleanLargeErr(FP,0.2,23);
             
       threshold = 0.2;
       MagThreshold = 23;
       all_measurments = 0;
       c1 = 0 ;


       for i = 1 : length(FP.Data.MAG_PSF(:,1))
           all_measurments = all_measurments +1; 
    
           s1 = FP.Data.MAGERR_PSF(i,1);
           m1 = FP.Data.MAG_PSF(i,1);
    

           if ~isnan(s1) && ~isnan(m1)
                if (abs(s1) > threshold)  || (m1 > MagThreshold)
        
                     FP.Data.MAGERR_PSF(i,:) = nan;
                     FP.Data.MAG_PSF(i,:) = nan;
                     fprintf('error too large t1 :%d \n',m1/s1)
        
                else
        
                     c1 = c1 +1;
                     
        
                end
         
           else
        
                FP.Data.MAGERR_PSF(i,:) = nan;
                FP.Data.MAG_PSF(i,:) = nan;
                fprintf('errorbar has nan value \n')
        
           end
    
       end
       
       dm = FP.Data.MAGERR_PSF(~isnan(FP.Data.MAG_PSF(:,1)),1);
       t  = FP.JD(~isnan(FP.Data.MAG_PSF(:,1)));
       m  = FP.Data.MAG_PSF(~isnan(FP.Data.MAG_PSF(:,1)),1);
       detections = (100*c1)/all_measurments;
       
       
       FileName = [Args.SaveTo,wd.Name(Iobj,:),'_FP.mat'];
   
       save(FileName,'FP', '-nocompression', '-v7.3')
       
       FileName = [Args.SaveTo,wd.Name(Iobj,:),'_FP_cleaned.mat'];
   
       save(FileName,'FP', '-nocompression', '-v7.3')
   
       figure(Iobj);
       subplot(2,2,1)
       FP.plotRMS('FieldX','MAG_PSF','PlotColor','r')
       
       tit = title(['Before SysRem ; RMS plot for Subframe # ',num2str(wd.CropID(Iobj))])
       tit.Interpreter = 'latex' ; 
       hold on
       
       FP.sysrem('MagFields',{'MAG_PSF'},'MagErrFields',{'MAGERR_PSF'}) ;
       
       
       FP.sysrem('MagFields',{'MAG_PSF'},'MagErrFields',{'MAGERR_PSF'}) ;
       FileName = [Args.SaveTo,wd.Name(Iobj,:),'_SysRem_FP.mat'];
       save(FileName,'FP', '-nocompression', '-v7.3')
       FP.plotRMS('FieldX','MAG_PSF')
       tit = title(['before and after 2 SysRem Iterations'])
       tit.Interpreter = 'latex' ; 
       
       legend('No SysRem or ZP correction','2 SysRem Iterations','Location','southeast')
       FileName = [Args.SaveTo,wd.Name(Iobj,:),'_SysRem_FP.mat'];
       save(FileName,'FP', '-nocompression', '-v7.3')
   
       subplot(2,2,2)
       
       dt = round(FP.JD(1));
       
       errorbar(FP.JD-dt,FP.Data.MAG_PSF(:,1),FP.Data.MAGERR_PSF(:,1),'.')
    
       xlabel(['JD - ',num2str(dt)],'Interpreter','latex')
       ylabel('Instrumental Magnitude','Interpreter','latex') % Double check
       t = title(['Raw Forced Photometry ']) %,wd.Name(Iobj,:),' Gaia g mag = ',num2str(wd.Mag(Iobj))])
       t.Interpreter = 'latex';
       set(gca,'YDir','reverse')
       lg = legend(['SF = ', num2str(ID(1)),' ; Dist from edge $\approx$ '...
       ,num2str(min(minxy(1,:))),' pix ; RobustSD $\approx$ ',num2str(Robust(2))])%,['SF = ', num2str(ID(2)),' ; Dist from edge $\approx$ '...
        lg.Interpreter = 'latex';
       
       % FP.sysrem('MagFields',{'MAG_PSF'},'MagErrFields',{'MAGERR_PSF'}) ;
       hold off
      
      % FP.sysrem('MagFields',{'MAG_PSF'},'MagErrFields',{'MAGERR_PSF'}) ;
       
      % FP.plotRMS
      % tit = title(['2nd SysRem iteration'])
      % tit.Interpreter = 'latex' ; 
       

   
       subplot(2,2,3)
       
       %% clean signal by flags
       flags = searchFlags(FP) ;
       sum   = countFlags(FP)  ;
       

       FP.Data.FLUX_PSF(flags(:,1),:) = NaN;
       FP.Data.FLUXERR_PSF(flags(:,1),:) = NaN;
       
       FP.Data.MAG_PSF(flags(:,1),:) = NaN;
       FP.Data.MAGERR_PSF(flags(:,1),:) = NaN;
       
       fprintf('cleaned %d Data points by Flags \n ',sum(1))
       
       
       
       
      
       
       %% clean points with snr lower than 5
       
       
      

       Median   = median(m);
       MAD = sort(abs(Median-m));
       mid = round(length(MAD)/2);
       if mid > 0
           
           SDrobust1= 1.5*MAD(mid);
           
       else
           SDrobust1 = nan;
           
       end
       
       wd.LC_FP_Info(Iobj,1) = detections ;
      
       errorbar(FP.JD-dt,FP.Data.MAG_PSF(:,1),FP.Data.MAGERR_PSF(:,1),'.')
       hold on
       p = scatter(Args.time_1immag(:,wd.CropID(Iobj))-dt,Args.limmag(:,wd.CropID(Iobj)),'.','MarkerFaceColor','k','MarkerEdgeColor','k')
       p.MarkerFaceAlpha = .1;
       p.MarkerEdgeAlpha = .1;
       xlabel(['JD - ',num2str(dt)],'Interpreter','latex')
       ylabel('Instrumental Magnitude','Interpreter','latex') % Double check
       t = title(['Cleaned Forced Photometry'])% for ',wd.Name(Iobj,:),' Gaia g mag = ',num2str(wd.Mag(Iobj))])
       t.Interpreter = 'latex';
       set(gca,'YDir','reverse')
       
       lg = legend(['RobustSD = ',num2str(SDrobust1),' ;  ',num2str(detections),'% of entire obs'], ...
           ['Lim Mag for SF # ',num2str(ID(1))])%,['SF = ', num2str(ID(2)),' ; Dist from edge $\approx$ '...
 
       lg.Interpreter = 'latex';
       hold off
       
       subplot(2,2,4)
       
       obsdate = datestr(datetime(FP.JD(1),'convertfrom','jd'));
       obsdate = obsdate(1:11);
       ObsTel = pwd;
       ObsTel = ObsTel(24:36);
       ObsId  = strcat(obsdate,'\_',ObsTel,'\_',wd.FieldID(Iobj));  
       
       Coord = strcat(num2str(wd.RA(Iobj)),'\,\', num2str(wd.Dec(Iobj)));
       
       SNR =  TheoreticalSNR(FP);
       
       
       latexText = {
            ['$$ ',wd.Name(Iobj,:),' $$'], ...
            ['$$ Gaia\ g\ mag\ =',num2str(wd.Mag(Iobj)),' $$'], ...
                      ['$$ Theroetical \ Error =\ ', num2str(1./SNR),'\ $$'], ...
            strcat('$$ ObsID\ : ',ObsId, '\ $$'), ...
          
             };
       
 
       text(0.5, 0.5, latexText, 'HorizontalAlignment', 'center', 'FontSize', 12,'Interpreter','latex');
       axis off;
       
      % strcat('$$ RA\ : \',num2str(wd.RA(Iobj)),'\ Dec\ : \ ',num2str(wd.Dec(Iobj)), ' $$'), ...
      %      strcat('$$ Gaia \ g = ',num2str(wd.Mag(Iobj)),' $$'), ...
       
     
        
        
               
        
        set(gcf, 'Position', get(0, 'ScreenSize'));
        % save the plot as a PNG file
        pause(7)
        filename = [Args.SaveTo,'LC_Result_',wd.Name(Iobj,:), '.png'];
        saveas(gcf, filename);
        close;
       
        
         %% REference sources 
  
        figure(100 + Iobj);
        CountMax = 4;
        count = 0;
        legend_labels = cell(1, CountMax);
        for j = 1 :length(FP.SrcData.phot_g_mean_mag)
        
       
        
            if (15 < FP.SrcData.phot_g_mean_mag(j) ) && (16 >FP.SrcData.phot_g_mean_mag(j) )
            
            
                ind = abs(FP.Data.MAGERR_PSF(:,j)) < 0.2
           
           
            
            
                if  mean(FP.Data.MAG_PSF(ind,j)) < 22
                    count = count +1 ;
                 
                    errorbar(FP.JD(ind)-dt,FP.Data.MAG_PSF(ind,j),FP.Data.MAGERR_PSF(ind,j),'.')
                    hold on
                    ax1 = xlabel(['JD - ',num2str(dt)])
                    ax1.Interpreter = 'latex'
                    ax2 = ylabel('Inst Mag')
                    ax2.Interpreter = 'latex'
                    tit = title(['Reference stars for ', wd.Name(Iobj,:)])
                    tit.Interpreter = 'latex'
                    legend_labels{count} = sprintf('Gaia g mag = %.2f', FP.SrcData.phot_g_mean_mag(j));
                    set(gca,'YDir','reverse')
                    legend(legend_labels(1:count));
                    legend('Location','best')
            
             
                
                end
            
           
                
            
                if count == CountMax
                
                    break;
                
                end
            
            
            end
        end
    
    
    
    
            set(gcf, 'Position', get(0, 'ScreenSize'));
        % save the plot as a PNG file
        %pause(7)
            filename = [Args.SaveTo,'REF_',wd.Name(Iobj,:), '.png'];
            saveas(gcf, filename);
           %close;
            pause(7)
            hold on
            errorbar(FP.JD-dt,FP.Data.MAG_PSF(:,1),FP.Data.MAGERR_PSF(:,1),'o')
            legend_labels{count+1} = sprintf('WD Gaia g mag = %.2f', wd.Mag(Iobj));
                
            legend(legend_labels(1:count+1))
            legend('Location','best')
            tit = title(['Reference stars And ', wd.Name(Iobj,:)])
            tit.Interpreter = 'latex'
            hold off
            set(gcf, 'Position', get(0, 'ScreenSize'));
        % save the plot as a PNG file
            pause(7)
           filename = [Args.SaveTo,'REF_RES',wd.Name(Iobj,:), '.png'];
           saveas(gcf, filename);
        
           close ;
        
        
      
    
    %% High SNR targets light curve
    
    fprintf('\nFinished with   %d / % d targets \n',[Iobj,length(wd.RA)] )
   
   
    
    
    
    
    
    
       
    else
        
        fprintf('could not find target number # %d \n',Iobj)
        
    end
    
    
   
end



%% 3.

%% 4.





%% 5.

%% 6.

%% 7.








end