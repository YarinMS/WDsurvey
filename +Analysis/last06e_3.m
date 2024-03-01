% Get all WD from reduced Data
% Most Ideally get WD from matlab

%% 210823

% field : 354+39
% coord : 355.039, 40.512

Targets    = [
354.2047889579332	41.33280052774627	18.737295
355.45394593379444	40.86828335157331	17.954098
354.702414376162	40.80094629979243	17.861652
354.2954329232683	40.92440921378735	17.72469
354.24018909627415	41.4926524657306	18.318554
356.1276837019136	40.22636494583123	17.588142
354.78558978848565	41.853600836013506	18.82793
]

TargetsName = [
    
'WDJ233649.20+411958.48',
'WDJ234148.89+405206.10',
'WDJ233848.60+404803.82',
'WDJ233711.04+405528.65',
'WDJ233657.64+412933.57',
'WDJ234430.64+401335.27',
'WDJ233908.52+415113.20'
]


% Initilize WD object

e1  = WD(Targets(:,1),Targets(:,2),Targets(:,3),TargetsName,'/last06e/data1/archive/LAST.01.06.01/2023/08/21/proc/15')

% GetData

e1 = GetData(e1)


%% 270823

% field : 355+45
% coord : 356.487, 45.829

Targets1    = [
%355.9639991585399	47.42994185667047	17.95181
%355.8899550947743	46.82027480218611	16.419102
%357.092075777811	45.746662199440344	18.921528
%356.9310680960374	44.28387310200634	17.821795
355.4357979983561	47.22312148612801	17.838444
355.581174181158	45.35466602364707	18.355501
356.1283050934123	45.47956723287801	18.987017
356.2887258157945	46.97155912962387	18.949417
355.5586502754895	46.76716995448918	18.532413
356.1057584940173	45.1372416766606	18.967127
355.53531356279495	46.51500303355681	18.90241
355.4632454501128	45.61648414147402	18.103533
355.4917487873969	46.842670658004444	18.720345
355.4329125014312	45.40879944772586	18.02718
355.4535051748611	46.453454462505015	18.229677

]

TargetsName1 = [
    
%'WDJ234350.65+472548.22',
%'WDJ234333.60+464912.45',
%'WDJ234822.15+454448.99',
%'WDJ234743.28+441701.04',
'WDJ234144.64+471325.14',
'WDJ234219.89+452118.08',
'WDJ234430.82+452847.61',
'WDJ234509.28+465817.29',
'WDJ234214.10+464602.12',
'WDJ234425.37+450813.86',
'WDJ234208.46+463054.43',
'WDJ234151.14+453659.18',
'WDJ234158.00+465033.76',
'WDJ234143.85+452431.50',
'WDJ234148.80+462711.91'
]


% Initilize WD object

e1  = WD(Targets1(:,1),Targets1(:,2),Targets1(:,3),TargetsName1,'/last06e/data1/archive/LAST.01.06.01/2023/08/27/proc/12')

% GetData

wd1 = GetData(e1,'SaveTo', '~/Documents/WD_survey/270823/355+45/')






%% Tests
%% 270823

% field : 355+45
% coord : 356.487, 45.829

Targets1    = [
355.4357979983561	47.22312148612801	17.838444

]

TargetsName1 = [

'WDJ234144.64+471325.14'
]




% Initilize WD object

e1  = WD(Targets1(:,1),Targets1(:,2),Targets1(:,3),TargetsName1,'/last06e/data1/archive/LAST.01.06.01/2023/08/27/proc/12')

% first lim mag calculations
[id,FieldId] = e1.Coo_to_Subframe(e1.Pathway,e1);
e1  = e1.get_id(id(:,1));
e1  = e1.get_fieldID(FieldId);
% [Index,cat_id] = WD.find_in_cat(WD);
% WD  = WD.get_cat_id(cat_id);
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
e1.R      = {t_rms_aper Rms_aper ; t_rms_psf Rms_psf; t_rms_flux rms_flux };




%%  Lim mag from header:

LimMag  = WD([],[],[],[],e1.Pathway)

%choose field ID :
LimMag.FieldID = e1.FieldID(1);

% limmag per subframe


[time_1,limmag] = LimMag.Header_LimMag(LimMag);

%





% GetData

wd1 = GetDataV4(e1 ,'SaveTo', '~/Documents/WD_survey/270823/355+45b/','time_1immag',time_1,'limmag',limmag)



%%
%Manual phot 
Targets2 = [
345.3170124674257	23.383896269230608	16.03735
345.0934981501417	22.07149651667664	17.37438
345.60245275554496	21.864845894962393	17.739908

]

TargetsName2 = [
'WDJ230116.04+232301.71',
'WDJ230022.08+220414.76',
'WDJ230224.73+215154.44'
]

w =  WD(Targets2(:,1),Targets2(:,2),Targets2(:,3),TargetsName2,'/last06e/data1/archive/LAST.01.06.01/2023/09/04/proc/225057v0')

% first lim mag calculations
[id,FieldId] = w.Coo_to_Subframe(w.Pathway,w);
w  = w.get_id(id(:,1));
w  = w.get_fieldID(FieldId);
 [Index,cat_id] = w.find_in_cat(w);
 w  = w.get_cat_id(cat_id);
% catalog extracion

[t_psf,y_psf,t_aper,y_aper,Info_psf,Info_aper, ... 
               flager,t_rms_aper,t_rms_psf,t_rms_flux,Rms_aper,Rms_psf, ... 
               rms_flux,t_flux,f_flux,total_rms_flux,magerr,magerrPSF] = w.get_LC_cat(w,20,30);
           
w.LC_psf   = {t_psf;y_psf;magerrPSF};
w.LC_aper  = {t_aper;y_aper;magerr};
w.Flux     = {t_flux;f_flux};
w.FluxRMS  = total_rms_flux;
w.InfoPsf  = Info_psf;
w.InfoAper = Info_aper;
w.R      = {t_rms_aper Rms_aper ; t_rms_psf Rms_psf; t_rms_flux rms_flux };

