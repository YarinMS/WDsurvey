% Example how to handle a WDs class

% Initilize targetList. one day it will use catHTM
Names = [
'WDJ023551.36+011845.45',
'WDJ023826.44+035310.50',
'WDJ023607.95+033735.68',
'WDJ023409.01+005115.19',
'WDJ023233.82+021438.21',
'WDJ023543.09+005557.07',
'WDJ023427.39+033457.26',
'WDJ023434.86+021252.25',
'WDJ023426.31+012225.43',
'WDJ023114.68+004059.19',
'WDJ023653.96+023100.04',
'WDJ023808.09+004908.77',
'WDJ023536.46+014103.29',
'WDJ023240.92+022045.92']

TargetList = [
38.96387398068409	1.312374415515603	16.153215	16.363483	15.790968
39.61002897569902	3.8857410451177694	18.61351	18.834017	18.30167
39.033257941277995	3.626325632892244	18.105719	18.142944	18.095617
38.53787136172686	0.8541725343309922	19.385395	19.60804	19.020752
38.1408633143671	2.243924162872992	19.121677	19.10912	19.227549
38.9300116748571	0.9327586722261365	18.08444	18.187714	17.979803
38.614663703352086	3.582558817395811	18.811316	18.721949	18.91699
38.645252091308734	2.214368720324519	18.280693	18.256939	18.404211
38.609842118325595	1.373725558213784	17.980848	17.93942	18.12713
37.81109719953584	0.6830724228078571	18.682297	18.661695	18.769793
39.224923632579134	2.5166581163661346	19.021412	19.02888	19.09601
39.53362898375925	0.8189560172957012	18.837904	18.829311	19.047295
38.90194339045485	1.6840576185934102	19.490337	19.44313	19.505
38.1705276053845	2.3460835864350806	19.008234	18.941101	19.326393
];






% First initilize with Path,Name,RA,DEC,.....

Pathway = '/last03e/data1/archive/LAST.01.03.01/2023/12/14/proc/153557v0'

e = WDs(Pathway,Names,TargetList(:,1)	,TargetList(:,2)	,TargetList(:,3)    ,TargetList(:,4)	,TargetList(:,5),'Batch',2)


%%

g = WDs(Pathway,Names,TargetList(8,1)	,TargetList(8,2)	,TargetList(8,3)    ,TargetList(8,4)	,TargetList(8,5),'Batch',2)



%% Example of RMSplot for a target
for Iobj = 1 : e.Nsrc
    
    Isubframe = e.Data.Catalog.CatID{Iobj};
    
    if ~isempty(Isubframe)
        
        for Iiter = 1 : length(Isubframe)
    
    
            figure();
            subplot(1,2,1)
                        
            e.Data.Catalog.MS{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','o','PlotColor','#D95319')
            
            hold on
            
            e.Data.Catalog.PSF{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','s','PlotColor','blue')
            
            ax = e.Data.Catalog.PSF{2,2}.plotRMS('FieldX','MAG_PSF','PlotSymbol','s','PlotColor','blue').XData ;
            ay = e.Data.Catalog.PSF{2,2}.plotRMS('FieldX','MAG_PSF','PlotSymbol','s','PlotColor','blue').YData
            
            e.Data.Catalog.PSFsys{Iobj,Iiter} =  e.Data.Catalog.PSF{Iobj,Iiter}.copy()
            %E.Data.Catalog.PSFsys{Iobj,Iiter}.sysrem('MagFields' ,{'MAG_PSF'} , 'MagErrFields',{'MAGERR_PSF'})
            %E.Data.Catalog.PSFsys{Iobj,Iiter}.sysrem('MagFields' ,{'MAG_PSF'} , 'MagErrFields',{'MAGERR_PSF'})
            e.Data.Catalog.PSFsys{Iobj,Iiter}.sysrem('sysremArgs',{'Niter',2},'MagFields' ,{'MAG_PSF'} , 'MagErrFields',{'MAGERR_PSF'});
            hold on
                        
            e.Data.Catalog.PSFsys{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','.','PlotColor','black')
            
            bx = e.Data.Catalog.PSFsys{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','.','PlotColor','black').XData
            by = e.Data.Catalog.PSFsys{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','.','PlotColor','black').YData
            
            
            
            
            
            
            
            
            legend('Mag PSF before ZP','Mag PSF after ZP','SysRem 2 Iter','Interpreter','latex','Location','best')
            title(sprintf('Catalog RMS (PSF) ; Sub Frame %i ',Isubframe(Iiter)),'Interpreter','latex')
            xlim([10,20])
            ylim([5e-3,1.2])

            subplot(1,2,2)
            
                        
            e.Data.Catalog.MS{Iobj,Iiter}.plotRMS('FieldX','MAG_APER_2','PlotSymbol','o','PlotColor','#D95319')
            hold on
            e.Data.Catalog.APER_2{Iobj,Iiter}.plotRMS('FieldX','MAG_APER_2','PlotSymbol','s','PlotColor','blue')
            
            e.Data.Catalog.APERsys{Iobj,Iiter} =  e.Data.Catalog.APER_2{Iobj,Iiter}.copy()
            %E.Data.Catalog.APERsys{Iobj,Iiter}.sysrem('MagFields' ,{'MAG_APER_2'} , 'MagErrFields',{'MAGERR_APER_2'})
            %E.Data.Catalog.APERsys{Iobj,Iiter}.sysrem('MagFields' ,{'MAG_APER_2'} , 'MagErrFields',{'MAGERR_APER_2'})
            e.Data.Catalog.APERsys{Iobj,Iiter}.sysrem('MagFields' ,{'MAG_APER_2'} , 'MagErrFields',{'MAGERR_APER_2'},'sysremArgs',{'Niter',2});

            hold on
                        
            e.Data.Catalog.APERsys{Iobj,Iiter}.plotRMS('FieldX','MAG_APER_2','PlotSymbol','.','PlotColor','black')
            
       
            
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

[times_vec,LimMag_vec] = e.Header_LimMag(e)



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
