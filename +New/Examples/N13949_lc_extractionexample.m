a = extractLCFromObs(['~/marvin/LAST.01.10.01/2024/10/28' ...
    '/proc'])

%%
Table.CropID = 8;
Table.RA = 218.949376;
Table.Dec = 37.560613;
Table.Nvisits =5;
Table.Name = 'NSiyi'
%%
MS = a
MSgroups = groupMS(MS,Table.Nvisits)
Res = getLCfromMS(MSgroups,Table,'~/Projects/WD_survey/LCs2/Siyi/')