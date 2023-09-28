% WD 16 08 23
addpath('home/ocs/WD Survey/util.functions')


%% Lim mag from header:

AN  = WD([],[],[],[],'/last04e/data2/archive/LAST.01.04.02/2023/09/05/proc/3')

%choose field ID :
AN.FieldID = '042+41'

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
278.0783902013127	36.543605591333886	18.958986
277.9376295658452	37.07280988135132	17.8848
279.2165883239766	38.82945960887888	18.197727
278.6859123397049	36.83383524493957	18.412907
279.1210456704433	36.750030486833445	18.993204
277.7726585417811	37.23668867218894	18.76529
278.86928591318707	37.665404362177554	18.461147
278.28703647396577	36.05698273610006	17.390617
277.5057300210671	36.57159071218521	18.46335
279.2643970899169	38.25584204230011	18.316376
277.7420688327845	38.04971869655587	18.794899
278.31333608178306	38.49508954533876	18.809862
279.35071704840914	37.54646590013118	18.248077
278.9180546032775	39.00194649142286	18.610916
277.2586516475178	37.33494476488699	17.798672
278.151991890058	38.90015064593811	18.968945
277.2875003968669	37.50626112335376	18.944601


]

name = [
'WDJ183218.82+363237.60',
'WDJ183145.31+370422.86',
'WDJ183651.97+384946.27',
'WDJ183444.65+365002.94',
'WDJ183629.00+364500.59',
'WDJ183105.40+371411.44',
'WDJ183528.60+373954.70',
'WDJ183308.89+360326.26',
'WDJ183001.39+363417.63',
'WDJ183703.45+381520.96',
'WDJ183058.11+380259.01',
'WDJ183315.19+382942.89',
'WDJ183724.18+373247.30',
'WDJ183540.34+390007.02',
'WDJ182902.08+372005.66',
'WDJ183236.47+385400.44',
'WDJ182909.01+373022.38'

]


e  = WD(targets(:,1),targets(:,2),targets(:,3),name,'/last06e/data1/archive/LAST.01.06.01/2023/08/16/proc/30')
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

for  ind = 1 : 17
    
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

