% Study case of WD1856+534

addpath('~/Documents/WD/WDsurvey')


%% Lim mag from header:

% AN stands for AstrometryNet. Since the center of FOV is extracted by
% solving a raw image via AN. ( For NOW)
% P stans for pipeline astroometric solution.

% Initilize a WD object with a pathway to proc images :
P  = WD([],[],[],[],'/last04e/data2/archive/LAST.01.04.02/2023/09/16/proc/3')

% Mention the name of the field from images names, field ID :
P.FieldID = 'WD1856+534'

% Get limmag per subframe


[time_1,limmag] = P.Header_LimMag(P)
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


        
%% Out source all WD in field:
% or just the target

% AN ra  = 
% AN dec = 

% Expected mount pointing
%PRA      =     284.442191076153 /                                                
%PDEC     =     53.5308278710417
        

AN_targets    = [
284.41659972938294	53.50890452766587	16.942257
%283.824577203396	53.98954558865595	17.3318
%285.46451665785054	54.64777805491314	17.45239
%283.3577355943599	53.193931035760706	18.779694
%283.79942439466413	53.135875647791075	18.743782
%284.4022063190331	51.9853111829201	18.964369
%284.5414039178612	52.65159237662189	18.29842
%283.9004155602518	54.96022455751371	18.284151
%284.20116270454224	53.40932701447755	18.48324
%285.35593587401297	53.15816175887681	18.038101
];


AN_names      = [
'WDJ185739.34+533033.30'%,
%'WDJ185517.99+535923.18',
%'WDJ190151.48+543853.29',
%'WDJ185325.67+531133.99',
%'WDJ185511.84+530809.21',
%'WDJ185736.52+515906.63',
%'WDJ185809.96+523905.92',
%'WDJ185536.06+545736.87',
%'WDJ185648.26+532433.63',
%'WDJ190125.42+530929.27'
];



P = WD(AN_targets(:,1),AN_targets(:,2),AN_targets(:,3),AN_names,'/last04e/data2/archive/LAST.01.04.02/2023/09/16/proc/3')


% AN :
[id,FieldId] = P.Coo_to_Subframe(P.Pathway,P);
P  = P.get_id(id(:,1));
P  = P.get_fieldID(FieldId);
[Index,cat_id] = P.find_in_cat(P);
P  = P.get_cat_id(cat_id);
%e  = e.get_LC
% catalog extracion

[t_psf,y_psf,t_aper,y_aper,Info_psf,Info_aper, ... 
               flager,t_rms_aper,t_rms_psf,t_rms_flux,Rms_aper,Rms_psf, ... 
               rms_flux,t_flux,f_flux,total_rms_flux,magerr,magerrPSF] = P.get_LC_cat(P,20,30);
           
P.LC_psf   = {t_psf;y_psf;magerrPSF};
P.LC_aper  = {t_aper;y_aper;magerr};
P.Flux     = {t_flux;f_flux};
P.FluxRMS  = total_rms_flux;
P.InfoPsf  = Info_psf;
P.InfoAper = Info_aper;
P.RMS      = {t_rms_aper Rms_aper ; t_rms_psf Rms_psf; t_rms_flux rms_flux };
% ploting section

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

% plot with error bar :

P.plotLCERR('Index',{},'id',1,'Ylabel','Inst Mag')


% plot RMS timeseries :

P.plotRMSseries('id',1,'Ylabel','RMS')

%%  Forced photometry section 
% still a draft since playing with the forcedphot arguments

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




% plot with error bar


P.plotLCERR_FP('Index',{},'id',ind,'Name','WD1856+534','Ylabel','Inst Mag')

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

P.plotLC('Index',{},'id',1,'Deltay',0.2)

% Gaia lim mag on limiting magnitudes
% plot air mass and subframe LimMag together
subplot(2,1,1)
plot(timeofday(datetime(P.LC_FP{1},'convertfrom','jd')),P.AirMass,'k.')
set(gca,'YDir','reverse')
xlabel('Time (UTC)','Interpreter','latex')
ylabel('Airass','Interpreter','latex')
title("Target's airmass during the observation",'Interpreter','latex')
subplot(2,1,2)
plot(timeofday(datetime(time_1(:,ind),'convertfrom','jd')),limmag(:,P.CropID(ind)),'k.')
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

% Forced photometry issue
%% forced flux 

[Rf,LCf,X,Y,RA,Dec,AirMass,FP,Robust_parameters] = P.ForcedFlux(P,'Find',true,'Moving',true)

time     = timeofday(datetime(LC(:,1),'convertfrom','jd'));
Flux     = LC(:,2);
Median   = Robust_parameters(1);
SDrobust = Robust_parameters(2);


% Noises:

SourceNoise = sqrt(Median)
% assuming 20 pix for no reason
TotalNoise  = sqrt(Median + 20*median(FP.Data.BACK_ANNULUS(:,1)) +20*(3.5*0.75*20 + 20 *0.01)  )

figure(10);
plot(time,Flux,'k.')





% Limiting magnitude VS different parameter







%% Detrend flux

% still a flux problem

[R,LC,X,Y,RA,Dec,AirMass,FP] = P.DetrendFlux(P,'Find',true)


