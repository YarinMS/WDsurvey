a = extractLCFromObs('~/marvin/LAST.01.03.04/2024/07/09/proc')

%%
Table.CropID = 12;
Table.RA = 10.413;
Table.Dec = 42.120;
Table.Nvisits =3
Table.Name = 'N13949_3'
%%
%MS = a(Table.CropID,:)
MSgroups = groupMS(MS,Table.Nvisits)
Res = getLCfromMS(MSgroups,Table,'~/Projects/WD_survey/LCs/N13949/')