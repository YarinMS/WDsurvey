a = extractLCFromObs('~/marvin/LAST.01.06.04/2023/09/15/proc')

%%
Table.CropID = 4;
Table.RA = 19.860;
Table.Dec = 36.067;
Table.Nvisits =8
Table.Name = 'N11497'
%%
MS = a(Table.CropID,:)
MSgroups = groupMS(MS,Table.Nvisits)
Res = getLCfromMS(MSgroups,Table,'~/Projects/WD_survey/LCs/SDSS14_37/')