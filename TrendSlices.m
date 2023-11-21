%% Terend series % ASSUming A WD object already exist (for now)
% load a ForcedPhotometry MatchedSources object

wdt = 6;
target = e1.Name(wdt,:);
%load(strcat('/home/ocs/Documents/WD_survey/270823/358+34/',target,'_FP1.mat'))

 
%load('/home/ocs/Documents/WD_survey/270823/358+34/Detrend/WDJ235425.63+360451.07_FP0.mat')

% sort FP

[N,SortedTimeStamps] = sort(FP.JD);

t0 = round(FP.JD(1))-0.5; % Ref JD 

MS = FP.copy()
MS.JD = FP.JD(SortedTimeStamps)
MS.Data.MAG_PSF(:,:) = FP.Data.MAG_PSF(SortedTimeStamps,:);

figure(1);
subplot(2,1,1)
plot(FP.JD-t0,'.')

hold on

plot(MS.JD-t0,'o')

legend('Raw Outout Time stamps','Sorted Time Stamps')


subplot(2,1,2)
plot(FP.Data.MAG_PSF(:,1)+1,'.')

hold on 

plot(MS.Data.MAG_PSF(:,1),'.')

pause(6)

close;

% slice detrend, plot


IntervalSize = 20 ; % 30 minutes

LC = []
LCModel = []
LCRes = []


Nint = ceil(MS.Nepoch / IntervalSize);
Times = timeofday(datetime(MS.JD,'convertfrom','jd'));
figure(222);

for Iiter = 1:Nint
    

    StartInd = (Iiter - 1) * IntervalSize + 1;
    EndInd   = min(Iiter * IntervalSize, MS.Nepoch);
    
    % message
    fprintf('\nPreform detrending on batch # %d \nFrom Index %d to %d ',[Iiter,StartInd,EndInd])
    fprintf('\nFirst time stamp: %s',[char(Times(StartInd))])
    fprintf('\nLast time stamp: %s',char(Times(EndInd)))
    

    % run lsq detrend
    [R,Model,GoodFlagSources] = lsqRelPhotByEranSlices(MS,'StartInd',StartInd,'EndInd',EndInd,...
        'Niter', 2,'obj',e1,'wdt',wdt)
    r     = reshape(R.Resid,[EndInd - StartInd + 1,FP.Nsrc]);
    model = reshape(Model,[EndInd - StartInd + 1,FP.Nsrc]);
    subplot(1,2,1)
    
         
     [~,ref_index] = find(GoodFlagSources == 1)
     
     if ref_index(1) ~= 1
         
         reg_index(1) = 1;
 
     end
     
     inx = 1
     
     
     LC = [LC ; MS.Data.MAG_PSF(StartInd:EndInd,ref_index(inx))];
     LCModel = [LCModel ; model(:,ref_index(inx))];
     LCRes = [LCRes ; r(:,ref_index(inx)) - mean(r(:,ref_index(inx)),'omitnan')+mean(MS.Data.MAG_PSF(StartInd:EndInd,ref_index(inx)),'omitnan')];
     
     subplot(3,1,1)
     plot(MS.JD(StartInd:EndInd)-t0,MS.Data.MAG_PSF(StartInd:EndInd,ref_index(inx)),'k.')
     hold on 
     plot(MS.JD(StartInd:EndInd)-t0,model(:,ref_index(inx)),'ro')
     LgLbl{3} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(MS.Data.MAG_PSF(StartInd:EndInd,ref_index(inx))))
     LgLbl{4} = sprintf('$$ ZP_i +M_j $$ ; RobustSD : %.3f',RobustSD(model(:,ref_index(inx))))
     legend(LgLbl(3:4),'Location','bestoutside','Interpreter','latex')
     set(gca , 'YDir','reverse')
     xlabel(['JD - ',num2str(dt)],'Interpreter','latex')
     ylabel('Inst Mag','Interpreter','latex')


    
     subplot(3,1,3)
    [rms1,meanmag1]  = CalcRMS(MS.SrcData.phot_g_mean_mag,r,e1,wdt,'Marker','xk','Predicted',false)
     hold on
     %FP.plotRMS('FieldX','MAG_PSF','PlotColor','blue','PlotSymbol','o')
     MS.plotRMS('FieldX','MAG_PSF','PlotColor','red')
     legend('Residual RMS within Slice','Original RMS','Location','best')
     xlim([10 , 20])
     hold off
     
     subplot(3,1,2)

     plot(MS.JD(StartInd:EndInd)-t0,MS.Data.MAG_PSF(StartInd:EndInd,ref_index(inx)),'k.')
     hold on 
     plot(MS.JD(StartInd:EndInd)-t0,r(:,ref_index(inx)) - mean(r(:,ref_index(inx)),'omitnan')+mean(MS.Data.MAG_PSF(StartInd:EndInd,ref_index(inx)),'omitnan'),'ro')
     LgLbl{5} = sprintf('No ZP ; RobustSD : %.3f',RobustSD(FP.Data.MAG_PSF(:,ref_index(ix))))
     LgLbl{6} = sprintf('Residual + mean signal ; RobustSD : %.3f',RobustSD(r(:,ref_index(ix))))
    legend(LgLbl(5:6),'Location','bestoutside','Interpreter','latex')
    set(gca , 'YDir','reverse')
    ylabel('Residuals')


    % Create a design matrix for the current interval (adjust as needed)
    %design_matrix = create_design_matrix(interval_data);
    
    % Solve the least squares problem
    %params = design_matrix \ interval_data;
    
    % Detrend the data using the fitted parameters
    %detrended_interval = interval_data - design_matrix * params;
    
    % Store the detrended interval back in the matrix
    
    
    %detrended_data(start_index:end_index, :) = detrended_interval;
end

% Now 'detrended_data' contains the detrended values for the entire dataset

close;

figure(2);
subplot(2,1,1)
plot(MS.JD-t0,LC(1:length(LC)-20),'.')
hold on
plot(MS.JD-t0,LCModel(1:length(LC)-20),'x')
LgLbl{5} = sprintf('Raw Data ; RobustSD : %.3f',RobustSD(LC(100:length(LCRes))))
LgLbl{6} = sprintf('$$ ZP_i +M_j$$ ; RobustSD : %.3f',RobustSD(LCModel(100:length(LCRes))))
legend(LgLbl(5:6),'Location','best','Interpreter','latex')
set(gca , 'YDir','reverse')
title(strcat(e1.Name(wdt,:),' 20 Frames slices'),'Interpreter','latex')
%legend('Raw Data','Model','Interpreter','latex')


subplot(2,1,2)
plot(MS.JD-t0,LC(1:length(LC)-20),'.')
hold on
plot(MS.JD-t0,LCRes(1:length(LC)-20),'o')
LgLbl{5} = sprintf('Raw Data ; RobustSD : %.3f',RobustSD(LC(100:length(LCRes))))
LgLbl{6} = sprintf('Residual + mean signal ; RobustSD : %.3f',RobustSD(LCRes(100:length(LCRes))))
legend(LgLbl(5:6),'Location','best','Interpreter','latex')
set(gca , 'YDir','reverse')   


[q,w] = sort(t)

t = t(w)
m=m(w)
dm = dm(w)

plot(t,m,'.')

e.RMS_timeseries(e,m,20)

T  = timeofday(datetime(t,'convertfrom','jd'))

tt = T(~isnan(m))
mm = m(~isnan(m))

plot(tt,mm)