%% no  15 / 08 
%% 


addpath('~/Documents/WDsurvey/')


%% 15/08
%% 15-16/08
%% Single field field



obj = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)
Mount     = '02'; % str
Tel       = 2   ; % int
Year      = '2023' ;
Month     = '08' ;
Night     = '15' ; 
SaveTo    =  '/home/ocs/Documents/WD_survey/Thesis/1508_278+13b/';
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
' WDJ183750.13+113310.70  ',
' WDJ183416.59+121515.82  ',
' WDJ183120.52+124734.89  ',
' WDJ183438.40+110353.10  ',
' WDJ183446.38+105332.22  ',
' WDJ183400.96+121438.73  ',
' WDJ183106.05+110200.45  ',
' WDJ183019.60+123302.36  ',
' WDJ183352.69+121500.93  ',
' WDJ183724.20+120045.92  ',
' WDJ183217.73+104102.45  ',
  ];

TargetList = [
279.45849294170847	11.552593959182428	17.347567	17.58001	16.982244
278.5686496621666	12.253413684576735	17.78308	17.914776	17.595182
277.83534955485095	12.793236928116748	17.094988	17.077267	17.1621
278.66005635523845	11.06467805342659	18.304712	18.301157	18.396107
278.6932934006016	10.892300694620118	17.796436	17.671152	17.777615
278.5040399226608	12.243954530476648	17.54425	17.517715	17.67114
277.77498800256365	11.032932612538348	17.839579	17.856853	17.738716
277.5820472018263	12.550755819233293	18.4519	18.548965	18.424723
278.46951924369694	12.250159933055516	17.731728	17.716642	17.807323
279.3508742890958	12.012689278329447	16.882923	16.815174	16.998358
278.0738487635523	10.683959180902015	18.416565	18.391054	18.460701



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
Mount     = '02'; % str
Tel       = 2   ; % int
Year      = '2023' ;
Month     = '08' ;
Night     = '16' ; 
SaveTo    =  '/home/ocs/Documents/WD_survey/Thesis/1608_294+42b/';
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
' WDJ193842.28+420705.74  ',
' WDJ193907.53+411458.62  ',
' WDJ194325.97+394930.27  ',
' WDJ194003.35+410530.73  ',
' WDJ193856.38+410131.48  ',
' WDJ194415.75+394302.84  ',
' WDJ194323.10+393837.43  ',
' WDJ193918.90+395257.79  ',
' WDJ193928.05+402414.76  ',
' WDJ194248.57+395249.87  ',
' WDJ194302.67+403258.91  ',
' WDJ194357.43+420429.95  ',
' WDJ194044.56+391913.75  ',
' WDJ193604.96+413305.81  ',
' WDJ194303.88+395037.71  ',
  ];

TargetList = [
294.676518190547	42.11853710356705	17.683708	17.740736	17.598747
294.781270725854	41.24929373146676	18.689854	18.837488	18.427536
295.85886161184544	39.82549282232831	18.172443	18.299927	18.02718
295.01312409797873	41.09146172385633	18.698109	18.637224	18.817019
294.7351686444129	41.025663425848165	17.295376	17.26208	17.404655
296.0656258956985	39.71761741825744	18.966251	18.886312	18.648537
295.8463137314065	39.643389185339615	19.120544	19.18325	19.257404
294.82883417467906	39.882724664650226	18.957674	18.952175	19.18969
294.8669197654422	40.40408340812224	18.858059	18.812187	19.010294
295.70240127492184	39.88050313256584	19.15197	19.1133	19.499542
295.761103987975	40.549601638428875	17.924625	17.825636	18.186687
295.9892951550936	42.07497726527752	18.909126	18.78488	19.155867
295.1855356013511	39.320756832748074	19.184174	19.152563	19.451263
294.02068794315005	41.55151377556131	16.495289	16.330015	16.828981
295.7661295875445	39.84372694407817	17.48285	17.33522	17.684828


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
%% 16/08 -2nd field


obj = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)
Mount     = '02'; % str
Tel       = 2   ; % int
Year      = '2023' ;
Month     = '08' ;
Night     = '16' ; 
SaveTo    =  '/home/ocs/Documents/WD_survey/Thesis/1608_352+21b/';
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
' WDJ233025.40+190706.55  ',
' WDJ233554.88+193812.85  ',
' WDJ233249.72+202653.57  ',
' WDJ233016.40+185352.80  ',
' WDJ233139.77+194557.53  ',
' WDJ233237.90+210453.51  ',
' WDJ233510.65+191247.13  ',
' WDJ233229.79+185615.27  ',
' WDJ233244.42+202048.40  ',
' WDJ233507.17+181743.63  ',
' WDJ233445.17+204359.08  ',
' WDJ233658.48+205734.76  ',
' WDJ233142.79+201912.97  ',
' WDJ233308.41+211707.00  ',
' WDJ233335.11+195618.02  ',
' WDJ232851.78+181518.13  ',
  ];

TargetList = [
352.60595668728024	19.117941371815558	18.865261	19.04134	18.616245
353.978813343251	19.636731574534142	17.551558	17.588306	17.541773
353.20752528838375	20.447920481433197	17.839079	17.947361	17.693703
352.5685345110239	18.89793242618225	17.3695	17.348562	17.466166
352.9160513285498	19.765660072007854	18.338884	18.559954	18.062595
353.15837372260467	21.08162382191828	17.108826	17.069092	17.265913
353.79418577497955	19.213000775408105	18.84152	19.049376	18.655102
353.1239816394043	18.93729071095261	18.153414	18.173922	18.198374
353.18541726646674	20.346608518386777	19.182596	19.371138	19.017761
353.7798377781415	18.295371631680524	19.098885	19.133614	19.02596
353.68821537531073	20.733052403819364	17.24031	17.138947	17.466894
354.2447440873459	20.95951308341704	18.717918	18.758797	18.700533
352.92850429856486	20.32030233825856	18.37041	18.353157	18.447603
353.28500190980793	21.28530250132263	18.959415	18.952927	18.962852
353.3961096727623	19.9382187340887	18.783266	18.779787	18.64193
352.2157266732633	18.25492157365223	17.716225	17.687115	17.829395



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
Mount     = '02'; % str
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
