%%

addpath('/home/ocs/Documents/WDsurvey/')


%% List Fields

DataPath = '/last01w/data1/archive/LAST.01.01.03/2023/12/15/proc';

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
Names = ['WDJ044759.97+554609.21',
'WDJ045452.60+543047.80',
'WDJ044850.40+545451.24',
'WDJ045436.45+535528.47',
'WDJ045537.46+552432.28'

  ]

TargetList = [
72.00135118429698	55.76801339788412	15.498046	15.4302	15.660245
73.71950933488556	54.512922054816	16.988503	16.956758	17.090132
72.20986454728778	54.91405089085889	19.051357	19.206903	18.876066
73.65185620612681	53.92459735212509	17.919127	17.940117	17.961555
73.90603115990415	55.40896479547258	18.951405	18.974964	18.919691

];



Pathway = [DataPath,'/161102v0']



e = WDs(Pathway,Names,TargetList(:,1)	,TargetList(:,2)	,TargetList(:,3)    ,TargetList(:,4)	,TargetList(:,5),'Batch',[],'getForcedData',false,'plotTargets',false,...
    'FieldId',FieldNames{1})


%% plot a source to check it

Idx = 1;
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

RMSpsf  = e.Data.Catalog.PSF{Idx}.plotRMS('FieldX','MAG_PSF','PlotColor','red')
Xdata = RMSpsf.XData;
Ydata = RMSpsf.YData;

hold on
RMSraw  = e.Data.Catalog.MS{Idx}.plotRMS('FieldX','MAG_PSF','PlotColor','black')
hold off
% with sysrem:
%%

BitMask =  BitDictionary ; 

Bits    =  BitMask.Class(e.Data.Catalog.MS{Idx}.Data.FLAGS);

BadBits =  {'Saturated','NaN','Negative','CR_DeltaHT','NearEdge'};

Remove  = zeros(size(Bits));

for b = BadBits
    
    BitIdx = find(contains(BitMask.Dic.BitName,b))
    
    Remove =  Remove | bitget(Bits,BitIdx);

end

% Remove Bad points
MS = e.Data.Catalog.PSF{Idx}.copy();

MS.Data.MAG_PSF(Remove)       = NaN ;
MS.Data.MAGERR_PSF(Remove)    = NaN ;
MS.Data.MAG_APER_2(Remove)    = NaN ;
MS.Data.MAGERR_APER_2(Remove) = NaN ;

% Take only points with more than 50 % measurements

NaNcut = sum(isnan(MS.Data.MAG_PSF))/length(MS.JD) > 0.5;

% Make sure your WD isnt mask 

if NaNcut(SourceIdx)
    
    NaNcut(SourceIdx) = 0;
    
end
    

% Copy Just to prevent confusion

ms = MS.copy();

clear MS

% Survivng source list
Nsrc = [1:ms.Nsrc] ;
ms.addMatrix(Nsrc(~NaNcut),'SrcIdx') ;
ms.addMatrix(sum(~NaNcut),'Nsources') ;

% Cut off Bad sources
ms.Data.MAG_PSF       = ms.Data.MAG_PSF(:,~NaNcut) ;
ms.Data.MAGERR_PSF    = ms.Data.MAGERR_PSF(:,~NaNcut) ;
ms.Data.MAG_APER_2    = ms.Data.MAG_APER_2(:,~NaNcut) ;
ms.Data.MAGERR_APER_2 = ms.Data.MAGERR_APER_2(:,~NaNcut) ;
ms.Data.FLAGS         = ms.Data.FLAGS(:,~NaNcut) ;
NewIdx = find(ms.Data.SrcIdx == SourceIdx);

% For model

model = ms.copy();

figure('Color','white');


ms.plotRMS('FieldX','MAG_PSF','plotColor','red','PlotSymbol',['x'])

hold on

% semilogy(Xdata(~NaNcut),Ydata(~NaNcut),'b.')

ms.sysrem('MagFields' ,{'MAG_PSF'} , 'MagErrFields',{'MAGERR_PSF'},'sysremArgs',{'Niter',2});

RMSsys = ms.plotRMS('FieldX','MAG_PSF','plotColor','cyan','PlotSymbol',['.'])
xdata  = RMSsys.XData;
ydata  = RMSsys.YData;


% Mark your WD
semilogy(Xdata(SourceIdx),Ydata(SourceIdx),'p','MarkerSize',10,'MarkerFaceColor','cyan','MarkerFaceColor','black')
semilogy(xdata(NewIdx),ydata(NewIdx),'p','MarkerSize',10,'MarkerFaceColor','cyan','MarkerFaceColor','black')




Leg = legend('ZP','SysRem',['rms zp = ',num2str(Ydata(SourceIdx))],['rms zp = ',num2str(ydata(NewIdx))])
title('RMS MAG PSF')






%% plot a source to check it



figure('Color','white');
plot(t,y_ZPpsf,'x')

hold on

t = ms.JD;
y_sys = ms.Data.MAG_PSF(:,NewIdx);
plot(t,y_sys,'o')

hold off
legend('ZP','SysRem')
title('MAG_PSF LC')


%% Model 
% get ext color
model.addExtMagColor


%%
Color = model.SrcData.ExtColor(~NaNcut);
Mag   = model.SrcData.ExtMag(~NaNcut);

Color(isnan(Color)) = 0;

if Color(NewIdx) == 0
    
    Color(NewIdx) = e.Color(Idx);
    
end

if isnan(Mag(NewIdx) )
    
    Mag(NewIdx) = e.G_Bp(Idx);
    
end

%% check Trend CC
model1 = e.Data.Catalog.PSF{Idx};

m




%%

%[DD,reff,FR,Mod] =  lsqRelPhotByEranV4(model,'Niter', 2,'obj',e,'wdt',Idx,)
RES =  lsqRelPhotByEranGOODVER(model,'Niter',2,'StarProp',{Color})

r = reshape(RES.Resid,[size(model.Data.MAG_PSF)]);
std_r = std(r,'omitnan')

[rms0,meanmag0]  = CalcRMS(Mag,r,e,Idx,'Marker','xk','Predicted',false)
%%


figure('Color','white');
%RMSpsf  = e.Data.Catalog.PSF{Idx}.plotRMS('FieldX','MAG_PSF','PlotColor',[0,0,0])
%Xdata = RMSpsf.XData;
%Ydata = RMSpsf.YData;

RMSsys = ms.plotRMS('FieldX','MAG_PSF','plotColor',[0 0 0])%,'PlotSymbol',['x'])

hold on

% semilogy(Xdata(~NaNcut),Ydata(~NaNcut),'b.')

xdata  = RMSsys.XData;
ydata  = RMSsys.YData;

semilogy(xdata,rms0,'.','MarkerSize',17,'MarkerFaceColor','cyan','MarkerFaceColor','black')
semilogy(xdata,rms1,'o','MarkerSize',10,'MarkerFaceColor','cyan','MarkerFaceColor','black')



semilogy(Xdata(~NaNcut),Ydata(~NaNcut),'.','MarkerSize',5,'MarkerFaceColor','cyan','MarkerFaceColor','cyan')


% Mark your WD
semilogy(xdata(NewIdx),ydata(NewIdx),'p','MarkerSize',10,'MarkerFaceColor','cyan','MarkerFaceColor','cyan')
semilogy(xdata(NewIdx),rms0(NewIdx),'p','MarkerSize',10,'MarkerFaceColor','cyan','MarkerFaceColor','cyan')


Leg = legend('SysRem','Linear Model',['rms sys = ',num2str(ydata(NewIdx))],['rms model = ',num2str(rms0(NewIdx))])
title('RMS MAG PSF')

%%



 [AirMass,t] = getAirmass(model,'Results',Results)
 
 %[DD,reff,FR,Mod] =  lsqRelPhotByEranV4(model,'Niter', 2,'obj',e,'wdt',Idx,)
RES =  lsqRelPhotByEranGOODVER(model,'Niter',2,'StarProp',{Color},'ImageProp',{AirMass})

r = reshape(RES.Resid,[size(model.Data.MAG_PSF)]);
std_r = std(r,'omitnan')

[rms1,meanmag0]  = CalcRMS(Mag,r,e,Idx,'Marker','xk','Predicted',false)


%%
LM   = model.Data.MAG_PSF;
Err  = model.Data.MAGERR_PSF;

[MMM,H,Par,m] = TrendCC(LM',Color,'JD',model.JD,'Err',Err)





%%

AC = AstroCatalog('LAST.01.01.01_20231215.181744.193_clear_074+56_001_001_015_sci_proc_Cat_1.fits')