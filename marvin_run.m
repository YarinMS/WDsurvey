function Obj = marvin_run(SaveTo,Args)

arguments
    SaveTo 
    Args.Mount ='02';
    Args.Tel   = 1 ; 
    Args.Year  = '2023';
    Args.Month = '09';
    Args.Night = '15';
    Args.Night2 = '16';

end

obj = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)
Mount     = Args.Mount ; % str
Tel       = Args.Tel   ; % int
Year      = Args.Year ;
Month     = Args.Month ;
Night     = Args.Night ; 
% SaveTo    =  '/home/ocs/Documents/WD_survey/Thesis/2708_280+40b/';
Night2    = Args.Night2;

%%
 Obj = GetFieldLCmarv(obj,'Mount',Mount,...
'Tel',Tel,...
'Year',Year,...
'Month',Month,...
'Night',Night,...
'SaveTo',SaveTo ,...
'Night2',{},...
'ListFields',true,'GetCoords',false)

%% 
filenames = Obj.Data.FieldNames;

Fields = unique(filenames)
FieldCoords = [];
FieldNames  = [];
%%
% 1 or middle or end (Usually)

for Ifield = 1: numel(Fields)

FN = Fields{Ifield};

 Obj1 = GetFieldLCmarv(obj,'Mount',Mount,...
'Tel',Tel,...
'Year',Year,...
'Month',Month,...
'Night',Night,...
'SaveTo',SaveTo ,...
'Night2',{},...
'ListFields',false,'GetCoords',true,'FieldCoords',FN)

 FieldCoords = [FieldCoords ; Obj1.Data.Results.Coord(1,:)]
 FieldNames  = [FieldNames  ; FN]

end
%%

 FN = Fields{2};
 
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

 Obj = GetFieldLCmarv(obj,'Mount',Mount,...
'Tel',Tel,...
'Year',Year,...
'Month',Month,...
'Night',Night,...
'SaveTo',SaveTo ,...
'Night2',Night2,...
'ListFields',false,'GetCoords',false,'FieldCoords',FN,...
'Names',Names,'TargetList',TargetList,'CloseAll',true)


end