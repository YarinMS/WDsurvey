function [Obj,FieldNames,FieldCoords,Path,counts,counts2,Flag] = marvin_FieldsFinal(SaveTo,Args)

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
 [Obj,Obj2,Flag] = GetFieldLCmarvFastFinal(obj,'Mount',Mount,...
'Tel',Tel,...
'Year',Year,...
'Month',Month,...
'Night',Night,...
'SaveTo',SaveTo ,...
'Night2',Night2,...
'ListFields',false,'GetCoords',false);

%% 
if Flag



 [obj,obj2,Flag] = GetFieldLCmarvFastFinal(obj,'Mount',Mount,...
'Tel',Tel,...
'Year',Year,...
'Month',Month,...
'Night',Night,...
'SaveTo',SaveTo ,...
'Night2',Night2,...
'ListFields',true,'GetCoords',false);


filenames = obj.Data.FieldNames;
Fields = unique(filenames)
filenames2 = obj2.Data.FieldNames;
Fields2 = unique(filenames2)

flager = false;
for i = 1 : numel(Fields2)

if contains(Fields2(i),Fields)
    flager = true;
end

if (length(Fields) > 2) | (length(Fields2)>2)

flager = false;
end


end

if flager

if isfield(obj.Data, 'FieldNames')
filenames = obj.Data.FieldNames;

Fields = unique(filenames)
if numel(Fields) <= 2
counts = cell(size(Fields));
counts2=cell(size(Fields));
FieldCoords = [];
FieldNames  = [];
Path = [];


for Ifield = 1: numel(Fields)
counts{Ifield} = sum(strcmp(filenames, Fields{Ifield}))
FN = Fields{Ifield};

 Obj1 = GetFieldLCmarvFastFinal(obj,'Mount',Mount,...
'Tel',Tel,...
'Year',Year,...
'Month',Month,...
'Night',Night,...
'SaveTo',SaveTo ,...
'Night2',{},...
'ListFields',false,'GetCoords',true,'FieldCoords',FN)

 FieldCoords = [FieldCoords ; {Obj1.Data.Results.Coord(1,:)}];
 FieldNames  = [FieldNames  ; {FN}];
 Path = [Path ; {Obj.Path}];
 filePath = [SaveTo,'/','FullFields.txt'];
 writeNumberedLines(filePath, ['Observation Exist', Obj.Path,' Field :',FN,' Nvisits :',num2str(counts{Ifield})]);

end

else
    counts = {};
counts2={};
FieldCoords = [];
FieldNames  = [];
Path = [];
end

else
counts = {};
counts2={};
FieldCoords = [];
FieldNames  = [];
Path = [];
end



%% 2nd night
if isfield(obj2.Data, 'FieldNames')
    
filenames = obj2.Data.FieldNames;

Fields = unique(filenames)
if numel(Fields) <= 2




counts2=cell(size(Fields));

for Ifield = 1: numel(Fields)
counts2{Ifield} = sum(strcmp(filenames, Fields{Ifield}))
FN = Fields{Ifield};
writeNumberedLines(filePath, ['Observation Exist', obj2.Path,' Field ',FN,' Nvisits ',num2str(counts2{Ifield})]);

end

else
    Path = [];
    FieldCoords = [];
    FieldNames  = [];
end

end






%%

else
counts = {};
counts2={};
FieldCoords = [];
FieldNames  = [];
Path = [];
end




else
counts = {};
counts2={};
FieldCoords = [];
FieldNames  = [];
Path = [];
end


end