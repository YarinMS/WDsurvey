%% Load LAST_Visits
OT = load('~/marvin/LAST_Visits_20241203.mat')

%% find in LAST DATA
OT = OT.OT;
%%
rowInd = 56
RA = 14.5783;%Tab.RA(rowInd);  14.5783 30.0187;
Dec = 30.0187;%Tab.Dec(rowInd);
Flag = celestial.coo.findInBox(RA, Dec, [OT.RAU1, OT.RAU2, OT.RAU3, OT.RAU4], [OT.DECU1, OT.DECU2, OT.DECU3, OT.DECU4]);



% unique sessions:
[US,xxx,iu] = unique(OT(Flag,{'Year','Month','Day','Mount','Camera','CropID','FieldID'}));

Nvisits = accumarray(iu,1);

if ~isempty(US)

    Paths =  compose("~/marvin/LAST.01.%02i.%02i/%i/%02i/%02i/proc/", US.Mount,US.Camera,US.Year,US.Month,US.Day)
end

% Get MS from Paths.
for Is = 1 : height(US)
wd = isWD([],RA,Dec);
wd= wd.Table;
wd.RA = wd.RA * 180/pi;
wd.Dec = wd.Dec *180/pi;
wd.FieldID = US.FieldID(Is);
wd.CropID = US.CropID(Is);
wd.Detected = 0;
wd.Nvisits = Nvisits(Is);
wd.BatchSize = 0;
wd.Nbatch = 0;
wd.BatchDetections = 0 ;
wd.Nevents = 0;
wd.BatchData = {0};
try
[stackedWDtable,mainMS,mainObsData] = marvinFP.getMSDateTgt(US.Mount(Is),US.Camera(Is), US.Year(Is),US.Month(Is),US.Day(Is), max(Nvisits)+5,'CropID',US.CropID(Is),'getMS',true,'FieldID',US.FieldID(Is),'TgtCoord',[RA,Dec],'WD',wd)
catch
    fprintf('\n ******Failed***** ID : M%iT%i %04d-%02d-%02d \n',US.Mount(Is),US.Camera(Is), US.Year(Is),US.Month(Is),US.Day(Is))
end

end