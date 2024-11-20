%% no  15 / 08 
%% 


addpath('~/Documents/WDsurvey/')


%% 15/08
%% 15-16/08
%% Single field field



obj = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)
Mount     = '06'; % str
Tel       = 2   ; % int
Year      = '2023' ;
Month     = '08' ;
Night     = '15' ; 
SaveTo    =  '/home/ocs/Documents/WD_survey/Thesis/1508_277+36b/';
Night2    = '16';

 %%   
    
    
 %%   
    
 Obj = GetFieldLC(obj,'Mount',Mount,...
'Tel',Tel,...
'Year',Year,...
'Month',Month,...
'Night',Night,...
'SaveTo',SaveTo ,...
'Night2',{},...
'ListFields',true,'GetCoords',false)

    
         
%% Choose field anf get coords.

% 1 or middle or end (Usually)
FN = Obj.Data.FieldNames{1};

 Obj = GetFieldLC(obj,'Mount',Mount,...
'Tel',Tel,...
'Year',Year,...
'Month',Month,...
'Night',Night,...
'SaveTo',SaveTo ,...
'Night2',{},...
'ListFields',false,'GetCoords',true,'FieldCoords',FN)
 % Obj = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


%% get Names AND WD coords from the data



Names = [
' WDJ183533.02+334156.71  ',
' WDJ183029.55+355333.93  ',
' WDJ183308.89+360326.26  ',
' WDJ183545.89+332340.96  ',
' WDJ183128.83+350009.73  ',
' WDJ183551.06+332239.47  ',
' WDJ183806.60+335002.80  ',
' WDJ183401.82+333656.80  ',
' WDJ183409.35+340859.09  ',
' WDJ183101.33+352406.74  ',
' WDJ183009.51+345343.84  ',
' WDJ183328.78+345123.57  ',
' WDJ183120.62+351948.26  ',
' WDJ182944.58+341134.55  ',
' WDJ183243.45+354518.42  ',
' WDJ183756.60+335836.59  ',
  ];

TargetList = [
278.8877716720274	33.69906845431518	17.766857	17.818197	17.729282
277.6232161622754	35.89279102932728	18.718454	18.728296	18.663353
278.2870310476425	36.056821385559545	17.390617	17.3129	17.559557
278.94123994785025	33.39439259119526	18.028841	18.02491	18.103745
277.8701260064803	35.00263372035371	19.079056	19.166014	19.026712
278.9628241989711	33.3774745488861	18.293688	18.297646	18.398945
279.5275352592792	33.834150961233874	19.169558	19.224617	19.108633
278.5075577934628	33.61586960037015	18.542723	18.51556	18.642551
278.53897173364453	34.14976311722852	19.033762	19.067081	19.127157
277.7555593958639	35.40165323957515	18.094307	18.058998	18.25335
277.5395599911427	34.89502299342075	18.51945	18.47268	18.692417
278.36991831754744	34.85649749679113	17.847477	17.80933	17.95335
277.8360718045373	35.33023974980778	18.426456	18.396381	18.563377
277.4357285586441	34.19294352398999	18.384958	18.29851	18.594505
278.18099701972363	35.75512664458946	18.102455	17.98656	18.243483
279.4857651705705	33.97676889144517	17.550072	17.417162	17.831964



];

%% Works good

 Obj = GetFieldLC(obj,'Mount',Mount,...
'Tel',Tel,...
'Year',Year,...
'Month',Month,...
'Night',Night,...
'SaveTo',SaveTo ,...
'Night2',Night2,...
'ListFields',false,'GetCoords',false,'FieldCoords',FN,...
'Names',Names,'TargetList',TargetList,'CloseAll',true)


clear all ;
%%

%% 16/08 1st field


obj = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)
Mount     = '06'; % str
Tel       = 2   ; % int
Year      = '2023' ;
Month     = '08' ;
Night     = '16' ; 
SaveTo    =  '/home/ocs/Documents/WD_survey/Thesis/1608_355+36b/';
Night2    = {};

 %%   
    
    
 %%   
    
 Obj = GetFieldLC(obj,'Mount',Mount,...
'Tel',Tel,...
'Year',Year,...
'Month',Month,...
'Night',Night,...
'SaveTo',SaveTo ,...
'Night2',{},...
'ListFields',true,'GetCoords',false)

    
         
%% Choose field anf get coords.

% 1 or middle or end (Usually)
FN = Obj.Data.FieldNames{end};

 Obj = GetFieldLC(obj,'Mount',Mount,...
'Tel',Tel,...
'Year',Year,...
'Month',Month,...
'Night',Night,...
'SaveTo',SaveTo ,...
'Night2',{},...
'ListFields',false,'GetCoords',true,'FieldCoords',FN)
 % Obj = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


%% get Names AND WD coords from the data



Names = [
' WDJ234544.58+341050.85  ',
' WDJ234212.47+352419.63  ',
' WDJ234926.19+333504.32  ',
' WDJ234348.88+354225.87  ',
' WDJ234615.05+354107.18  ',
' WDJ234431.09+351608.87  ',
' WDJ234527.02+350747.34  ',
' WDJ234419.71+340729.22  ',
' WDJ234934.16+345816.07  ',
' WDJ234844.89+344457.86  ',
' WDJ234244.58+354201.15  ',
' WDJ234926.58+335058.73  ',
' WDJ234716.83+340157.33  ',
' WDJ234602.97+344714.36  ',
' WDJ234902.81+355301.08  ',
' WDJ234243.16+361815.68  ',
' WDJ234347.61+341319.26  ',
' WDJ234432.39+344144.45  ',
' WDJ234440.44+354403.17  ',
  ];

TargetList = [
356.43606228875154	34.18135562283092	18.028858	18.399742	17.52324
355.5521795034076	35.40544371983701	17.96237	18.055729	17.767567
357.3592120599385	33.58335192766478	16.824327	16.835466	16.839817
355.95335239075695	35.707008010139795	17.242613	17.246872	17.277996
356.5632289334015	35.68584167701971	17.480652	17.51233	17.46241
356.1296333395026	35.2688819800091	19.169569	19.283686	19.041176
356.3622775045793	35.12957579140598	17.69706	17.684267	17.75946
356.0819136804668	34.12455768569419	18.991856	19.111227	18.899755
357.39202429513733	34.9709970592347	19.085083	19.03908	18.907814
357.18689658594883	34.74919236446661	18.758278	18.797411	18.808025
355.685886644632	35.70023627231072	17.456078	17.37532	17.597183
357.3609310338108	33.849692538148155	18.721958	18.710783	18.824137
356.82014641965145	34.03249435300136	17.828075	17.737906	18.048447
356.51240098561664	34.78724114071847	17.932756	17.877626	18.098137
357.2615899993041	35.88360345003591	18.608028	18.544827	18.818508
355.67980632105935	36.30429303377867	19.152807	19.139158	19.39504
355.9484685134436	34.22199293018873	19.17017	19.162964	19.343512
356.1348887401717	34.695650147367004	18.416973	18.302189	18.708649
356.1685724274134	35.73424422740476	18.932703	18.879568	19.191378



];

%% Works good

 Obj = GetFieldLC(obj,'Mount',Mount,...
'Tel',Tel,...
'Year',Year,...
'Month',Month,...
'Night',Night,...
'SaveTo',SaveTo ,...
'Night2',Night2,...
'ListFields',false,'GetCoords',false,'FieldCoords',FN,...
'Names',Names,'TargetList',TargetList,'CloseAll',true)


clear all;





%% 27-28
%% 1stField


obj = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)
Mount     = '06'; % str
Tel       = 2   ; % int
Year      = '2023' ;
Month     = '08' ;
Night     = '28' ; 
SaveTo    =  '/home/ocs/Documents/WD_survey/Thesis/2708_312+25b/';
Night2    = {};

 %%   
    
    
 %%   
    
 Obj = GetFieldLC(obj,'Mount',Mount,...
'Tel',Tel,...
'Year',Year,...
'Month',Month,...
'Night',Night,...
'SaveTo',SaveTo ,...
'Night2',{},...
'ListFields',true,'GetCoords',false)

    
         
%% Choose field anf get coords.

% 1 or middle or end (Usually)
FN = Obj.Data.FieldNames{30};

 Obj = GetFieldLC(obj,'Mount',Mount,...
'Tel',Tel,...
'Year',Year,...
'Month',Month,...
'Night',Night,...
'SaveTo',SaveTo ,...
'Night2',{},...
'ListFields',false,'GetCoords',true,'FieldCoords',FN)
 % Obj = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


%% get Names AND WD coords from the data



Names = [
' WDJ205042.36+233827.55  ',
' WDJ205536.94+252949.07  ',
' WDJ205446.64+242729.14  ',
' WDJ204856.52+225901.96  ',
' WDJ205422.62+233743.10  ',
' WDJ205315.06+251606.42  ',
' WDJ205508.95+251443.33  ',
' WDJ205405.84+233205.86  ',
' WDJ205650.06+232710.61  ',
' WDJ204858.71+244934.16  ',
' WDJ205023.98+235255.60  ',
' WDJ205151.31+252819.32  ', ];

TargetList = [
312.6760966690376	23.641635609461158	18.780338	19.232435	18.149044
313.90296182472065	25.497928389989756	18.990204	19.68148	18.292528
313.69460356277506	24.458133942253827	15.862765	15.862692	15.891509
312.2348444082303	22.9831096073424	18.834246	19.188133	18.401587
313.59399966735236	23.628402388310292	16.297394	16.241774	16.431557
313.3121672044609	25.26769332270087	18.009312	17.858768	17.307714
313.78737135897785	25.245365480969117	18.318577	18.343273	18.371244
313.52422051288505	23.53455302207755	18.478397	18.514996	18.574976
314.2084128454133	23.452609581743708	17.663948	17.655668	17.707447
312.24468513784063	24.82615325563125	18.67181	18.707457	18.726454
312.5998750717517	23.882031318800816	18.8587	18.796297	18.982956
312.96382139039775	25.472018827646977	19.162369	19.062635	19.323294



];

%% Works good

 Obj = GetFieldLC(obj,'Mount',Mount,...
'Tel',Tel,...
'Year',Year,...
'Month',Month,...
'Night',Night,...
'SaveTo',SaveTo ,...
'Night2',Night2,...
'ListFields',false,'GetCoords',false,'FieldCoords',FN,...
'Names',Names,'TargetList',TargetList,'CloseAll',true)

clear all;
%% 27-28  NO second field

