% 1. extractLC from Pbs --> extract MS from path

% 
% 
% 
% 
% 
a = extractLCFromObs('~/marvin/LAST.01.04.02/2023/09/16/proc')


Table.CropID = 9;
Table.RA = 284.413932;
Table.Dec = 53.509250;
Table.Nvisits = 9
Table.Name = 'WD1856+534b'
%%
MS = a(Table.CropID,:)
MSgroups = groupMS(MS,Table.Nvisits)
Res = getLCfromMS(MSgroups,Table,'~/Projects/WD_survey/LCs/')