function S = insertRow2Scheduler(S,FieldName,RA,Dec,MountNum,StartJD,StopJD,Priority)


exRow = S.searchFieldName('919.WD');

S.List.Catalog(end+1,:) = S.List.Catalog(exRow,:);

%
S.List.Catalog.FieldName(end) = FieldName;

S.List.Catalog.RA(end) = RA;

S.List.Catalog.Dec(end) = Dec;

S.List.Catalog.MountNum(end) = MountNum; 

S.List.Catalog.StartJD(end) = StartJD;

S.List.Catalog.StopJD(end) = StopJD;

S.List.Catalog.BasePriority(end) = Priority;

end