%% 15 / 08 
%% 


addpath('~/Documents/WDsurvey/')


%% check


obj = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)
Mount     = '08'; % str
Tel       = 1   ; % int
Year      = '2023' ;
Month     = '08' ;
Night     = '16' ; 
SaveTo    =  '/home/ocs/Documents/WD_survey/Thesis/1608_310+32/';
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
' WDJ204745.04+323922.58  ',
' WDJ203946.86+344605.48  ',
' WDJ204339.27+323422.02  ',
' WDJ204748.57+324615.85  ',
' WDJ204558.10+351446.08  ',
' WDJ204239.17+341732.80  ',
' WDJ204501.25+351926.82  ',
' WDJ204519.64+351016.86  ',
' WDJ204300.06+332218.91  ',
' WDJ204650.39+321314.74  ',
' WDJ204247.95+341134.79  ',
' WDJ204306.51+350016.46  ',
' WDJ204432.60+330653.50  ',
' WDJ203958.17+324844.75  ',
' WDJ204403.29+331648.69  ',
' WDJ203959.79+351430.71  ',
' WDJ204004.12+330441.10  ',
' WDJ203949.74+344945.49  ',
' WDJ204651.47+324809.41  ',
' WDJ204028.59+330912.02  ',
' WDJ204601.03+321719.78  ',
  ];

TargetList = [
311.93767560602157	32.65605783404406	15.263405	15.199707	15.422639
309.9453556283339	34.767770439627654	18.359795	18.585514	18.022856
310.9132571976653	32.57279801586145	18.59708	18.810963	18.326452
311.951675433605	32.77037359419483	18.902544	19.201796	18.470167
311.49183159701505	35.24555460721429	18.978102	19.175781	18.634632
310.6635809651439	34.292388542368336	17.486967	17.519325	17.441214
311.25566362693047	35.32429710970485	18.254845	18.345747	18.169888
311.33162407298585	35.171703361953725	18.638748	18.579525	18.02269
310.7507842229504	33.371888121801916	18.00474	17.97811	17.61039
311.71019342675095	32.22083032015709	18.76923	18.805378	18.92148
310.69992328761475	34.19306617526794	19.156126	19.151863	19.157574
310.7772468632817	35.00455093716605	18.955393	18.992428	19.045847
311.1358120934848	33.11468871453339	19.036674	19.053947	19.136147
309.99228525131804	32.81228869351717	18.039614	17.94712	18.191433
311.0137153608909	33.2801967550356	18.651217	18.594393	18.940626
309.9991909864171	35.24194534545517	19.061298	19.07731	19.21773
310.01718380705364	33.078012093980966	18.93931	18.88287	19.138227
309.9572942209507	34.82930659010945	18.442926	18.314676	18.756977
311.71444729101046	32.80231479597282	19.010859	18.958698	19.270592
310.1191023220602	33.153292544504396	18.867517	18.614016	18.546526
311.50424615628265	32.28873401644324	18.555384	18.41584	18.86738

];

%% Works good

 Obj = GetFieldLC(obj,'Mount',Mount,...
'Tel',Tel,...
'Year',Year,...
'Month',Month,...
'Night',Night,...
'SaveTo',SaveTo ,...
'Night2',{},...
'ListFields',false,'GetCoords',false,'FieldCoords',FN,...
'Names',Names,'TargetList',TargetList)


%%
clear all ; 


%% 21-22/08
%% 1st field 291+45



obj = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)
Mount     = '08'; % str
Tel       = 1   ; % int
Year      = '2023' ;
Month     = '08' ;
Night     = '21' ; 
SaveTo    =  '/home/ocs/Documents/WD_survey/Thesis/2108_291+45/';
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
' WDJ192626.93+462015.10  ',
' WDJ192744.80+454547.33  ',
' WDJ193136.29+465643.71  ',
' WDJ192550.93+470127.31  ',
' WDJ193355.19+475301.93  ',
' WDJ192728.02+451916.86  ',
' WDJ193309.81+474852.61  ',
' WDJ192755.53+475332.10  ',
' WDJ193003.34+464623.80  ',
' WDJ193008.37+480318.62  ',
' WDJ193150.90+462730.90  ',
' WDJ193417.84+463244.78  ',
' WDJ192644.78+472425.43  ',
' WDJ192842.79+470529.29  ',
' WDJ193109.77+445651.03  ',
  ];

TargetList = [
291.6117529200204	46.33788255347057	15.831139	15.957728	15.604966
291.93615569715166	45.76297499509169	17.246283	17.311747	17.142946
292.901511081315	46.94569255160927	18.209406	18.259964	18.19595
291.46250412566036	47.0239781607605	18.000347	18.028084	18.021418
293.48012103122244	47.884056100329786	19.040894	19.116402	18.876581
291.86715246641216	45.321669402012	18.653187	18.72261	18.598003
293.29103784485585	47.814815561303405	19.087843	19.168516	19.083967
291.9814419648926	47.892168358036706	18.752558	18.625345	18.857048
292.5140196576979	46.77337304955534	18.74541	18.791224	18.882084
292.53490852404434	48.055057606225915	18.970274	19.040403	19.066572
292.9620748188523	46.458553270170825	18.19318	18.101885	18.445099
293.5743810900413	46.54575397188234	19.04903	18.860601	18.991716
291.68663688012333	47.40712997390387	19.022184	18.892805	19.285324
292.1783589856318	47.09160710801858	18.941498	18.847918	19.422367
292.7907906787449	44.94751106420174	19.159834	19.114016	19.455984

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
Mount     = '08'; % str
Tel       = 1   ; % int
Year      = '2023' ;
Month     = '08' ;
Night     = '21' ; 
SaveTo    =  '/home/ocs/Documents/WD_survey/Thesis/2108_356+25/';
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
' WDJ192626.93+462015.10  ',
' WDJ192744.80+454547.33  ',
' WDJ193136.29+465643.71  ',
' WDJ192550.93+470127.31  ',
' WDJ193355.19+475301.93  ',
' WDJ192728.02+451916.86  ',
' WDJ193309.81+474852.61  ',
' WDJ192755.53+475332.10  ',
' WDJ193003.34+464623.80  ',
' WDJ193008.37+480318.62  ',
' WDJ193150.90+462730.90  ',
' WDJ193417.84+463244.78  ',
' WDJ192644.78+472425.43  ',
' WDJ192842.79+470529.29  ',
' WDJ193109.77+445651.03  ',
  ];

TargetList = [
291.61175291987854	46.337882553581494	15.831139	15.957728	15.604966
291.93615569698704	45.7629749950383	17.246283	17.311747	17.142946
292.9015110814128	46.9456925516767	18.209406	18.259964	18.19595
291.46250412575205	47.0239781606753	18.000347	18.028084	18.021418
293.480121031278	47.88405610038815	19.040894	19.116402	18.876581
291.8671524665365	45.32166940211119	18.653187	18.72261	18.598003
293.29103784490445	47.81481556136554	19.087843	19.168516	19.083967
291.9814419649123	47.89216835801144	18.752558	18.625345	18.857048
292.51401965772504	46.77337304958544	18.74541	18.791224	18.882084
292.5349085240602	48.0550576061898	18.970274	19.040403	19.066572
292.9620748188439	46.458553270160515	18.19318	18.101885	18.445099
293.5743810900516	46.54575397187588	19.04903	18.860601	18.991716
291.68663688013413	47.407129973925166	19.022184	18.892805	19.285324
292.1783589856526	47.0916071080628	18.941498	18.847918	19.422367
292.79079067876825	44.94751106420228	19.159834	19.114016	19.455984


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
Mount     = '08'; % str
Tel       = 1   ; % int
Year      = '2023' ;
Month     = '08' ;
Night     = '27' ; 
SaveTo    =  '/home/ocs/Documents/WD_survey/Thesis/2708_287+29/';
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
' WDJ191316.54+294928.33  ',
' WDJ191843.36+291240.04  ',
' WDJ191630.67+305145.49  ',
' WDJ191859.67+284913.67  ',
' WDJ191238.62+284948.42  ',
' WDJ191328.70+295834.68  ',
' WDJ191241.86+303038.89  ',
' WDJ191558.74+305056.60  ',
' WDJ191825.49+284018.56  ',
' WDJ191232.70+311245.34  ',
' WDJ191357.70+302151.75  ', ];

TargetList = [
288.31857270555497	29.82644921270911	16.938068	17.213648	16.506166
289.68081361366217	29.211057443127615	18.67478	18.736238	18.226034
289.12790130905324	30.862467792725237	18.97087	19.069132	18.922657
289.7484479088619	28.820292001400485	17.11257	17.028786	17.320377
288.16113691228117	28.83036287171769	18.672607	18.69899	18.746197
288.3696003989595	29.976410626702506	19.068365	19.01041	19.33698
288.1744700942196	30.510888256495697	19.070305	18.987082	19.355186
288.99478355064906	30.849105189808686	19.01767	18.807304	18.952589
289.6062132071265	28.671793304070913	18.77369	18.615269	18.49784
288.13625065884355	31.212593188023735	19.049004	18.942852	19.229351
288.49040528805267	30.36430277458732	18.841208	18.75196	19.169374


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
Mount     = '08'; % str
Tel       = 1   ; % int
Year      = '2023' ;
Month     = '08' ;
Night     = '27' ; 
SaveTo    =  '/home/ocs/Documents/WD_survey/Thesis/2708_355+21/';
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
' WDJ233856.32+210118.30  ',
' WDJ234633.68+220042.63  ',
' WDJ233854.91+233121.60  ',
' WDJ234113.20+215810.72  ',
' WDJ234221.92+222241.53  ',
' WDJ234017.20+220801.14  ',
' WDJ234220.22+205817.69  ',
' WDJ233844.26+233032.50  ',
' WDJ234003.83+205912.40  ',
' WDJ234618.00+212008.39  ',
' WDJ234347.44+222837.90  ',
];

TargetList = [
354.73663284974066	21.022938307083937	17.682983	18.088337	17.07712
356.6412470282155	22.012126443839193	16.466854	16.489805	16.449379
354.72903884607	23.522835191932803	17.908676	18.017105	17.773752
355.3055046741132	21.970078907741552	17.686487	17.748444	17.654493
355.5916251226369	22.377994086939758	18.162144	18.252535	18.003246
355.07175307403793	22.133533322210106	17.805712	17.764523	17.931206
355.5846266512745	20.971529402537367	18.690046	18.773817	18.663952
354.68445931525673	23.509010180548014	19.170467	19.234247	19.097427
355.01629608363663	20.986572186487212	18.92037	18.970657	18.99242
356.57505719613687	21.335659092076675	18.395067	18.45475	18.302269
355.94763230595606	22.47714871274258	18.694689	18.638191	18.985088



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