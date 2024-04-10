function [Obj,Obj2] = GetFieldLCmarvFast(Obj,Args)

 % Obj = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)



arguments 
    
    Obj WDss
    Args.Mount     = '10'; % str
    Args.Tel       = 1   ; % int
    Args.Year      = '2023' ;
    Args.Month     = '08' ;
    Args.Night     = '15' ; 
    Args.SaveTo    =  '/home/ocs/Documents/WD_survey/Thesis/2708_312+25/';
    Args.Night2    = {};
    
    
    
    Args.ListFields   = true;
    Args.GetCoords    = false;
    Args.FieldCoords  = 'XXX+YY';
    
    
    Args.Names = {};
    Args.TargetList ={};
    
    Args.CloseAll = false;
end



%% Establish correct path

if ~rem(Args.Tel,2) 
    
    if Args.Tel == 2 
        
        PathSegment1 = ['/Users/yarinms/marvin/LAST.01.',Args.Mount,'.0',num2str(Args.Tel),'/'];
    else
        PathSegment1 = ['/Users/yarinms/marvin/LAST.01.',Args.Mount,'.0',num2str(Args.Tel),'/'];
        
    end
    
    
    
else
    
    if Args.Tel == 1
        PathSegment1 = ['/Users/yarinms/marvin/LAST.01.',Args.Mount,'.0',num2str(Args.Tel),'/'];
        
    else
        PathSegment1 = ['/Users/yarinms/marvin/LAST.01.',Args.Mount,'.0',num2str(Args.Tel),'/'];
    end
    
    
    
end

 


Obj.Path =  [PathSegment1,Args.Year,'/',Args.Month,'/',Args.Night,'/','proc']; % Manual at the moment.

Obj.Data.save_to = Args.SaveTo;
    try
        if exist(Obj.Path, 'dir') == 7 % Check if directory exists
            
            disp(['Observation Exist ' Obj.Path]);
            % Your code that uses the directory here
        else
            disp(['Directory does not exist: ' Obj.Path]);
            return;
        end
    catch ME
        disp(['Error occurred while changing to directory: ' Obj.Path]);
        disp(ME.message);
    end


%% 2nd night - only if exist
% Initilize WDs Object

if ~isempty(Args.Night2)


Obj2 = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


Obj2.Path =  [PathSegment1,Args.Year,'/',Args.Month,'/',Args.Night2,'/','proc'];

Obj2.Data.save_to =  Args.SaveTo;

else
    Obj2 = {};

end


%%
if Args.ListFields 

Obj = ListFields(Obj)

elseif Args.GetCoords 

Obj = ListFields(Obj); % List All Fields in Path


%% Get field FWHM LimMAG ra,dec during the obs
Obj.FieldID = Args.FieldCoords;
Obj2.FieldID = Args.FieldCoords;
Obj = getObsInfo(Obj,'FN',Obj.FieldID);


elseif ~isempty(Args.Names) & isempty(Args.Night2)
    
    %% one night
Obj = ListFields(Obj); % List All Fields in Path


%% Get field FWHM LimMAG ra,dec during the obs
Obj.FieldID = Args.FieldCoords;
Obj2.FieldID = Args.FieldCoords;
Obj = getObsInfo(Obj,'FN',Obj.FieldID);    


%%


Obj.Name = Args.Names ;
Obj.RA   = Args.TargetList(:,1);
Obj.Dec  = Args.TargetList(:,2);
Obj.G_g  = Args.TargetList(:,3);
Obj.G_Bp = Args.TargetList(:,4);
Obj.G_Rp = Args.TargetList(:,5);
Obj.Color = Obj.G_Bp  - Obj.G_Rp ;

%% Visit Inspection
Obj = VisitInspection(Obj)

TabName         = [Obj.Data.DataStamp,'_','WDobj',Obj.Data.FieldID,'.mat'];
save_path = [Obj.Data.save_to,TabName];

save(save_path,'Obj','-v7.3')




elseif ~isempty(Args.Names) & ~isempty(Args.Night2)



%%

Obj = ListFields(Obj) % List All Fields in Path
Obj.Data.DataStamp = [Obj.Data.DataStamp,'-',Args.FieldCoords];
%% Get field FWHM LimMAG ra,dec during the obs
Obj.FieldID = Args.FieldCoords;
Obj2.FieldID = Args.FieldCoords;
Obj = getObsInfo(Obj,'FN',Obj.FieldID);


%% Now you can look for WD within the field and add to the Objecyt


%% targets in field


Obj.Name = Args.Names ;
Obj.RA   = Args.TargetList(:,1);
Obj.Dec  = Args.TargetList(:,2);
Obj.G_g  = Args.TargetList(:,3);
Obj.G_Bp = Args.TargetList(:,4);
Obj.G_Rp = Args.TargetList(:,5);
Obj.Color = Obj.G_Bp  - Obj.G_Rp ;

%% Visit Inspection
Obj = VisitInspection(Obj)

% Batch Sorting:
%[Obj,Results_N1_160823] = BatchSort(Obj)

% get 2vis light curves:

%[Obj] = get2VisLC(Obj,'Results1',Results_N1_160823)

%% Save Obj for later:

TabName         = [Obj.Data.DataStamp,'_','WDobj',Obj.Data.FieldID,'.mat'];
save_path = [Obj.Data.save_to,TabName];

save(save_path,'Obj','-v7.3')

%% 2nd night

%%

Obj2 = ListFields(Obj2) % List All Fields in Path
Obj2.Data.DataStamp = [Obj2.Data.DataStamp,'-',Args.FieldCoords];
%% Get field FWHM LimMAG ra,dec during the obs

Obj2 = getObsInfo(Obj2,'FN',Obj2.FieldID);


%% Now you can look for WD within the field and add to the Objecyt


%% targets in field

%% targets in field



Obj2.Name = Args.Names ;
Obj2.RA   = Args.TargetList(:,1);
Obj2.Dec  = Args.TargetList(:,2);
Obj2.G_g  = Args.TargetList(:,3);
Obj2.G_Bp = Args.TargetList(:,4);
Obj2.G_Rp = Args.TargetList(:,5);
Obj2.Color = Obj.G_Bp  - Obj.G_Rp ;

%% Visit Inspection
Obj2 = VisitInspection(Obj2)

% Batch Sorting:
%[Obj2,Results_N2] = BatchSort(Obj2)

% get 2vis light curves:

%[Obj2] = get2VisLC(Obj2,'Results1',Results_N2)
%% Save Obj2 for later:

TabName         = [Obj2.Data.DataStamp,'_','WDobj2',Obj2.Data.FieldID,'.mat'];
save_path = [Obj.Data.save_to,TabName];

save(save_path,'Obj2','-v7.3')



end



if Args.CloseAll 
    
    close all;
    %clear all;


end


end