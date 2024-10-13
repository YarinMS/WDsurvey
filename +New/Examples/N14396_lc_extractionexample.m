a = extractLCFromObs('~/marvin/LAST.01.06.04/2023/09/15/proc')

%%
Table.CropID = 10;
Table.RA = 19.860;
Table.Dec = 36.067;
Table.Nvisits =36
Table.Name = 'N14396_cropID10'
%%
%MS = a(Table.CropID,:)
MSgroups = groupMS(MS,Table.Nvisits)
Res = getLCfromMS(MSgroups,Table,'~/Projects/WD_survey/LCs/N1396/')