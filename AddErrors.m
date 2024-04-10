%% Error bars 
addpath('~/WDsurvey/WDsurvey/')
set(0,'DefaultFigureWindowStyle','docked')
cd('~/Documents/Data/')
%%
% Given a path to a proc directory.
% get catalog Data:
obj = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)
 


Obj = GetFieldLCmarv2(obj,'Mount','02',...
'Tel',2,...
'Year','2023',...
'Month','08',...
'Night','22',...
'SaveTo','/Users/yarinms/Documents/Master/Results/Run3/',...
'Night2',{},...
'ListFields',true) %,'GetCoords',false,'FieldCoords','field1145',...
%'Names',Names,'TargetList',TargetList,'CloseAll',true)
%%

Obj = getObsInfo(Obj)

%%
'/Users/yarinms/Documents/Data'


    % MATLAB script generated from Python
    % Telescope Name: LAST.01.08.01
    % Observation Date: 2023/09/15

   
        obj = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)
        % Names matrix
        Names = [ ' WDJ234926.19+333504.32  ',
' WDJ234926.58+335058.73  ',
' WDJ234716.83+340157.33  ',
' WDJ235036.87+330245.69  ',
' WDJ234856.31+314207.82  ',
' WDJ235106.81+321828.52  ',]
        % TargetList matrix
       TargetList = [ 357.3592121024242	33.58335143446601	16.824327	16.835466	16.839817
357.36093111113405	33.849692556398786	18.721958	18.710783	18.824137
356.8201464331848	34.032494312329064	17.828075	17.737906	18.048447
357.6536194227089	33.04596808404657	19.003864	18.979767	19.107862
357.2347374247124	31.702099617021403	19.097359	19.106815	19.209877
357.7784967943153	32.30776861433026	18.955025	18.888506	19.079998
];
        
   
Obj = GetFieldLCmarv2(obj,'Mount','02',...
'Tel',2,...
'Year','2023',...
'Month','08',...
'Night','22',...
'SaveTo','/Users/yarinms/Documents/Master/Results/Run3/',...
'Night2',{},...
'ListFields',false,'GetCoords',false,'FieldCoords','356+34',...
'Names',Names,'TargetList',TargetList,'CloseAll',true)

%%