% Example how to handle a WDs class

% Initilize targetList. one day it will use catHTM
Names = [
'WDJ043112.57+585841.29',
'WDJ042726.57+581938.07',
'WDJ043342.80+585555.40',
'WDJ043323.50+582415.76',
]

TargetList = [
67.81967272041223	58.96513235636069	12.33619	12.493927	12.051627
66.86106556261191	58.326540314193174	18.145452	18.383633	17.782572
68.42822874877491	58.93208919614751	18.404922	18.47761	18.406345
68.34820888702602	58.40401267107105	18.931223	19.053305	18.898142
];






% First initilize with Path,Name,RA,DEC,.....

Pathway = '/last10w/data1/archive/LAST.01.10.03/2024/01/08/proc/184118v0'

e = WDs(Pathway,Names,TargetList(:,1)	,TargetList(:,2)	,TargetList(:,3)    ,TargetList(:,4)	,TargetList(:,5),'Batch',2)


%%

g = WDs(Pathway,Names,TargetList(8,1)	,TargetList(8,2)	,TargetList(8,3)    ,TargetList(8,4)	,TargetList(8,5),'Batch',2)



%% Example of RMSplot for a target
for Iobj = 1 : e.Nsrc
    
    Isubframe = e.Data.Catalog.CatID{Iobj};
    
    if ~isempty(Isubframe)
        
        for Iiter = 1 : length(Isubframe)
    
            
    
            figure('color','white');
            subplot(1,2,1)
                        
            e.Data.Catalog.MS{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','o','PlotColor','#D95319')
            wdID = e.Data.Catalog.PSF{Iobj,Iiter}.coneSearch(e.RA(Iobj),e.Dec(Iobj)).Ind;
            hold on
            
            p = e.Data.Catalog.PSF{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','s','PlotColor','blue')
            
            ax = p.XData;
            ay = p.YData;
            %ax = e.Data.Catalog.PSF{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','s','PlotColor','blue').XData ;
            %ay = e.Data.Catalog.PSF{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','s','PlotColor','blue').YData
            
            e.Data.Catalog.PSFsys{Iobj,Iiter} =  e.Data.Catalog.PSF{Iobj,Iiter}.copy()
            %E.Data.Catalog.PSFsys{Iobj,Iiter}.sysrem('MagFields' ,{'MAG_PSF'} , 'MagErrFields',{'MAGERR_PSF'})
            %E.Data.Catalog.PSFsys{Iobj,Iiter}.sysrem('MagFields' ,{'MAG_PSF'} , 'MagErrFields',{'MAGERR_PSF'})
            e.Data.Catalog.PSFsys{Iobj,Iiter}.sysrem('sysremArgs',{'Niter',2},'MagFields' ,{'MAG_PSF'} , 'MagErrFields',{'MAGERR_PSF'});
            hold on
            
            wdIDsys = e.Data.Catalog.PSFsys{Iobj,Iiter}.coneSearch(e.RA(Iobj),e.Dec(Iobj)).Ind;

            psys = e.Data.Catalog.PSFsys{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','.','PlotColor','black')
            bx = psys.XData;
            by = psys.YData;
            %bx = e.Data.Catalog.PSFsys{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','.','PlotColor','black').XData
            %by = e.Data.Catalog.PSFsys{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','.','PlotColor','black').YData
            
            plot(ax(wdID),ay(wdID),'o','Markersize',5,"MarkerFaceColor","#FF8800")
            plot(bx(wdIDsys),by(wdIDsys),'+','Markersize',10,"MarkerFaceColor","#FF8800")
            
            
            
            
            hline(0.2);
            xline(19,'color','r');
            
            legend('Mag PSF before ZP','Mag PSF after ZP','SysRem 2 Iter',...
                sprintf('zp ; rms = %.3f, Mag = %.3f , $B_p$ = %.2f ',ay(wdID),...
                ax(wdID),e.G_Bp(Iobj)),...
                sprintf('sysrem ; rms = %.3f, Mag = %.3f , $G$ = %.2f ',by(wdIDsys),bx(wdIDsys),e.G_g(Iobj)),...
                'SNR = 5','MAG = 19','Interpreter','latex','Location','best')
            title(sprintf('Catalog RMS (PSF) ; CropID %i ',Isubframe(Iiter)),'Interpreter','latex','FontSize',10)
            xlim([10,20])
            ylim([5e-3,1.2])
            
            ax = gca;
            ax.FontSize = 12;
            ax.TickLabelInterpreter = 'latex'

            subplot(1,2,2)
            
                        
            e.Data.Catalog.MS{Iobj,Iiter}.plotRMS('FieldX','MAG_APER_2','PlotSymbol','o','PlotColor','#D95319')
            hold on
            p = e.Data.Catalog.APER_2{Iobj,Iiter}.plotRMS('FieldX','MAG_APER_2','PlotSymbol','s','PlotColor','blue');
           
            ax = p.XData;
            ay = p.YData;
            wdIDaper = e.Data.Catalog.APER_2{Iobj,Iiter}.coneSearch(e.RA(Iobj),e.Dec(Iobj)).Ind;

            
            e.Data.Catalog.APERsys{Iobj,Iiter} =  e.Data.Catalog.APER_2{Iobj,Iiter}.copy()
            %E.Data.Catalog.APERsys{Iobj,Iiter}.sysrem('MagFields' ,{'MAG_APER_2'} , 'MagErrFields',{'MAGERR_APER_2'})
            %E.Data.Catalog.APERsys{Iobj,Iiter}.sysrem('MagFields' ,{'MAG_APER_2'} , 'MagErrFields',{'MAGERR_APER_2'})
            e.Data.Catalog.APERsys{Iobj,Iiter}.sysrem('MagFields' ,{'MAG_APER_2'} , 'MagErrFields',{'MAGERR_APER_2'},'sysremArgs',{'Niter',2});

            
            
            hold on
                        
            p = e.Data.Catalog.APERsys{Iobj,Iiter}.plotRMS('FieldX','MAG_APER_2','PlotSymbol','.','PlotColor','black');
        
            wdIDsys = e.Data.Catalog.APERsys{Iobj,Iiter}.coneSearch(e.RA(Iobj),e.Dec(Iobj)).Ind;
            bx = p.XData;
            by = p.YData;
             
            
            plot(ax(wdIDaper),ay(wdIDaper),'o','Markersize',5,"MarkerFaceColor","#FF8800")
            plot(bx(wdIDsys),by(wdIDsys),'+','Markersize',10,"MarkerFaceColor","#FF8800")
            
            hline(0.2);
            xline(19,'color','r');
            
            legend('Mag PSF before ZP','Mag PSF after ZP','SysRem 2 Iter',...
                sprintf('zp ; rms = %.3f, Mag = %.3f , $B_p$ = %.2f ',ay(wdIDaper),...
                ax(wdIDaper),e.G_Bp(Iobj)),...
                sprintf('sysrem ; rms = %.3f, Mag = %.3f , $G$ = %.2f ',by(wdIDsys),bx(wdIDsys),e.G_g(Iobj)),...
                'SNR = 5','MAG = 19','Interpreter','latex','Location','best')
            title(sprintf('MAG APER 2 ; %s $B_p-R_p$ =  %.3f ',e.Name(Iobj,[1:7 13:17]),e.Color(Iobj)),'Interpreter','latex','FontSize',10)
         
            %legend('Mag APER 2 before ZP','Mag APER 2 after ZP','SysRem 2 Iter','SNR = 5','MAG = 19','Interpreter','latex','Location','best')
            %title(sprintf('RMS (MAG APER 2)  '),'Interpreter','latex')
            xlim([10,20])
            ylim([5e-3,1.2])
            
            ax = gca;
            ax.FontSize = 12;
            ax.TickLabelInterpreter = 'latex'
            
            set(gcf, 'Position', get(0, 'ScreenSize'));
            pause(5);
            filename = ['~/Documents/WD/080124/T3/wd_',num2str(Iobj),'_RMS_catalog.png']
%saveas(gcf, filename)

            
            
        end
    end
    
end



%% Lim MAG of obs

[times_vec,LimMag_vec] = e.Header_LimMag(e)

%% Catalog - 2 visits - LC
cd(e.Path)
cd ../


for Iobj = 1 : e.Nsrc
    
    
    
    if e.Data.Catalog.InCat(Iobj)
                    
                    
                     if length(e.Data.Catalog.CatID{Iobj}) == 1
                
                           Ls = MatchedSources.rdirMatchedSourcesSearch('CropID',e.Data.Catalog.CatID{Iobj}(1));      
                           ms = MatchedSources.readList(Ls);
                           TimeTag = {};
                           
                           for Ivisit = 1 : length(Ls.FileName)
                               
                               TimeTag{1,Ivisit} =  Ls.FileName{Ivisit}(1,15:29);
                           
                               
                           end
                           
                           % sort
                           Date          = cellfun(@(str) str2double(str(1:8)), TimeTag);
                           Time          = cellfun(@(str) str2double(str(10:end)), TimeTag);
                           NumericTime   = Date + Time/1e9;
                           [~,SortedIdx] = sort(NumericTime);
                           
                           
                           batchCount = 0 ;
                           MaxBatch   = floor(numel(SortedIdx)/2 ) ; 
                           
                           %while(batchCount < MaxBatch)
                           batchNum = 1 ;
                           flag     = false;
                           for Ibatch = 1:2:floor(numel(SortedIdx) )  
                               
                              
                               Ivis = Ibatch ;
                             
                                  
                                  
                         
                               
                               ms1  = ms(SortedIdx(Ivis)).copy();
                               ms2  = ms(SortedIdx(Ivis+1)).copy();
                               
                               wdInd = ms1.coneSearch(e.RA(Iobj),e.Dec(Iobj)).Ind;
                               
                               if ~isempty(wdInd)
                                   
                                   if length(wdInd) == 1 
                                       
                                       fprintf('\nMerge by coo : %s --- %s',TimeTag{1,SortedIdx(Ivis)},TimeTag{1,SortedIdx(Ivis+1)})
                                       e.Data.Catalog.ms{Iobj,batchNum} = mergeByCoo(ms([SortedIdx(Ivis),SortedIdx(Ivis+1)]),ms1);
                                       batchNum = batchNum + 1;
                                     
                                       
                                   else
                                       
                                       fprintf('\nDouble -Index Merge by coo : %s --- %s',TimeTag{1,SortedIdx(Ivis)},TimeTag{1,SortedIdx(Ivis+1)})
                                       e.Data.Catalog.ms{Iobj,batchNum} = mergeByCoo(ms([SortedIdx(Ivis),SortedIdx(Ivis+1)]),ms1);
                                       batchNum = batchNum + 1;
                                 
                                       
                                   
                                   end
                                   
                               else
                                   
                                   fprintf('\nwd %i Could not be found at visit %s in Crop ID %i',e.Name(Iobj,:),TimeTag{1,SortedIdx(Ivis)},e.Data.Catalog.CatID{Iobj,1})
                                   wdInd2 = ms2.coneSearch(e.RA(Iobj),e.Dec(Iobj)).Ind;
                                   if ~isempty(wdInd2)
                                   
                                     if length(wdInd2) == 1 
                                       
                                       fprintf('\nMerge by coo of SECOND visit : %s --- %s',TimeTag{1,SortedIdx(Ivis+1)},TimeTag{1,SortedIdx(Ivis)})
                                       e.Data.Catalog.ms{Iobj,batchNum} = mergeByCoo(ms([SortedIdx(Ivis),SortedIdx(Ivis+1)]),ms2);
                                       batchNum = batchNum + 1;
                                     
                                       
                                     else
                                       
                                       fprintf('\nDouble -Index Merge by coo of SECOND visit : %s --- %s',TimeTag{1,SortedIdx(Ivis+1)},TimeTag{1,SortedIdx(Ivis)})
                                       e.Data.Catalog.ms{Iobj,batchNum} = mergeByCoo(ms([SortedIdx(Ivis),SortedIdx(Ivis+1)]),ms2);
                                       batchNum = batchNum + 1;
                                       
                                     end
                                     
                                   else
                                       fprintf('\nwd %i Could not be found at visit %s in Crop ID %i AS WELL',Iobj,e.Name(Iobj,:),TimeTag{1,SortedIdx(Ivis+1)},e.Data.Catalog.CatID{Iobj,1})
 
                                 
                                       
                                   
                                   end
                                 
                                   
                               end
                               
                               
                           end
                          
                           
                           %SortedTime = TimeTag(SortedIdx)
                           %Ls.FileName(SortedIdx)
                           %sort(TimeTag(:,:))
                           
                           %   Upload all files to a MatchedSources object
                               
                           %   % Merge all MatchedSources elkement into a single element object
                     end
                     
    end
    
    %%

end






%% ploting forced data
for Iobj = 1 : e.Nsrc
    
    Isubframe = cell2mat(e.CropID(Iobj,:));

    
    if ~isempty(Isubframe)
        
        for Iiter = 1 : length(Isubframe)
    
    
            figure();
           % subplot(1,2,1)
                        
            e.Data.Forced.MS{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','o','PlotColor','#D95319')
            hold on
            e.Data.Forced.PSFzp{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','.')
            
            e.Data.Forced.PSFsys{Iobj,Iiter} =  e.Data.Forced.PSFzp{Iobj,Iiter}.copy()
            % E.Data.Forced.PSFsys{Iobj,Iiter}.sysrem('MagFields' ,{'MAG_PSF'} , 'MagErrFields',{'MAGERR_PSF'})
            e.Data.Forced.PSFsys{Iobj,Iiter}.sysrem('MagFields' ,{'MAG_PSF'} , 'MagErrFields',{'MAGERR_PSF'},'sysremArgs',{'Niter',2})
            hold on
                        
            e.Data.Forced.PSFsys{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','s','PlotColor','blue')
            
            
            legend('Mag PSF before ZP','Mag PSF after ZP','SysRem 2 Iter','Interpreter','latex','Location','best')
            title(sprintf('Forced Photometry ; RMS (PSF) ; Sub Frame %i ',Isubframe(Iiter)),'Interpreter','latex')
            xlim([10,20])
 

           % subplot(1,2,2)
            
                        
           % E.Data.Catalog.MS{Iobj,Iiter}.plotRMS('FieldX','MAG_APER_2','PlotSymbol','o','PlotColor','#D95319')
           % hold on
           % E.Data.Catalog.APER_2{Iobj,Iiter}.plotRMS('FieldX','MAG_APER_2')
            
           % E.Data.Catalog.APERsys{Iobj,Iiter} =  E.Data.Catalog.APER_2{Iobj,Iiter}.copy()
           % E.Data.Catalog.APERsys{Iobj,Iiter}.sysrem('MagFields' ,{'MAG_APER_2'} , 'MagErrFields',{'MAGERR_APER_2'})
           % E.Data.Catalog.APERsys{Iobj,Iiter}.sysrem('MagFields' ,{'MAG_APER_2'} , 'MagErrFields',{'MAGERR_APER_2'})
           % hold on
                        
          %  E.Data.Catalog.APERsys{Iobj,Iiter}.plotRMS('FieldX','MAG_APER_2','PlotSymbol','.','PlotColor','#77AC30')
            
       
            
   %         legend('Mag APER 2 before ZP','Mag APER 2 after ZP','SysRem 2 Iter','Interpreter','latex','Location','best')
   %         title(sprintf('RMS (MAG APER 2)  '),'Interpreter','latex')
     %       xlim([10,20])
      %      ylim([5e-3,1.2])
            
            
            set(gcf, 'Position', get(0, 'ScreenSize'));
            pause(5);
%filename = ['~/Documents/WD_survey/261123/BackGround_Histogram_',num2str(ind),'.png']
%saveas(gcf, filename)

            
            
        end
    end
    
end

%% ploting light curves , 
e.plotLC(e,'Iobj',4)

%% please dont shutdown/restart the computer
