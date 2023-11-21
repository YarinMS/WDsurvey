%clear all

% get FP
%load('/home/ocs/Documents/WD_survey/270823/358+34/WDJ235844.68+353353.83_SysRem_FP.mat')
wdt = 1
target = e1.Name(wdt,:);
%load(strcat('/home/ocs/Documents/WD_survey/270823/358+34/',target,'_FP1.mat'))
   

% find ref

CountMax = 5;
count = 0;
index = cell(1,6);
index{1} = 1;
%        for j = 1 :length(FP.SrcData.phot_g_mean_mag)
%        
%           colorterm = e1.LC_coadd(wdt) ;
           
        
%            if (15 < FP.SrcData.phot_g_mean_mag(j) ) && (16 >FP.SrcData.phot_g_mean_mag(j) )
 %               bp_rp = FP.SrcData.phot_bp_mean_mag(j) - FP.SrcData.phot_rp_mean_mag(j);
                
  %              if abs(colorterm - bp_rp) < 1
            
   %$                  ind = abs(FP.Data.MAGERR_PSF(:,j)) < 0.2  ;
                     
                     
           
           
            
            
     %                if  mean(FP.Data.MAG_PSF(ind,j)) < 22
      %                    count = count +1 ;
                          %index{count+1} = j 
%                          
%                          Nlightcurve(:,1) = Nlightcurve(:,1) + (1./CountMax).* FP.Data.MAG_PSF(ind,j) ;             
%                 
       %                   errorbar(FP.JD(ind)-dt,FP.Data.MAG_PSF(ind,j),FP.Data.MAGERR_PSF(ind,j),'.')
        %                  hold on
%                          ax1 = xlabel(['JD - ',num2str(dt)])
%                          ax1.Interpreter = 'latex'
%                          ax2 = ylabel('Inst Mag')
 %                         ax2.Interpreter = 'latex'
%                          tit = title(['Reference stars for ', wd.Name(Iobj,:)])
%                          tit.Interpreter = 'latex'
%                          legend_labels{count} = sprintf('Gaia g mag = %.2f', FP.SrcData.phot_g_mean_mag(j));
         %                 set(gca,'YDir','reverse')
%                          legend(legend_labels(1:count));
%                          legend('Location','best')
            
             
                
          %           end 

            
           %     if count == CountMax
                
            %        break;
                
             %   end
                
              %  end
            
            
           % end
        %end

%pause(5)
%close;
index{1} = 1;
[R,s] = lsqRelPhotByEran(FP,'Niter', 1);
for k = 1 :length(s)
index{k+1} = s(k);
end

RR = lsqRelPhotByEran(FP,'Niter', 2);


for Iind = 1 :numel(index) 


        ind = index{Iind};
        
  

legend_labels = cell(1,4)
% plot before
dt = round(FP.JD(1))
figure(1);
subplot(2,1,1)
plot(FP.JD-dt,FP.Data.MAG_PSF(:,ind),'k.','MarkerSize',6)
set(gca , 'YDir','reverse')
xlabel(['JD - ',num2str(dt)],'Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
rms0 = RobustSD(FP.Data.MAG_PSF(:,ind));
legend_labels{1} = sprintf('NO ZP ; robustSD = %.4f',rms0)
if ind == 1
    

    title(['Model : $$ m_{ij} = ZP_i +M_j$$  :',e1.Name(wdt,1:9)],'Interpreter','latex')
else
     title(['Model : $$ m_{ij} = ZP_i +M_j$$  REF:',e1.Name(wdt,1:9)],'Interpreter','latex')
end
    
% detrend once

%[R,s] = lsqRelPhotByEran(FP,'Niter', 1);
yo = reshape(R.Resid,[FP.Nepoch,FP.Nsrc]);
%%[MS1,ApplyToMagFieldr] = applyZP(FP, R.ParZP,'ApplyToMagField','MAG_PSF');

% plot
hold on
%%plot(MS1.JD,MS1.Data.MAG_PSF(:,ind),'o')
plot(FP.JD-dt,yo(:,ind)-mean(yo(:,ind),'omitnan')+mean(FP.Data.MAG_PSF(:,ind),'omitnan'),'o')
rms1 = RobustSD(yo(:,ind));
legend_labels{2} = sprintf('1 lsq Iter ; robustSD = %.4f',rms1)
legend(legend_labels(1:2),'Interpreter','latex','Location','best')
hold off
% load again
%load('/home/ocs/Documents/WD_survey/270823/358+34/WDJ235844.68+353353.83_SysRem_FP.mat')

%load(strcat('/home/ocs/Documents/WD_survey/270823/358+34/',target,'_FP1.mat'))


% plot before
subplot(2,1,2)
plot(FP.JD-dt,FP.Data.MAG_PSF(:,ind),'k.','MarkerSize',6)


rms00 = RobustSD(FP.Data.MAG_PSF(:,ind));
legend_labels{3} = sprintf('NO ZP ; robustSD = %.4f',rms00)

% detrend twice
%RR = lsqRelPhotByEran(FP,'Niter', 2);
yo2 = reshape(RR.Resid,[FP.Nepoch,FP.Nsrc]);
%%[MS1,ApplyToMagFieldr] = applyZP(FP, R.ParZP,'ApplyToMagField','MAG_PSF');

% plot
hold on
%%plot(MS1.JD,MS1.Data.MAG_PSF(:,ind),'o')
plot(FP.JD-dt,yo2(:,ind)-mean(yo2(:,ind),'omitnan')+mean(FP.Data.MAG_PSF(:,ind),'omitnan'),'o')
rms2 = RobustSD(yo2(:,ind));
legend_labels{4} = sprintf('2 lsq Iter ; robustSD = %.4f',rms2)
legend(legend_labels(3:4),'Interpreter','latex','Location','best')
xlabel(['JD - ',num2str(dt)],'Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
set(gca , 'YDir','reverse')

if ind > 1 
    
title(sprintf('Sub Frame : %d ; Gaia g mag %.2f',[e1.CropID(wdt) FP.SrcData.phot_g_mean_mag(ind)]),'Interpreter','latex')

else
    title(sprintf('Sub Frame : %d ; Gaia g mag %.2f',[e1.CropID(wdt) e1.Mag(wdt)]),'Interpreter','latex')

end
hold off

% plot


set(gcf, 'Position', get(0, 'ScreenSize'));
        % save the plot as a PNG file
        pause(7)
       
            filename = strcat('~/Documents/WD_survey/270823/358+34/zp/','ZP_',num2str(index{Iind}),'_',e1.Name(wdt,:), '.png');
            saveas(gcf, filename);
           close;

           
M1 = yo - mean(yo,'omitnan') + mean(FP.Data.MAG_PSF,'omitnan');
M2 = yo2 - mean(yo2,'omitnan') + mean(FP.Data.MAG_PSF,'omitnan');
% FP.plotRMS('FieldX','MAG_PSF')
rms0 = CalcRMS(FP.SrcData.phot_g_mean_mag,FP.Data.MAG_PSF,e1,wdt,'Marker','xk','Predicted',false)
hold on

rms1 = CalcRMS(FP.SrcData.phot_g_mean_mag,M1,e1,wdt,'Marker','b.','Predicted',false)
hold on
rms2 = CalcRMS(FP.SrcData.phot_g_mean_mag,M2,e1,wdt,'Marker','go','Predicted',false)
title(strcat('RMS VS MAG  SF $$ \#$$ ',num2str(e1.CropID(wdt))),'Interpreter','latex')
xlabel('Gaia g mag','Interpreter','latex')
ylabel('RMS','Interpreter','latex')
legend('Np ZP','1 lsq Iter','2 lsq Iter','Location','best')
set(gcf, 'Position', get(0, 'ScreenSize'));
        % save the plot as a PNG file
        pause(7)
       
            filename = strcat('~/Documents/WD_survey/270823/358+34/zp/','ZP_RMS2','_',e1.Name(wdt,:), '.png');
            saveas(gcf, filename);
           close;
end



           