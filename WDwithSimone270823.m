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



[time_1,limmag] = AN.Header_LimMag(e)
figure();
for  i = 1 : 24
    
    

        p = plot(datetime(time_1(:,i),'convertfrom','jd'),limmag(:,i),'k.','MarkerSize',12)
        %hold on
        hx = xlabel('Time');
        hx.Interpreter = 'latex';
        hy = ylabel('Limiting Magnitude (Gaia G mag)');
        hy.Interpreter = 'latex';
        tit = title(['Sub frame Limiting Magnitude over night']);
        tit.Interpreter = 'latex';
        lg = legend(['Sub frame #  ',num2str(i)])
        lg.Interpreter = 'latex';
        set(gca,'YDir','reverse')
        
        
        set(gcf, 'Position', get(0, 'ScreenSize'));
        % save the plot as a PNG file
        pause(8)
        filename = ['LimMag_sub_',num2str(i), '.png'];
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

[t_psf,y_psf,t_aper,y_aper,Info_psf,Info_aper, ... 
               flager,t_rms_aper,t_rms_psf,t_rms_flux,Rms_aper,Rms_psf, ... 
               rms_flux,t_flux,f_flux,total_rms_flux,magerr] = e.get_LC_cat(e,20,30);
           
e.LC_psf   = {t_psf;y_psf};
e.LC_aper  = {t_aper;y_aper;magerr};
e.Flux     = {t_flux;f_flux};
e.FluxRMS  = total_rms_flux;
e.InfoPsf  = Info_psf;
e.InfoAper = Info_aper;
e.RMS      = {t_rms_aper Rms_aper ; t_rms_psf Rms_psf; t_rms_flux rms_flux };
% ploting section

% flux

for  ind = 1 : 24
    
   if e.CatID(ind) > 0 
        e.plotFLUX(e,'id',ind,'TextShift',450,'JDShift',2.460173e6,'Xlabel','Time JD -2.460173e6 ')
        set(gcf, 'Position', get(0, 'ScreenSize'));
        % save the plot as a PNG file
        pause(8)
        filename = [e.Name(ind,:),'_flux', '.png'];
        saveas(gcf, filename);
        close;
   end
end


% mag and rms
for  ind = 1 : length(e.RA)
    
   if e.CatID(ind) > 0 
        e.plotLC('Index',{},'id',ind,'Ylabe','Mag')
        set(gcf, 'Position', get(0, 'ScreenSize'));
        % save the plot as a PNG file
        pause(8)
        filename = [e.Name(ind,:),'_mag', '.png'];
        saveas(gcf, filename);
        close;
   end
end

for  ind = 1 : length(e.RA)
    
    
   if e.CatID(ind) > 0 
        e.plotRMSseries('id',ind)
        set(gcf, 'Position', get(0, 'ScreenSize'));
        % save the plot as a PNG file
        pause(8)
        filename = [e.Name(ind,:),'_RMS', '.png'];
        saveas(gcf, filename);
        close;
   end
end


% move al .png's from the directory
% limmag per subframe


[time_1,limmag] = e.Header_LimMag(e)

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

% coadd section.
tic;
[m,m2,ID,id,flags] = e.find_in_coadd(e,3) 
toc
e = e.get_CoaddID(id);
e = e.get_NobsCoadd(flags);
e.LC_coadd = m(:,:,1:2);
e.JD_coadd = m(:,:,3);


% Ploting section


%%  Forced photometry section 
% still a draft since playing with the forcedphot arguments
P = e;
ForcedMag    = [];
ForcedMagErr = [];
ForcedTime   = [];
X            = [];
Y            = [];
ra           = [];
dec          = [];
AM           = [];

for i = 1:length(P.RA)
    
    if P.CropID(i) >0
    
        [R,LC,Xpos,Ypos,RA,Dec,AirMass,~] = P.forceddraft(P,'Index',i);
    
        ForcedTime   = [ForcedTime ; LC(:,1)'];
        ForcedMag    = [ForcedMag ; LC(:,7)'];
        ForcedMagErr = [ForcedMagErr ; LC(:,3)'];
        X    = [X ; Xpos'] ;
        Y    = [Y ; Ypos'] ;
        ra   = [ra ; RA'] ;
        dec  = [dec ; Dec'];
        AM   = [AM ; AirMass'];
        
            
        
    
        fprintf('Finished with target # ',num2str(i))
        
    else
        
        fprintf('Coordinate is not in field ? check')
        
        ForcedTime   = [ForcedTime ; nan*LC(:,1)'];
        ForcedMag   = [ForcedMag ; nan*LC(:,7)'];
        ForcedMagErr   = [ForcedMagErr ; nan*LC(:,7)'];
        X    = [X ; nan*Xpos'] ;
        Y    = [Y ; nan*Ypos'] ;
        ra   = [ra ; nan*RA'] ;
        dec  = [dec ; nan*Dec'];
        AM   = [AM ; nan*AirMass'];
        
    end
        
end

P = P.get_FP( {ForcedTime, ForcedMag , ForcedMagErr}');
P = P.get_FP_Info( {ra , dec , X , Y}');
P = P.get_AirMass(AM);

ind = 1; 


figure();
plot()
xlabel('X [pix]','Interpreter','latex')
ylabel('Inst Magnitude','Interpreter','latex')
title('Position drift on the detector durinf the observation','Interpreter','latex')





% plot with error bar
P.plotLCERR_FP('Index',{},'id',6,'Name','WD6 Field 351+32','Ylabel','Inst Mag','Xlabel','JD-2460183.5')

% rms timeseries :
[rms,interval_center] = P.RMS_timeseries(P,P.LC_FP{1},P.LC_FP{2},20)
figure;
plot(interval_center,rms,'-o')
xlabel('Time [JD]','Interpreter','latex')
ylabel('RMS','Interpreter','latex')
title('Forced Photometry RMS timeseries','Interpreter','latex')



% P.RMS_timeseries


% plot position drift
figure;
plot(P.LC_FP_Info{3},P.LC_FP_Info{4},'k.')
xlabel('X [pix]','Interpreter','latex')
ylabel('Y [pix]','Interpreter','latex')
title('Position drift on the detector durinf the observation','Interpreter','latex')


% plot deviation from input coord:

        ind = 1;
        
        
% ploting section
F =ForcedMag;
T =ForcedTime;

for  ind = 1 : length(P.RA)
    
    
    if ~isnan(F(ind,2))
    
        subplot(2,1,1)
    
        rms = P.calcRMS(F(ind,:));
    
        h = plot(T(ind,:),F(ind,:),'.k','Color',[0.1 0.1 0.1])
        %ylim([(mean(F(ind,:)) - 0.5 ), (mean(F(ind,:)) +0.5 )])
        %hold on
        sub = P.CropID(ind) ;
        [a,b] = sort(time_1(:,sub));
       % plot(time_1(b,sub),limmag(b,sub),'.')
       % hold off
        xlim([min(T(ind,:)),max(T(ind,:))])
        hx = xlabel('Time [JD]');
        hx.Interpreter = 'latex';
        hx.FontSize    = 18;
        hy = ylabel('Mag');
        hy.Interpreter = 'latex';
        hy.FontSize    = 18;
        set(gca,'YDir','reverse');
        tit = title([P.Name(ind,:),' Forced Photometry',  ' G mag = ',num2str(P.Mag(ind))]);
        tit.Interpreter = 'latex';
        legend(['LC ; rms = ',num2str(rms)])%,['LimMag sub #', num2str(sub)],'Location','southwest','FontSize',8)
        % axis tight
        
        subplot(2,1,2)
        
        
        rmss = P.InfoPsf(ind,7);
    
        hw = plot(P.LC_psf{1}(ind,:),P.LC_psf{2}(ind,:),'.')
        %hold on 
        %plot(time_1(b,sub),limmag(b,sub),'.')
        %hold off
        %ylim([(mean(AN.LC_psf{2}(ind,:),'omitnan') - 0.5 ), (mean(AN.LC_psf{2}(ind,:),'omitnan') +0.5 )])
        xlim([min(T(ind,:)),max(T(ind,:))])
        hx = xlabel('Time [JD]');
        hx.Interpreter = 'latex';
        hx.FontSize    = 18;
        hy = ylabel('Mag');
        hy.Interpreter = 'latex';
        hy.FontSize    = 18;
        tit = title([P.Name(ind,:),' Psf Photometry',  ' Subframe = ',num2str(P.CropID(ind))]);
        tit.Interpreter = 'latex';
        set(gca,'YDir','reverse');
        %tite = title([AN.Name(ind,:),' Psf Photometry',  ' G mag = ',num2str(AN.Mag(ind)), ' Subframe #', num2str(AN.CropID(ind))]);
        %tite.Interpreter = 'latex';
        legend(['LC ; rms = ',num2str(rmss)])%,['LimMag sub #', num2str(sub)],'Location','southwest','FontSize',8)
        %axis tight
        
        
        
        
        
     
        
        set(gcf, 'Position', get(0, 'ScreenSize'));
        % save the plot as a PNG file
        pause(8)
        filename = [P.Name(ind,:),'Forced_mag1', '.png'];
        saveas(gcf, filename);
        close;
        
    end 
   
end




%

for  ind = 1 : length(P.RA)
    
    
    if ~isnan(F(ind,2))
    
        subplot(2,1,1)
    
        rms = P.calcRMS(F(ind,:));
    
        h = plot(T(ind,:),F(ind,:),'.k','Color',[0.1 0.1 0.1])
        %ylim([(mean(F(ind,:)) - 0.5 ), (mean(F(ind,:)) +0.5 )])
        %hold on
        sub = P.CropID(ind) ;
        [a,b] = sort(time_1(:,sub));
       % plot(time_1(b,sub),limmag(b,sub),'.')
       % hold off
        xlim([min(T(ind,:)),max(T(ind,:))])
        hx = xlabel('Time [JD]');
        hx.Interpreter = 'latex';
        hx.FontSize    = 18;
        hy = ylabel('Mag');
        hy.Interpreter = 'latex';
        hy.FontSize    = 18;
        set(gca,'YDir','reverse');
        tit = title([P.Name(ind,:),' Forced Photometry',  ' G mag = ',num2str(P.Mag(ind))]);
        tit.Interpreter = 'latex';
        legend(['LC ; rms = ',num2str(rms)])%,['LimMag sub #', num2str(sub)],'Location','southwest','FontSize',8)
        % axis tight
        
       % subplot(2,1,2)
        
        
        
        
        
     
        
        set(gcf, 'Position', get(0, 'ScreenSize'));
        % save the plot as a PNG file
        pause(8)
        filename = [P.Name(ind,:),'Forced_mag1', '.png'];
        saveas(gcf, filename);
        close;
        
    end 
   
end



%% fix plots

% robust RMS

% lim axis on y axis

P.plotLC('Index',{},'id',2,'Deltay',0.2)

% Gaia lim mag on limiting magnitudes
% plot air mass and subframe LimMag together
subplot(2,1,1)
plot(timeofday(datetime(P.LC_FP{1}-0.1,'convertfrom','jd')),P.AirMass,'k.')
set(gca,'YDir','reverse')
xlabel('Time (UTC)','Interpreter','latex')
ylabel('Airass','Interpreter','latex')
title("Target's airmass during the observation",'Interpreter','latex')
subplot(2,1,2)
plot(timeofday(datetime(time_1(:,ind)-0.1,'convertfrom','jd')),limmag(:,P.CropID(ind)),'k.')
set(gca,'YDir','reverse')
xlabel('Time (UTC)','Interpreter','latex')
ylabel('Magnitude (Gaia g)','Interpreter','latex')
title("Limiting Magnitude of target's subframe ",'Interpreter','latex')
legend(['sub frame # ',num2str(P.CropID(ind))])


% Delta deg to Delta arcsec
ind = 1;
y_arcsec = 3600*sqrt( (P.RA(ind)-P.LC_FP_Info{1}(ind,:)).^2 + (P.Dec(ind)-P.LC_FP_Info{2}(ind,:)).^2);
h = plot( P.LC_FP{1}(ind,:),y_arcsec,'.k','Color',[0.1 0.1 0.1])
        %ylim([(mean(F(ind,:)) - 0.5 ), (mean(F(ind,:)) +0.5 )])
        %hold on
        sub = P.CropID(ind) ;
        [a,b] = sort(time_1(:,sub));
       % plot(time_1(b,sub),limmag(b,sub),'.')
       % hold off
        %xlim([min(T(ind,:)),max(T(ind,:))])
        hx = xlabel('Time [JD]');
        hx.Interpreter = 'latex';
        hx.FontSize    = 18;
        hy = ylabel('Arc Seconds');
        hy.Interpreter = 'latex';
        hy.FontSize    = 18;
        %set(gca,'YDir','reverse');
        tit = title('Deviation between source and detected coordinates  $\sqrt{(\alpha_s-\alpha_i)^2+(\delta_s-\delta_i)^2}$');
        tit.Interpreter = 'latex';
        lg = legend(['Average deviation $\Delta C$ = ',num2str(mean(y_arcsec,'omitnan')),' arcsec $\approx$ ',num2str(mean(y_arcsec,'omitnan')./1.25),' Pixels'])
        lg.Interpreter = 'latex';

% Catalog light curves

        
for  ind = 1 : length(P.RA)
    
   if P.CatID(ind) > 0 
        P.plotLC('Index',{},'id',ind,'Ylabel','Mag')
        set(gcf, 'Position', get(0, 'ScreenSize'));
        % save the plot as a PNG file
        pause(8)
        filename = [P.Name(ind,:),'_mag', '.png'];
        saveas(gcf, filename);
        close;
   end
end
% Forced photometry issue


% moving = false
P=e
[R,LC,X,Y,RA,Dec,AirMass,FP,Robust_parameters] = P.ForcedFlux(P,'Find',true,'Moving',false)

time     = timeofday(datetime(LC(:,1),'convertfrom','jd'));
Flux     = LC(:,2);
Median   = Robust_parameters(1);
SDrobust = Robust_parameters(2);


% Noises:

SourceNoise = sqrt(Median);
% assuming 20 pix for no reason
TotalNoise  = sqrt(Median + 20*median(FP.Data.BACK_ANNULUS(:,1)) +20*(3.5*0.75*20 + 20 *0.01)  )

ind = 1
figure(10);
plot(time,Flux,'k.')
xlabel(['Time '],'Interpreter','latex')
ylabel('Counts') % Double check
title(['Forced Photometry for ',P.Name(ind,:)],'Interpreter','latex')

lg = legend(['Source noise $\approx$ ', num2str(SourceNoise),' Total noise $\approx$ '...
    ,num2str(TotalNoise),' Robust SD $\approx$ ',num2str(SDrobust)])
lg.Interpreter = 'latex';


%% get overlapped targets :

% add index number :

ind = 6;
[lc,ForcedMag,ForcedMagErr,ForcedTime,X,Y,ra,dec,AM,FP,Robust,minxy,ID] = e.ForcedCheck(e,'Index',ind)

%% filter bad measurements
all_measurements = 0
c1 =0 ;
c2=0;

for i = 1 : length(ForcedMag(1,:))
    all_measurements = all_measurements +1; 
    
    s1 = ForcedMagErr(1,i)
    m1 = ForcedMag(1,i)
    
    s2 = ForcedMagErr(2,i)
    m2 = ForcedMag(2,i)
    
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
    
    if ~isnan(s2)
        
         if (m2/s2) < abs(5*s2)
        
             ForcedMagErr(2,i) = nan;
             ForcedMag(2,i) = nan;
             fprintf('error too large t2 :%d',m2/s2)
        
         else
        
             c2 = c2 +1;
        
         end 
         
     else
        
        ForcedMagErr(2,i) = nan;
        ForcedMag(2,i) = nan;
        fprintf('errorbar has nan value')
        
        
    end
    
end

m1 = ForcedMag(1,~isnan(ForcedMag(1,:)))
m2 = ForcedMag(2,~isnan(ForcedMag(2,:)))
      Median   = median(m2);
      MAD = sort(abs(Median-m2));
      mid = round(length(MAD)/2);
      SDrobust2 = 1.5*MAD(mid);
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

