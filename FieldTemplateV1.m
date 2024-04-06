%% 


addpath('~/Documents/WDsurvey/')


%% check


obj = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)
Mount     = '10'; % str
Tel       = 1   ; % int
Year      = '2023' ;
Month     = '08' ;
Night     = '15' ; 
SaveTo    =  '/home/ocs/Documents/WD_survey/Thesis/1508_291+35/';
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
FN = Obj.Data.FieldNames{end}

 Obj = GetFieldLC(obj,'Mount',Mount,...
'Tel',Tel,...
'Year',Year,...
'Month',Month,...
'Night','16',...
'SaveTo',SaveTo ,...
'Night2',{},...
'ListFields',false,'GetCoords',true,'FieldCoords',FN)
 % Obj = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


%% get Names AND WD coords from the data



Names = [
' WDJ194008.01+351322.65  ',
' WDJ193431.30+355409.55  ',
' WDJ193747.46+371747.83  ',
' WDJ193756.61+345818.47  ',
' WDJ193525.35+355740.35  ',
' WDJ194030.10+352102.16  ',
' WDJ193844.02+360323.99  ',
' WDJ193707.43+365432.11  ',
' WDJ194009.09+372158.17  ',
' WDJ193602.86+353850.88  ',
' WDJ193155.12+354810.13  ',
' WDJ193557.37+345321.05  ',
' WDJ193259.80+371112.62  ',
' WDJ193924.48+354557.67  ',
' WDJ193255.79+354830.82  ',
' WDJ193245.73+345556.56  ',
' WDJ193354.11+380139.11  ',
' WDJ193305.83+372615.58  ',
' WDJ193756.28+373119.83  ',
  ];

TargetList = [
295.03412494030005	35.224219145695365	16.282505	16.413021	16.046583
293.63049140504404	35.902420734069615	18.513414	18.687565	18.247725
294.4474754492684	37.29584241317964	17.521496	17.572304	17.47134
294.48614870586493	34.971881830482786	18.501465	18.487125	18.645975
293.85563233303895	35.96122716947395	18.07697	18.100666	18.118368
295.1257932186837	35.35052102226395	18.664425	18.784018	18.68429
294.6836009496499	36.05685184329008	18.090555	18.078466	18.23314
294.28097973679814	36.908738894964856	18.741741	18.723606	18.715343
295.0378897590815	37.36617730972967	18.536877	18.530025	18.669838
294.01179686453867	35.647319165998056	17.903917	17.753988	17.926155
292.9795775031157	35.80259445366795	19.008173	19.026073	18.905556
293.98894775320133	34.889252812245935	18.843681	18.79128	18.932451
293.2491302569573	37.18672211267496	18.675632	18.637043	18.85684
294.8519241339331	35.76581535643988	17.630438	17.49945	17.891811
293.2323953207045	35.808416558405995	17.44821	17.301804	17.702467
293.1905639966586	34.93231549692287	19.13793	19.083	19.365242
293.47549990638066	38.027667487047665	18.498348	18.42103	18.893183
293.27428841807733	37.437612110241005	18.042694	17.875784	18.247667
294.4845011326422	37.52208042351409	18.954206	18.677677	18.729395
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



%% 2 fields



obj = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)
Mount     = '10'; % str
Tel       = 1   ; % int
Year      = '2023' ;
Month     = '08' ;
Night     = '21' ; 
SaveTo    =  '/home/ocs/Documents/WD_survey/Thesis/2108_291+23/';
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
' WDJ192646.95+242911.98  ',
' WDJ192455.21+243826.23  ',
' WDJ192329.48+235824.01  ',
' WDJ192546.91+241113.05  ',
' WDJ192648.73+252817.61  ',
  ];

TargetList = [
291.69548767933424	24.48714905714121	16.470274	16.50976	16.359936
291.22968063099063	24.640268797948043	19.04993	19.414358	18.475557
290.8730992406243	23.973434300508927	17.577864	17.353178	16.91618
291.44557635999683	24.187333555875888	18.740353	18.852732	18.711782
291.70307751775584	25.471516666677118	18.312845	18.310083	18.361254

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
%%
