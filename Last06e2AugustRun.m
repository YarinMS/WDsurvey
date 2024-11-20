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
' WDJ234440.44+354403.17  ',,
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


%% 21-22/08
%% 1st field



obj = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)
Mount     = '06'; % str
Tel       = 2   ; % int
Year      = '2023' ;
Month     = '08' ;
Night     = '21' ; 
SaveTo    =  '/home/ocs/Documents/WD_survey/Thesis/2108_291+34b/';
Night2    = '22';

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
' WDJ192623.50+334720.66  ',
' WDJ193121.95+325058.48  ',
' WDJ192951.88+333057.41  ',
' WDJ192952.74+321322.54  ',
' WDJ192957.96+325723.30  ',
' WDJ193211.83+333637.99  ',
' WDJ193302.71+334339.32  ',
' WDJ192607.84+332305.40  ',
' WDJ192836.97+332414.64  ',
' WDJ192715.70+322941.38  ',
' WDJ192434.59+335536.35  ',
' WDJ192816.84+335404.26  ',
' WDJ192832.52+324829.52  ',
' WDJ193228.83+335052.30  ',
' WDJ192511.22+322039.80  ',
' WDJ193107.77+315122.71  ',
' WDJ192933.92+314233.16  ',
' WDJ192747.11+325928.57  ',
  ];

TargetList = [
291.5983611748577	33.78835685221495	18.358055	18.839596	17.694855
292.8424647243251	32.849425773445844	17.54183	17.695286	17.25005
292.466302245344	33.5159179556415	17.047949	17.061647	17.072687
292.4694753309857	32.222773548868986	18.854221	18.942926	18.64593
292.4915039658161	32.9564993573713	18.84311	18.84868	18.930807
293.0494838471044	33.61069903129637	17.622084	17.57545	17.796087
293.26061744178804	33.727545084216466	17.780687	17.739634	17.93451
291.53272318152733	33.38488446103064	19.017332	19.023495	19.011698
292.1541333942983	33.404119797713356	19.126284	19.142216	19.188541
291.81535981038417	32.494706195691585	18.758352	18.675476	18.936382
291.14415913578205	33.92676711837959	19.142097	19.098843	19.364141
292.07021449194895	33.901208279579706	18.97128	18.880167	19.046696
292.1354864124128	32.80816047172161	17.841461	17.694952	18.163244
293.1200778817819	33.84782078437103	19.000076	18.901825	19.287544
291.2967372956709	32.344375052012076	19.118814	19.00694	19.383999
292.7823080089656	31.856188622027485	19.041048	18.927683	19.311388
292.39128999186175	31.709130220664168	19.189608	19.092524	19.431675
291.9463031553076	32.99128191466504	18.962137	18.905424	19.141125



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

%% 2nd field


obj = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)
Mount     = '02'; % str
Tel       = 2   ; % int
Year      = '2023' ;
Month     = '08' ;
Night     = '21' ; 
SaveTo    =  '/home/ocs/Documents/WD_survey/Thesis/2108_356+34b/';
Night2    = '22';

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
' WDJ234926.19+333504.32  ',
' WDJ234926.58+335058.73  ',
' WDJ234716.83+340157.33  ',
' WDJ235036.87+330245.69  ',
' WDJ234856.31+314207.82  ',
' WDJ235106.81+321828.52  ',
  ];

TargetList = [
357.35921205970743	33.58335193034703	16.824327	16.835466	16.839817
357.3609310333903	33.8496925380489	18.721958	18.710783	18.824137
356.82014641957784	34.03249435322255	17.828075	17.737906	18.048447
357.6536194236401	33.045968108617046	19.003864	18.979767	19.107862
357.23473738100864	31.702099647440637	19.097359	19.106815	19.209877
357.7784967396756	32.30776867912374	18.955025	18.888506	19.079998



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
%%



%% 27-28
%% 1stField


obj = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)
Mount     = '02'; % str
Tel       = 2   ; % int
Year      = '2023' ;
Month     = '08' ;
Night     = '27' ; 
SaveTo    =  '/home/ocs/Documents/WD_survey/Thesis/2708_292+39b/';
Night2    = '28';

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
' WDJ193431.30+355409.55  ',
' WDJ193525.35+355740.35  ',
' WDJ192926.32+365112.16  ',
' WDJ193603.39+382817.01  ',
' WDJ193451.65+384003.50  ',
' WDJ193421.91+381045.29  ',
' WDJ192854.96+372136.32  ',
' WDJ193155.12+354810.13  ',
' WDJ192825.92+381741.03  ',
' WDJ193259.80+371112.62  ',
' WDJ193255.79+354830.82  ',
' WDJ193007.48+373059.10  ',
' WDJ193033.09+375157.22  ',
' WDJ193331.93+380917.80  ',
' WDJ193126.23+385618.00  ',
' WDJ193357.71+383556.08  ',
' WDJ193127.63+380541.33  ',
' WDJ193021.67+385320.94  ',
' WDJ193354.11+380139.11  ',
' WDJ193305.83+372615.58  ',
' WDJ193441.56+380525.97  ',
' WDJ193011.50+373955.69  ',
' WDJ193143.59+355753.50  ',
' WDJ192841.94+360148.50  ', ];

TargetList = [
293.6304914132263	35.902420711526496	18.513414	18.687565	18.247725
293.85563233388746	35.96122717117479	18.07697	18.100666	18.118368
292.3598203291692	36.85355799242825	18.114733	18.076302	18.139025
294.0141435126559	38.47149094357166	18.67122	18.719711	18.384495
293.7150379029367	38.667550528493734	18.073065	18.027035	18.236204
293.5913459367161	38.179253987389785	18.418144	18.392992	18.574554
292.22885934417104	37.36046365944974	17.94069	17.863121	18.064669
292.9795774961603	35.80259443268354	19.008173	19.026073	18.905556
292.10801371480625	38.294796797026095	17.738008	17.60137	17.908846
293.24913025175584	37.18672210152044	18.675632	18.637043	18.85684
293.2323953148362	35.80841654419742	17.44821	17.301804	17.702467
292.5311379825568	37.51634801273672	19.186253	19.151865	19.362326
292.6379038671199	37.865953296707474	18.836987	18.74222	19.093998
293.38299961201335	38.15500923425098	18.370281	18.252316	18.624847
292.85923635545504	38.93811476188328	18.980326	18.891027	19.32494
293.4905198635276	38.59898373361103	18.634811	18.574972	18.850786
292.86513486355517	38.09477792578376	19.118813	19.04728	19.305832
292.5901908164115	38.889057803922825	17.849976	17.71022	18.210148
293.4754999122468	38.02766750019163	18.498348	18.42103	18.893183
293.2742884186597	37.4376121058319	18.042694	17.875784	18.247667
293.673165147078	38.090573156418955	19.125492	19.081184	19.319878
292.54790884552307	37.66543260856671	18.619543	18.45089	18.707806
292.93163079173183	35.96482983144006	19.010038	18.86093	19.291365
292.17474694646154	36.03011726492629	18.502703	18.392263	18.932789


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
%% 27-28 second field


obj = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)
Mount     = '02'; % str
Tel       = 2   ; % int
Year      = '2023' ;
Month     = '08' ;
Night     = '27' ; 
SaveTo    =  '/home/ocs/Documents/WD_survey/Thesis/2708_358+34b/';
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
' WDJ235526.26+322603.11  ',
' WDJ235615.55+322240.33  ',
' WDJ235602.24+332857.51  ',
' WDJ235616.13+320852.62  ',
' WDJ235723.16+313734.63  ',
' WDJ235913.09+311920.57  ',];

TargetList = [
358.8597338301597	32.43419827879009	18.270971	18.317595	18.298876
359.06475957377756	32.377680039229645	18.28904	18.292746	18.39913
359.0096466843817	33.482522562078856	18.756325	18.780573	18.86669
359.0670560871582	32.14789922665188	18.738976	18.739311	18.880592
359.3465760004857	31.626245334660073	18.856041	18.829191	19.073706
359.80464505218396	31.322306514021935	18.91668	18.89376	19.164495



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
