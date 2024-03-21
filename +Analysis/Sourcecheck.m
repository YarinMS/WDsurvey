
%% plot a source to check it

e=E;
%e.Data.Catalog.MS{Idx} = MSU2.copy()
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
set(gca,'YDir','reverse')
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

set(gca,'YDir','reverse')



%% get from different subfram
%cd proc

L = MatchedSources.rdirMatchedSourcesSearch('CropID',16);            
            
matched_source2 = MatchedSources.readList(L); 
MSU2 = mergeByCoo( matched_source2, matched_source2(14));


for i = 1 :  numel(matched_source2)
    IInd = matched_source2(i).coneSearch(e.RA(1),e.Dec(1)).Ind
    if ~isempty(IInd)
        i
        break
    end
end