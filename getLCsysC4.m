function [ms,Event,Npts,STD,STDs] = getLCsysC4(MatchedSource,Args)

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
    Args.SigmaClip = false;
    Args.SDcluster = false; 
    Args.ErrorBars = true;
    Args.Title     = {};
    Args.SaveLC    = false;
    
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

%figure('Color','white');


%RMSzp = MS.plotRMS('FieldX','MAG_PSF','plotColor',[0.9 0.9 0.9],'PlotSymbol',['x']);
%Xdata = RMSzp.XData;
%Ydata = RMSzp.YData;

%hold on

%model.plotRMS('FieldX','MAG_PSF','plotColor',"#80B3FF",'PlotSymbol',['.']);
% semilogy(Xdata(~NaNcut),Ydata(~NaNcut),'b.')

ms.sysrem('MagFields' ,{'MAG_PSF'} , 'MagErrFields',{'MAGERR_PSF'},'sysremArgs',{'Niter',2});

%RMSsys = ms.plotRMS('FieldX','MAG_PSF','plotColor',[0.25, 0.25, 0.25],'PlotSymbol',['.']);
%xdata  = RMSsys.XData;
%ydata  = RMSsys.YData;

%clear MS
% Mark your WD
%semilogy(Xdata(Args.SourceIdx),Ydata(Args.SourceIdx),'p','MarkerSize',10,'MarkerFaceColor',[0.7350, 0.1780, 0.2840],'MarkerFaceColor',[0.7350, 0.1780, 0.2840])
%semilogy(xdata(NewIdx),ydata(NewIdx),'p','MarkerSize',10,'MarkerFaceColor',[0.7350, 0.1780, 0.2840],'MarkerFaceColor',[0.7350, 0.1780, 0.2840])




%Leg = legend('No zp','ZP','SysRem',['rms zp = ',num2str(Ydata(Args.SourceIdx))],['rms sys = ',num2str(ydata(NewIdx))],'Location','best');
%title('RMS MAG PSF','Interpreter','latex')
%pause(1)
%close();






%% calc by sigma clip

if Args.SigmaClip






    t = datetime(ms.JD,'convertfrom','jd');
    [~,s] = sort(t);
    t = t(s);
    y_zp = MS.Data.(Args.MagField)(s,Args.SourceIdx);
    y_zpErr = MS.Data.(Args.MagErrField)(s,Args.SourceIdx);
    Npts  = sum(~isnan(y_zp));
    
    
    
    
 if Npts > 19
    t     = t(~isnan(y_zp));
    y_zp  = y_zp(~isnan(y_zp));
    Med   = median(y_zp,'omitnan');
    sigma = std(y_zp,'omitnan');
    [newM,newS] = SigmaClips(y_zp,'SigmaThreshold',2.5,'MeanClip',false);
    threshold = Args.threshold*newS;
    MarkedEvents = [];
    
    for Ipt = 1 : length(y_zp) - 1
        
        if abs(y_zp(Ipt) -  newM) > threshold
            
            if abs(y_zp(Ipt+1) - newM) > threshold
                
                MarkedEvents = [MarkedEvents ; Ipt, Ipt+1];
                
            end
        end
    end
    
    
    
    
    
    if ~isempty(MarkedEvents)
        
        mm = reshape(MarkedEvents,1,[]);
        
        d = y_zp;
        for Ie = 1 : numel(mm)
            
            d(mm(Ie)) = NaN;
            
        end
            
        newsd = std(d,'omitnan');
        
        
    end
        
    %[newM,newS] = SigmaClips(y_zp,'SigmaThreshold',3,'MeanClip',false);


    figure('Color','white','Units', 'inches', 'Position', [0, 0, 14, 6]);
    plot(t,y_zp,'cs')

    hold on
    threshold_values0 = [Med-Args.threshold*sigma, Med , Med+ Args.threshold*sigma];
    
    if ~isnan(Med)
        

        for i = 1:length(threshold_values0)
           if i == 2
               yline(threshold_values0(i), '-.', 'Color', [0.05 0.05 0.05],'DisplayName','Median'); % '--' for dashed style, 'r' for red color
           else
              
            
               yline(threshold_values0(i), '--', 'Color', [0.65 0.65 0.65],'DisplayName','Threshold'); % '--' for dashed style, 'r' for red color
           end
        
        end
    end
        
    
    threshold_values = [newM-threshold, newM , newM+ threshold];
    if ~isnan(newM)
        

        for i = 1:length(threshold_values)
           if i == 2
               yline(threshold_values(i), '-', 'Color', [240, 0, 0] / 255,'DisplayName','new Median'); % '--' for dashed style, 'r' for red color
           else
              
            
               yline(threshold_values(i), '--', 'Color', [200, 0, 0] / 255,'DisplayName','New Threshold'); % '--' for dashed style, 'r' for red color
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
       
        mm = MarkedEventss;
        
        d = y_sys;
        for Ie = 1 : numel(mm)
            
            d(mm(Ie)) = NaN;
            
        end
            
        newsd1 = std(d,'omitnan');
    
        
    end
    plot(t,y_zp,'-o','Color',[0.8 0.8 0.8])
hold off
Title  = sprintf('$ %s \\  G_{B_p} = %.2f $',Args.Serial,Args.WD.G_Bp(Args.wdIdx));
title(Title,'Interpreter','latex');
set(gca,'YDir','reverse')
 lglbl{1} = sprintf('ZP rms = %.3f Clipped RMS = %.3f',sigma,newS);
 lglbl{2} = sprintf('SysRem rms = %.3f',sigmas);
 lglbl{4} = sprintf('Med - $2.5 \\sigma  $ = %.2f',threshold_values0(1));
 lglbl{3} = sprintf('Median = %.2f',Med);
 lglbl{5} = sprintf('Med +$2.5 \\sigma  $ = %.2f',threshold_values0(3));
 lglbl{6} = sprintf('ClipMed - $2.5 \\sigma  $  = %.2f ',threshold_values(1));
 lglbl{7} = sprintf('Clipped Median = %.2f',newM);
 lglbl{8} = sprintf('ClipMed + $2.5 \\sigma $  = %.2f',threshold_values(3));
 %legend(lglbl{1},num2str(threshold_values(1)),num2str(threshold_values(2)),num2str(threshold_values(3)),lglbl{2},'Interpreter','latex','Location','best')
legend(lglbl{1},lglbl{4},lglbl{3},lglbl{5},lglbl{6},lglbl{7},lglbl{8},lglbl{2},'Interpreter','latex','Location','southeast')

 
 %title('MAG_PSF LC')
pause(1)
%close();

Event = false;

if exist('newsd','var') == 1
    
else
    
    newsd = NaN;
    
end
if exist('newsd1','var') == 1
    
else
    
    newsd1 = NaN;
    
end

if (~isempty(MarkedEventss)) | (~isempty(MarkedEvents))
    
         Event = true;
         figure('Color','white','Units', 'inches', 'Position', [0, 0, 14, 8]);
         plot(t,y_zp,'cs')
         hold on
         plot(t,y_sys,'k.')
         
         lglbl{1} = sprintf('ZP rms = %.3f  or %.3f',sigma,newS)
         lglbl{2} = sprintf('SysRem rms = %.3f or %.3f',sigmas,newsd1)
         legend(lglbl{1:2},'Interpreter','latex','Location','southeast')
         plot(t(MarkedEventss),y_sys(MarkedEventss),'ro','MarkerSize',8,'DisplayName','Events zp')
         plot(t(MarkedEvents),y_zp(MarkedEvents),'mo','MarkerSize',8,'DisplayName','Events sysrem')
         
         if ~isnan(Med)
        

        for i = 1:length(threshold_values)
           if i == 2
               yline(threshold_values(i), '-', 'Color', [0.05 0.05 0.05],'DisplayName','Median'); % '--' for dashed style, 'r' for red color
           else
              
            
               yline(threshold_values(i), '--', 'Color', [0.65 0.65 0.65],'DisplayName','Threshold'); % '--' for dashed style, 'r' for red color
           end
        
        end
    end
         plot(t,y_zp,'-o','Color',[0.8 0.8 0.8])
         set(gca,'YDir','reverse')
         B_p = Args.WD.G_Bp(Args.wdIdx);
         coords = [Args.WD.RA(Args.wdIdx),Args.WD.Dec(Args.wdIdx)];
         WDname = Args.WD.Name(Args.wdIdx,1:8);
         Title  = sprintf('$ %s \\ %s \\ G_{B_p} = %.2f \\ ; \\ (ra,dec) = %.3f , %.3f $',WDname,Args.Serial,B_p,coords(1),coords(2))
         tit = title(Title,'Interpreter','latex')
   
         xlabel('Time','Interpreter','latex')
         ylabel('Magnitude','Interpreter','latex')
         
         
         save_to   = Args.SaveTo % '/home/ocs/Documents/WD_survey/Thesis/'
         file_name = [Args.Serial,'.png'];
         sfile = strcat(save_to,file_name);
         sfile= strrep(sfile, ' ', '');


         sfile = strrep(sfile, '\', '_');
          sfile = strrep(sfile, '+', '_')

         saveas(gcf,sfile) ;
         pause(1)
         %close();
         
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
title('RMS MAG PSF','Interpreter','latex')
pause(1)

file_name = [Args.Serial,'_RMSplot.png']
sfile = strcat(save_to,file_name);
sfile= strrep(sfile, ' ', '');


         sfile = strrep(sfile, '\', '_');
          sfile = strrep(sfile, '+', '_')

saveas(gcf,sfile) ;
close();




         

end

if Npts > 19

if isnan(newsd)
    STD = sigma;
else
    STD =newsd;
    
end

if isnan(newsd1)
    STDs = sigmas;
else
    STDs =newsd1;
    
end



 else
     STD = NaN;
     STDs = NaN;
     Event = 0;
end

 else
     
     STD = NaN;
     STDs = NaN;
     Event =0;



 end
end


if Args.SDcluster
%% Get ZP data    
    t = datetime(ms.JD,'convertfrom','jd');
    [~,s] = sort(t);
    t = t(s);
    y_zp = MS.Data.(Args.MagField)(s,Args.SourceIdx);
    
    y_zpErr = MS.Data.(Args.MagErrField)(s,Args.SourceIdx);
    Npts  = sum(~isnan(y_zp));
    
    
    
%% Find out if data is good    
 if Npts > 19
    GoodPoints = ~isnan(y_zp);
    t     = t(GoodPoints);

    y_zpErr = y_zpErr(GoodPoints);
    y_zp  = y_zp(GoodPoints);
    Med   = median(y_zp,'omitnan');
    % Full Sigma
    sigma = std(y_zp,'omitnan');
    % Sigma Clipped Sigma - present
    [newM,newS] = SigmaClips(y_zp,'SigmaThreshold',3,'MeanClip',false);
    % [Threshold,CC] =  clusteredSD(MS,'MedInt',newM,'ExtData',true,'Color',Args.WD.Color(Args.wdIdx));
    % General Sigma.
    [Threshold,~] =  clusteredSDclipped(MS,'MedInt',newM,'ExtData',false);
    % Going with threshold of General Sigma
    threshold = Threshold*Args.threshold ;

%% Look for Events
%   With Sigma-Clipped Median
    MarkedEvents = [];
    
    for Ipt = 1 : length(y_zp) - 1
        
        if abs(y_zp(Ipt) -  newM) > threshold
            
            if abs(y_zp(Ipt+1) - newM) > threshold
                
                MarkedEvents = [MarkedEvents ; Ipt, Ipt+1];
                
            end
        end
    end
    
    
    if ~isempty(MarkedEvents)
        sfile= strrep([Args.Serial(1,:),'__ZP'], ' ', '');
        sfile = strrep(sfile, '\', '-');
         sfile = strrep(sfile, '+', '_')
        writeToLog(sfile, [Args.SaveTo,'Log_Report'])
        MarkedEvents = reshape(MarkedEvents,1,[]);
        
       %plot(t(MarkedEventss),y_sys(MarkedEventss),'ro','MarkerSize',8)
  
        mm = MarkedEvents;
        
        dd = y_zp;
        for Ie = 1 : numel(mm)
            
            dd(mm(Ie)) = NaN;
            
        end
            
        newsd = std(dd,'omitnan');
    
    end 
    
    
   lglbl{1} = sprintf('ZP rms = %.3f General RMS = %.3f',newS,Threshold);
 

    figure('Color','white','Units', 'inches', 'Position', [0, 0, 8, 14]);
    if Args.ErrorBars
       h1 = errorbar(t,y_zp,y_zpErr, '.', 'MarkerFaceColor', [0.75, 0.75, 0.75], 'MarkerEdgeColor', [0.75, 0.75, 0.75], 'Color', [0.75, 0.75, 0.75],...
           'DisplayName',lglbl{1});
    else
       h1 = plot(t,y_zp,'.','Color',[0.75, 0.75, 0.75],'DisplayName',lglbl{1})
    end

    hold on
    threshold_values0 = [Med-Args.threshold*newS, Med , Med+ Args.threshold*newS];
    
    if ~isnan(Med)
        

        for i = 1:length(threshold_values0)
           if i == 2
               yline(threshold_values0(i), '-.', 'Color', [0.05 0.05 0.05]); % '--' for dashed style, 'r' for red color
           elseif i == 3
              
            
               yline(threshold_values0(i), '--', 'Color', [0.65 0.65 0.65]); % '--' for dashed style, 'r' for red color
           end
        
        end
    end
        
    
    threshold_values = [newM-threshold, newM , newM+ threshold];
    if ~isnan(newM)
        

        for i = 1:length(threshold_values)
           if i == 2
               yline(threshold_values(i), '-', 'Color', [105, 0, 0] / 255); % '--' for dashed style, 'r' for red color
           elseif i== 3
              
            
               yline(threshold_values(i), '--', 'Color', [85, 0, 0] / 255); % '--' for dashed style, 'r' for red color
           end
        
        end
    end   
    
   %% SysRem 
    
    y_sys = ms.Data.MAG_PSF(:,NewIdx);
    y_sysErr = ms.Data.(Args.MagErrField)(:,NewIdx);
    GoodPoints1 = ~isnan(y_sys);
    ts     = ms.JD(GoodPoints1);

    y_sysErr = y_sysErr(GoodPoints1);
    y_sys  = y_sys(GoodPoints1);

    Meds   = median(y_sys,'omitnan');
    sigmas = std(y_sys,'omitnan');
    % Sigma Clipped Sigma - present
    [newMs,newSs] = SigmaClips(y_sys,'SigmaThreshold',3,'MeanClip',false);
    % [Threshold,CC] =  clusteredSD(MS,'MedInt',newM,'ExtData',true,'Color',Args.WD.Color(Args.wdIdx));
    % General Sigma.
     [Thresholds,~] =  clusteredSDclipped(ms,'MedInt',newMs,'ExtData',false,'Sys',true,'ZP',true);
    % Going with threshold of General Sigma
    thresholds = Thresholds*Args.threshold ;
    %[Thresholds,~] =  clusteredSD(ms,'MedInt',newMs,'ExtData',true,'Sys',true,'Color',Args.WD.Color(Args.wdIdx),'CC',CC); % with color term
     
    lglbl{2} = sprintf('SysRem rms = %.3f General RMS = %.3f;',newSs,Thresholds);

    
    if Args.ErrorBars
      h2 =  errorbar(t,y_sys,y_sysErr, '.', 'MarkerFaceColor', [0.1, 0.1, 0.1], 'MarkerEdgeColor', [0.1, 0.1, 0.1], 'Color', [0.1, 0.1, 0.1],...
         'DisplayName',lglbl{2});
    else
       h2 =  plot(t,y_sys,'.','Color',[0.25 0.25 0.25],'DisplayName',lglbl{2})
    end
    
    
    if ~isempty(MarkedEvents)
        MarkedEvents = reshape(MarkedEvents,1,[]);
        
       plot(t(MarkedEvents),y_zp(MarkedEvents),'o','MarkerSize',8,'Color',[0.25 0.25 0.25])
        
    end
    
    

  %%
  
  
    
    MarkedEventss = [];
    
    for Ipt = 1 : length(y_sys) - 1
        
        if abs(y_sys(Ipt) - newMs) > thresholds
            
            if abs(y_sys(Ipt+1) - newMs) > thresholds
                
                MarkedEventss = [MarkedEventss ; Ipt, Ipt+1];
                
            end
        end
    end
    
    if ~isempty(MarkedEventss)
        sfile= strrep([Args.Serial(1,:),'__SysRem'], ' ', '');
        sfile = strrep(sfile, '\', '-');
         sfile = strrep(sfile, '+', '_')
        writeToLog(sfile, [Args.SaveTo,'Log_Report'])
        MarkedEvents = reshape(MarkedEvents,1,[]);
        MarkedEventss = reshape(MarkedEventss,1,[]);
        
       plot(t(MarkedEventss),y_sys(MarkedEventss),'ro','MarkerSize',8)
  
        mm = MarkedEventss;
        
        d = y_sys;
        for Ie = 1 : numel(mm)
            
            d(mm(Ie)) = NaN;
            
        end
            
        newsd1 = std(d,'omitnan');
    
    end
    % plot(t,y_zp,'-o','Color',[0.8 0.8 0.8])
hold off


if isempty(Args.Title)
    Title  = sprintf('$ %s \\  G_{B_p} = %.2f $',Args.Serial,Args.WD.G_Bp(Args.wdIdx));
    title(Title,'Interpreter','latex');
else
  Title  = sprintf(Args.Title);
    title(Title,'Interpreter','latex','FontSize',18);
end
set(gca,'YDir','reverse')
 %lglbl{1} = sprintf('ZP rms = %.3f General RMS = %.3f',newS,Threshold);
 %lglbl{2} = sprintf('SysRem rms = %.3f General RMS = %.3f;',newSs,Thresholds);
% lglbl{4} = sprintf('Med - $2.5 \\sigma  $ = %.2f',threshold_values0(1));
% lglbl{3} = sprintf('Median = %.2f',Med);
% lglbl{5} = sprintf('Med +$2.5 \\sigma  $ = %.2f',threshold_values0(3));
% lglbl{6} = sprintf('$Med_{Clipped}$ - $2.5 \\sigma_{mag}  $  = %.2f ',threshold_values(1));
% lglbl{7} = sprintf('Clipped Median = %.2f',newM);
% lglbl{8} = sprintf('$Med_{{Clipped}}$ + $2.5 \\sigma_{{mag}} $  = %.2f',threshold_values(3));
 % legend(lglbl{1},num2str(threshold_values(1)),num2str(threshold_values(2)),num2str(threshold_values(3)),lglbl{2},'Interpreter','latex','Location','best')
%legend(lglbl{1},lglbl{4},lglbl{3},lglbl{5},lglbl{6},lglbl{7},lglbl{8},lglbl{2},'Interpreter','latex','Location','eastoutside','box','off')
  text(0.25,0.95, Args.WD.Name(Args.wdIdx,:),'Units', 'normalized', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top',...
      'FontSize',16,'Interpreter', 'latex');
 legend([h1 h2],'Interpreter','latex','Location','southeast','box','off')

 %title('MAG_PSF LC')
%pause(1)
%close();

Event = false;

if exist('newsd','var') == 1
    
else
    
    newsd = std(y_zp,'omitnan');
    
end
if exist('newsd1','var') == 1
    
else
    
    newsd1 = std(y_sys,'omitnan');
    
end

if Args.SaveLC
    Ysys = [y_sys y_sysErr ms.JD(GoodPoints1)];
    %;
    MD ={};
    MD.name = Args.WD.Name(Args.wdIdx,:);
    MD.Bp = Args.WD.G_Bp(Args.wdIdx)
    MD.Coords = [Args.WD.RA(Args.wdIdx) Args.WD.Dec(Args.wdIdx)];
    MD.Serial = Args.Title;
    MD.GeneralRMS  = Thresholds;
    MD.Events     = {MarkedEventss,length(MarkedEventss)};

    MD.LC  = Ysys;
    save_to   = Args.SaveTo; % '/home/ocs/Documents/WD_survey/Thesis/'
   file_name = ['sys_',Args.Serial,'LC.mat'];
         sfile = strcat(save_to,file_name);
         sfile= strrep(sfile, ' ', '');
         sfile = strrep(sfile, '\', '_');
         sfile = strrep(sfile, '+', '_');
    save(sfile,'MD','-v7.3')


     Yzp = [y_zp y_zpErr MS.JD(GoodPoints)];
    MJ ={};
    MJ.name = Args.WD.Name(Args.wdIdx,:);
    MJ.Bp = Args.WD.G_Bp(Args.wdIdx)
    MJ.Coords = [Args.WD.RA(Args.wdIdx) Args.WD.Dec(Args.wdIdx)];
    MJ.Serial = Args.Title;
    MJ.GeneralRMS  = Threshold;
    MJ.Events     = {MarkedEvents,length(MarkedEvents)};
    MD.LC  = Ysys;
   save_to   = Args.SaveTo; % '/home/ocs/Documents/WD_survey/Thesis/'
   file_name = ['z_',Args.Serial,'LCzp.mat'];
         sfile = strcat(save_to,file_name);
         sfile= strrep(sfile, ' ', '');
         sfile = strrep(sfile, '\', '_');
          sfile = strrep(sfile, '+', '_')
    save(sfile,'Yzp','-v7.3')


 


end

if (~isempty(MarkedEventss)) | (~isempty(MarkedEvents))
    
         Event = true;
         %figure('Color','white','Units', 'inches', 'Position', [0, 0, 14, 8]);
         %plot(t,y_zp,'cs')
         %hold on
         %plot(t,y_sys,'k.')
         
         %lglbl{1} = sprintf('ZP rms = %.3f  or %.3f',sigma,newS)
         %lglbl{2} = sprintf('SysRem rms = %.3f or %.3f',sigmas,newsd1)
         %legend(lglbl{1:2},'Interpreter','latex','Location','best')
         %plot(t(MarkedEventss),y_sys(MarkedEventss),'ro','MarkerSize',8,'DisplayName','Events zp')
         %plot(t(MarkedEvents),y_zp(MarkedEvents),'mo','MarkerSize',8,'DisplayName','Events sysrem')
         
         %if ~isnan(Med)
        

        %for i = 1:length(threshold_values)
           %if i == 2
           %    yline(threshold_values(i), '-', 'Color', [0.05 0.05 0.05],'DisplayName','Median'); % '--' for dashed style, 'r' for red color
          % else
              
            
         %      yline(threshold_values(i), '--', 'Color', [0.65 0.65 0.65],'DisplayName','Threshold'); % '--' for dashed style, 'r' for red color
         %  end
        
        %end
        %end
        
        
         %plot(t,y_zp,'-o','Color',[0.8 0.8 0.8])
         %set(gca,'YDir','reverse')
         %B_p = Args.WD.G_Bp(Args.wdIdx);
         %coords = [Args.WD.RA(Args.wdIdx),Args.WD.Dec(Args.wdIdx)];
         %WDname = Args.WD.Name(Args.wdIdx,1:8);
         %Title  = sprintf('$ %s \\ %s \\ G_{B_p} = %.2f \\ ; \\ (ra,dec) = %.3f , %.3f $',WDname,Args.Serial,B_p,coords(1),coords(2))
         %tit = title(Title,'Interpreter','latex')
   
  %       xlabel('Time','Interpreter','latex')
   %      ylabel('Magnitude','Interpreter','latex')
         
         
         save_to   = Args.SaveTo; % '/home/ocs/Documents/WD_survey/Thesis/'
         file_name = [Args.Serial,'.png'];
         sfile = strcat(save_to,file_name);
         sfile= strrep(sfile, ' ', '');


         sfile = strrep(sfile, '\', '_');
          sfile = strrep(sfile, '+', '_')
         

         saveas(gcf,sfile) ;
         %pause(5)
         %close();
figure('Color','white');


RMSzp = MS.plotRMS('FieldX','MAG_PSF','plotColor',[0.9 0.9 0.9],'PlotSymbol',['x']);
Xdata = RMSzp.XData;
Ydata = RMSzp.YData;

hold on

model.plotRMS('FieldX','MAG_PSF','plotColor',"#80B3FF",'PlotSymbol',['.']);
% semilogy(Xdata(~NaNcut),Ydata(~NaNcut),'b.')

ms.sysrem('MagFields' ,{'MAG_PSF'} , 'MagErrFields',{'MAGERR_PSF'},'sysremArgs',{'Niter',2});

RMSsys = ms.plotRMS('FieldX','MAG_PSF','plotColor',[0.25, 0.25, 0.25],'PlotSymbol',['.']);
xdata  = RMSsys.XData;
ydata  = RMSsys.YData;

%clear MS
% Mark your WD
semilogy(Xdata(Args.SourceIdx),Ydata(Args.SourceIdx),'p','MarkerSize',10,'MarkerFaceColor','red','MarkerFaceColor','red')
semilogy(xdata(NewIdx),ydata(NewIdx),'p','MarkerSize',10,'MarkerFaceColor','red','MarkerFaceColor','red')




Leg = legend('No zp','ZP','SysRem',['rms zp = ',num2str(Ydata(Args.SourceIdx))],['rms sys = ',num2str(ydata(NewIdx))],'Location','SouthEast');
title('RMS MAG PSF','Interpreter','latex')
%pause(2)





file_name = [Args.Serial,'_RMSplot.png']
sfile = strcat(save_to,file_name);
sfile= strrep(sfile, ' ', '');


         sfile = strrep(sfile, '\', '_');
          sfile = strrep(sfile, '+', '_')

saveas(gcf,sfile) ;
close();

         
      
else 
    
    close();

         

end

if Npts > 19

if isnan(newsd)
    STD = sigma;
else
    STD =newsd;
    
end

if isnan(newsd1)
    STDs = sigmas;
else
    STDs =newsd1;
    
end



 else
     STD = NaN;
     STDs = NaN;
     Event = 0;
end

 else
     
     STD = NaN;
     STDs = NaN;
     Event =0;



 end
    
    
end
 
end
% Results statis

