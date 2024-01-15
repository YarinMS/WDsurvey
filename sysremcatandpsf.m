%E = E.plotRMSComparison(E, 'WDidx',2,'Iimage',1,'SaveTo','/home/ocs/Documents/WD_survey/SysRem/141223T1')


%%
Iiter = 1 ;
Iobj = 3;
            
%%
for i = 10: 14     

[e,LC{i}]  = e.plotRMSComparison(e, 'WDidx',i,'Iimage',Iiter,'SaveTo','/home/ocs/Documents/WD_survey/SysRem/141223T1')
      
end
            
%%   original function, use zp only with sources without any NANS 
 
figure('color','white','Position',[10 10 1120 840 ]);
            
                        
e.Data.Catalog.MS{Iobj,Iiter}.plotRMS('FieldX','MAG_APER_2','PlotSymbol','o','PlotColor','#D95319')
hold on
            
msmodel = e.Data.Catalog.MS{Iobj,Iiter}.copy() ;
            
MSmodel3 = FitZP2CatOrig(msmodel,'MagField','MAG_APER_2','MagErrField','MAGERR_APER_2','title',' MAG APER 2 (Catalog)','Title2','ZP - SysRem RMS results  - APER 2 (Catalog)')

 
figure('color','white','Position',[10 10 1120 840 ]);

objIdx = MSmodel3.coneSearch(e.RA(Iobj),e.Dec(Iobj)).Ind

if isempty(objIdx)
    
    error('Target couldnt be found in catalog AFTER sysrem')
    
end

y = MSmodel3.Data.MAG_APER_2(:,objIdx);

plot(MSmodel3.JD,MSmodel3.Data.MAG_APER_2(:,objIdx),'-o')
legend(sprintf('Robust SD = %.3f ',RobustSD(y)))
title(sprintf('Catalog LC ; WD %i $B_p$ = %.2f',Iobj,e.G_Bp(Iobj)),'Interpreter','latex')
xlabel('JD','Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
  


%%   LIKE original function, use zp for all sources
 
figure('color','white','Position',[10 10 1120 840 ]);
            
                        
e.Data.Catalog.MS{Iobj,Iiter}.plotRMS('FieldX','MAG_APER_2','PlotSymbol','o','PlotColor','#D95319')
hold on
            
msmodel = e.Data.Catalog.MS{Iobj,Iiter}.copy() ;
            
MSmodel3 = FitZP2Cat(msmodel,'MagField','MAG_APER_2','MagErrField','MAGERR_APER_2','title',' MAG APER 2 (Catalog)','Title2','ZP - SysRem RMS results  - APER 2 (Catalog)')

   

figure('color','white','Position',[10 10 1120 840 ]);

objIdx = MSmodel3.coneSearch(e.RA(Iobj),e.Dec(Iobj)).Ind

y = MSmodel3.Data.MAG_APER_2(:,objIdx);

plot(MSmodel3.JD,MSmodel3.Data.MAG_APER_2(:,objIdx),'-o')
legend(sprintf('Robust SD = %.3f ',RobustSD(y)))
title(sprintf('APER 2Catalog LC ; WD %i $B_p$ = %.2f',Iobj,e.G_Bp(Iobj)),'Interpreter','latex')
xlabel('JD','Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
  

%% The same for psf Original

 
figure('color','white','Position',[10 10 1120 840 ]);

            %subplot(1,2,1)
                        
e.Data.Catalog.MS{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','o','PlotColor','#D95319')
            
hold on
MSmodel = e.Data.Catalog.MS{Iobj,Iiter}.copy() ;
            %MSmodel.plotRMS('PlotSymbol','o','PlotColor','#D95319','FieldX','MAG_PSF')
MSmodel2 = FitZP2CatOrig(MSmodel,'MagField','MAG_PSF','MagErrField','MAGERR_PSF','title',' only good sources MAG PSF (Catalog)','Title2','ZP - SysRem RMS results  - PSF (Catalog Visit)')


 
figure('color','white','Position',[10 10 1120 840 ]);

objIdx = MSmodel2.coneSearch(e.RA(Iobj),e.Dec(Iobj)).Ind

y = MSmodel2.Data.MAG_APER_2(:,objIdx);

plot(MSmodel2.JD,MSmodel2.Data.MAG_APER_2(:,objIdx),'-o')
legend(sprintf('Robust SD = %.3f ',RobustSD(y)))
title(sprintf('PSF Catalog LC ; WD %i $B_p$ = %.2f',Iobj,e.G_Bp(Iobj)),'Interpreter','latex')
xlabel('JD','Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
  




%% The same for psf take all sources

 
figure('color','white','Position',[10 10 1120 840 ]);

            %subplot(1,2,1)
                        
e.Data.Catalog.MS{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','o','PlotColor','#D95319')
            
hold on
MSmodel = e.Data.Catalog.MS{Iobj,Iiter}.copy() ;
            %MSmodel.plotRMS('PlotSymbol','o','PlotColor','#D95319','FieldX','MAG_PSF')
MSmodel2 = FitZP2Cat(MSmodel,'MagField','MAG_PSF','MagErrField','MAGERR_PSF','title',' only good sources MAG PSF (Catalog)','Title2','ZP - SysRem RMS results  - PSF (Catalog Visit)')
            
 
figure('color','white','Position',[10 10 1120 840 ]);
objIdx = MSmodel2.coneSearch(e.RA(Iobj),e.Dec(Iobj)).Ind

y = MSmodel2.Data.MAG_APER_2(:,objIdx);

plot(MSmodel2.JD,MSmodel2.Data.MAG_APER_2(:,objIdx),'-o')
legend(sprintf('Robust SD = %.3f ',RobustSD(y)))
title(sprintf('PSF Catalog LC ; WD %i $B_p$ = %.2f',Iobj,e.G_Bp(Iobj)),'Interpreter','latex')
xlabel('JD','Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')               