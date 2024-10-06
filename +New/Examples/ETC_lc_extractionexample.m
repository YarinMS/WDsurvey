% 1. extractLC from Pbs --> extract MS from path

% 
% 
% 
% 
% 
a = extractLCFromObs('~/marvin/LAST.01.10.04/2023/09/15/proc')



%%
Table.CropID = 9;
Table.RA = 18.977;
Table.Dec = 29.821;
Table.Nvisits = 5
Table.Name = 'N2071'
%%
MS = a(Table.CropID,:)
MSgroups = groupMS(MS,Table.Nvisits)        
Res = getLCfromMS(MSgroups,Table,'~/Projects/WD_survey/LCs/')