%% no  15 / 08 
%% 


addpath('~/Documents/WDsurvey/')


%% check

%% no  16 - 291+35




%% 21-22/08
%% !st field



obj = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)
Mount     = '10'; % str
Tel       = 2   ; % int
Year      = '2023' ;
Month     = '08' ;
Night     = '21' ; 
SaveTo    =  '/home/ocs/Documents/WD_survey/Thesis/2108_291+23b/';
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
' WDJ192359.24+214103.62  ',
' WDJ192423.17+213610.47  ',
' WDJ193130.74+205200.62  ',
' WDJ192924.79+221344.55  ',
' WDJ193131.05+210948.76  ',
' WDJ192325.33+201900.95  ',
' WDJ192942.92+204041.63  ',
' WDJ193139.12+203713.84  ',
' WDJ192659.29+215715.47  ',
' WDJ193045.02+221214.49  ',
' WDJ192731.51+230147.65  ',
' WDJ192255.11+224914.94  ',
' WDJ192954.18+220249.47  ',
  ];

TargetList = [
290.9971112780098	21.68380377143782	14.66489	14.716438	14.422297
291.0974909248265	21.60356274573188	18.700962	19.191004	18.007969
292.87862427248575	20.867164188584887	19.0137	19.272991	18.660872
292.3522217599621	22.228824136585864	18.738312	18.978735	18.287714
292.8794662467938	21.163609716799346	17.409653	17.36458	17.550856
290.85594106885213	20.317016742361538	17.05745	17.008986	17.107805
292.4288297661052	20.678139825607726	18.642666	18.756748	18.341822
292.91331924008136	20.620232391601434	19.115416	19.255747	18.941738
291.74735051781283	21.954374268562503	19.147066	19.238363	19.119291
292.6875931608172	22.204023881317617	18.90172	18.956366	18.829445
291.8813038936425	23.029903837152705	18.781452	18.764399	18.97102
290.72967096404966	22.820864588693578	18.200493	18.165192	18.221737
292.4758210915581	22.0471165301778	19.143007	18.992476	18.976284


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
Mount     = '10'; % str
Tel       = 2   ; % int
Year      = '2023' ;
Month     = '08' ;
Night     = '21' ; 
SaveTo    =  '/home/ocs/Documents/WD_survey/Thesis/2108_356+23b/';
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
' WDJ234732.21+223132.31  ',
' WDJ234633.68+220042.63  ',
' WDJ235010.39+201914.37  ',
' WDJ234949.49+225014.76  ',
' WDJ234717.04+230357.20  ',
' WDJ235244.65+215807.56  ',
' WDJ234731.94+201929.26  ',
' WDJ234938.35+205308.70  ',
' WDJ235026.86+232014.76  ',
' WDJ234618.00+212008.39  ',
' WDJ235042.23+210010.80  ',
  ];

TargetList = [
358.2208575989205	25.517020750724317	18.873037	19.074282	18.681423
356.9959172697891	24.693081668130098	18.948751	19.140745	18.70592
358.04180638593573	25.56942217143537	17.46696	17.444569	17.597021
357.24284449148183	25.588533021703228	18.25435	18.180454	18.522638
356.6612848038086	25.95484802879726	17.904066	17.874393	18.038887
357.37444156279116	23.515124725605233	17.673399	17.555634	17.944736
357.43821276485016	26.100335606085245	18.99894	19.00245	19.16346
357.35252674348646	24.821369422918327	19.155794	19.204947	19.167252
357.6120397916696	23.33739279869756	18.083189	18.041376	18.241135
356.8836491820654	22.52525680294596	18.764448	19.035595	18.392214
356.64124704251054	22.012126448221643	16.466854	16.489805	16.449379
357.5431042262393	20.320456141900184	17.405924	17.434992	17.413334
357.45654298969885	22.836743986625837	17.554142	17.595217	17.56
356.82083485447083	23.06581261370575	18.032606	18.053148	18.019648
358.1862568274523	21.96860832265338	19.127007	19.17952	19.137922
356.8831958907067	20.32462862523776	18.16624	18.204594	18.14176
357.40981797667655	20.8857097979131	18.145365	18.132679	18.289263
357.61203979410357	23.3373927979528	18.083189	18.041376	18.241135
356.57505719692244	21.335659092000768	18.395067	18.45475	18.302269
357.67607533457135	21.002994058020203	18.893631	18.84088	19.038582


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
Mount     = '10'; % str
Tel       = 2   ; % int
Year      = '2023' ;
Month     = '08' ;
Night     = '27' ; 
SaveTo    =  '/home/ocs/Documents/WD_survey/Thesis/2708_280+40b/';
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
' WDJ184933.96+402015.54  ',
' WDJ184518.02+380630.85  ',
' WDJ184738.71+400039.47  ',
' WDJ184533.59+384258.72  ',
' WDJ184607.28+384909.75  ',
' WDJ184219.10+384448.73  ',
' WDJ184451.46+392925.05  ',
' WDJ184213.78+375832.86  ',
' WDJ184855.15+401130.84  ',
' WDJ184540.34+374832.34  ',
' WDJ184815.60+382405.94  ',
' WDJ184530.88+401030.37  ',
' WDJ184239.97+390334.80  ',
' WDJ184144.39+392007.71  ',
' WDJ184611.80+373602.52  ',
' WDJ184751.92+394145.53  ',
' WDJ184357.40+393417.98  ',
' WDJ184724.34+380802.43  ',  ];

TargetList = [
282.3921981234926	40.337605095074004	14.810568	14.748262	14.961938
281.3237410303575	38.108550673664816	19.095491	19.690578	18.414948
281.9115159705667	40.010838412703045	16.910696	16.926971	16.885466
281.3900190801924	38.71614044307171	18.020735	17.947739	17.564917
281.5303558937831	38.81899455802464	18.745293	18.858498	18.539507
280.5796498409822	38.74673008350118	16.485695	16.402323	16.690367
281.21446059080523	39.49022076834944	18.346146	18.350946	18.438997
280.5576331939763	37.97617882959007	17.392426	17.28601	17.35376
282.22998708058964	40.19205480885266	18.5118	18.550972	18.566765
281.41812900397736	37.80885105995354	17.788326	17.81413	17.812809
282.06507264770596	38.40172288119952	19.174002	19.159763	19.255363
281.3788949912621	40.175181074106185	18.16864	18.133581	18.317442
280.66655760699985	39.05970300707339	18.922298	18.833155	19.055578
280.4349234211232	39.33546082820005	18.704933	18.743649	18.744253
281.5490060048443	37.60063135019636	18.73885	18.729218	18.90701
281.96641080821956	39.696118688184875	19.032486	19.046066	19.12923
280.98919777195925	39.57165658272809	19.073143	18.998695	19.36608
281.8514270308793	38.13401430695063	19.13302	19.060026	19.433804


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
Mount     = '10'; % str
Tel       = 2   ; % int
Year      = '2023' ;
Month     = '08' ;
Night     = '27' ; 
SaveTo    =  '/home/ocs/Documents/WD_survey/Thesis/2708_351+32b/';
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
' WDJ232445.27+301441.49  ',
' WDJ233129.57+300112.50  ',
' WDJ232731.43+305716.80  ',
' WDJ232739.29+304354.03  ',
' WDJ232928.89+315533.04  ',
' WDJ233211.05+303059.97  ',
' WDJ233315.34+312530.81  ',
' WDJ233036.96+293440.53  ',
' WDJ233055.81+314651.71  ',
' WDJ232518.27+313937.89  ',
' WDJ232952.90+291506.66  ',
' WDJ233021.72+292042.64  ',
' WDJ232752.03+302208.03  ',
' WDJ233235.94+313312.10  ',
' WDJ232842.29+315846.83  ',];

TargetList = [
351.18995978616744	30.244538541057313	17.434097	17.58193	17.199015
352.873086395303	30.020220944486475	19.14863	19.50239	18.758873
351.88064577333836	30.954400618675162	19.100235	19.359022	18.790112
351.91433215889356	30.731485684561093	17.274862	17.356905	17.160175
352.3705095214281	31.92576068297096	18.785543	18.979435	18.5373
353.046391607052	30.51663794000575	19.08194	19.191387	19.038082
353.3138107123877	31.425065526234622	18.936401	18.991959	18.801878
352.6541007887159	29.577872792294084	16.909729	16.775127	17.18709
352.73232470474665	31.780826863234314	18.648848	18.740334	18.552261
351.32620015883	31.660626893711818	18.91753	19.072449	18.781889
352.47064807872613	29.25180185811459	18.97832	19.009241	18.89127
352.59069186961403	29.345123062414853	19.139381	19.25438	19.076607
351.9669179058929	30.36904386850908	18.441992	18.470678	18.517735
353.14978700222815	31.55345240296133	18.45582	18.446209	18.536474
352.1760570359986	31.97951287165534	19.081602	19.101707	19.066067


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
%% 15-16/09
% Empty in last10e1 - marvin