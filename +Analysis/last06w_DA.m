% Get all WD from reduced Data
% Most Ideally get WD from matlab

%% 160923

% field : field1280
% coord : 315.643, 33.301

Targets    = [
20.406355804329927	34.67865298575906	16.611736

]

TargetsName = [
'WDJ012137.80+344042.98'

]


% Initilize WD object

e  = WD(Targets(:,1),Targets(:,2),Targets(:,3),TargetsName,'/last06w/data2/archive/LAST.01.06.04/2023/09/16/proc/1')

% GetData

% find their CropID and find them in catalog data
      % no lim mag calculations
[id,FieldId] = e.Coo_to_Subframe(e.Pathway,e);
e  = e.get_id(id(:,1));
e  = e.get_fieldID(FieldId);
[Index,cat_id] = e.find_in_cat(e);
e  = e.get_cat_id(cat_id);

% catalog extracion

[t_psf,y_psf,t_aper,y_aper,Info_psf,Info_aper, ... 
               flager,t_rms_aper,t_rms_psf,t_rms_flux,Rms_aper,Rms_psf, ... 
               rms_flux,t_flux,f_flux,total_rms_flux,magerr,magerrPSF] = e.get_LC_cat(e,20,30);
           
e.LC_psf   = {t_psf;y_psf;magerrPSF};
e.LC_aper  = {t_aper;y_aper;magerr};
e.Flux     = {t_flux;f_flux};
e.FluxRMS  = total_rms_flux;
e.InfoPsf  = Info_psf;
e.InfoAper = Info_aper;
e.R      = {t_rms_aper Rms_aper ; t_rms_psf Rms_psf; t_rms_flux rms_flux };





wd = GetData(e,'SaveTo','~/Documents/WD/160923/field1280/')



%% field 1221

% RA, Dec  : 20.610, 33.369



Targets    = [
315.0025684354898	32.841394398433955	18.296093
316.53491079338255	32.892343080353605	17.8439
314.9656327508868	34.44697886150665	18.455912
316.39227444738407	34.16877530689955	18.932055
315.0325725592904	33.30965921772545	18.636675
316.64756569316785	34.01911630017025	18.274849
315.03896083214494	32.710953032150144	18.415997
316.0524465089175	32.702725474135114	18.423088
315.8330421446102	33.734592451695	18.479233
315.93730366641984	34.41844054361551	18.562574
316.4042393160772	34.33654390925448	18.914228
316.4061106959927	32.923428191519875	18.209526
316.33946024642967	32.64866224327392	17.682055
315.061327030969	32.01744603548057	18.64601
314.9625176550723	34.928891331511416	18.750946
316.7550950651426	34.14458098369708	18.483698
315.4013080716866	33.14954368584326	17.616648
315.50456881737637	33.09584557861343	18.78192

]

TargetsName = [
'WDJ210000.65+325030.00',
'WDJ210608.47+325334.91',
'WDJ205951.62+342646.49',
'WDJ210533.99+341007.98',
'WDJ210007.73+331834.30',
'WDJ210635.37+340108.42',
'WDJ210009.38+324239.57',
'WDJ210412.64+324210.70',
'WDJ210319.91+334404.66',
'WDJ210344.88+342506.37',
'WDJ210537.06+342012.12',
'WDJ210537.46+325524.70',
'WDJ210521.41+323855.45',
'WDJ210014.70+320102.46',
'WDJ205951.03+345544.74',
'WDJ210701.23+340841.11',
'WDJ210136.30+330858.11',
'WDJ210201.12+330545.52'

]


% Initilize WD object

e1  = WD(Targets1(:,1),Targets1(:,2),Targets1(:,3),TargetsName1,'/last06w/data1/archive/LAST.01.06.03/2023/09/16/proc/Exp/37')

% GetData

WD = GetData(e1,'SaveTo','~/Documents/WD/160923/field1280/')


