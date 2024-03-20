% WD 27 08 23



%% Lim mag from header:

AN  = WD([],[],[],[],'/last10e/data1/archive/LAST.01.10.01/2023/08/27/proc/1')

%choose field ID :
AN.FieldID = '351+32'

% limmag per subframe


[time_1,limmag] = AN.Header_LimMag(AN)

for  i = 1 : 24
    
    
        figure();
        p = plot(datetime(time_1(:,i),'convertfrom','jd'),limmag(:,i),'o','MarkerSize',15)
        hx = xlabel('Time');
        hx.Interpreter = 'latex';
        hy = ylabel('Limiting Magnitude');
        hy.Interpreter = 'latex';
        tit = title(['Sub frame #',num2str(i),' Limiting Magnitude over night']);
        tit.Interpreter = 'latex';
        set(gcf, 'Position', get(0, 'ScreenSize'));
        % save the plot as a PNG file
        pause(3)
        filename = ['LimMag_Sub_',num2str(i), '.png'];
        saveas(gcf, filename);
        close;

end






targets = [ 
351.011359	33.502127	18.909500
353.107556	33.897510	17.597006
352.370507	31.925762	18.785543
352.630665	33.735717	16.877939
352.732329	31.780831	18.648848
351.586162	33.414294	18.962555
352.532987	33.345250	18.332022
]

name = [


'WDJ232402.53+333008.47',
'WDJ233225.88+335351.89',
'WDJ232928.89+315533.04',
'WDJ233031.28+334409.57',
'WDJ233055.81+314651.71',
'WDJ232620.71+332451.78',
'WDJ233007.89+332043.31'


]


e  = WD(targets(:,1),targets(:,2),targets(:,3),name,'/last10e/data1/archive/LAST.01.10.01/2023/08/27/proc/1')
[id,FieldId] = e.Coo_to_Subframe(e.Pathway,e);
e  = e.get_id(id(:,1));
e  = e.get_fieldID(FieldId);
[Index,cat_id] = e.find_in_cat(e);
e  = e.get_cat_id(cat_id);
%e  = e.get_LC
% catalog extracion

%[t_psf,y_psf,t_aper,y_aper,Info_psf,Info_aper, ... 
%               flager,t_rms_aper,t_rms_psf,t_rms_flux,Rms_aper,Rms_psf, ... 
%               rms_flux,t_flux,f_flux,total_rms_flux,magerr] = e.get_LC_cat(e,20,30);
           
%e.LC_psf   = {t_psf;y_psf};
%e.LC_aper  = {t_aper;y_aper;magerr};
%e.Flux     = {t_flux;f_flux};
%e.FluxRMS  = total_rms_flux;
%e.InfoPsf  = Info_psf;
%e.InfoAper = Info_aper;
%e.RMS      = {t_rms_aper Rms_aper ; t_rms_psf Rms_psf; t_rms_flux rms_flux };
% ploting section

% flux

%for  ind = 1 : 24
    
%   if e.CatID(ind) > 0 
%        e.plotFLUX(e,'id',ind,'TextShift',450,'JDShift',2.460173e6,'Xlabel','Time JD -2.460173e6 ')
%        set(gcf, 'Position', get(0, 'ScreenSize'));
%        % save the plot as a PNG file
%        pause(8)
%        filename = [e.Name(ind,:),'_flux', '.png'];
%        saveas(gcf, filename);
%        close;
%   end
%end


% mag and rms
%for  ind = 1 : length(e.RA)
    
%   if e.CatID(ind) > 0 
%        e.plotLC('Index',{},'id',ind,'Ylabe','Mag')
%        set(gcf, 'Position', get(0, 'ScreenSize'));
        % save the plot as a PNG file
%        pause(8)
%        filename = [e.Name(ind,:),'_mag', '.png'];
%        saveas(gcf, filename);
%        close;
%   end
%end

%for  ind = 1 : length(e.RA)
    
    
%   if e.CatID(ind) > 0 
%        e.plotRMSseries('id',ind)
%        set(gcf, 'Position', get(0, 'ScreenSize'));
%        % save the plot as a PNG file
%        pause(8)
%        filename = [e.Name(ind,:),'_RMS', '.png'];
%        saveas(gcf, filename);
%        close;
%   end
%end


% move al .png's from the directory
% limmag per subframe


%[time_1,limmag] = e.Header_LimMag(e)

%for  i = 1 : 24
    
    
% %       figure();
%        p = plot(datetime(time_1(:,i),'convertfrom','jd'),limmag(:,i),'o','MarkerSize',15)
%        hx = xlabel('Time');
%        hx.Interpreter = 'latex';
%        hy = ylabel('Limiting Magnitude');
%        hy.Interpreter = 'latex';
%        tit = title(['Sub frame #',num2str(i),' Limiting Magnitude over night']);
%        tit.Interpreter = 'latex';
%        set(gcf, 'Position', get(0, 'ScreenSize'));
%        % save the plot as a PNG file
%        pause(3)
%        filename = ['LimMag_Sub_',num2str(i), '.png'];
%        saveas(gcf, filename);
%        close;
%
%end

% coadd section.
%tic;
%[m,m2,ID,id,flags] = e.find_in_coadd(e,3) 
%toc
%e = e.get_CoaddID(id);
%e = e.get_NobsCoadd(flags);
%e.LC_coadd = m(:,:,1:2);
%e.JD_coadd = m(:,:,3);


% Ploting section


%%  Forced photometry section 

%% get forced for specifice targets :
% consider their errors
% add index number :

ind = 1;
[lc,ForcedMag,ForcedMagErr,ForcedTime,X,Y,ra,dec,AM,FP,Robust,minxy,ID] = e.ForcedCheck(e,'Index',ind)
ForcedFlux = FP.Data.FLUX_PSF(:,1);
ForcedErr  = FP.Data.FLUXERR_PSF(:,1);
%% filter bad measurements
all_measurements = 0
c1 =0 ;
c2=0;

for i = 1 : length(ForcedMag(1,:))
    all_measurements = all_measurements +1; 
    
    s1 = ForcedMagErr(1,i)
    m1 = ForcedMag(1,i)
    
  %  s2 = ForcedMagErr(2,i)
  %  m2 = ForcedMag(2,i)
    
    if ~isnan(s1)
         if (m1/s1) < abs(5*s1)
        
             ForcedMagErr(1,i) = nan;
             ForcedMag(1,i) = nan;
             fprintf('error too large t1 :%d',m1/s1)
        
         else
        
             c1 = c1 +1;
        
         end
         
    else
        
        ForcedMagErr(1,i) = nan;
        ForcedMag(1,i) = nan;
        fprintf('errorbar has nan value')
        
    end
    
   % if ~isnan(s2)
        
   %      if (m2/s2) < abs(5*s2)
        
   %          ForcedMagErr(2,i) = nan;
   %          ForcedMag(2,i) = nan;
   %          fprintf('error too large t2 :%d',m2/s2)
        
   %      else
        
    %$         c2 = c2 +1;
        
     %    end 
         
     %else
        
    %    ForcedMagErr(2,i) = nan;
    %    ForcedMag(2,i) = nan;
    %    fprintf('errorbar has nan value')
        
        
   % end
    
end

all_measurements_f = 0
d1 =0 ;
d2=0;

for i = 1 : length(ForcedFlux(:,1))
    all_measurements_f = all_measurements_f +1; 
    
    sd1 = ForcedErr(i,1)
    f1 = ForcedFlux(i,1)
    

    
    if ~isnan(sd1)
         if (f1/sd1) < abs(5*sd1)
        
             ForcedErr(i,1) = nan;
             ForcedFlux(i,1) = nan;
             fprintf('error too large t1 :%d',f1/sd1)
        
         else
        
             d1 = d1 +1;
        
         end
         
    else
        
        ForcedErr(i,1) = nan;
        ForcedFlux(i,1) = nan;
        fprintf('errorbar has nan value')
        
    end
   
    
end


ff1 = ForcedMag(1,~isnan(ForcedFlux(:,1)))
      Median   = median(ff1);
      MAD = sort(abs(Median-ff1));
      mid = round(length(MAD)/2);
      SDf1= 1.5*MAD(mid);

errorbar(FP.JD-2460184,ForcedFlux(:,1),ForcedErr(:,1),'.')      
      
      

m1 = ForcedMag(1,~isnan(ForcedMag(1,:)))
%m2 = ForcedMag(2,~isnan(ForcedMag(2,:)))
%      Median   = median(m2);
%      MAD = sort(abs(Median-m2));
%      mid = round(length(MAD)/2);
%      SDrobust2 = 1.5*MAD(mid);
      Median   = median(m1);
      MAD = sort(abs(Median-m1));
      mid = round(length(MAD)/2);
      SDrobust1= 1.5*MAD(mid);


errorbar(ForcedTime(1,:)-2460184,ForcedMag(1,:),ForcedMagErr(1,:),'.')
hold on
errorbar(ForcedTime(2,:)-2460184,ForcedMag(2,:),ForcedMagErr(2,:),'.')

xlabel(['JD - 2460184 '],'Interpreter','latex')
ylabel('Instrumental Magnitude','Interpreter','latex') % Double check
t = title(['Forced Photometry for ',e.Name(ind,:),' Gaia g mag = ',num2str(e.Mag(ind))])
t.Interpreter = 'latex';
set(gca,'YDir','reverse')

lg = legend(['SF = ', num2str(ID(1)),' ; Dist from edge $\approx$ '...
    ,num2str(min(minxy(1,:))),' pix ; RobustSD $\approx$ ',num2str(SDrobust1),' ; $5-\sigma$ detections : ',num2str(length(m1)/720) ],['SF = ', num2str(ID(2)),' ; Dist from edge $\approx$ '...
    ,num2str(min(minxy(2,:))),' pix ; RobustSD $\approx$ ',num2str(SDrobust2),' ; $5-\sigma$ detections : ',num2str(length(m2)/720) ])
lg.Interpreter = 'latex';

