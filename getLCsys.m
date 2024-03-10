function [ms,Event,Npts] = getLCsys(MatchedSource,Args)

arguments
    
    MatchedSource MatchedSources
    Args.RMSplot  = false;
    Args.MagField = 'MAG_PSF';
    Args.MagErrField = 'MAGERR_PSF';
    Args.BadBits     =  {'Saturated','NaN','Negative','CR_DeltaHT','NearEdge'};
    
    Args.SourceIdx   = 0;
    
    Args.plot = true;
    Args.threshold = 2.5;
    Args.SaveTo    = '';
    Args.Serial    = '';
    Args.WD        =  1;
    Args.wdIdx     =  1;
    
end

% MS =  ms before after ZP !!
R = lcUtil.zp_meddiff(MatchedSource,'MagField',Args.MagField,'MagErrField',Args.MagErrField);

[MS_ZP,ApplyToMagFieldr] = applyZP(MatchedSource, R.FitZP,'ApplyToMagField',Args.MagField);



%% RMS plot
if Args.RMSplot
   figure('Color','white')

   RMSpsf  = MS_ZP.plotRMS('FieldX','MAG_PSF','PlotColor','red')
   Xdata = RMSpsf.XData;
   Ydata = RMSpsf.YData;

   %hold on
   %RMSraw  = e.Data.Catalog.MS{Idx}.plotRMS('FieldX','MAG_PSF','PlotColor','black')
   %hold off

end
% with sysrem:
%%

BitMask =  BitDictionary ; 

Bits    =  BitMask.Class(MS_ZP.Data.FLAGS);

BadBits =  Args.BadBits;

Remove  = zeros(size(Bits));

for b = BadBits
    
    BitIdx = find(contains(BitMask.Dic.BitName,b));
    
    Remove =  Remove | bitget(Bits,BitIdx);

end

% Remove Bad points
MS = MS_ZP.copy();

MS.Data.MAG_PSF(Remove)       = NaN ;
MS.Data.MAGERR_PSF(Remove)    = NaN ;
MS.Data.MAG_APER_2(Remove)    = NaN ;
MS.Data.MAGERR_APER_2(Remove) = NaN ;

% Take only points with more than 50 % measurements

NaNcut = sum(isnan(MS.Data.MAG_PSF))/length(MS.JD) > 0.5;


% Make sure your WD isnt mask 

if NaNcut(Args.SourceIdx)
    
    NaNcut(Args.SourceIdx) = 0;
    
end
    

% Copy Just to prevent confusion


ms = MS.copy();



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
NewIdx = find(ms.Data.SrcIdx == Args.SourceIdx);

% For model

model = ms.copy();

figure('Color','white');


RMSzp = MS.plotRMS('FieldX','MAG_PSF','plotColor',[0.9 0.9 0.9],'PlotSymbol',['x']);
Xdata = RMSzp.XData;
Ydata = RMSzp.YData;

hold on

model.plotRMS('FieldX','MAG_PSF','plotColor','red','PlotSymbol',['x']);
% semilogy(Xdata(~NaNcut),Ydata(~NaNcut),'b.')

ms.sysrem('MagFields' ,{'MAG_PSF'} , 'MagErrFields',{'MAGERR_PSF'},'sysremArgs',{'Niter',2});

RMSsys = ms.plotRMS('FieldX','MAG_PSF','plotColor','cyan','PlotSymbol',['.']);
xdata  = RMSsys.XData;
ydata  = RMSsys.YData;

%clear MS
% Mark your WD
semilogy(Xdata(Args.SourceIdx),Ydata(Args.SourceIdx),'p','MarkerSize',10,'MarkerFaceColor','cyan','MarkerFaceColor','black')
semilogy(xdata(NewIdx),ydata(NewIdx),'p','MarkerSize',10,'MarkerFaceColor','cyan','MarkerFaceColor','black')




Leg = legend('No zp','ZP','SysRem',['rms zp = ',num2str(Ydata(Args.SourceIdx))],['rms sys = ',num2str(ydata(NewIdx))],'Location','best');
title('RMS MAG PSF')
pause(2)
close();






%% plot a source to check it

if Args.plot

    t = datetime(ms.JD,'convertfrom','jd');
    y_zp = MS.Data.(Args.MagField)(:,Args.SourceIdx);
    Npts  = sum(~isnan(y_zp));
    t     = t(~isnan(y_zp));
    y_zp  = y_zp(~isnan(y_zp));
    Med   = median(y_zp,'omitnan');
    sigma = std(y_zp,'omitnan');
    
    threshold = Args.threshold*sigma;
    
    MarkedEvents = [];
    
    for Ipt = 1 : length(y_zp) - 1
        
        if abs(y_zp(Ipt) - Med) > threshold
            
            if abs(y_zp(Ipt+1) - Med) > threshold
                
                MarkedEvents = [MarkedEvents ; Ipt, Ipt+1];
                
            end
        end
    end
    
    
    
    if ~isempty(MarkedEvents)
        
        
    end
        
    


    figure('Color','white','Units', 'inches', 'Position', [0, 0, 10, 4]);
    plot(t,y_zp,'cs')

    hold on
    threshold_values = [Med-threshold, Med , Med+ threshold];
    
    if ~isnan(Med)
        

        for i = 1:length(threshold_values)
           if i == 2
               yline(threshold_values(i), '-', 'Color', [0.05 0.05 0.05],'DisplayName','Median'); % '--' for dashed style, 'r' for red color
           else
              
            
               yline(threshold_values(i), '--', 'Color', [0.65 0.65 0.65],'DisplayName','Threshold'); % '--' for dashed style, 'r' for red color
           end
        
        end
    end
        
    if ~isempty(MarkedEvents)
        MarkedEvents = reshape(MarkedEvents,1,[]);
        
       plot(t(MarkedEvents),y_zp(MarkedEvents),'ro','MarkerSize',8)
        
    end

    
    y_sys = ms.Data.MAG_PSF(:,NewIdx);
    
    Meds   = median(y_sys,'omitnan');
    sigmas = std(y_sys,'omitnan');
    
    y_sys  = y_sys(~isnan(y_sys));
    plot(t,y_sys,'k.')
    thresholds = Args.threshold*sigmas;
    
    MarkedEventss = [];
    
    for Ipt = 1 : length(y_sys) - 1
        
        if abs(y_sys(Ipt) - Meds) > thresholds
            
            if abs(y_sys(Ipt+1) - Meds) > thresholds
                
                MarkedEventss = [MarkedEventss ; Ipt, Ipt+1];
                
            end
        end
    end
    
    if ~isempty(MarkedEventss)
        MarkedEventss = reshape(MarkedEventss,1,[])
        
       plot(t(MarkedEventss),y_sys(MarkedEventss),'ro','MarkerSize',8)
        
    end
hold off
Title  = sprintf('%s $G_{B_p}$ = %.2f ',Args.Serial,Args.WD.G_Bp(Args.wdIdx));
title(Title,'Interpreter','latex');

 lglbl{1} = sprintf('ZP rms = %.3f',sigma);
 lglbl{2} = sprintf('SysRem rms = %.3f',sigmas);
 legend(lglbl{1},num2str(threshold_values(1)),num2str(threshold_values(2)),num2str(threshold_values(3)),lglbl{2},'Interpreter','latex','Location','best')
%title('MAG_PSF LC')
pause(5)
close();

Event = false;

if (~isempty(MarkedEventss)) | (~isempty(MarkedEvents))
    
         Event = true;
         figure('Color','white');
         plot(t,y_zp,'cs')
         hold on
         plot(t,y_sys,'k.')
         
         lglbl{1} = sprintf('ZP rms = %.3f',sigma)
         lglbl{2} = sprintf('SysRem rms = %.3f',sigmas)
         legend(lglbl{1:2},'Interpreter','latex','Location','best')
         plot(t(MarkedEventss),y_sys(MarkedEventss),'ro','MarkerSize',8,'DisplayName','Events zp')
         plot(t(MarkedEvents),y_zp(MarkedEvents),'mo','MarkerSize',8,'DisplayName','Events sysrem')
         
         set(gca,'YDir','reverse')
         B_p = Args.WD.G_Bp(Args.wdIdx);
         coords = [Args.WD.RA(Args.wdIdx),Args.WD.Dec(Args.wdIdx)];
         WDname = Args.WD.Name(Args.wdIdx,1:8);
         Title  = sprintf('%s $G_{B_p}$ = %.2f ; (ra,dec) = %.3f , %.3f',WDname,B_p,coords(1),coords(2))
         title(Title,'Interpreter','latex')
         xlabel('Time','Interpreter','latex')
         ylabel('Magnitude','Interpreter','latex')
         
         
         save_to   = Args.SaveTo % '/home/ocs/Documents/WD_survey/Thesis/'
         file_name = [Args.Serial,'.png']

         save(gca,[save_to,file_name]) ;
         pause(5)
         close();

end




end



% Results statis

