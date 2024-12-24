%% Load gaia data;
gaiaData = load('~/Documents/WDsurvey/gaia_bp_rp_mg.mat');


%% Go over path load tables
visID = '3Vis'
resultTables = dir(sprintf('/media/yarinms/Data2/Projects/NightlyRun1/%s/*Results_Table_p*',visID));



%% Only WDs
gtab = table();

for Itab = 1 : numel(resultTables)
    tab = load(fullfile(resultTables(Itab).folder,resultTables(Itab).name));
    if ~isempty(tab)
     tab = tab.MetaTable;
     gtab = vertcat(gtab,tab(tab.Pwd > 0 ,:)); %  onlyWDs
    end
end


%% Analysis and plots


disp(sprintf('%i WD events',sum(gtab.Pwd>0)))

%% plot maxRMF correlation with background 
plts.plotNTabStat(gtab,'gaiaData',gaiaData,'Xfield','C_LimMag','Yfield','MaxPS')

%%
plts.plotNTabStat(gtab,'gaiaData',gaiaData,'Xfield','C_LimMag','Yfield','maxRMS')




%% plot only WDS
Tab = gtab
for i = 1: height(gtab)
    figure()
t = Tab.JD(i);
t = datetime(t{1},'convertfrom','jd');
y = Tab.MAG_PSF(i);
plot(t,y{1},'k-o')

title(sprintf('(%.4f,%.4f)  $P_{wd}$ -  %.2f; ID \\# %i',Tab.RA(i),Tab.Dec(i), Tab.Pwd(i),i))
xlabel(sprintf('Abs  $G$ = %.2f; $B_p-R_p$ = %.3f\n %s %04d-%02d-%02d %s',Tab.AbsMag(i),Tab.BpRp(i),Tab.TelescopeID(i,:),Tab.Year(i),Tab.Month(i),Tab.Day(i),Tab.FieldID{i}))
set(gca,'YDir','reverse')
end
%%


figHandles = findall(0, 'Type', 'figure');

% Extract the figure numbers
figNumbers = arrayfun(@(x) x.Number, figHandles);

% Display the figure numbers
disp('Open figure numbers:')









%%

Res= [ 6; 7; 8; 13; 14; 16; 17; 27; 30; 31; 38; 41; 42; 44; 45; 47; 54;...
    71; 89; 94; 96; 108; 117; 118; 128; 132; 135; 139; 144; 149; 151; 157; 160;...
    163; 175; 211; 213; 222; 225; 226; 227; 230; 232; 238; 243; 252; 255; 257; 259; 260 ]%;5


%% try
for rowInd = 1: length(Res)
%rowInd =2 % Some loop over Res.
eventInfo = marvinFP.evenInfoTable(gtab,Res(rowInd))
eventInfo.rowID = Res(rowInd);
eventRow = gtab(Res(rowInd),:);
% funpack localy and run pipeline
Data = marvinFP.SSHunpackFitsFilesMarv(eventInfo)
% FP
[fn] = marvinFP.automateRemoteProcessingMarv(Data);
ms = dir(sprintf('~/Projects/MarvinRunRes/*Row%i.mat',eventInfo.tabID))
ms= load(fullfile(ms.folder,ms.name));
ms = ms.ms;
figure()
plot(ms.JD,ms.Data.MAG_PSF(:,1))
hold on
plot(eventRow.JD{:},eventRow.MAG_PSF{:})
end