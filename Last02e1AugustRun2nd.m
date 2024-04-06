%% 15 / 08 
%% 


addpath('~/Documents/WDsurvey/')

%% 21-22/08

%% 2nd field


obj = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)
Mount     = '02'; % str
Tel       = 1   ; % int
Year      = '2023' ;
Month     = '08' ;
Night     = '22' ; 
SaveTo    =  '/home/ocs/Documents/WD_survey/Thesis/2108__356_34/';
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

Names = [' WDJ235300.03+365723.82  ',
' WDJ235430.18+343745.73  ',
' WDJ235425.63+360451.07  ',
' WDJ235355.00+361128.46  ',
' WDJ234615.05+354107.18  ',
' WDJ235137.15+361058.94  ',
' WDJ235343.17+362228.63  ',
' WDJ235353.60+355725.51  ',
' WDJ235233.66+361929.47  ',
' WDJ234934.16+345816.07  ',
' WDJ235148.36+362011.25  ',
' WDJ234844.89+344457.86  ',
' WDJ234602.97+344714.36  ',
' WDJ234804.68+371125.64  ',
' WDJ235115.08+355156.23  ',
' WDJ234902.81+355301.08  ',
  ];

TargetList = [
358.2490786372035	36.95602019242748	17.766068	18.02604	17.360794
358.6262040044346	34.629178069507404	17.730215	17.766941	17.666399
358.60691829894745	36.080867915255354	17.409506	17.480482	17.320492
358.4791566999056	36.191144233288874	17.282484	17.303087	17.30017
356.56322881707945	35.68584156079553	17.480652	17.51233	17.46241
357.9048310804486	36.18297355668468	19.155947	19.294252	19.05411
358.42991799227474	36.37460306534316	17.795748	17.53455	17.361908
358.47370661484814	35.95695843937606	18.35812	18.366528	18.452127
358.1404258710068	36.32479792290022	17.94189	17.892187	18.01698
357.39202436545224	34.97099708987863	19.085083	19.03908	18.907814
357.95105279670605	36.33621917732026	17.724937	17.673506	17.882141
357.18689661636387	34.74919241333775	18.758278	18.797411	18.808025
356.5124009830615	34.78724115911146	17.932756	17.877626	18.098137
357.01950955702785	37.19043010949823	18.573198	18.6289	18.589886
357.8128765670505	35.86549336287511	18.908047	18.907557	19.00362
357.2615900230666	35.88360345698252	18.608028	18.544827	18.818508


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
Tel       = 1   ; % int
Year      = '2023' ;
Month     = '08' ;
Night     = '27' ; 
SaveTo    =  '/home/ocs/Documents/WD_survey/Thesis/2708__292_39/';
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
    ' WDJ191858.63+384321.48  ',
' WDJ192453.39+375114.12  ',
' WDJ191829.64+385120.92  ',
' WDJ192119.12+381228.77  ',
' WDJ192433.08+373416.64  ',
' WDJ192210.31+361303.48  ',
' WDJ192251.93+390207.59  ',
' WDJ192408.26+365518.06  ',
' WDJ192549.15+363350.90  ',
' WDJ192603.04+370316.18  ',
' WDJ192228.51+380643.83  ',
' WDJ192006.75+365229.07  ',
' WDJ192616.15+383401.00  ',
' WDJ191914.79+363440.09  ',
' WDJ192704.18+381616.56  ',
' WDJ192056.80+372118.05  ',
' WDJ192135.56+370944.26  ',
  ];

TargetList = [
289.7445123416303	38.720937211680216	14.468728	14.70764	14.069847
291.22130959977767	37.85345137566349	18.742365	19.004896	18.368837
289.6236914365616	38.855705421924526	18.47594	18.626867	18.337448
290.3296502242715	38.20815802780617	17.561943	17.677254	17.410595
291.13900149070173	37.571650855336344	18.153393	18.201235	18.05303
290.5429602929434	36.21766077524346	17.472574	17.3519	17.521475
290.7164423365314	39.03559889547563	19.070604	19.19868	19.027458
291.0344369137689	36.921800392823755	18.062197	18.052776	18.197077
291.45474338310873	36.564198608203164	18.19943	18.23068	18.199593
291.51273237638975	37.054617441879465	19.012222	19.042492	19.135777
290.6187902902786	38.112215772571666	19.011774	19.01941	19.09882
290.0282841392444	36.87460163385959	18.815098	18.816214	18.944126
291.56714792247834	38.56675266126871	18.810986	18.700867	18.942148
289.8116154469776	36.57790681333144	18.36311	18.261122	18.529402
291.7674598281449	38.271320110293736	19.173668	19.113625	19.512377
290.23671111460834	37.35503802436986	18.680408	18.563673	19.02728
290.39798086878716	37.16220909976764	18.88919	18.802715	18.962502


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
Tel       = 1   ; % int
Year      = '2023' ;
Month     = '08' ;
Night     = '27' ; 
SaveTo    =  '/home/ocs/Documents/WD_survey/Thesis/2708__358_34/';
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



Names = [' WDJ234350.72+323246.73  ',
' WDJ234544.58+341050.85  ',
' WDJ234926.19+333504.32  ',
' WDJ234419.71+340729.22  ',
' WDJ234926.58+335058.73  ',
' WDJ234716.83+340157.33  ',
' WDJ235036.87+330245.69  ',
' WDJ234354.19+312742.57  ',
' WDJ234856.31+314207.82  ',
' WDJ235106.81+321828.52  ',
' WDJ234347.61+341319.26  ',
  ];

TargetList = [
355.9596124985845	32.545909990764116	12.966921	12.964135	13.007412
356.4360622155066	34.18135549560884	18.028858	18.399742	17.52324
357.35921203692845	33.58335219477887	16.824327	16.835466	16.839817
356.08191372524146	34.12455773608384	18.991856	19.111227	18.899755
357.36093099193283	33.8496925282637	18.721958	18.710783	18.824137
356.82014641232183	34.03249437502928	17.828075	17.737906	18.048447
357.65361942413665	33.045968121719426	19.003864	18.979767	19.107862
355.9757635441623	31.46182049697991	18.071423	17.97854	18.327915
357.23473735770335	31.70209966366189	19.097359	19.106815	19.209877
357.7784967105386	32.307768713675294	18.955025	18.888506	19.079998
355.94846848835095	34.22199293551438	19.17017	19.162964	19.343512

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
