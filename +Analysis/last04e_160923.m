% Get all WD from reduced Data
% Most Ideally get WD from matlab

%% 270823

% field : 358+34
% coord : 358.881, 35.611

Targets1    = [
    
%358.2490957110293	36.956030015414214	17.766068
%359.68511291074407	35.56351186545541	18.70435
%359.64968737222955	35.94763859011489	18.77262
%358.81723780295493	36.04804630014442	16.934488
358.6261963706165	34.62918120298527	17.730215
358.60691592710907	36.08086765592638	17.409506
%358.9262330289217	35.35949509780521	17.104704
%358.47915664031876	36.19114580288572	17.282484
%359.5426919227249	35.91870208333357	18.937252
358.42991719218435	36.37460335780781	17.795748
358.4737002248643	35.956960544020575	18.35812
358.14042291019064	36.324798811716654	17.94189
357.95106006323556	36.33622309276605	17.724937
357.81287618304833	35.86549542303695	18.908047


]

TargetsName1 = [
%'WDJ235300.03+365723.82',
%'WDJ235844.68+353353.83',
%'WDJ235835.92+355652.22',
%'WDJ235516.48+360253.89',
'WDJ235430.18+343745.73',
'WDJ235425.63+360451.07',
%'WDJ235542.33+352134.38',
%'WDJ235355.00+361128.46',
%'WDJ235810.18+355507.50',
'WDJ235343.17+362228.63',
'WDJ235353.60+355725.51',
'WDJ235233.66+361929.47',
'WDJ235148.36+362011.25',
'WDJ235115.08+355156.23',
]


% Initilize WD object

e1  = WD(Targets1(:,1),Targets1(:,2),Targets1(:,3),TargetsName1,'/last02e/data1/archive/LAST.01.02.01/2023/08/27/proc/000540v0')

e1.LC_FP = [
% 18.02604
%19.063189
%19.274632
%17.035667
17.766941
17.480482
%17.069855
%17.303087
%19.040138
17.53455
18.366528
17.892187
17.673506
18.907557
];

e1.LC_coadd = [
%0.66524506
%0.83859444
%1.1449165
%0.27044868
0.10054207
0.15999031
%-0.15054321
%0.002916336
%0.20973015
0.17264175
-0.0855999
-0.1247921
-0.20863533
-0.096063614
]




% first lim mag calculations
[id,FieldId] = e1.Coo_to_Subframe(e1.Pathway,e1);
e1  = e1.get_id(id(:,1));
e1  = e1.get_fieldID(FieldId);
[Index,cat_id] = e1.find_in_cat(e1);
e1  = e1.get_cat_id(cat_id);
%e  = e.get_LC
% catalog extracion

[t_psf,y_psf,t_aper,y_aper,Info_psf,Info_aper, ... 
               flager,t_rms_aper,t_rms_psf,t_rms_flux,Rms_aper,Rms_psf, ... 
               rms_flux,t_flux,f_flux,total_rms_flux,magerr,magerrPSF] = e1.get_LC_cat(e1,20,30);
           
e1.LC_psf   = {t_psf;y_psf;magerrPSF};
e1.LC_aper  = {t_aper;y_aper;magerr};
e1.Flux     = {t_flux;f_flux};
e1.FluxRMS  = total_rms_flux;
e1.InfoPsf  = Info_psf;
e1.InfoAper = Info_aper;
e1.RMS      = {t_rms_aper Rms_aper ; t_rms_psf Rms_psf; t_rms_flux rms_flux };

%figure();

%errorbar(e1.LC_psf{1}(1,:),e1.LC_psf{2}(1,:),e1.LC_psf{3}(1,:),'.')




% rms timeseries :
%[rms,interval_center] = e1.RMS_timeseries(e1,e1.LC_psf{1}(1,:),e1.LC_psf{2}(1,:),20)






%%  Lim mag from header:

LimMag  = WD([],[],[],[],e1.Pathway)

%choose field ID :
LimMag.FieldID = e1.FieldID(1);

% limmag per subframe


[time_1,limmag] = LimMag.Header_LimMag(LimMag);

%





% GetData

wd1 = GetDataWref(e1 ,'SaveTo', '~/Documents/WD_survey/270823/358+34/','time_1immag',time_1,'limmag',limmag)