% Example how to handle a WDs class

% Initilize targetList. one day it will use catHTM
Names = [
'WDJ045927.24+552521.05'
'WDJ050427.95+572212.58',
'WDJ050415.39+560048.59',
'WDJ050017.14+555944.52',
'WDJ050214.97+571746.94',
'WDJ050244.55+552138.14',
'WDJ050504.38+554333.45',
'WDJ050252.93+552349.36',
'WDJ050220.08+545653.57',
'WDJ050406.05+544526.05',
'WDJ045905.87+570302.55',
'WDJ050640.11+544504.04',
'WDJ050413.48+570430.54',
'WDJ045955.36+572324.27',
'WDJ050419.16+550506.82']

TargetList = [
74.86099996612612	55.42108875194858	15.973261	15.994185	15.967215
76.11620731675573	57.36822913113302	17.681812	17.814215	17.45064
76.06371300557537	56.01304202502301	18.909513	19.202078	18.483395
75.07158486656986	55.99569149752898	17.54945	17.643406	17.388554
75.56353190439445	57.29556766590215	18.96953	18.954218	19.054396
75.68510488808187	55.36018765809179	19.42342	19.683197	18.967628
76.267904217738  	55.72605621403975	17.51806	17.497694	17.547382
75.72026918437764	55.396914384363754	19.183249	19.2559	19.046532
75.58374695239141	54.94795313449597	19.4591	19.621683	19.278166
76.02559688731728	54.757059161291785	17.651005	17.637726	17.740812
74.7743043952651	57.05064609599765	18.374273	18.445314	18.359669
76.66723070593603	54.75101663991809	18.987984	19.12918	18.85162
76.05620508751191	57.075139652706504	18.702803	18.806835	18.62539
74.9810055166602	57.38992125139152	19.493341	19.60297	19.302364
76.07980047639484	55.08518710400043	19.05001	19.105104	18.971575]






% First initilize with Path,Name,RA,DEC,.....

Pathway = '/home/ocs/Documents/WD_survey/EXP/233328v0'
%Pathway = '/last10e/data1/archive/LAST.01.10.01/2023/12/14/proc/011816v0'
E = WDs(Pathway,Names,TargetList(:,1)	,TargetList(:,2)	,TargetList(:,3)    ,TargetList(:,4)	,TargetList(:,5),'Batch',[],'getForcedData',false)

%%

%%
E2 = WDs(Pathway,Names,TargetList(:,1)	,TargetList(:,2)	,TargetList(:,3)    ,TargetList(:,4)	,TargetList(:,5),'Batch',[],'getForcedData',false)
%%
NWD = length(E.Data.Catalog.InCat);

Nwd = sum(E.Data.Catalog.InCat);

for Iwd = 1 : NWD
    
    if E.Data.Catalog.InCat(Iwd)
        
        
        
%%        
        Iobj =8;
        Iiter = 1;
        MS = E.Data.Catalog.PSF{Iobj,1}.copy() ; 
        MS.addSrcData
        E.G_Bp(Iobj)
        index = MS.coneSearch(E.RA(Iobj),E.Dec(Iobj)).Ind
        E.RA(Iobj)
        E.Dec(Iobj)
        %figure('color','white','Position',[10 10 1120 840 ]);
        MS.plotRMSint('FieldX','MAG_PSF')
               
        
        
      %%
      
      
      
      %Obj.coneSearch(76.1162073167557,57.368229131133)
      plot(XP(1145),YP(1145),'bo','markersize', 10)
                
        
        
        
%%        
        Iobj =2;
        Iiter = 1;
        MS = E.Data.Catalog.PSF{Iobj,1}.copy() ; 
        figure('color','white','Position',[10 10 1120 840 ]);
        MS.plotRMS('FieldX','MAG_PSF')
       


        E.Data.Catalog.MS{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','o','PlotColor','#D95319')
            
        hold on
        MSmodel = E.Data.Catalog.MS{Iobj,Iiter}.copy() ;
            %MSmodel.plotRMS('PlotSymbol','o','PlotColor','#D95319','FieldX','MAG_PSF')
        MSmodel2 = FitZP2CatOrig(MSmodel,'MagField','MAG_PSF','MagErrField','MAGERR_PSF','title',' MAG PSF (Catalog+Forced)','Title2','ZP - SysRem RMS results  - PSF (Catalog Visit)')
%%
        hold on
        E2.Data.Forced.PSFzp{Iobj,Iiter}.plotRMS('FieldX','MAG_PSF','PlotSymbol','o','PlotColor','cyan')
        MSmodel0 = E2.Data.Forced.PSFzp{Iobj,Iiter}.copy() ;
        MSmodelF = FitZP2(MSmodel0,'MagField','MAG_PSF','MagErrField','MAGERR_PSF','title',' only good sources MAG PSF (Catalog)','Title2','ZP - SysRem RMS results  - PSF (Catalog Visit)')
        MSmodelF.plotRMS('FieldX','MAG_PSF','PlotSymbol','o','PlotColor',[0.2 0.2 0.2])
        legend('NO ZP','cat ZP','','','cat ZP + sysrem','Forced','Forced + sysrem','Interpreter','latex','Location','best')

        %%
        filename = ['\home\ocs\Documents\WD_survey\sysREM2visits\WD_',num2str(Iobj),'_RMS_ZP', '.png'];
        saveas(gcf, filename);
          
        
        
 %%       
 
       figure('color','white','Position',[10 10 1120 840 ]);

       objIdx = MSmodel.coneSearch(E.RA(Iobj),E.Dec(Iobj)).Ind

       y = E.Data.Catalog.PSF{Iobj,Iiter}.Data.MAG_PSF(:,objIdx);
       t = timeofday(datetime(E.Data.Catalog.PSF{Iobj,Iiter}.JD,'convertfrom','jd'))
       %tF = timeofday(datetime(MSmodelF.JD,'convertfrom','jd'))
       plot(E.Data.Catalog.PSF{Iobj,Iiter}.JD,y,'-o')
       hold on 
       %plot(tF,MSmodel0.Data.MAG_PSF(:,1),'-o')
       hold on
       %plot(t,LimMag_vec1(:,E.CropID{Iobj}),'-')
       legend(sprintf('Catalog Robust SD = %.3f ',RobustSD(y)),sprintf('Forced Robust SD = %.3f ',RobustSD(MSmodelF.Data.MAG_PSF(:,1))),sprintf('Limiting Mag CropID : %i',E.CropID{Iobj}),'Interpreter','latex')
       title(sprintf('PSF Catalog and Forced photometry LC ; WD %i $B_p$ = %.2f',Iobj,e.G_Bp(Iobj)),'Interpreter','latex')
       xlabel('JD','Interpreter','latex')
       ylabel('Inst Mag','Interpreter','latex')
       set(gca,'Ydir','reverse')
       
       
        filename = ['\home\ocs\Documents\WD_survey\sysREM2visits\WD_',num2str(Iobj),'_LC_ZP', '.png'];
        saveas(gcf, filename);

%%        
       figure('color','white','Position',[10 10 1120 840 ]);

       %objIdx = MSmodel.coneSearch(E.RA(Iobj),E.Dec(Iobj)).Ind
       Iobj = 14
       y = E2.Data.Forced.MS{Iobj,Iiter}.Data.MAG_PSF(:,1);
       t = timeofday(datetime(E2.Data.Forced.MS{Iobj,Iiter}.JD,'convertfrom','jd'))
       %tF = timeofday(datetime(MSmodelF.JD,'convertfrom','jd'))
       plot(t,y,'-o')
       hold on 
       %plot(tF,MSmodel0.Data.MAG_PSF(:,1),'-o')
       hold on
       plot(t,LimMag_vec1(:,E2.CropID{Iobj}),'-')
       legend(sprintf('Forced Robust SD = %.3f ',RobustSD(y)),sprintf('Limiting Mag CropID : %i',E.CropID{Iobj}),'Interpreter','latex')
       title(sprintf('PSF Forced photometry LC ; WD %i $B_p$ = %.2f',Iobj,e.G_Bp(Iobj)),'Interpreter','latex')
       xlabel('JD','Interpreter','latex')
       ylabel('Inst Mag','Interpreter','latex')
       set(gca,'Ydir','reverse')
            filename = ['\home\ocs\Documents\WD_survey\sysREM2visits\WD_',num2str(Iobj),'_LC_2', '.png'];
        saveas(gcf, filename);
        
        
    end
    
    
end




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

[times_vec,LimMag_vec] = E.Header_LimMag1Dir(E,'Iobj',7)
%%

[times_vec1,LimMag_vec1] = E.Header_LimMag1Dir(E)


tl = timeofday(datetime(times_vec1(:,1),'convertfrom','jd'))

figure('Color','white')
plot(t,LimMag_vec1,'-o')
xlabel('Time','Interpreter','latex')
ylabel('Limiting Magnitude','Interpreter','latex')


%%
figure('Color','white')
c=0;
for Isf = 1 :3: 24
    
    c = c + 1;
    plot(t,LimMag_vec1(:,Isf),'-o')
    text(t(c),LimMag_vec1(Isf,Isf),num2str(Isf))
    
    hold on
    
end
xlabel('Time','Interpreter','latex')
ylabel('Limiting Magnitude','Interpreter','latex')
ylabel('Limiting Magnitude from Header','Interpreter','latex')



    
    

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

%% Export matrices

file_path = '/home/ocs/Documents/WD_survey/EXP/M1.txt';
fid = fopen(file_path, 'w');
file_path2 = '/home/ocs/Documents/WD_survey/EXP/XY.txt';
fid2 = fopen(file_path2, 'w');


M = E.Data.Catalog.MS{Iobj,Iiter}.Data.MAG_PSF(Sorted,:);
X1 = E.Data.Catalog.MS{Iobj,Iiter}.Data.X1(Sorted,:);
Y1 = E.Data.Catalog.MS{Iobj,Iiter}.Data.Y1(Sorted,:);
% Write the matrix to the file
row = 0
M(56,objIdx) = 17.95;
for i = 1:size(M, 2)

    
    
    if ~isnan(sum(M(:, i)))
        
       fprintf(fid, '[ ');
       fprintf(fid, ' %f ,', M(:, i)');
       fprintf(fid, '], ');
       fprintf(fid, '\n');
       row = row+1;
       XY = [mean(X1(:,i),'omitnan') ,mean(Y1(:,i),'omitnan')];
       if i == objIdx
           row
           XY
       end
       
       
       fprintf(fid2, '[ ');
       
       fprintf(fid2, ' %f ,', XY');
       fprintf(fid2, '], ');
       fprintf(fid2, '\n');
    end
end

fclose(fid);
fclose(fid2);

