function [Obj,FieldNames,FieldCoords] = marvin_Fields(SaveTo,Args)

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
if isfield(Obj.Data, 'FieldNames')
filenames = Obj.Data.FieldNames;

Fields = unique(filenames)
FieldCoords = [];
FieldNames  = [];


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

else
    FieldCoords = [];
    FieldNames  = [];
end
%%




end