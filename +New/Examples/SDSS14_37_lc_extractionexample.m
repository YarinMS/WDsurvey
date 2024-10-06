a = extractLCFromObs('~/marvin/LAST.01.10.01/2024/06/04/proc')

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