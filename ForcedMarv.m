%%

set(0,'DefaultFigureWindowStyle','docked')
addpath('~/WDsurvey/WDsurvey/')

%% Forced photometry.


obj = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)

 [Obj,Obj2] = GetFieldLCmarvFast(obj,'Mount','02',...
'Tel',1,...
'Year','2023',...
'Month','09',...
'Night','15',...
'SaveTo','/Users/yarinms/Documents/Master/Results/Forced/',...
'Night2',{},...
'ListFields',false,'GetCoords',true ,'FieldCoords','field1064'),%...
%'Names',Names,'TargetList',TargetList,'CloseAll',true)

%%

Names = [
' WDJ014519.42+231753.94  ',
' WDJ014247.90+223944.37  ',
' WDJ014125.42+225734.98  ',
' WDJ013852.98+252322.64  ',
' WDJ013830.80+225445.37  ',
' WDJ014447.90+235616.39  ',
' WDJ014507.03+233704.76  ',
' WDJ014022.40+242718.38  ',
' WDJ014332.80+241706.97  ',
' WDJ014559.02+252136.40  ',
' WDJ014523.66+234239.40  ',
' WDJ014557.49+250653.25  ',]

TargetList = [
26.333190307168415	23.29759215249117	17.111774	17.239735	16.917555
25.699410208017923	22.661500905003916	19.184147	19.7705	18.559317
25.35630356544241	22.959490128304413	17.374647	17.50112	17.203596
24.721134460237877	25.38927717395861	15.915779	15.758811	16.237497
24.628612032188386	22.91265282628544	18.238607	18.405096	18.071085
26.199624163370043	23.937539769525642	17.85421	17.927782	17.80091
26.279154034406936	23.617833310566372	18.985508	19.106634	18.875925
25.09360223713597	24.455128031261427	18.653343	18.704964	18.705553
25.88718234019142	24.285130270999936	17.759352	17.728561	17.869566
26.496064647592632	25.36020130521715	17.829033	17.877771	17.774717
26.34856551588972	23.710894553806128	18.623999	18.5786	18.775768
26.489965967029026	25.11460031604698	19.022621	19.043392	19.029144]


obj = WDss('/Users/yarinms/marvin/LAST.01.02.01/2023/09/15/proc/235417v0',Names,TargetList(:,1),TargetList(:,2)	,TargetList(:,3),TargetList(:,4),TargetList(:,5),'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',false)
Mount     = '02'; % str
Tel       = 1   ; % int
Year      = '2023' ;
Month     = '09' ;
Night     = '15' ; 
obj.Data.save_to    =  '/Users/yarinms/Documents/Master/Results/Forced/';
Night2    = {};


%obj.Path = '/last02e/data1/archive/LAST.01.02.01/2023/08/22/proc';


%% get cropID as a function of visits
%Obj = ListFields(obj)
%Obj.FieldID = Obj.Data.FieldNames{1}
%Obj = getObsInfo(Obj,'FN',Obj.FieldID); 
%%

%Obj.Data.FieldID = Obj.Data.FieldNames{1}
%% GetLimMAG

% Obj = VisitInspection(obj)
%%
 
%%

%FP = ForcedMSbatch(obj,'Iobj',2,'CropID',obj.CropID{2})


%%
ForceData = struct();

for Isource = 1:numel(obj.RA)
    
    % Create Forced photometry source # i (Nbatches)
    FP = ForcedMSbatch(obj,'Iobj',Isource,'CropID',obj.CropID{Isource});
    
    % Store the object
    
    ForceData.(['WD_' num2str(Isource)]) = FP;
    
    
    
    
    
end%%

%%




