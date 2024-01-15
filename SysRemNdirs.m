
Pathway = '/last01e/data1/archive/LAST.01.01.01/2023/12/14/proc/1visit/191915v0/'

E = WDs(Pathway,Names,TargetList(2,1)	,TargetList(2,2)	,TargetList(2,3)    ,TargetList(2,4)	,TargetList(2,5))

%% Example of RMSplot for a target
%for Iobj = 1 : E.Nsrc
    
 %   Isubframe = E.Data.Catalog.CatID{Iobj};
    
  %  if ~isempty(Isubframe)
        
   %     for Iiter = 1 : length(Isubframe)
    
            Iiter = 1 ;
            Iobj = 1 ;
            figure();
            %subplot(1,2,1)
                        
            E.Data.Catalog.MS{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','o','PlotColor','#D95319')
            
            hold on
            MSmodel = E.Data.Catalog.MS{Iiter,Iobj}.copy() ;
            %MSmodel.plotRMS('PlotSymbol','o','PlotColor','#D95319','FieldX','MAG_PSF')
            MSmodel2 = FitZP2(MSmodel,'MagField','MAG_PSF','MagErrField','MAGERR_PSF','title',' only good sources MAG PSF (1 visit)','Title2','ZP - SysRem RMS results  - PSF (1 Visit)')
            
            %E.Data.Catalog.PSF{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','s','PlotColor','blue')
            
           % ax = E.Data.Catalog.PSF{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','s','PlotColor','blue').XData ;
           % ay = E.Data.Catalog.PSF{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','s','PlotColor','blue').YData
            
            %E.Data.Catalog.PSFsys{Iobj,Iiter} =  E.Data.Catalog.PSF{Iobj,Iiter}.copy()
            %E.Data.Catalog.PSFsys{Iobj,Iiter}.sysrem('MagFields' ,{'MAG_PSF'} , 'MagErrFields',{'MAGERR_PSF'})
            %E.Data.Catalog.PSFsys{Iobj,Iiter}.sysrem('MagFields' ,{'MAG_PSF'} , 'MagErrFields',{'MAGERR_PSF'})
            %E.Data.Catalog.PSFsys{Iobj,Iiter}.sysrem('sysremArgs',{'Niter',2},'MagFields' ,{'MAG_PSF'} , 'MagErrFields',{'MAGERR_PSF'});
            %hold on
                        


            figure();
            
                        
            E.Data.Catalog.MS{Iobj,Iiter}.plotRMS('FieldX','MAG_APER_2','PlotSymbol','o','PlotColor','#D95319')
            hold on
            
            msmodel = E.Data.Catalog.MS{Iiter,Iobj}.copy() ;
            %msmodel.plotRMS('PlotSymbol','o','PlotColor','#D95319','FieldX','MAG_APER_2')
            MSmodel3 = FitZP2(msmodel,'MagField','MAG_APER_2','MagErrField','MAGERR_APER_2','title',' only good sources MAG APER 2 (1 visit)','Title2','ZP - SysRem RMS results  - APER 2 (1 Visit)')

            
            
            
            
            
            
            
         %   E.Data.Catalog.APER_2{Iobj,Iiter}.plotRMS('FieldX','MAG_APER_2','PlotSymbol','s','PlotColor','blue')
            
          %  E.Data.Catalog.APERsys{Iobj,Iiter} =  E.Data.Catalog.APER_2{Iobj,Iiter}.copy()
            %E.Data.Catalog.APERsys{Iobj,Iiter}.sysrem('MagFields' ,{'MAG_APER_2'} , 'MagErrFields',{'MAGERR_APER_2'})
            %E.Data.Catalog.APERsys{Iobj,Iiter}.sysrem('MagFields' ,{'MAG_APER_2'} , 'MagErrFields',{'MAGERR_APER_2'})
           % E.Data.Catalog.APERsys{Iobj,Iiter}.sysrem('MagFields' ,{'MAG_APER_2'} , 'MagErrFields',{'MAGERR_APER_2'},'sysremArgs',{'Niter',2});

            %hold on
                        
           % E.Data.Catalog.APERsys{Iobj,Iiter}.plotRMS('FieldX','MAG_APER_2','PlotSymbol','.','PlotColor','black')
            
       
            
          %  legend('Mag APER 2 before ZP','Mag APER 2 after ZP','SysRem 2 Iter','Interpreter','latex','Location','best')

            
           % set(gcf, 'Position', get(0, 'ScreenSize'));
            %pause(5);
%filename = ['~/Documents/WD_survey/261123/BackGround_Histogram_',num2str(ind),'.png']
%saveas(gcf, filename)

            
            
   %     end
  %  end
    
%end
%%


Pathway = '/last01e/data1/archive/LAST.01.01.01/2023/12/14/proc/4visits/191915v0/'

E4 = WDs(Pathway,Names,TargetList(2,1)	,TargetList(2,2)	,TargetList(2,3)    ,TargetList(2,4)	,TargetList(2,5))

%% Example of RMSplot for a target
%for Iobj = 1 : E.Nsrc
    
 %   Isubframe = E.Data.Catalog.CatID{Iobj};
    
  %  if ~isempty(Isubframe)
        
   %     for Iiter = 1 : length(Isubframe)
    
            Iiter = 1 ;
            Iobj = 1 ;
            figure();
            %subplot(1,2,1)
                        
            E4.Data.Catalog.MS{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','o','PlotColor','#D95319')
            
            hold on
            MSmodel = E4.Data.Catalog.MS{Iiter,Iobj}.copy() ;
            %MSmodel.plotRMS('PlotSymbol','o','PlotColor','#D95319','FieldX','MAG_PSF')
            MSmodel2 = FitZP2(MSmodel,'MagField','MAG_PSF','MagErrField','MAGERR_PSF','title',' only good sources MAG PSF (4 Visits)','Title2','ZP - SysRem RMS results  - PSF (4 Visits)')
            
            %E.Data.Catalog.PSF{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','s','PlotColor','blue')
            
           % ax = E.Data.Catalog.PSF{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','s','PlotColor','blue').XData ;
           % ay = E.Data.Catalog.PSF{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','s','PlotColor','blue').YData
            
            %E.Data.Catalog.PSFsys{Iobj,Iiter} =  E.Data.Catalog.PSF{Iobj,Iiter}.copy()
            %E.Data.Catalog.PSFsys{Iobj,Iiter}.sysrem('MagFields' ,{'MAG_PSF'} , 'MagErrFields',{'MAGERR_PSF'})
            %E.Data.Catalog.PSFsys{Iobj,Iiter}.sysrem('MagFields' ,{'MAG_PSF'} , 'MagErrFields',{'MAGERR_PSF'})
            %E.Data.Catalog.PSFsys{Iobj,Iiter}.sysrem('sysremArgs',{'Niter',2},'MagFields' ,{'MAG_PSF'} , 'MagErrFields',{'MAGERR_PSF'});
            %hold on
                        
            %E.Data.Catalog.PSFsys{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','.','PlotColor','black')
            
            %bx = E.Data.Catalog.PSFsys{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','.','PlotColor','black').XData
            %by = E.Data.Catalog.PSFsys{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','.','PlotColor','black').YData
            


            figure();
            
                        
            E4.Data.Catalog.MS{Iobj,Iiter}.plotRMS('FieldX','MAG_APER_2','PlotSymbol','o','PlotColor','#D95319')
            hold on
            
            msmodel = E4.Data.Catalog.MS{Iiter,Iobj}.copy() ;

            MSmodel3 = FitZP2(msmodel,'MagField','MAG_APER_2','MagErrField','MAGERR_APER_2','title',' only good sources MAG APER 2 (4 Visits)','Title2','ZP - SysRem RMS results  - APER 2 (4 Visits)')

            
            
            
            
            
            
            
         %   E.Data.Catalog.APER_2{Iobj,Iiter}.plotRMS('FieldX','MAG_APER_2','PlotSymbol','s','PlotColor','blue')
            
          %  E.Data.Catalog.APERsys{Iobj,Iiter} =  E.Data.Catalog.APER_2{Iobj,Iiter}.copy()
            %E.Data.Catalog.APERsys{Iobj,Iiter}.sysrem('MagFields' ,{'MAG_APER_2'} , 'MagErrFields',{'MAGERR_APER_2'})
            %E.Data.Catalog.APERsys{Iobj,Iiter}.sysrem('MagFields' ,{'MAG_APER_2'} , 'MagErrFields',{'MAGERR_APER_2'})
           % E.Data.Catalog.APERsys{Iobj,Iiter}.sysrem('MagFields' ,{'MAG_APER_2'} , 'MagErrFields',{'MAGERR_APER_2'},'sysremArgs',{'Niter',2});

            %hold on
                        
           % E.Data.Catalog.APERsys{Iobj,Iiter}.plotRMS('FieldX','MAG_APER_2','PlotSymbol','.','PlotColor','black')
            
       

            
            
            
            
            %%
Pathway = '/last01e/data1/archive/LAST.01.01.01/2023/12/14/proc/9visits/191915v0/'

E9 = WDs(Pathway,Names,TargetList(2,1)	,TargetList(2,2)	,TargetList(2,3)    ,TargetList(2,4)	,TargetList(2,5))

%% Example of RMSplot for a target
%for Iobj = 1 : E.Nsrc
    
 %   Isubframe = E.Data.Catalog.CatID{Iobj};
    
  %  if ~isempty(Isubframe)
        
   %     for Iiter = 1 : length(Isubframe)
    
            Iiter = 1 ;
            Iobj = 1 ;
            figure();
            %subplot(1,2,1)
                        
            E9.Data.Catalog.MS{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','o','PlotColor','#D95319')
            
            hold on
            MSmodel = E9.Data.Catalog.MS{Iiter,Iobj}.copy() ;
            %MSmodel.plotRMS('PlotSymbol','o','PlotColor','#D95319','FieldX','MAG_PSF')
            MSmodel2 = FitZP2(MSmodel,'MagField','MAG_PSF','MagErrField','MAGERR_PSF','title',' only good sources MAG PSF (9 Visits)','Title2','ZP - SysRem RMS results  - PSF (9 Visits)')
            

            figure();
            
                        
            E9.Data.Catalog.MS{Iobj,Iiter}.plotRMS('FieldX','MAG_APER_2','PlotSymbol','o','PlotColor','#D95319')
            hold on
            
            msmodel = E9.Data.Catalog.MS{Iiter,Iobj}.copy() ;

            MSmodel3 = FitZP2(msmodel,'MagField','MAG_APER_2','MagErrField','MAGERR_APER_2','title',' only good sources MAG APER2 (9 Visits)','Title2','ZP - SysRem RMS results  - APER 2 (9 Visits)')

            

            

           %%
Pathway = '/last01e/data1/archive/LAST.01.01.01/2023/12/14/proc/18visits/191915v0/'

E18 = WDs(Pathway,Names,TargetList(2,1)	,TargetList(2,2)	,TargetList(2,3)    ,TargetList(2,4)	,TargetList(2,5),'getForcedData',false)

%% Example of RMSplot for a target
%for Iobj = 1 : E.Nsrc
    
 %   Isubframe = E.Data.Catalog.CatID{Iobj};
    
  %  if ~isempty(Isubframe)
        
   %     for Iiter = 1 : length(Isubframe)
    
            Iiter = 1 ;
            Iobj = 1 ;
            figure();
            %subplot(1,2,1)
                        
            E18.Data.Catalog.MS{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','o','PlotColor','#D95319')
            
            hold on
            MSmodel = E18.Data.Catalog.MS{Iiter,Iobj}.copy() ;
            %MSmodel.plotRMS('PlotSymbol','o','PlotColor','#D95319','FieldX','MAG_PSF')
            MSmodel2 = FitZP2(MSmodel,'MagField','MAG_PSF','MagErrField','MAGERR_PSF','title',' only good sources MAG PSF (18 Visits)','Title2','ZP - SysRem RMS results  - PSF (18 Visits)')
            

            figure();
            
                        
            E18.Data.Catalog.MS{Iobj,Iiter}.plotRMS('FieldX','MAG_APER_2','PlotSymbol','o','PlotColor','#D95319')
            hold on
            
            msmodel = E18.Data.Catalog.MS{Iiter,Iobj}.copy() ;

            MSmodel3 = FitZP2(msmodel,'MagField','MAG_APER_2','MagErrField','MAGERR_APER_2','title',' only good sources MAG APER2 (18 Visits)','Title2','ZP - SysRem RMS results  - APER 2 (18 Visits)')

            

            

           %%
Pathway = '/last01e/data1/archive/LAST.01.01.01/2023/12/14/proc/33visits/191915v0/'

E33 = WDs(Pathway,Names,TargetList(2,1)	,TargetList(2,2)	,TargetList(2,3)    ,TargetList(2,4)	,TargetList(2,5),'getForcedData',false)

%% Example of RMSplot for a target
%for Iobj = 1 : E.Nsrc
    
 %   Isubframe = E.Data.Catalog.CatID{Iobj};
    
  %  if ~isempty(Isubframe)
        
   %     for Iiter = 1 : length(Isubframe)
    
            Iiter = 1 ;
            Iobj = 1 ;
            figure();
            %subplot(1,2,1)
                        
            E33.Data.Catalog.MS{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','o','PlotColor','#D95319')
            
            hold on
            MSmodel = E33.Data.Catalog.MS{Iiter,Iobj}.copy() ;
            %MSmodel.plotRMS('PlotSymbol','o','PlotColor','#D95319','FieldX','MAG_PSF')
            MSmodel2 = FitZP2(MSmodel,'MagField','MAG_PSF','MagErrField','MAGERR_PSF','title',' only good sources MAG PSF (33 Visits)','Title2','ZP - SysRem RMS results  - PSF (33 Visits)')
            

            figure();
            
                        
            E33.Data.Catalog.MS{Iobj,Iiter}.plotRMS('FieldX','MAG_APER_2','PlotSymbol','o','PlotColor','#D95319')
            hold on
            
            msmodel = E33.Data.Catalog.MS{Iiter,Iobj}.copy() ;

            MSmodel3 = FitZP2(msmodel,'MagField','MAG_APER_2','MagErrField','MAGERR_APER_2','title',' only good sources MAG APER2 (33 Visits)','Title2','ZP - SysRem RMS results  - APER 2 (33 Visits)')

            

            






