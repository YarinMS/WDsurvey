function S = insertRow2Scheduler(S,FieldName,RA,Dec,MountNum,StartJD,StopJD)


exRow = S.searchFieldName('31UDR19');

S.List.Catalog(end+1,:) = S.List.Catlaog(exRow,:);

%
S.List.Catalog.FieldName(end) = FieldName;

S.List.Catalog.RA(end) = RA;

S.List.Catalog.Dec(end) = Dec;

S.List.Catalog.MountNum(end) = MountNum; 

S.List.Catalog.StartJD(end) = StartJD;

S.List.Catalog.StopJD(end) = StopJD;

end