% slice FP to the better end.
% get results.

%% Create a FP ( MS ) object via ForcedPhotometry tools

% compare ZPmeddiff with lsq (1 and 2 iteration)
%% apply forced photometry
[AirMass,FP,MS,Robust_parameters] = e.Forced1(e,'Index',wdt,'FieldID',e.FieldID(wdt),'ID',e.CropID(wdt));


% A target defines a subframe 
%% List of targets
%% 270823

% field : 358+34
% coord : 358.881, 35.611

Targets1    = [

358.2490939340986	36.95602899310303	17.766068
359.6851110826381	35.56350936019282	18.70435
359.6496874215545	35.947638239844196	18.77262
358.81723529471816	36.048045855693054	16.934488
358.6261971650937	34.629180876873704	17.730215
358.60691617395423	36.080867682915624	17.409506
358.92623274836905	35.35949500332723	17.104704
358.47915664652015	36.1911456395325	17.282484
359.54269238125187	35.918701995030695	18.937252
358.4299172754524	36.374603327370025	17.795748
358.4737008898914	35.95696032498315	18.35812
358.1404232183327	36.324798719214535	17.94189
357.9510593069834	36.336222685272446	17.724937
357.8128762230127	35.86549520862897	18.908047


]

TargetsName1 = [
'WDJ235300.03+365723.82',
'WDJ235844.68+353353.83',
'WDJ235835.92+355652.22',
'WDJ235516.48+360253.89',
'WDJ235430.18+343745.73',
'WDJ235425.63+360451.07',
'WDJ235542.33+352134.38',
'WDJ235355.00+361128.46',
'WDJ235810.18+355507.50',
'WDJ235343.17+362228.63',
'WDJ235353.60+355725.51',
'WDJ235233.66+361929.47',
'WDJ235148.36+362011.25',
'WDJ235115.08+355156.23'


]


% Initilize WD object

e  = WD(Targets1(:,1),Targets1(:,2),Targets1(:,3),TargetsName1,'/last02e/data1/archive/LAST.01.02.01/2023/08/27/proc/000540v0')

e.LC_FP = [
18.02604
19.063189
19.274632
17.035667
17.766941
17.480482
17.069855
17.303087
19.040138
17.53455
18.366528
17.892187
17.673506
18.907557
];

e.LC_coadd = [
0.66524506
0.83859444
1.1449165
0.27044868
0.10054207
0.15999031
-0.15054321
0.002916336
0.20973015
0.17264175
-0.0855999
-0.1247921
-0.20863533
-0.096063614
]
% find their CropID and find them in catalog data
      % no lim mag calculations
[id,FieldId] = e.Coo_to_Subframe(e.Pathway,e);
e  = e.get_id(id(:,1));
e  = e.get_fieldID(FieldId);
[Index,cat_id] = e.find_in_cat(e);
e  = e.get_cat_id(cat_id);

% catalog extracion


% for now e = obj
%% Data extraction

%apply ZP on a copy of the forced photometry

MS = FP.copy();
% apply zp meddiff on copy
R = lcUtil.zp_meddiff(MS,'MagField','MAG_PSF','MagErrField','MAGERR_PSF');
                             
[MS,ApplyToMagFieldr] = applyZP(MS, R.FitZP,'ApplyToMagField','MAG_PSF');


wdt = 6;
% run lsq detrend
StartInd = 1;
EndInd   = length(FP.JD);

Color = {FP.SrcData.phot_bp_mean_mag - FP.SrcData.phot_rp_mean_mag } ; 
Color{1}(1) = e.LC_coadd(wdt) ;

[~,Sorted2] = sort(FP.JD);

time = FP.JD(Sorted2);


% Mark Bad Flags :
        FlagsList =  {'NearEdge','Saturated','NaN','Negative','NearEdge'};
        Bit= BitDictionary;
        BitClass = Bit.Class;
        Flags = BitClass(FP.Data.FLAGS);
        Flags = Flags(StartInd:EndInd,:);
        FLAG = zeros(size(Flags));
        Nflag  = numel(FlagsList);
        for Iflag = 1:1:Nflag
            FieldIndex = find(strcmp(Bit.Dic.BitName,FlagsList{Iflag}));
            if ~isempty(FieldIndex)
                FLAG = FLAG  |  bitget(Flags,FieldIndex);
            else
                error('Field "%s" not found in dictionary', Args.Flags{Iflag});
            end
        end
        
        GoodFlags = ~FLAG;
            
% Mark High SNR Targets

        FlagSNR = zeros(size(FLAG));
        
        FlagSNR = (FP.Data.MAGERR_PSF < 1/50);
        
        [~,GoodTargets] = find(sum(FlagSNR) == length(FP.JD));
        
        fprintf('\nFound %d targets with SNR higher than 50 for %d measurements\n',[length(GoodTargets) ,...
            length(FP.JD)])
        
        Targets =[];
        
        for Itgt = 1 : length(GoodTargets)
            
            
            FlagSum = sum(GoodFlags(:,GoodTargets(Itgt)));
            
            if FlagSum == length(FP.JD)
                fprintf('\nUsing source # %d for detrending\n',GoodTargets(Itgt))
                
                Targets = [Targets ; GoodTargets(Itgt) ];
                
            end
            
            
            
            
            
            
        end
        fprintf('\nUsing %d targets with SNR higher than 50 for %d measurements\n',[length(Targets) ,...
            length(FP.JD)])
       
       
   % slice currect data
   
   M = FP.Data.MAG_PSF(Sorted2,Targets);
   M(:,length(Targets)+1) = FP.Data.MAG_PSF(Sorted2,1);
   
   dM =  FP.Data.MAGERR_PSF(Sorted2,Targets);
   dM(:,length(Targets)+1) = FP.Data.MAGERR_PSF(Sorted2,1);
   
   C = {FP.SrcData.phot_bp_mean_mag(Targets) - FP.SrcData.phot_rp_mean_mag(Targets) }
   C{1}(length(Targets)+1) = e.LC_coadd(wdt) ;
   

    [Result,Refstars,Model]=lsqrelphotMAT(M,dM ,'StarProp',{},'StarPropNames','COLOR', 'Niter', 1,'obj',e,'wdt',WDInx)

       r2     = reshape(Result.Resid,[FP.Nepoch,length(Targets)+1]);
       model2 = reshape(Model,[FP.Nepoch,length(Targets)+1]);

    [rms1,meanmag1]  = CalcRMS(mean(model2),r2,e,wdt,'Marker','xk','Predicted',false)
% close;
 %[rms1,meanmag1]  = CalcRMS(MS.SrcData.phot_g_mean_mag,r,e,WDInx,'Marker','xk','Predicted',true)
 hold on
    FP.plotRMS('Fieldx','MAG_PSF','PlotColor',"#7E2F8E"','PlotSymbol','*') 

    MS.plotRMS('Fieldx','MAG_PSF','PlotColor','#77AC30','PlotSymbol','o')
 %   hold on
    %semilogy(median(FP2.Data.MAG_PSF,'omitnan'),rms1,'o','Color','#D95319')
    legend('Model','Raw','ZP mediff')
xlim([10 16])


t0 = ceil(FP.JD(1)) ;


%%
figure(13)
ind = 1;
plot(time-t0,FP.Data.MAG_PSF(Sorted2,1),'k.')
hold on 
plot(time-t0,r2(:,48) - mean(r2(:,48),'omitnan')+mean(FP.Data.MAG_PSF(Sorted2,1),'omitnan'),'ro')
%plot(time-t0,model2(:,1),'k.')
LgLbl{3} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(:,1)))
LgLbl{4} = sprintf('Residuals + mean ; RobustSD : %.3f',RobustSD(r2(:,48)))
legend(LgLbl(3:4),'Location','best','Interpreter','latex')
set(gca , 'YDir','reverse')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
title('Mistake','Interpreter','latex')
Title = sprintf('WD Target  $$ B_p = $$ %.3f',e.LC_FP(wdt))
title(Title,'Interpreter','latex')


%%

figure(12)
ind = 1;
plot(time-t0,FP.Data.MAG_PSF(Sorted2,1),'k.')
hold on 
plot(time-t0,r2(:,1) - mean(r2(:,1),'omitnan')+mean(FP.Data.MAG_PSF(Sorted2,1),'omitnan'),'ro')
%plot(time-t0,model2(:,1),'k.')
LgLbl{3} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(:,1)))
LgLbl{4} = sprintf('Residuals + mean ; RobustSD : %.3f',RobustSD(r2(:,1)))
legend(LgLbl(3:4),'Location','best','Interpreter','latex')
set(gca , 'YDir','reverse')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
title('Mistake','Interpreter','latex')
Title = sprintf('Wrong residuals with Wd target')
title(Title,'Interpreter','latex')

%%

figure(10)
ind = 1;
plot(time-t0,FP.Data.MAG_PSF(Sorted2,Targets(ind)),'k.')
hold on 
plot(time-t0,r2(:,ind) - mean(r2(:,ind),'omitnan')+mean(FP.Data.MAG_PSF(Sorted2,Targets(ind)),'omitnan'),'ro')
%plot(time-t0,model2(:,1),'k.')
LgLbl{3} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(:,Targets(ind))))
LgLbl{4} = sprintf('Residuals + mean ; RobustSD : %.3f',RobustSD(r2(:,1)))
legend(LgLbl(3:4),'Location','best','Interpreter','latex')
set(gca , 'YDir','reverse')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
Title = sprintf('Ref Target 1 $$ B_p = $$ %.3f',FP.SrcData.phot_bp_mean_mag(Targets(ind)))
title(Title,'Interpreter','latex')

%%

figure(11)
ind = 47;
plot(time-t0,FP.Data.MAG_PSF(Sorted2,Targets(ind)),'k.')
hold on 
plot(time-t0,r2(:,ind) - mean(r2(:,ind),'omitnan')+mean(FP.Data.MAG_PSF(Sorted2,Targets(ind)),'omitnan'),'ro')
%plot(time-t0,model2(:,1),'k.')
LgLbl{3} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(:,Targets(ind))))
LgLbl{4} = sprintf('Residuals + mean ; RobustSD : %.3f',RobustSD(r2(:,1)))
legend(LgLbl(3:4),'Location','best','Interpreter','latex')
set(gca , 'YDir','reverse')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
Title = sprintf('Ref Target 47 $$ B_p = $$ %.3f',FP.SrcData.phot_bp_mean_mag(Targets(ind)))
title(Title,'Interpreter','latex')





%%

figure(9)
ind = 2;
plot(time-t0,FP.Data.MAG_PSF(Sorted2,Targets(ind)),'k.')
hold on 
plot(time-t0,r2(:,2) - mean(r2(:,2),'omitnan')+mean(FP.Data.MAG_PSF(Sorted2,Targets(2)),'omitnan'),'ro')
plot(time-t0,model2(:,2),'g.')
LgLbl{3} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(:,Targets(ind))))
LgLbl{4} = sprintf('Residuals + mean ; RobustSD : %.3f',RobustSD(r2(:,2)))
LgLbl{5} = sprintf('Model')
legend(LgLbl(3:5),'Location','best','Interpreter','latex')
set(gca , 'YDir','reverse')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
Title = sprintf('Ref Target 2 $$ B_p = $$ %.3f',FP.SrcData.phot_bp_mean_mag(Targets(ind)))
title(Title,'Interpreter','latex')
xline(-0.48)
xline(-0.41)









%% now slice
% run lsq detrend


Color = {FP.SrcData.phot_bp_mean_mag - FP.SrcData.phot_rp_mean_mag } ; 
Color{1}(1) = e.LC_coadd(wdt) ;

[~,Sorted2] = sort(FP.JD);

time = FP.JD(Sorted2);

StartInd = 420;
EndInd   = length(FP.JD);
% Mark Bad Flags :
        FlagsList =  {'NearEdge','Saturated','NaN','Negative','NearEdge'};
        Bit= BitDictionary;
        BitClass = Bit.Class;
        Flags = BitClass(FP.Data.FLAGS);
        Flags = Flags(StartInd:EndInd,:);
        FLAG = zeros(size(Flags));
        Nflag  = numel(FlagsList);
        for Iflag = 1:1:Nflag
            FieldIndex = find(strcmp(Bit.Dic.BitName,FlagsList{Iflag}));
            if ~isempty(FieldIndex)
                FLAG = FLAG  |  bitget(Flags,FieldIndex);
            else
                error('Field "%s" not found in dictionary', Args.Flags{Iflag});
            end
        end
        
        GoodFlags = ~FLAG;
            
% Mark High SNR Targets

        FlagSNR = zeros(size(FLAG));
        
        FlagSNR = (FP.Data.MAGERR_PSF < 1/50);
        
        [~,GoodTargets] = find(sum(FlagSNR) == length(FP.JD));
        
        fprintf('\nFound %d targets with SNR higher than 50 for %d measurements\n',[length(GoodTargets) ,...
            length(FP.JD)])
        
        Targets =[1];
        
        for Itgt = 1 : length(GoodTargets)
            
            
            FlagSum = sum(GoodFlags(:,GoodTargets(Itgt)));
            
            if FlagSum == EndInd - StartInd +1
                fprintf('\nUsing source # %d for detrending\n',GoodTargets(Itgt))
                
                Targets = [Targets ; GoodTargets(Itgt) ];
                
            end
            
            
            
            
            
            
        end
        fprintf('\nUsing %d targets with SNR higher than 50 for %d measurements\n',[length(Targets) ,...
            length(FP.JD)])
       
       
   % slice currect data
   
   M = FP.Data.MAG_PSF(Sorted2,Targets);
   M(:,length(Targets)+1) = FP.Data.MAG_PSF(Sorted2,1);
   
   m = M(StartInd:EndInd,:);
   
   dM =  FP.Data.MAGERR_PSF(Sorted2,Targets);
   dM(:,length(Targets)+1) = FP.Data.MAGERR_PSF(Sorted2,1);
   
   dm = dM(StartInd:EndInd,:);
   C = {FP.SrcData.phot_bp_mean_mag(Targets) - FP.SrcData.phot_rp_mean_mag(Targets) }
   C{1}(length(Targets)+1) = e.LC_coadd(wdt) ;
   
 
    [result,FinalRef,model]=lsqrelphotMAT(m,dm ,'StarProp',{},'StarPropNames','COLOR', 'Niter', 2,'obj',e,'wdt',WDInx)

       r3     = reshape(result.Resid,[size(m)]);
       model3 = reshape(model,[size(m)]);

    [rms2,meanmag2]  = CalcRMS(mean(model3),r3,e,wdt,'Marker','xk','Predicted',false)
% close;
 %[rms1,meanmag1]  = CalcRMS(MS.SrcData.phot_g_mean_mag,r,e,WDInx,'Marker','xk','Predicted',true)
 hold on
    FP.plotRMS('Fieldx','MAG_PSF','PlotColor',"#7E2F8E"','PlotSymbol','*') 

%   FP3.plotRMS('Fieldx','MAG_PSF','PlotColor','#77AC30','PlotSymbol','o')
 %   hold on
    %semilogy(median(FP2.Data.MAG_PSF,'omitnan'),rms1,'o','Color','#D95319')
xlim([10 16])


%%
figure(19)
ind = 1;
plot(time(StartInd:EndInd)-t0,FP.Data.MAG_PSF(Sorted2(StartInd:EndInd),Targets(ind)),'k.')
hold on 
plot(time(StartInd:EndInd)-t0,r3(:,2) - mean(r3(:,2),'omitnan')+mean(FP.Data.MAG_PSF(Sorted2(StartInd:EndInd),Targets(2)),'omitnan'),'ro')
%plot(time(StartInd:EndInd)-t0,model2(:,2),'k.')
LgLbl{3} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(Sorted2(StartInd:EndInd),Targets(ind))))
LgLbl{4} = sprintf('Residuals + mean ; RobustSD : %.3f',RobustSD(r3(:,2)))
legend(LgLbl(3:4),'Location','best','Interpreter','latex')
set(gca , 'YDir','reverse')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
Title = sprintf('Ref Target 2  $$ B_p = $$ %.3f',FP.SrcData.phot_bp_mean_mag(Targets(ind)))
title(Title,'Interpreter','latex')

%%
figure(20)
ind =1;
plot(time(StartInd:EndInd)-t0,FP.Data.MAG_PSF(Sorted2(StartInd:EndInd),Targets(ind)),'k.')
hold on 
%plot(time(StartInd:EndInd)-t0,r3(:,ind) - mean(r3(:,ind),'omitnan')+mean(FP.Data.MAG_PSF(Sorted(StartInd:EndInd),Targets(ind)),'omitnan'),'ro')
%plot(time-t0,model2(:,1),'k.')
LgLbl{3} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(Sorted2(StartInd:EndInd),Targets(ind))))
LgLbl{4} = sprintf('Residuals + mean ; RobustSD : %.3f',RobustSD(r2(:,ind)))
legend(LgLbl(3:4),'Location','best','Interpreter','latex')
set(gca , 'YDir','reverse')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
Title = sprintf('Ref Target 1  $$ B_p = $$ %.3f',FP.SrcData.phot_bp_mean_mag(Targets(ind)))
title(Title,'Interpreter','latex')



%%

figure(20)
ind = 46;
plot(time(StartInd:EndInd)-t0,FP.Data.MAG_PSF(Sorted2(StartInd:EndInd),Targets(ind)),'k.')
hold on 
plot(time(StartInd:EndInd)-t0,r3(:,ind) - mean(r3(:,ind),'omitnan')+mean(FP.Data.MAG_PSF(Sorted2(StartInd:EndInd),Targets(ind)),'omitnan'),'ro')
%plot(time-t0,model2(:,1),'k.')
LgLbl{3} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(Sorted2(StartInd:EndInd),Targets(ind))))
LgLbl{4} = sprintf('Residuals + mean ; RobustSD : %.3f',RobustSD(r2(:,1)))
legend(LgLbl(3:4),'Location','best','Interpreter','latex')
set(gca , 'YDir','reverse')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
Title = sprintf('Ref Target 47 $$ B_p = $$ %.3f',FP.SrcData.phot_bp_mean_mag(Targets(ind)))
title(Title,'Interpreter','latex')




%%
figure(22)
ind = 1;
plot(time(StartInd:EndInd)-t0,FP.Data.MAG_PSF(Sorted2(StartInd:EndInd),1),'k.')
hold on 
plot(time(StartInd:EndInd)-t0,r3(:,1) - mean(r3(:,1),'omitnan')+mean(FP.Data.MAG_PSF(Sorted2(StartInd:EndInd),1),'omitnan'),'ro')
%plot(time-t0,model2(:,1),'k.')
LgLbl{3} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(Sorted2(StartInd:EndInd),1)))
LgLbl{4} = sprintf('Residuals + mean ; RobustSD : %.3f',RobustSD(r2(:,1)))
legend(LgLbl(3:4),'Location','best','Interpreter','latex')
set(gca , 'YDir','reverse')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
Title = sprintf('Wrong Residuals over WD target')
title(Title,'Interpreter','latex')




%%

figure(23)
ind = 1;
plot(time(StartInd:EndInd)-t0,FP.Data.MAG_PSF(Sorted2(StartInd:EndInd),1),'k.')
hold on 
plot(time(StartInd:EndInd)-t0,r3(:,48) - mean(r3(:,48),'omitnan')+mean(FP.Data.MAG_PSF(Sorted2(StartInd:EndInd),1),'omitnan'),'ro')
%plot(time-t0,model2(:,1),'k.')
LgLbl{3} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(Sorted2(StartInd:EndInd),1)))
LgLbl{4} = sprintf('Residuals + mean ; RobustSD : %.3f',RobustSD(r2(:,ind)))
legend(LgLbl(3:4),'Location','best','Interpreter','latex')
set(gca , 'YDir','reverse')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
Title = sprintf('WD Target  $$ B_p = $$ %.3f',e.LC_FP(wdt))
title(Title,'Interpreter','latex')


%% Color 

% run lsq detrend
StartInd = 1;
EndInd   = length(FP.JD);

Color = {FP.SrcData.phot_bp_mean_mag - FP.SrcData.phot_rp_mean_mag } ; 
Color{1}(1) = e.LC_coadd(wdt) ;

[~,Sorted2] = sort(FP.JD);

time = FP.JD(Sorted2);


% Mark Bad Flags :
        FlagsList =  {'NearEdge','Saturated','NaN','Negative','NearEdge'};
        Bit= BitDictionary;
        BitClass = Bit.Class;
        Flags = BitClass(FP.Data.FLAGS);
        Flags = Flags(StartInd:EndInd,:);
        FLAG = zeros(size(Flags));
        Nflag  = numel(FlagsList);
        for Iflag = 1:1:Nflag
            FieldIndex = find(strcmp(Bit.Dic.BitName,FlagsList{Iflag}));
            if ~isempty(FieldIndex)
                FLAG = FLAG  |  bitget(Flags,FieldIndex);
            else
                error('Field "%s" not found in dictionary', Args.Flags{Iflag});
            end
        end
        
        GoodFlags = ~FLAG;
            
% Mark High SNR Targets

        FlagSNR = zeros(size(FLAG));
        
        FlagSNR = (FP.Data.MAGERR_PSF < 1/50);
        
        [~,GoodTargets] = find(sum(FlagSNR) == length(FP.JD));
        
        fprintf('\nFound %d targets with SNR higher than 50 for %d measurements\n',[length(GoodTargets) ,...
            length(FP.JD)])
        
        Targets = [1] ;
        
        for Itgt = 1 : length(GoodTargets)
            
            
            FlagSum = sum(GoodFlags(:,GoodTargets(Itgt)));
            
            if FlagSum == length(FP.JD)
                fprintf('\nUsing source # %d for detrending\n',GoodTargets(Itgt))
                
                Targets = [Targets ; GoodTargets(Itgt) ];
                
            end
            
            
            
            
            
            
        end
        fprintf('\nUsing %d targets with SNR higher than 50 for %d measurements\n',[length(Targets) ,...
            length(FP.JD)])
       
       
   % slice currect data
   
   M = FP.Data.MAG_PSF(Sorted2,Targets);
   %M(:,length(Targets)+1) = FP.Data.MAG_PSF(Sorted,1);
   
   dM =  FP.Data.MAGERR_PSF(Sorted2,Targets);
  % dM(:,length(Targets)+1) = FP.Data.MAGERR_PSF(Sorted,1);
   
   C = {FP.SrcData.phot_bp_mean_mag(Targets) - FP.SrcData.phot_rp_mean_mag(Targets) }
   C{1}(1) = e.LC_coadd(wdt) ;
   

    [Result,Refstars,Model]=lsqrelphotMAT(M,dM ,'StarProp',C,'StarPropNames','COLOR', 'Niter', 2,'obj',e,'wdt',WDInx);

       r2     = Result.r2
       model2 = Result.Model

    [rms1,meanmag1]  = CalcRMS(mean(model2),r2,e,wdt,'Marker','xk','Predicted',false)
% close;
 %[rms1,meanmag1]  = CalcRMS(MS.SrcData.phot_g_mean_mag,r,e,WDInx,'Marker','xk','Predicted',true)
 hold on
    FP.plotRMS('Fieldx','MAG_PSF','PlotColor',"#7E2F8E"','PlotSymbol','*') 

    MS.plotRMS('Fieldx','MAG_PSF','PlotColor','#77AC30','PlotSymbol','o')
 %   hold on
    %semilogy(median(FP2.Data.MAG_PSF,'omitnan'),rms1,'o','Color','#D95319')
    legend('$$ m_{ij} = ZP_i + M_j +\beta (B_p - R_p)$$ ','Raw','ZP mediff','Interpreter','latex')
xlim([10 16])


t0 = ceil(FP.JD(1)) ;


%%
figure(33)
ind = 1;
plot(time-t0,FP.Data.MAG_PSF(Sorted2,1),'k.')
hold on 
plot(time-t0,r2(:,1) - mean(r2(:,1),'omitnan')+mean(FP.Data.MAG_PSF(Sorted2,1),'omitnan'),'ro')
%plot(time-t0,model2(:,1),'k.')
LgLbl{3} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(:,1)))
LgLbl{4} = sprintf('Residuals + mean ; RobustSD : %.6f',RobustSD(r2(:,1)))
legend(LgLbl(3:4),'Location','best','Interpreter','latex')
set(gca , 'YDir','reverse')
xlabel('$$ m_{ij} = ZP_i + M_j +\beta (B_p - R_p)$$ ','Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
title('Mistake','Interpreter','latex')
Title = sprintf('WD Target  $$ B_p = $$ %.3f',e.LC_FP(wdt))
title(Title,'Interpreter','latex')


%%



figure(30)
ind = 12;
plot(time-t0,FP.Data.MAG_PSF(Sorted2,Targets(ind)),'k.')
hold on 
plot(time-t0,r2(:,ind) - mean(r2(:,ind),'omitnan')+mean(FP.Data.MAG_PSF(Sorted2,Targets(ind)),'omitnan'),'ro')
%plot(time-t0,model2(:,1),'k.')
LgLbl{3} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(:,Targets(ind))))
LgLbl{4} = sprintf('Residuals + mean ; RobustSD : %.3f',RobustSD(r2(:,ind)))
legend(LgLbl(3:4),'Location','best','Interpreter','latex')
set(gca , 'YDir','reverse')
xlabel('$$ m_{ij} = ZP_i + M_j +\beta (B_p - R_p)$$ ','Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
Title = sprintf('Ref Target 12 $$ B_p = $$ %.3f',FP.SrcData.phot_bp_mean_mag(Targets(ind)))
title(Title,'Interpreter','latex')


%% CGS

%% Data extraction

%apply ZP on a copy of the forced photometry

MS = FP.copy();
% apply zp meddiff on copy
R = lcUtil.zp_meddiff(MS,'MagField','MAG_PSF','MagErrField','MAGERR_PSF');
                             
[MS,ApplyToMagFieldr] = applyZP(MS, R.FitZP,'ApplyToMagField','MAG_PSF');


wdt = 6;
% run lsq detrend
StartInd = 1;
EndInd   = length(FP.JD);

Color = {FP.SrcData.phot_bp_mean_mag - FP.SrcData.phot_rp_mean_mag } ; 
Color{1}(1) = e.LC_coadd(wdt) ;

[~,Sorted2] = sort(FP.JD);

time = FP.JD(Sorted2);


% Mark Bad Flags :
        FlagsList =  {'NearEdge','Saturated','NaN','Negative','NearEdge'};
        Bit= BitDictionary;
        BitClass = Bit.Class;
        Flags = BitClass(FP.Data.FLAGS);
        Flags = Flags(StartInd:EndInd,:);
        FLAG = zeros(size(Flags));
        Nflag  = numel(FlagsList);
        for Iflag = 1:1:Nflag
            FieldIndex = find(strcmp(Bit.Dic.BitName,FlagsList{Iflag}));
            if ~isempty(FieldIndex)
                FLAG = FLAG  |  bitget(Flags,FieldIndex);
            else
                error('Field "%s" not found in dictionary', Args.Flags{Iflag});
            end
        end
        
        GoodFlags = ~FLAG;
            
% Mark High SNR Targets

        FlagSNR = zeros(size(FLAG));
        
        FlagSNR = (FP.Data.MAGERR_PSF < 1/50);
        
        [~,GoodTargets] = find(sum(FlagSNR) == length(FP.JD));
        
        fprintf('\nFound %d targets with SNR higher than 50 for %d measurements\n',[length(GoodTargets) ,...
            length(FP.JD)])
        
        Targets =[];
        
        for Itgt = 1 : length(GoodTargets)
            
            
            FlagSum = sum(GoodFlags(:,GoodTargets(Itgt)));
            
            if FlagSum == length(FP.JD)
                fprintf('\nUsing source # %d for detrending\n',GoodTargets(Itgt))
                
                Targets = [Targets ; GoodTargets(Itgt) ];
                
            end
            
            
            
            
            
            
        end
        fprintf('\nUsing %d targets with SNR higher than 50 for %d measurements\n',[length(Targets) ,...
            length(FP.JD)])
       
       
   % slice currect data
   
   M = FP.Data.MAG_PSF(Sorted2,Targets);
   M(:,length(Targets)+1) = FP.Data.MAG_PSF(Sorted2,1);
   
   dM =  FP.Data.MAGERR_PSF(Sorted2,Targets);
   dM(:,length(Targets)+1) = FP.Data.MAGERR_PSF(Sorted2,1);
   
   C = {FP.SrcData.phot_bp_mean_mag(Targets) - FP.SrcData.phot_rp_mean_mag(Targets) }
   C{1}(length(Targets)+1) = e.LC_coadd(wdt) ;
   

    [Result,Refstars,Model]=lsqrelphotMAT(M,dM ,'StarProp',{},'StarPropNames','COLOR', 'Niter', 2,'obj',e,'wdt',WDInx,'Method','cgs')

       r2     = reshape(Result.Resid,[FP.Nepoch,length(Targets)+1]);
       model2 = reshape(Model,[FP.Nepoch,length(Targets)+1]);

    [rms1,meanmag1]  = CalcRMS(mean(model2),r2,e,wdt,'Marker','xk','Predicted',false)
% close;
 %[rms1,meanmag1]  = CalcRMS(MS.SrcData.phot_g_mean_mag,r,e,WDInx,'Marker','xk','Predicted',true)
 hold on
    FP.plotRMS('Fieldx','MAG_PSF','PlotColor',"#7E2F8E"','PlotSymbol','*') 

    MS.plotRMS('Fieldx','MAG_PSF','PlotColor','#77AC30','PlotSymbol','o')
 %   hold on
    %semilogy(median(FP2.Data.MAG_PSF,'omitnan'),rms1,'o','Color','#D95319')
    legend('Model','Raw','ZP mediff')
xlim([10 16])


t0 = ceil(FP.JD(1)) ;


%%
figure(13)
ind = 1;
plot(time-t0,FP.Data.MAG_PSF(Sorted2,1),'k.')
hold on 
plot(time-t0,r2(:,48) - mean(r2(:,48),'omitnan')+mean(FP.Data.MAG_PSF(Sorted2,1),'omitnan'),'ro')
%plot(time-t0,model2(:,1),'k.')
LgLbl{3} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(:,1)))
LgLbl{4} = sprintf('Residuals + mean ; RobustSD : %.3f',RobustSD(r2(:,48)))
legend(LgLbl(3:4),'Location','best','Interpreter','latex')
set(gca , 'YDir','reverse')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
title('Mistake','Interpreter','latex')
Title = sprintf('WD Target  $$ B_p = $$ %.3f',e.LC_FP(wdt))
title(Title,'Interpreter','latex')

result.Par'
%%



%%

figure(10)
ind = 1;
plot(time-t0,FP.Data.MAG_PSF(Sorted2,Targets(ind)),'k.')
hold on 
plot(time-t0,r2(:,ind) - mean(r2(:,ind),'omitnan')+mean(FP.Data.MAG_PSF(Sorted2,Targets(ind)),'omitnan'),'ro')
%plot(time-t0,model2(:,1),'k.')
LgLbl{3} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(:,Targets(ind))))
LgLbl{4} = sprintf('Residuals + mean ; RobustSD : %.3f',RobustSD(r2(:,1)))
legend(LgLbl(3:4),'Location','best','Interpreter','latex')
set(gca , 'YDir','reverse')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
Title = sprintf('Ref Target 1 $$ B_p = $$ %.3f',FP.SrcData.phot_bp_mean_mag(Targets(ind)))
title(Title,'Interpreter','latex')

%%

figure(11)
ind = 47;
plot(time-t0,FP.Data.MAG_PSF(Sorted2,Targets(ind)),'k.')
hold on 
plot(time-t0,r2(:,ind) - mean(r2(:,ind),'omitnan')+mean(FP.Data.MAG_PSF(Sorted2,Targets(ind)),'omitnan'),'ro')
%plot(time-t0,model2(:,1),'k.')
LgLbl{3} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(:,Targets(ind))))
LgLbl{4} = sprintf('Residuals + mean ; RobustSD : %.3f',RobustSD(r2(:,1)))
legend(LgLbl(3:4),'Location','best','Interpreter','latex')
set(gca , 'YDir','reverse')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
Title = sprintf('Ref Target 47 $$ B_p = $$ %.3f',FP.SrcData.phot_bp_mean_mag(Targets(ind)))
title(Title,'Interpreter','latex')



%% AM

%% Data extraction

%apply ZP on a copy of the forced photometry

MS = FP.copy();
% apply zp meddiff on copy
R = lcUtil.zp_meddiff(MS,'MagField','MAG_PSF','MagErrField','MAGERR_PSF');
                             
[MS,ApplyToMagFieldr] = applyZP(MS, R.FitZP,'ApplyToMagField','MAG_PSF');


wdt = 6;
% run lsq detrend
StartInd = 1;
EndInd   = length(FP.JD);

Color = {FP.SrcData.phot_bp_mean_mag - FP.SrcData.phot_rp_mean_mag } ; 
Color{1}(1) = e.LC_coadd(wdt) ;

[~,Sorted2] = sort(FP.JD);

time = FP.JD(Sorted2);


% Mark Bad Flags :
        FlagsList =  {'NearEdge','Saturated','NaN','Negative','NearEdge'};
        Bit= BitDictionary;
        BitClass = Bit.Class;
        Flags = BitClass(FP.Data.FLAGS);
        Flags = Flags(StartInd:EndInd,:);
        FLAG = zeros(size(Flags));
        Nflag  = numel(FlagsList);
        for Iflag = 1:1:Nflag
            FieldIndex = find(strcmp(Bit.Dic.BitName,FlagsList{Iflag}));
            if ~isempty(FieldIndex)
                FLAG = FLAG  |  bitget(Flags,FieldIndex);
            else
                error('Field "%s" not found in dictionary', Args.Flags{Iflag});
            end
        end
        
        GoodFlags = ~FLAG;
            
% Mark High SNR Targets

        FlagSNR = zeros(size(FLAG));
        
        FlagSNR = (FP.Data.MAGERR_PSF < 1/50);
        
        [~,GoodTargets] = find(sum(FlagSNR) == length(FP.JD));
        
        fprintf('\nFound %d targets with SNR higher than 50 for %d measurements\n',[length(GoodTargets) ,...
            length(FP.JD)])
        
        Targets =[1];
        
        for Itgt = 1 : length(GoodTargets)
            
            
            FlagSum = sum(GoodFlags(:,GoodTargets(Itgt)));
            
            if FlagSum == length(FP.JD)
                fprintf('\nUsing source # %d for detrending\n',GoodTargets(Itgt))
                
                Targets = [Targets ; GoodTargets(Itgt) ];
                
            end
            
            
            
            
            
            
        end
        fprintf('\nUsing %d targets with SNR higher than 50 for %d measurements\n',[length(Targets) ,...
            length(FP.JD)])
       
       
   % slice currect data
   
   M = FP.Data.MAG_PSF(Sorted2,Targets);
 %  M(:,length(Targets)+1) = FP.Data.MAG_PSF(Sorted,1);
   
   dM =  FP.Data.MAGERR_PSF(Sorted2,Targets);
 %  dM(:,length(Targets)+1) = FP.Data.MAGERR_PSF(Sorted,1);
   
   C = {FP.SrcData.phot_bp_mean_mag(Targets) - FP.SrcData.phot_rp_mean_mag(Targets) }
   C{1}(1) = e.LC_coadd(wdt) ;
   

    [Result,Refstars,Model]=lsqrelphotMAT(M,dM ,'StarProp',C,'StarPropNames','COLOR', 'Niter', 2,'obj',e,'wdt',WDInx,'Method','cgs'...
        ,'ImageProp',{AirMass})

       r5     = Result.r2;
       model5 = Result.Model;
       
     [Result,Refstars,Model]=lsqrelphotMAT(M,dM ,'StarProp',{},'StarPropNames','COLOR', 'Niter', 2,'obj',e,'wdt',WDInx,'Method','cgs'...
        ,'ImageProp',{AirMass})

       r6    = Result.r2;
       model6 = Result.Model;

    [rms5,meanmag1]  = CalcRMS(mean(model5),r5,e,wdt,'Marker','xk','Predicted',false)
% close;
 %[rms1,meanmag1]  = CalcRMS(MS.SrcData.phot_g_mean_mag,r,e,WDInx,'Marker','xk','Predicted',true)
 hold on
%  semilogy(mean(model2),rms1,'s')
    FP.plotRMS('Fieldx','MAG_PSF','PlotColor',"#7E2F8E"','PlotSymbol','*') 

    MS.plotRMS('Fieldx','MAG_PSF','PlotColor','#77AC30','PlotSymbol','o')
 %   hold on
    %semilogy(median(FP2.Data.MAG_PSF,'omitnan'),rms1,'o','Color','#D95319')
    legend('$$ m_{ij} = ZP_i + M_j +\beta (B_p - R_p)+ \alpha \chi_i$$ ','$$ m_{ij} = ZP_i + M_j +\beta (B_p - R_p)$$ ','Raw','ZP mediff','Interpreter','latex')

xlim([10 16])


t0 = ceil(FP.JD(1)) ;

r2 = r5 ;
model2 = model5;
%%
figure(13)
ind = 1;
plot(time-t0,FP.Data.MAG_PSF(Sorted2,1),'k.')
hold on 
plot(time-t0,r5(:,ind) - mean(r5(:,ind),'omitnan')+mean(FP.Data.MAG_PSF(Sorted2,1),'omitnan'),'ro')
%plot(time-t0,model2(:,1),'k.')
LgLbl{3} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(:,1)))
LgLbl{4} = sprintf('Residuals + mean ; RobustSD : %.3f',RobustSD(r5(:,ind)))
legend(LgLbl(3:4),'Location','best','Interpreter','latex')
set(gca , 'YDir','reverse')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
title('Mistake','Interpreter','latex')
Title = sprintf('WD Target  $$ B_p = $$ %.3f',e.LC_FP(wdt))
title(Title,'Interpreter','latex')

%result.Par'
%%


r2 = r5
model2 = model5
%%

figure(10)
ind = 1;
plot(time-t0,FP.Data.MAG_PSF(Sorted2,Targets(ind)),'k.')
hold on 
plot(time-t0,r6(:,ind) - mean(r6(:,ind),'omitnan')+mean(FP.Data.MAG_PSF(Sorted2,Targets(ind)),'omitnan'),'ro')
%plot(time-t0,model2(:,1),'k.')
LgLbl{3} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(:,Targets(ind))))
LgLbl{4} = sprintf('Residuals + mean ; RobustSD : %.3f',RobustSD(r6(:,ind)))
legend(LgLbl(3:4),'Location','best','Interpreter','latex')
set(gca , 'YDir','reverse')
xlabel('$$ m_{ij} = ZP_i + M_j +\beta (B_p - R_p)+ \alpha \chi_i$$ ','Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
Title = sprintf('WD Target 1 $$ B_p = $$ %.3f',e.LC_FP(wdt))
title(Title,'Interpreter','latex')
%%

figure(10)
ind = 1;
plot(time-t0,FP.Data.MAG_PSF(Sorted2,Targets(ind)),'k.')
hold on 
plot(time-t0,r5(:,ind) - mean(r5(:,ind),'omitnan')+mean(FP.Data.MAG_PSF(Sorted2,Targets(ind)),'omitnan'),'ro')
%plot(time-t0,model2(:,1),'k.')
LgLbl{3} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(:,Targets(ind))))
LgLbl{4} = sprintf('Residuals + mean ; RobustSD : %.3f',RobustSD(r5(:,ind)))
legend(LgLbl(3:4),'Location','best','Interpreter','latex')
set(gca , 'YDir','reverse')
xlabel('$$ m_{ij} = ZP_i + M_j +\beta (B_p - R_p)+ \alpha \chi_i$$ ','Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
Title = sprintf('WD Target 1 $$ B_p = $$ %.3f',e.LC_FP(wdt))
title(Title,'Interpreter','latex')




%%

figure(11)
ind = 47;
plot(time-t0,FP.Data.MAG_PSF(Sorted2,Targets(ind)),'k.')
hold on 
plot(time-t0,r2(:,ind) - mean(r2(:,ind),'omitnan')+mean(FP.Data.MAG_PSF(Sorted2,Targets(ind)),'omitnan'),'ro')
%plot(time-t0,model2(:,1),'k.')
LgLbl{3} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(:,Targets(ind))))
LgLbl{4} = sprintf('Residuals + mean ; RobustSD : %.3f',RobustSD(r2(:,ind)))
legend(LgLbl(3:4),'Location','best','Interpreter','latex')
set(gca , 'YDir','reverse')
xlabel('$$ m_{ij} = ZP_i + M_j +\beta (B_p - R_p)+ \alpha \chi_i$$ ','Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
Title = sprintf('Ref Target 47 $$ B_p = $$ %.3f',FP.SrcData.phot_bp_mean_mag(Targets(ind)))
title(Title,'Interpreter','latex')

%%
figure(100)
ind = 12;
plot(time-t0,FP.Data.MAG_PSF(Sorted2,Targets(ind)),'k.')
hold on 
plot(time-t0,r2(:,ind) - mean(r2(:,ind),'omitnan')+mean(FP.Data.MAG_PSF(Sorted2,Targets(ind)),'omitnan'),'ro')
%plot(time-t0,model2(:,1),'k.')
LgLbl{3} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(:,Targets(ind))))
LgLbl{4} = sprintf('Residuals + mean ; RobustSD : %.3f',RobustSD(r2(:,ind)))
legend(LgLbl(3:4),'Location','best','Interpreter','latex')
set(gca , 'YDir','reverse')
xlabel('$$ m_{ij} = ZP_i + M_j +\beta (B_p - R_p)+ \alpha \chi_i$$ ','Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
Title = sprintf('Ref Target 12 $$ B_p = $$ %.3f',FP.SrcData.phot_bp_mean_mag(Targets(ind)))
title(Title,'Interpreter','latex')


%%
figure(111)
ind = 12;
plot(time-t0,FP.Data.MAG_PSF(Sorted2,Targets(ind)),'k.')
hold on 
plot(time-t0,r2(:,ind) - mean(r2(:,ind),'omitnan')+mean(FP.Data.MAG_PSF(Sorted2,Targets(ind)),'omitnan'),'ro')
%plot(time-t0,model2(:,1),'k.')
LgLbl{3} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(:,Targets(ind))))
LgLbl{4} = sprintf('Residuals + mean ; RobustSD : %.3f',RobustSD(r2(:,ind)))
legend(LgLbl(3:4),'Location','best','Interpreter','latex')
set(gca , 'YDir','reverse')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
Title = sprintf('Ref Target 47 $$ B_p = $$ %.3f',FP.SrcData.phot_bp_mean_mag(Targets(ind)))
title(Title,'Interpreter','latex')



%% choose targets with magnitude like target

%% Data extraction

%apply ZP on a copy of the forced photometry

MS = FP.copy();
% apply zp meddiff on copy
R = lcUtil.zp_meddiff(MS,'MagField','MAG_PSF','MagErrField','MAGERR_PSF');
                             
[MS,ApplyToMagFieldr] = applyZP(MS, R.FitZP,'ApplyToMagField','MAG_PSF');


wdt = 6;
% run lsq detrend
StartInd = 1;
EndInd   = length(FP.JD);

Color = {FP.SrcData.phot_bp_mean_mag - FP.SrcData.phot_rp_mean_mag } ; 
Color{1}(1) = e.LC_coadd(wdt) ;

[~,Sorted2] = sort(FP.JD);

time = FP.JD(Sorted2);


% Mark Bad Flags :
        FlagsList =  {'NearEdge','Saturated','NaN','Negative','NearEdge'};
        Bit= BitDictionary;
        BitClass = Bit.Class;
        Flags = BitClass(FP.Data.FLAGS);
        Flags = Flags(StartInd:EndInd,:);
        FLAG = zeros(size(Flags));
        Nflag  = numel(FlagsList);
        for Iflag = 1:1:Nflag
            FieldIndex = find(strcmp(Bit.Dic.BitName,FlagsList{Iflag}));
            if ~isempty(FieldIndex)
                FLAG = FLAG  |  bitget(Flags,FieldIndex);
            else
                error('Field "%s" not found in dictionary', Args.Flags{Iflag});
            end
        end
        
        GoodFlags = ~FLAG;
            
% Mark High SNR Targets

        FlagSNR = zeros(size(FLAG));
        
        FlagSNR = (FP.Data.MAGERR_PSF < 1/20);
        
        [~,GoodTargets] = find(sum(FlagSNR) == length(FP.JD));
        
        fprintf('\nFound %d targets with SNR higher than 50 for %d measurements\n',[length(GoodTargets) ,...
            length(FP.JD)])
        
        Targets =[1];
        
        for Itgt = 1 : length(GoodTargets)
            
            
            FlagSum = sum(GoodFlags(:,GoodTargets(Itgt)));
            
            if FlagSum == length(FP.JD)
                fprintf('\nUsing source # %d for detrending\n',GoodTargets(Itgt))
                
                if median(FP.Data.MAG_PSF(Sorted2,GoodTargets(Itgt)),'omitnan') < 15.5
                
                       Targets = [Targets ; GoodTargets(Itgt) ];
                end
                
            end
            
            
            
            
            
            
        end
        fprintf('\nUsing %d targets with SNR higher than 50 for %d measurements\n',[length(Targets) ,...
            length(FP.JD)])
       
       
   % slice currect data
   
   M = FP.Data.MAG_PSF(Sorted2,Targets);
   %M(:,length(Targets)+1) = FP.Data.MAG_PSF(Sorted2,1);
   
   dM =  FP.Data.MAGERR_PSF(Sorted2,Targets);
   %dM(:,length(Targets)+1) = FP.Data.MAGERR_PSF(Sorted2,1);
   
   C = {FP.SrcData.phot_bp_mean_mag(Targets) - FP.SrcData.phot_rp_mean_mag(Targets) }
   C{1}(1) = e.LC_coadd(wdt) ;
   

    [Result1,Refstars,Model]=lsqrelphotMAT(M,dM , 'Niter', 2,'obj',e,'wdt',wdt,'Method','cgs')

       r2     = Result1.r2;
       model2 = Result1.Model;
       
          

    [Result2,Refstars,Model]=lsqrelphotMAT(M,dM ,'StarProp',C,'StarPropNames','COLOR', 'Niter', 2,'obj',e,'wdt',wdt,'Method','cgs'...
        ,'ImageProp',{AirMass})

       r5     = Result2.r2;
       model5 = Result2.Model;
       
     [Result3,Refstars,Model]=lsqrelphotMAT(M,dM ,'StarProp',C,'StarPropNames','COLOR', 'Niter', 2,'obj',e,'wdt',wdt,'Method','cgs')

       r6    = Result3.r2;
       model6 = Result3.Model;

    [rms1,meanmag1]  = CalcRMS(mean(model5),r5,e,wdt,'Marker','xk','Predicted',false)
% close;
 %[rms1,meanmag1]  = CalcRMS(MS.SrcData.phot_g_mean_mag,r,e,WDInx,'Marker','xk','Predicted',true)
 hold on
    FP.plotRMS('Fieldx','MAG_PSF','PlotColor',"#7E2F8E"','PlotSymbol','*') 

    MS.plotRMS('Fieldx','MAG_PSF','PlotColor','#77AC30','PlotSymbol','o')
 %   hold on
    %semilogy(median(FP2.Data.MAG_PSF,'omitnan'),rms1,'o','Color','#D95319')
    legend('Model','Raw','ZP mediff')
xlim([16 18])


t0 = ceil(FP.JD(1)) ;


%%
figure(100)
ind = 1;
plot(time-t0,FP.Data.MAG_PSF(Sorted2,Targets(ind)),'k.')
hold on 
plot(time-t0,r2(:,ind) - mean(r2(:,ind),'omitnan')+mean(FP.Data.MAG_PSF(Sorted2,Targets(ind)),'omitnan'),'ro')
%plot(time-t0,model2(:,1),'k.')
LgLbl{3} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(:,Targets(ind))))
LgLbl{4} = sprintf('Residuals + mean ; RobustSD : %.6f',RobustSD(r2(:,ind)))
legend(LgLbl(3:4),'Location','best','Interpreter','latex')
set(gca , 'YDir','reverse')
xlabel('$$ m_{ij} = ZP_i + M_j $$ ','Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
Title = sprintf('Ref Target 12 $$ B_p = $$ %.3f',FP.SrcData.phot_bp_mean_mag(Targets(ind)))
title(Title,'Interpreter','latex')
plot(time-t0,model2(:,1),'b.')


%%
figure(101)
ind =1;
plot(time-t0,FP.Data.MAG_PSF(Sorted2,Targets(ind)),'k.')
hold on 
plot(time-t0,r6(:,ind) - mean(r6(:,ind),'omitnan')+mean(FP.Data.MAG_PSF(Sorted2,Targets(ind)),'omitnan'),'ro')
%plot(time-t0,model2(:,1),'k.')
LgLbl{3} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(:,Targets(ind))))
LgLbl{4} = sprintf('Residuals + mean ; RobustSD : %.6f',RobustSD(r6(:,ind)))
legend(LgLbl(3:4),'Location','best','Interpreter','latex')
set(gca , 'YDir','reverse')
xlabel('$$ m_{ij} = ZP_i + M_j +\beta (B_p - R_p)$$ ','Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
Title = sprintf('Ref Target 12 $$ B_p = $$ %.3f',FP.SrcData.phot_bp_mean_mag(Targets(ind)))
title(Title,'Interpreter','latex')

plot(time-t0,model6(:,1),'b.')

%%
figure(102)
ind = 1;
plot(time-t0,FP.Data.MAG_PSF(Sorted2,Targets(ind)),'k.')
hold on 
plot(time-t0,r5(:,ind) - mean(r5(:,ind),'omitnan')+mean(FP.Data.MAG_PSF(Sorted2,Targets(ind)),'omitnan'),'ro')
%plot(time-t0,model2(:,1),'k.')
LgLbl{3} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(:,Targets(ind))))
LgLbl{4} = sprintf('Residuals + mean ; RobustSD : %.6f',RobustSD(r5(:,ind)))
legend(LgLbl(3:4),'Location','best','Interpreter','latex')
set(gca , 'YDir','reverse')
xlabel('$$ m_{ij} = ZP_i + M_j +\beta (B_p - R_p) +\alpha \chi_i$$ ','Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
Title = sprintf('Ref Target 12 $$ B_p = $$ %.3f',FP.SrcData.phot_bp_mean_mag(Targets(ind)))
title(Title,'Interpreter','latex')

%plot(time-t0,model6(:,1),'.')


%% Sysrem
MS = FP.copy()
% apply zp meddiff on copy
R = lcUtil.zp_meddiff(MS,'MagField','MAG_PSF','MagErrField','MAGERR_PSF');
                             
[MS,ApplyToMagFieldr] = applyZP(MS, R.FitZP,'ApplyToMagField','MAG_PSF');


figure(103);
plot(MS.JD,MS.Data.MAG_PSF(:,1),'.')
hold on
MS.sysrem('MagFields',{'MAG_PSF'},'MagErrFields',{'MAGERR_PSF'})
plot(MS.JD,MS.Data.MAG_PSF(:,1),'x')
hold on
MS.sysrem('MagFields',{'MAG_PSF'},'MagErrFields',{'MAGERR_PSF'})
plot(MS.JD,MS.Data.MAG_PSF(:,1),'o')
legend('ZP meddiff','+ SysRem','+2 SysRem','Interpreter','latex')
set(gca , 'YDir','reverse')




figure(104);
plot(MS.JD,MS.Data.MAG_PSF(:,Targets(47)),'.')
hold on
MS.sysrem('MagFields',{'MAG_PSF'},'MagErrFields',{'MAGERR_PSF'})
plot(MS.JD,MS.Data.MAG_PSF(:,Targets(47)),'x')
hold on
MS.sysrem('MagFields',{'MAG_PSF'},'MagErrFields',{'MAGERR_PSF'})
plot(MS.JD,MS.Data.MAG_PSF(:,Targets(47)),'o')
legend('ZP meddiff','+ SysRem','+2 SysRem','Interpreter','latex')
set(gca , 'YDir','reverse')


%% Color 

% run lsq detrend
StartInd = 1;
EndInd   = length(FP.JD);

Color = {FP.SrcData.phot_bp_mean_mag - FP.SrcData.phot_rp_mean_mag } ; 
Color{1}(1) = e.LC_coadd(wdt) ;

[~,Sorted2] = sort(FP.JD);

time = FP.JD(Sorted2);


% Mark Bad Flags :
        FlagsList =  {'NearEdge','Saturated','NaN','Negative','NearEdge'};
        Bit= BitDictionary;
        BitClass = Bit.Class;
        Flags = BitClass(FP.Data.FLAGS);
        Flags = Flags(StartInd:EndInd,:);
        FLAG = zeros(size(Flags));
        Nflag  = numel(FlagsList);
        for Iflag = 1:1:Nflag
            FieldIndex = find(strcmp(Bit.Dic.BitName,FlagsList{Iflag}));
            if ~isempty(FieldIndex)
                FLAG = FLAG  |  bitget(Flags,FieldIndex);
            else
                error('Field "%s" not found in dictionary', Args.Flags{Iflag});
            end
        end
        
        GoodFlags = ~FLAG;
            
% Mark High SNR Targets

        FlagSNR = zeros(size(FLAG));
        
        FlagSNR = (FP.Data.MAGERR_PSF < 1/50);
        
        [~,GoodTargets] = find(sum(FlagSNR) == length(FP.JD));
        
        fprintf('\nFound %d targets with SNR higher than 50 for %d measurements\n',[length(GoodTargets) ,...
            length(FP.JD)])
        
        Targets = [1] ;
        
        for Itgt = 1 : length(GoodTargets)
            
            
            FlagSum = sum(GoodFlags(:,GoodTargets(Itgt)));
            
            if FlagSum == length(FP.JD)
                fprintf('\nUsing source # %d for detrending\n',GoodTargets(Itgt))
                
                Targets = [Targets ; GoodTargets(Itgt) ];
                
            end
            
            
            
            
            
            
        end
        fprintf('\nUsing %d targets with SNR higher than 50 for %d measurements\n',[length(Targets) ,...
            length(FP.JD)])
       
       
   % slice currect data
   
   M = FP.Data.MAG_PSF(Sorted2,Targets);
   %M(:,length(Targets)+1) = FP.Data.MAG_PSF(Sorted,1);
   
   dM =  FP.Data.MAGERR_PSF(Sorted2,Targets);
  % dM(:,length(Targets)+1) = FP.Data.MAGERR_PSF(Sorted,1);
   
   C = {FP.SrcData.phot_bp_mean_mag(Targets) - FP.SrcData.phot_rp_mean_mag(Targets) }
   C{1}(1) = e.LC_coadd(wdt) ;
   

    [Result,Refstars,Model]=lsqrelphotMAT(M,dM ,'StarProp',C,'StarPropNames','COLOR', 'Niter', 2,'obj',e,'wdt',6,'Method','cgs');

       r2     = Result.r2
       model2 = Result.Model
       
%%
figure(333)
ind = 1;
plot(time-t0,FP.Data.MAG_PSF(Sorted2,1),'k.')
hold on 
plot(time-t0,r2(:,1) - mean(r2(:,1),'omitnan')+mean(FP.Data.MAG_PSF(Sorted2,1),'omitnan'),'ro')
%plot(time-t0,model2(:,1),'k.')
LgLbl{3} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(:,1)))
LgLbl{4} = sprintf('Residuals + mean ; RobustSD : %.15f',RobustSD(r2(:,1)))
legend(LgLbl(3:4),'Location','best','Interpreter','latex')
set(gca , 'YDir','reverse')
xlabel('$$ m_{ij} = ZP_i + M_j +\beta (B_p - R_p)$$ ','Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
title('Mistake','Interpreter','latex')
Title = sprintf('WD Target  $$ B_p = $$ %.3f',e.LC_FP(wdt))
title(Title,'Interpreter','latex')


%% No Color 

% run lsq detrend
StartInd = 1;
EndInd   = length(FP.JD);

Color = {FP.SrcData.phot_bp_mean_mag - FP.SrcData.phot_rp_mean_mag } ; 
Color{1}(1) = e.LC_coadd(wdt) ;

[~,Sorted2] = sort(FP.JD);

time = FP.JD(Sorted2);


% Mark Bad Flags :
        FlagsList =  {'NearEdge','Saturated','NaN','Negative','NearEdge'};
        Bit= BitDictionary;
        BitClass = Bit.Class;
        Flags = BitClass(FP.Data.FLAGS);
        Flags = Flags(StartInd:EndInd,:);
        FLAG = zeros(size(Flags));
        Nflag  = numel(FlagsList);
        for Iflag = 1:1:Nflag
            FieldIndex = find(strcmp(Bit.Dic.BitName,FlagsList{Iflag}));
            if ~isempty(FieldIndex)
                FLAG = FLAG  |  bitget(Flags,FieldIndex);
            else
                error('Field "%s" not found in dictionary', Args.Flags{Iflag});
            end
        end
        
        GoodFlags = ~FLAG;
            
% Mark High SNR Targets

        FlagSNR = zeros(size(FLAG));
        
        FlagSNR = (FP.Data.MAGERR_PSF < 1/50);
        
        [~,GoodTargets] = find(sum(FlagSNR) == length(FP.JD));
        
        fprintf('\nFound %d targets with SNR higher than 50 for %d measurements\n',[length(GoodTargets) ,...
            length(FP.JD)])
        
        Targets = [1] ;
        
        for Itgt = 1 : length(GoodTargets)
            
            
            FlagSum = sum(GoodFlags(:,GoodTargets(Itgt)));
            
            if FlagSum == length(FP.JD)
                fprintf('\nUsing source # %d for detrending\n',GoodTargets(Itgt))
                
                Targets = [Targets ; GoodTargets(Itgt) ];
                
            end
            
            
            
            
            
            
        end
        fprintf('\nUsing %d targets with SNR higher than 50 for %d measurements\n',[length(Targets) ,...
            length(FP.JD)])
       
       
   % slice currect data
   
   M = FP.Data.MAG_PSF(Sorted2,Targets);
   %M(:,length(Targets)+1) = FP.Data.MAG_PSF(Sorted,1);
   
   dM =  FP.Data.MAGERR_PSF(Sorted2,Targets);
  % dM(:,length(Targets)+1) = FP.Data.MAGERR_PSF(Sorted,1);
   
   C = {FP.SrcData.phot_bp_mean_mag(Targets) - FP.SrcData.phot_rp_mean_mag(Targets) }
   C{1}(1) = e.LC_coadd(wdt) ;
   

    [Result,Refstars,Model]=lsqrelphotMAT(M,dM , 'Niter', 2,'obj',e,'wdt',6,'Method','cgs');

       r2     = Result.r2
       model2 = Result.Model
       
%%
figure(433)
ind = 1;
plot(time-t0,FP.Data.MAG_PSF(Sorted2,1),'k.')
hold on 
plot(time-t0,r2(:,1) - mean(r2(:,1),'omitnan')+mean(FP.Data.MAG_PSF(Sorted2,1),'omitnan'),'ro')
%plot(time-t0,model2(:,1),'k.')
LgLbl{3} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(:,1)))
LgLbl{4} = sprintf('Residuals + mean ; RobustSD : %.6f',RobustSD(r2(:,1)))
legend(LgLbl(3:4),'Location','best','Interpreter','latex')
set(gca , 'YDir','reverse')
xlabel('$$ m_{ij} = ZP_i + M_j $$ ','Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
title('Mistake','Interpreter','latex')
Title = sprintf('WD Target  $$ B_p = $$ %.3f',e.LC_FP(wdt))
title(Title,'Interpreter','latex')




%% Color 

% run lsq detrend
StartInd = 1;
EndInd   = length(FP.JD);

Color = {FP.SrcData.phot_bp_mean_mag - FP.SrcData.phot_rp_mean_mag } ; 
Color{1}(1) = e.LC_coadd(wdt) ;

[~,Sorted2] = sort(FP.JD);

time = FP.JD(Sorted2);


% Mark Bad Flags :
        FlagsList =  {'NearEdge','Saturated','NaN','Negative','NearEdge'};
        Bit= BitDictionary;
        BitClass = Bit.Class;
        Flags = BitClass(FP.Data.FLAGS);
        Flags = Flags(StartInd:EndInd,:);
        FLAG = zeros(size(Flags));
        Nflag  = numel(FlagsList);
        for Iflag = 1:1:Nflag
            FieldIndex = find(strcmp(Bit.Dic.BitName,FlagsList{Iflag}));
            if ~isempty(FieldIndex)
                FLAG = FLAG  |  bitget(Flags,FieldIndex);
            else
                error('Field "%s" not found in dictionary', Args.Flags{Iflag});
            end
        end
        
        GoodFlags = ~FLAG;
            
% Mark High SNR Targets

        FlagSNR = zeros(size(FLAG));
        
        FlagSNR = (FP.Data.MAGERR_PSF < 1/50);
        
        [~,GoodTargets] = find(sum(FlagSNR) == length(FP.JD));
        
        fprintf('\nFound %d targets with SNR higher than 50 for %d measurements\n',[length(GoodTargets) ,...
            length(FP.JD)])
        
        Targets = [1] ;
        
        for Itgt = 1 : length(GoodTargets)
            
            
            FlagSum = sum(GoodFlags(:,GoodTargets(Itgt)));
            
            if FlagSum == length(FP.JD)
                fprintf('\nUsing source # %d for detrending\n',GoodTargets(Itgt))
                
                Targets = [Targets ; GoodTargets(Itgt) ];
                
            end
            
            
            
            
            
            
        end
        fprintf('\nUsing %d targets with SNR higher than 50 for %d measurements\n',[length(Targets) ,...
            length(FP.JD)])
       
       
   % slice currect data
   
   M = FP.Data.MAG_PSF(Sorted2,Targets);
   %M(:,length(Targets)+1) = FP.Data.MAG_PSF(Sorted,1);
   
   dM =  FP.Data.MAGERR_PSF(Sorted2,Targets);
  % dM(:,length(Targets)+1) = FP.Data.MAGERR_PSF(Sorted,1);
   
   C = {FP.SrcData.phot_bp_mean_mag(Targets) - FP.SrcData.phot_rp_mean_mag(Targets) }
   C{1}(1) = e.LC_coadd(wdt) ;
   

    [Result,Refstars,Model]=lsqrelphotMAT(M,dM ,'StarProp',C,'StarPropNames','COLOR', 'Niter', 2,'obj',e,'wdt',6,'ImageProp',{AirMass},'Method','cgs');

       r2     = Result.r2
       model2 = Result.Model
       
%%
figure(533)
ind = 1;
plot(time-t0,FP.Data.MAG_PSF(Sorted2,1),'k.')
hold on 
plot(time-t0,r2(:,1) - mean(r2(:,1),'omitnan')+mean(FP.Data.MAG_PSF(Sorted2,1),'omitnan'),'ro')
%plot(time-t0,model2(:,1),'k.')
LgLbl{3} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(:,1)))
LgLbl{4} = sprintf('Residuals + mean ; RobustSD : %.15f',RobustSD(r2(:,1)))
legend(LgLbl(3:4),'Location','best','Interpreter','latex')
set(gca , 'YDir','reverse')
xlabel('$$ m_{ij} = ZP_i + M_j +\beta (B_p - R_p) +\alpha\chi_i$$ ','Interpreter','latex')
ylabel('Inst Mag','Interpreter','latex')
title('Mistake','Interpreter','latex')
Title = sprintf('WD Target  $$ B_p = $$ %.3f',e.LC_FP(wdt))
title(Title,'Interpreter','latex')




%% relative flux

RelLC = zeros(length(FP.JD),1);

Ntgt = length(Targets)-1;

for Itgt = 2: Ntgt
    
    RelLC(:) = RelLC(:) +(1./Ntgt)*FP.Data.FLUX_PSF(Sorted2,Targets(Itgt))
    
    
    
end

subplot(3,1,1)
plot(time-t0,RelLC/median(RelLC),'.')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Normilized Flux','Interpreter','latex')

Title = sprintf('Normlized light curve of brightest targets')
title(Title,'Interpreter','latex')
legend(['RobustSD : ',num2str(RobustSD(RelLC/median(RelLC)))],'Interperter','latex')
subplot(3,1,2)
plot(time-t0,FP.Data.FLUX_PSF(:,1)/median(FP.Data.FLUX_PSF(:,1)),'o')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Normilized Flux','Interpreter','latex')
legend(['RobustSD : ',num2str(RobustSD(FP.Data.FLUX_PSF(:,1)/median(FP.Data.FLUX_PSF(:,1))))],'Interperter','latex')
Title = sprintf('Normlized light curve of a WD target')
title(Title,'Interpreter','latex')
subplot(3,1,3)
plot(time-t0,(FP.Data.FLUX_PSF(:,1)/median(FP.Data.FLUX_PSF(:,1)))./(RelLC/median(RelLC)),'o')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Normilized Flux','Interpreter','latex')
legend(['RobustSD : ',num2str(RobustSD((FP.Data.FLUX_PSF(:,1)/median(FP.Data.FLUX_PSF(:,1)))./(RelLC/median(RelLC))))],'Interperter','latex')
Title = sprintf('Relative light curve of a WD target')
title(Title,'Interpreter','latex')


%% with zp
figure(203)

subplot(3,1,1)
plot(time-t0,RelLC/median(RelLC),'.')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Normilized Flux','Interpreter','latex')

Title = sprintf('Normlized light curve of brightest targets')
title(Title,'Interpreter','latex')
legend(['RobustSD : ',num2str(RobustSD(RelLC/median(RelLC)))],'Interperter','latex')
subplot(3,1,2)
plot(time-t0,MS.Data.FLUX_PSF(:,1)/median(MS.Data.FLUX_PSF(:,1)),'o')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Normilized Flux','Interpreter','latex')
legend(['RobustSD : ',num2str(RobustSD(MS.Data.FLUX_PSF(:,1)/median(MS.Data.FLUX_PSF(:,1))))],'Interperter','latex')
Title = sprintf('Normlized light curve of a WD target')
title(Title,'Interpreter','latex')
subplot(3,1,3)
plot(time-t0,(MS.Data.FLUX_PSF(:,1)/median(MS.Data.FLUX_PSF(:,1)))./(RelLC/median(RelLC)),'o')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Normilized Flux','Interpreter','latex')
legend(['RobustSD : ',num2str(RobustSD((MS.Data.FLUX_PSF(:,1)/median(MS.Data.FLUX_PSF(:,1)))./(RelLC/median(RelLC))))],'Interperter','latex')
Title = sprintf('Relative light curve of a WD target')
title(Title,'Interpreter','latex')



%% binning
figure(172)
averageddata = binAndAverage((FP.Data.FLUX_PSF(:,1)/median(FP.Data.FLUX_PSF(:,1)))./(RelLC/median(RelLC)), 700/4)

subplot(4,1,2)
plot(averageddata,'o')
%legend(['Bin = 4 ; RobustSD : ',num2str(RobustSD(averageddata))],'Interperter','latex')

xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Normelized Flux','Interpreter','latex')
hold on 
plot(averagedData,'x')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Normelized Flux','Interpreter','latex')

Title = sprintf('Bin Rel Flux = 4')
title(Title,'Interpreter','latex')
legend(['Normalized Bin = 4 ; RobustSD : ',num2str(RobustSD(averageddata))],['Bin = 4 ; RobustSD : ',num2str(RobustSD(averagedData))],'Interperter','latex')

Title = sprintf('Bin Rel Flux = 4')
title(Title,'Interpreter','latex')
subplot(4,1,1)
plot(time-t0,(FP.Data.FLUX_PSF(:,1)/median(FP.Data.FLUX_PSF(:,1)))./(RelLC/median(RelLC)),'o')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Normilized Flux','Interpreter','latex')
hold on
plot(time-t0,(FP.Data.FLUX_PSF(:,1)/median(FP.Data.FLUX_PSF(:,1))),'x')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Normilized Flux','Interpreter','latex')


legend(['normalized RobustSD : ',num2str(RobustSD((FP.Data.FLUX_PSF(:,1)/median(FP.Data.FLUX_PSF(:,1)))./(RelLC/median(RelLC))))],['RobustSD : ',num2str(RobustSD(FP.Data.FLUX_PSF(:,1)/median(FP.Data.FLUX_PSF(:,1))))],'Interperter','latex')
Title = sprintf('Normlized light curve of a WD target')
title(Title,'Interpreter','latex')


subplot(4,1,3)
averageddata2 = binAndAverage((FP.Data.FLUX_PSF(:,1)/median(FP.Data.FLUX_PSF(:,1)))./(RelLC/median(RelLC)), ceil(700/9))

plot(averageddata2,'o')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Normilized Flux','Interpreter','latex')
hold on
plot(averagedData2,'o')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Normalized Flux','Interpreter','latex')

Title = sprintf('Bin Rel Flux = 9')
title(Title,'Interpreter','latex')


Title = sprintf('Bin Rel Flux = 9')
title(Title,'Interpreter','latex')
legend(['Normalized Bin = 9 ; RobustSD : ',num2str(RobustSD(averageddata2))],['Bin = 9 ; RobustSD : ',num2str(RobustSD(averagedData2))],'Interperter','latex')

subplot(4,1,4)
averageddata3 = binAndAverage((FP.Data.FLUX_PSF(:,1)/median(FP.Data.FLUX_PSF(:,1)))./(RelLC/median(RelLC)), ceil(700/20))

plot(averageddata3,'o')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Normilized Flux','Interpreter','latex')
hold on 

plot(averagedData3,'o')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Normilized Flux','Interpreter','latex')

Title = sprintf('Bin Re Flux = 20')
title(Title,'Interpreter','latex')



Title = sprintf('Bin Re Flux = 20')
title(Title,'Interpreter','latex')
legend(['Norm Bin = 20 ; RobustSD : ',num2str(RobustSD(averageddata3))],['Bin = 20 ; RobustSD : ',num2str(RobustSD(averagedData3))],'Interperter','latex')


%%

figure(173)
averagedData = binAndAverage((FP.Data.FLUX_PSF(:,1)/median(FP.Data.FLUX_PSF(:,1))), 700/4)

subplot(4,1,2)
plot(averagedData,'o')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Normelized Flux','Interpreter','latex')

Title = sprintf('Bin Rel Flux = 4')
title(Title,'Interpreter','latex')
legend(['Bin = 4 ; RobustSD : ',num2str(RobustSD(averagedData))],'Interperter','latex')
subplot(4,1,1)
plot(time-t0,(FP.Data.FLUX_PSF(:,1)/median(FP.Data.FLUX_PSF(:,1)))./(RelLC/median(RelLC)),'o')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Normilized Flux','Interpreter','latex')
legend(['RobustSD : ',num2str(RobustSD(FP.Data.FLUX_PSF(:,1)/median(FP.Data.FLUX_PSF(:,1))))],'Interperter','latex')
Title = sprintf(' light curve of a WD target')
title(Title,'Interpreter','latex')


subplot(4,1,3)
averagedData2 = binAndAverage((FP.Data.FLUX_PSF(:,1)/median(FP.Data.FLUX_PSF(:,1))), ceil(700/9))

plot(averagedData2,'o')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Normilized Flux','Interpreter','latex')

Title = sprintf('Bin Rel Flux = 9')
title(Title,'Interpreter','latex')
legend(['Bin = 9 ; RobustSD : ',num2str(RobustSD(averagedData2))],'Interperter','latex')

subplot(4,1,4)
averagedData3 = binAndAverage((FP.Data.FLUX_PSF(:,1)/median(FP.Data.FLUX_PSF(:,1))), ceil(700/20))

plot(averagedData3,'o')
xlabel(['JD - ',num2str(t0)],'Interpreter','latex')
ylabel('Normilized Flux','Interpreter','latex')

Title = sprintf('Bin Re Flux = 20')
title(Title,'Interpreter','latex')
legend(['Bin = 20 ; RobustSD : ',num2str(RobustSD(averagedData3))],'Interperter','latex')

