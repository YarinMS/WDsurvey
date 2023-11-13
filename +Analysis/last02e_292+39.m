% Get all WD from reduced Data
% Most Ideally get WD from matlab

%% 270823

% field : 292+39
% coord : 292.811, 40.092

Targets2    = [   
293.06352173499795	39.85128774076349	18.17214
293.46964780734754	39.88746488991339	17.891073
292.2289982700712	41.0062872182974	17.912794
293.49578212988416	39.41687073278046	17.23874
292.4668080136854	38.963767377752625	18.51148
292.0658265482453	39.979680968717744	18.858063
292.26263529992804	40.52350521300974	18.675386
291.7969638954005	39.06024581905873	18.019825
293.2546690577954	40.27385303819409	17.814104
293.7150410511628	38.667551975569246	18.073065
293.25719613493584	39.8896254581345	18.415854
292.0588126498352	39.498431222037425	18.686182
292.1445950040837	41.02500225620359	18.67594
292.85923732698586	38.93811833606112	18.980326
293.4905189483744	38.59898256157145	18.634811
292.7541712156602	40.93837571728363	18.554184
292.59019217456574	38.889059322251434	17.849976
]

TargetsName2 = [
'WDJ193215.26+395105.39',
'WDJ193352.72+395314.88',
'WDJ192854.92+410022.17',
'WDJ193359.04+392500.53',
'WDJ192952.08+385750.36',
'WDJ192815.81+395847.79',
'WDJ192903.03+403124.32',
'WDJ192711.23+390336.47',
'WDJ193301.15+401626.02',
'WDJ193451.65+384003.50',
'WDJ193301.71+395322.96',
'WDJ192814.19+392954.94',
'WDJ192834.69+410130.39',
'WDJ193126.23+385618.00',
'WDJ193357.71+383556.08',
'WDJ193101.01+405618.16',
'WDJ193021.67+385320.94'

]


% Initilize WD object

e2  = WD(Targets2(:,1),Targets2(:,2),Targets2(:,3),TargetsName2,'/last02e/data1/archive/LAST.01.02.01/2023/08/27/proc/000540v0')

e2.LC_FP = [
0.23545837
0.056833267
-0.097984314
0.21029282
0.039201736
0.20056725
-0.10103035
-0.27329445
-0.117471695
-0.20916939
-0.17463493
-0.06900406
-0.32728004
-0.43391228
-0.27581406
-0.445652
-0.49992752

];

e2.LC_coadd = [
18.275583
17.937714
17.90692
16.879425
18.557684
18.94985
18.65655
17.959301
17.792267
18.027035
18.397877
18.627823
18.595945
18.891027
18.574972
18.40719
17.71022

]




% first lim mag calculations
[id,FieldId] = e2.Coo_to_Subframe(e2.Pathway,e2);
e2  = e2.get_id(id(:,1));
e2  = e2.get_fieldID(FieldId);
[Index,cat_id] = e2.find_in_cat(e2);
e2  = e2.get_cat_id(cat_id);
%e  = e.get_LC
% catalog extracion

[t_psf,y_psf,t_aper,y_aper,Info_psf,Info_aper, ... 
               flager,t_rms_aper,t_rms_psf,t_rms_flux,Rms_aper,Rms_psf, ... 
               rms_flux,t_flux,f_flux,total_rms_flux,magerr,magerrPSF] = e2.get_LC_cat(e2,20,30);
           
e2.LC_psf   = {t_psf;y_psf;magerrPSF};
e2.LC_aper  = {t_aper;y_aper;magerr};
e2.Flux     = {t_flux;f_flux};
e2.FluxRMS  = total_rms_flux;
e2.InfoPsf  = Info_psf;
e2.InfoAper = Info_aper;
e2.RMS      = {t_rms_aper Rms_aper ; t_rms_psf Rms_psf; t_rms_flux rms_flux };

%figure();

%errorbar(e1.LC_psf{1}(1,:),e1.LC_psf{2}(1,:),e1.LC_psf{3}(1,:),'.')




% rms timeseries :
%[rms,interval_center] = e1.RMS_timeseries(e1,e1.LC_psf{1}(1,:),e1.LC_psf{2}(1,:),20)






%%  Lim mag from header:

LimMag2  = WD([],[],[],[],e2.Pathway)

%choose field ID :
LimMag2.FieldID = e2.FieldID(1);

% limmag per subframe


[time_12,limmag2] = LimMag2.Header_LimMag(LimMag2);

%





% GetData

wd2 = GetDataV6(e2 ,'SaveTo', '~/Documents/WD_survey/270823/292+39/','time_1immag',time_12,'limmag',limmag2)