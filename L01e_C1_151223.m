%%

addpath('/home/ocs/Documents/WDsurvey/')


%% List Fields

DataPath = '/last01e/data1/archive/LAST.01.01.01/2023/12/15/proc';

cd(DataPath)

Visits = dir;

FieldNames = [] ;

for Ivis = 3 : numel(Visits)
    
    cd(Visits(Ivis).name)
    
    Cats = dir;
    
    VisitCenter = '010_001_015_sci_proc_Cat_1.fits';
    
    IDX = find(contains({Cats.name},VisitCenter));
    
    H   = AstroHeader(Cats(IDX).name,3);
    
    FieldNames = [FieldNames ; {H.Key.FIELDID}]
    
    
    cd ..
        
    
end
    
    
    
%% Read from Cats by FieldID

% FOV center by subframe

Results = ReadFromCat(DataPath,'Field',FieldNames{1},'SubFrame','015')


%% targets in field
Names = [
 'WDJ050310.89+583017.51',
'WDJ050427.95+572212.58',
'WDJ050415.39+560048.59',
'WDJ050017.14+555944.52',
'WDJ050214.97+571746.94',
'WDJ050504.38+554333.45',
'WDJ050413.48+570430.54',
'WDJ050828.83+570359.48'
  ]

TargetList = [
75.79441181560156	58.50377776447404	18.834263	19.067596	18.479187
76.1162056000186	57.368216020926944	17.681812	17.814215	17.45064
76.06371024895085	56.013038941909706	18.909513	19.202078	18.483395
75.07158608061597	55.99569144059584	17.54945	17.643406	17.388554
75.5635397876903	57.295562190711365	18.96953	18.954218	19.054396
76.26790180226217	55.72605686887395	17.51806	17.497694	17.547382
76.05620536116282	57.075139578328894	18.702803	18.806835	18.62539
77.11985621038693	57.066527856941505	18.13492	18.15322	18.165815
];



Pathway = [DataPath,'/161101v0']

e = WDs(Pathway,Names,TargetList(:,1)	,TargetList(:,2)	,TargetList(:,3)    ,TargetList(:,4)	,TargetList(:,5),'Batch',[],'getForcedData',false)


%% plot a source to check it

Idx = 2 ;
SourceIdx = e.Data.Catalog.MS{Idx}.coneSearch(e.RA(Idx),e.Dec(Idx)).Ind

t = e.Data.Catalog.MS{Idx}.JD;
y_noZP = e.Data.Catalog.MS{Idx}.Data.MAG_PSF(:,SourceIdx);

figure('Color','white');
plot(t,y_noZP,'o')
hold on

t = e.Data.Catalog.PSF{Idx}.JD;
y_ZPpsf = e.Data.Catalog.PSF{Idx}.Data.MAG_PSF(:,SourceIdx);
plot(t,y_ZPpsf,'x')
hold off

%% RMS plot

figure('Color','white')

RMSnoZP  = e.Data.Catalog.PSF{Idx}.plotRMS('FieldX','MAG_PSF','PlotColor','red')
hold on
RMSnoZP  = e.Data.Catalog.MS{Idx}.plotRMS('FieldX','MAG_PSF','PlotColor','black')

% with sysrem:

flags = BitDictionary.BitDic.Class(e.Data.Catalog.MS{Idx})

BitMask =  BitDictionary.BitDic.Class

%%

AC = AstroCatalog('LAST.01.01.01_20231215.181744.193_clear_074+56_001_001_015_sci_proc_Cat_1.fits')