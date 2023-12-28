% Example how to handle a WDs class

% Initilize targetList. one day it will use catHTM
Names = [
'WDJ041207.43+632725.33',
'WDJ041122.51+634225.10',
'WDJ041036.37+662505.48',
'WDJ041155.11+643108.33']

TargetList = [
63.03283186794167	63.45645325968673	19.414335	19.876038	18.862103
62.84327136512444	63.70728491130131	17.837122	17.929632	17.70627
62.65118352277544	66.41816050235799	19.496265	19.613472	19.33754
62.97968175083718	64.51880880548879	19.395586	19.503075	19.28843
    
]






% First initilize with Path,Name,RA,DEC,.....

Pathway = '/last01e/data1/archive/LAST.01.01.01/2023/12/14/proc/002630v1'

E = WDs(Pathway,Names,TargetList(:,1)	,TargetList(:,2)	,TargetList(:,3)    ,TargetList(:,4)	,TargetList(:,5),'Batch',2)





%% Example of RMSplot for a target
for Iobj = 1 : E.Nsrc
    
    Isubframe = E.Data.Catalog.CatID{Iobj};
    
    if ~isempty(Isubframe)
        
        for Iiter = 1 : length(Isubframe)
    
    
            figure();
            subplot(1,2,1)
                        
            E.Data.Catalog.MS{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','o','PlotColor','#D95319')
            
            hold on
            
            E.Data.Catalog.PSF{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','s','PlotColor','blue')
            
            ax = E.Data.Catalog.PSF{2,2}.plotRMS('FieldX','MAG_PSF','PlotSymbol','s','PlotColor','blue').XData ;
            ay = E.Data.Catalog.PSF{2,2}.plotRMS('FieldX','MAG_PSF','PlotSymbol','s','PlotColor','blue').YData
            
            E.Data.Catalog.PSFsys{Iobj,Iiter} =  E.Data.Catalog.PSF{Iobj,Iiter}.copy()
            %E.Data.Catalog.PSFsys{Iobj,Iiter}.sysrem('MagFields' ,{'MAG_PSF'} , 'MagErrFields',{'MAGERR_PSF'})
            %E.Data.Catalog.PSFsys{Iobj,Iiter}.sysrem('MagFields' ,{'MAG_PSF'} , 'MagErrFields',{'MAGERR_PSF'})
            E.Data.Catalog.PSFsys{Iobj,Iiter}.sysrem('sysremArgs',{'Niter',2},'MagFields' ,{'MAG_PSF'} , 'MagErrFields',{'MAGERR_PSF'});
            hold on
                        
            E.Data.Catalog.PSFsys{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','.','PlotColor','black')
            
            bx = E.Data.Catalog.PSFsys{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','.','PlotColor','black').XData
            by = E.Data.Catalog.PSFsys{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','.','PlotColor','black').YData
            
            
            
            
            
            legend('Mag PSF before ZP','Mag PSF after ZP','SysRem 2 Iter','Interpreter','latex','Location','best')
            title(sprintf('Catalog RMS (PSF) ; Sub Frame %i ',Isubframe(Iiter)),'Interpreter','latex')
            xlim([10,20])
            ylim([5e-3,1.2])

            subplot(1,2,2)
            
                        
            E.Data.Catalog.MS{Iobj,Iiter}.plotRMS('FieldX','MAG_APER_2','PlotSymbol','o','PlotColor','#D95319')
            hold on
            E.Data.Catalog.APER_2{Iobj,Iiter}.plotRMS('FieldX','MAG_APER_2','PlotSymbol','s','PlotColor','blue')
            
            E.Data.Catalog.APERsys{Iobj,Iiter} =  E.Data.Catalog.APER_2{Iobj,Iiter}.copy()
            %E.Data.Catalog.APERsys{Iobj,Iiter}.sysrem('MagFields' ,{'MAG_APER_2'} , 'MagErrFields',{'MAGERR_APER_2'})
            %E.Data.Catalog.APERsys{Iobj,Iiter}.sysrem('MagFields' ,{'MAG_APER_2'} , 'MagErrFields',{'MAGERR_APER_2'})
            E.Data.Catalog.APERsys{Iobj,Iiter}.sysrem('MagFields' ,{'MAG_APER_2'} , 'MagErrFields',{'MAGERR_APER_2'},'sysremArgs',{'Niter',2});

            hold on
                        
            E.Data.Catalog.APERsys{Iobj,Iiter}.plotRMS('FieldX','MAG_APER_2','PlotSymbol','.','PlotColor','black')
            
       
            
            legend('Mag APER 2 before ZP','Mag APER 2 after ZP','SysRem 2 Iter','Interpreter','latex','Location','best')
            title(sprintf('RMS (MAG APER 2)  '),'Interpreter','latex')
            xlim([10,20])
            ylim([5e-3,1.2])
            
            
            set(gcf, 'Position', get(0, 'ScreenSize'));
            pause(5);
%filename = ['~/Documents/WD_survey/261123/BackGround_Histogram_',num2str(ind),'.png']
%saveas(gcf, filename)

            
            
        end
    end
    
end



%% Lim MAG of obs

[times_vec,LimMag_vec] = E.Header_LimMag(E)



%% ploting forced data
for Iobj = 1 : E.Nsrc
    
    Isubframe = cell2mat(E.CropID(Iobj,:));

    
    if ~isempty(Isubframe)
        
        for Iiter = 1 : length(Isubframe)
    
    
            figure();
           % subplot(1,2,1)
                        
            E.Data.Forced.MS{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','o','PlotColor','#D95319')
            hold on
            E.Data.Forced.PSFzp{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','.')
            
            E.Data.Forced.PSFsys{Iobj,Iiter} =  E.Data.Forced.PSFzp{Iobj,Iiter}.copy()
            % E.Data.Forced.PSFsys{Iobj,Iiter}.sysrem('MagFields' ,{'MAG_PSF'} , 'MagErrFields',{'MAGERR_PSF'})
            E.Data.Forced.PSFsys{Iobj,Iiter}.sysrem('MagFields' ,{'MAG_PSF'} , 'MagErrFields',{'MAGERR_PSF'},'sysremArgs',{'Niter',2})
            hold on
                        
            E.Data.Forced.PSFsys{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','s','PlotColor','blue')
            
            
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
E.plotLC(E,'Iobj',4)

%% please dont shutdown/restart the computer
