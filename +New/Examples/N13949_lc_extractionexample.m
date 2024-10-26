a = extractLCFromObs(['~/marvin/LAST.01.04.04/2024/07/05' ...
    '/proc'])

%%
Table.CropID = 8;
Table.RA = 218.949376;
Table.Dec = 37.560613;
Table.Nvisits =5;
Table.Name = 'N55944'
%%
MS = a
MSgroups = groupMS(MS,Table.Nvisits)
Res = getLCfromMS(MSgroups,Table,'~/Projects/WD_survey/LCs/N55944/')