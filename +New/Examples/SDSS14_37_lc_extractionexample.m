a = extractLCFromObs('~/marvin/LAST.01.08.03/2023/01/15/proc')

%%
Table.CropID = 2;
Table.RA = 218.949322;
Table.Dec = 37.560520;
Table.Nvisits =3
Table.Name = 'SDSS14+37'
%%
MS = a(Table.CropID,:)
MSgroups = groupMS(MS,Table.Nvisits)
Res = getLCfromMS(MSgroups,Table,'~/Projects/WD_survey/LCs/SDSS14_37/')