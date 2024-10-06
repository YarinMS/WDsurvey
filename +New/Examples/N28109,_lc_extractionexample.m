% 1. extractLC from Pbs --> extract MS from path

% 
% 
% 
% 
% 
a = extractLCFromObs('~/marvin/LAST.01.10.03/2023/05/24/proc')



%%
Table.CropID = 14;
Table.RA = 160.962;
Table.Dec = 51.752;
Table.Nvisits = 5
Table.Name = 'N28109'
%%
MS = a(Table.CropID,:)
MSgroups = groupMS(MS,Table.Nvisits)
Res = getLCfromMS(MSgroups,Table,'~/Projects/WD_survey/LCs/')