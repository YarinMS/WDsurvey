%% 15_08_23




addpath('~/Documents/WDsurvey/')
%% Initilize WDs Object


F277_36N1 = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


F277_36N1.Path =  '/last06e/data1/archive/LAST.01.06.01/2023/08/15/proc'; % Manual at the moment.

F277_36N1.Data.save_to =  '/home/ocs/Documents/WD_survey/Thesis/1508_277+36/';



%%

F277_36N1 = ListFields(F277_36N1) % List All Fields in Path

%% Get field FWHM LimMAG ra,dec during the obs
F277_36N1.FieldID = '277+36';
F277_36N1 = getObsInfo(F277_36N1,'FN',F277_36N1.FieldID);


%% Now you can look for WD within the field and add to E


%% targets in field
Names = [
    ' WDJ183218.82+363237.60  ',
' WDJ183145.31+370422.86  ',
' WDJ183651.97+384946.27  ',
' WDJ183444.65+365002.94  ',
' WDJ183629.00+364500.59  ',
' WDJ183105.40+371411.44  ',
' WDJ183528.60+373954.70  ',
' WDJ183308.89+360326.26  ',
' WDJ183703.45+381520.96  ',
' WDJ183058.11+380259.01  ',
' WDJ183755.09+385220.23  ',
' WDJ183315.19+382942.89  ',
' WDJ183724.18+373247.30  ',
' WDJ183540.34+390007.02  ',
' WDJ183414.77+381712.11  ',
' WDJ183738.39+365439.97  ',
' WDJ183236.47+385400.44  ',
  ];

TargetList = [
278.0783847616547	36.543516459580474	18.958986	19.517525	18.3312
277.93702427274036	37.072701933099886	17.8848	17.976393	17.760303
279.21661615726146	38.82942824898391	18.197727	18.316595	18.135353
278.6858527201984	36.833672801744406	18.412907	18.434786	18.39616
279.1211614327405	36.74996092812995	18.993204	19.138372	18.796446
277.7727314907298	37.236780176461565	18.76529	18.802181	18.845871
278.8693492685543	37.66551237652615	18.461147	18.533937	18.430735
278.28703105027	36.05682146369016	17.390617	17.3129	17.559557
279.2644120747496	38.255852671763925	18.316376	18.297882	18.38669
277.7420300654792	38.049715541536614	18.794899	18.800684	18.906445
279.4793681595708	38.87215696308871	18.845476	18.842093	18.904043
278.31335005193426	38.495006825286424	18.809862	18.838043	18.859127
279.350700910709	37.54646239866789	18.248077	18.211945	18.390963
278.91804639728826	39.00194300157912	18.610916	18.491575	18.76021
278.5614327251072	38.28653472813236	19.031754	18.959686	19.134285
279.4099609814048	36.91113434006961	19.111826	19.064842	19.336964
278.1520072729942	38.90016510112941	18.968945	18.917665	19.379482


];


F277_36N1.Name = Names ;
F277_36N1.RA = TargetList(:,1);
F277_36N1.Dec = TargetList(:,2);
F277_36N1.G_g  = TargetList(:,3);
F277_36N1.G_Bp = TargetList(:,4);
F277_36N1.G_Rp =TargetList(:,5);
F277_36N1.Color = F277_36N1.G_Bp  - F277_36N1.G_Rp ;

%% Visit Inspection
F277_36N1 = VisitInspection(F277_36N1)

%% Batch Sorting:
[F277_36N1,Results1] = BatchSort(F277_36N1)

%% get 2vis light curves:

[F277_36N1] = get2VisLC(F277_36N1,'Results1',Results1)



%% all night data



[~,SortTicks] = sort(F277_36N1.G_Bp);

%
figure('Color','White','units','normalized','outerposition',[0 0 1 1])
Ticks = [];
for Iwd = 1 : numel(F277_36N1.RA)
    
    tick = num2str(F277_36N1.G_Bp(SortTicks(Iwd)));
    Ticks = [Ticks ; tick(1:5)];

end


T = F277_36N1.Data.Results.TotalObs;  %+ TotalObs2;

bar(T(SortTicks), 'FaceColor', [0.5 0.7 0.9])
%ylim([0,105]);
xticklabels(Ticks)
xlabel('$B_p$ [mag]','Interpreter','latex')
ylabel('Actuall Time','Interpreter','latex')

%title(sprintf('Available visits length ; Entire Observation (%s) hrs',obs_len+obs_len2),'Interpreter','latex')

title(sprintf('Available visits length ; Entire Observation (%s) hrs $N_{WD} = %i$ - %s',F277_36N1.Data.Results.obs_len,length(F277_36N1.RA),F277_36N1.Data.DataStamp),'Interpreter','latex')

file_name = [sprintf('Available \\ Visits \\ Obs \\ Time \\ %s \\ ID \\ %s \\ %i \\ Vis \\ %s \\ %s',F277_36N1.Data.Results.obs_len,F277_36N1.Data.DataStamp),'.png'];
sfile = strcat(F277_36N1.Data.save_to,file_name);
sfile= strrep(sfile, ' ', '');


sfile = strrep(sfile, '\', '_');
         

saveas(gcf,sfile) ;

pause(2)
close();



%%


Tab =[F277_36N1.RA, F277_36N1.Dec, F277_36N1.G_Bp, T]
    
%% If only E1 , Save Results
%% Save table
%monthyear       = E1.Data.Date;
%montyear.Format = 'MMM-uuuu';
TabName         = [F277_36N1.Data.DataStamp,'_','Table_Results_',F277_36N1.Data.FieldID,'.mat']
save_path = [F277_36N1.Data.save_to,TabName];

save(save_path,'Tab','-v7.3')
%% Save RMS Results

RMS = F277_36N1.Data.Results.RMS_zp;
%TabName1         = ['Table_Results_',FieldNames{FieldIdx(1)},'_',num2str(date.Day),'-',num2str(date2.Day),'-',char(monthyear),'_',DataPath(24:36),'RMS.mat']

TabName1  = [F277_36N1.Data.DataStamp,'_','Results_',F277_36N1.Data.FieldID,'RMS.mat']
save_path = [F277_36N1.Data.save_to,TabName1];

save(save_path,'RMS','-v7.3')
RMSsys =F277_36N1.Data.Results.RMS_sys;
%TabName12         = ['Table_Results_',FieldNames{FieldIdx(1)},'_',num2str(date.Day),'-',num2str(date2.Day),'-',char(monthyear),'_',DataPath(24:36),'RMSsys.mat']
TabName2  = [F277_36N1.Data.DataStamp,'_','Results_',F277_36N1.Data.FieldID,'RMSsys.mat']
save_path = [F277_36N1.Data.save_to,TabName2];


save(save_path,'RMSsys','-v7.3')

%%

close all;
clear all;


%% 21-22 /08


%% Field 1 night 1 
% Initilize WDs Object


F290_39N1 = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


F290_39N1.Path =  '/last06e/data1/archive/LAST.01.06.01/2023/08/21/proc'; % Manual at the moment.

F290_39N1.Data.save_to =  '/home/ocs/Documents/WD_survey/Thesis/2108_290+39/';



%% 2nd night
% Initilize WDs Object


F290_39N2 = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


F290_39N2.Path = '/last06e/data1/archive/LAST.01.06.01/2023/08/22/proc'; % Manual at the moment.

F290_39N2.Data.save_to =  '/home/ocs/Documents/WD_survey/Thesis/2108_290+39/';



%%

F290_39N1 = ListFields(F290_39N1) % List All Fields in Path

%% Get field FWHM LimMAG ra,dec during the obs
F290_39N1.FieldID = '290+39';
F290_39N2.FieldID = '290+39';
F290_39N1 = getObsInfo(F290_39N1,'FN',F290_39N1.FieldID);


%% Now you can look for WD within the field and add to the Objecyt


%% targets in field
Names = [
   ' WDJ193215.26+395105.39  ',
' WDJ192854.92+410022.17  ',
' WDJ192827.40+421501.37  ',
' WDJ192815.81+395847.79  ',
' WDJ192903.03+403124.32  ',
' WDJ193301.15+401626.02  ',
' WDJ193301.71+395322.96  ',
' WDJ192457.87+421011.02  ',
' WDJ192807.41+420310.77  ',
' WDJ192524.73+413009.98  ',
' WDJ192715.38+411414.63  ',
' WDJ192814.19+392954.94  ',
' WDJ192518.02+411502.43  ',
' WDJ193212.06+421053.63  ',
' WDJ193256.06+421843.56  ',
' WDJ192834.69+410130.39  ',
' WDJ192550.24+410534.15  ',
' WDJ193101.01+405618.16  ',
  ];

TargetList = [
293.0635206316437	39.8512842863356	18.17214	18.275583	18.040125
292.2290013346243	41.00628936693642	17.912794	17.90692	18.004904
292.114259398	42.250309393032836	18.135462	18.12724	18.292643
292.065826043019	39.97967661848222	18.858063	18.94985	18.749283
292.26263528014977	40.52350658730858	18.675386	18.65655	18.75758
293.2546669070436	40.27385235818821	17.814104	17.792267	17.909739
293.25719760790184	39.88962406157084	18.415854	18.397877	18.572512
291.24108693102136	42.169666950285475	18.824585	18.90518	18.899946
292.0308552809661	42.05321412611313	19.14914	19.225788	19.205633
291.35291979370214	41.50274143131218	19.035315	19.042545	19.170473
291.81404126801874	41.237352557144355	19.02422	19.08059	19.121107
292.05880786045924	39.49842851575269	18.686182	18.627823	18.696827
291.325210569465	41.25067022747145	19.060253	19.035946	19.161558
293.05019148763967	42.18138466234132	18.852354	18.878942	18.932806
293.233792878206	42.31217257107478	19.196405	19.140982	19.271328
292.144595641106	41.0250005634265	18.67594	18.595945	18.923225
291.45935808637927	41.09280663508079	19.012161	18.948875	19.249592
292.7541707966683	40.93837574409093	18.554184	18.40719	18.852842


];


F290_39N1.Name = Names ;
F290_39N1.RA = TargetList(:,1);
F290_39N1.Dec = TargetList(:,2);
F290_39N1.G_g  = TargetList(:,3);
F290_39N1.G_Bp = TargetList(:,4);
F290_39N1.G_Rp =TargetList(:,5);
F290_39N1.Color = F290_39N1.G_Bp  - F290_39N1.G_Rp ;

%% Visit Inspection
F290_39N1 = VisitInspection(F290_39N1)

%% Batch Sorting:
[F290_39N1,Results_N1_160823] = BatchSort(F290_39N1)

%% get 2vis light curves:

[F290_39N1] = get2VisLC(F290_39N1,'Results1',Results_N1_160823)

%% 2nd night


%%

F290_39N2 = ListFields(F290_39N2) % List All Fields in Path

%% Get field FWHM LimMAG ra,dec during the obs

F290_39N2 = getObsInfo(F290_39N2,'FN',F290_39N2.FieldID);


%% Now you can look for WD within the field and add to the Objecyt


%% targets in field

F290_39N2.Name = Names ;
F290_39N2.RA = TargetList(:,1);
F290_39N2.Dec = TargetList(:,2);
F290_39N2.G_g  = TargetList(:,3);
F290_39N2.G_Bp = TargetList(:,4);
F290_39N2.G_Rp =TargetList(:,5);
F290_39N2.Color = F290_39N2.G_Bp  - F290_39N2.G_Rp ;

%% Visit Inspection
F290_39N2 = VisitInspection(F290_39N2)

%% Batch Sorting:
[F290_39N2,Results_N2_1608] = BatchSort(F290_39N2)

%% get 2vis light curves:

[F290_39N2] = get2VisLC(F290_39N2,'Results1',Results_N2_1608)


%% Connect 2 nights , Save Results
E1 = F290_39N1;
E2 = F290_39N2;
[~,SortTicks] = sort(E1.G_Bp);

%
figure('Color','White','units','normalized','outerposition',[0 0 1 1])
Ticks = [];
for Iwd = 1 : numel(E1.RA)
    
    tick = num2str(E1.G_Bp(SortTicks(Iwd)));
    Ticks = [Ticks ; tick(1:5)];

end


T = E1.Data.Results.TotalObs + E2.Data.Results.TotalObs;

bar(T(SortTicks), 'FaceColor', [0.5 0.7 0.9])
%ylim([0,105]);
xticklabels(Ticks)
xlabel('$B_p$ [mag]','Interpreter','latex')
ylabel('Actuall Time','Interpreter','latex')

%title(sprintf('Available visits length ; Entire Observation (%s) hrs',obs_len+obs_len2),'Interpreter','latex')
ObsLen = E1.Data.Results.obs_len +E2.Data.Results.obs_len;
title(sprintf('Available visits length ; Entire Observation (%s) hrs $N_{WD} = %i$ - %s',ObsLen,length(E1.RA),E1.Data.DataStamp),'Interpreter','latex')
NewStamp = [E1.Data.DataStamp,'__',E2.Data.DataStamp(end-2:end)];
file_name = [sprintf('Available \\ Visits \\ Obs \\ Time \\ %s \\ ID \\ %s \\ %i \\ Vis \\ %s \\ %s',ObsLen,NewStamp),'.png'];
sfile = strcat(E1.Data.save_to,file_name);
sfile= strrep(sfile, ' ', '');


sfile = strrep(sfile, '\', '_');
         

saveas(gcf,sfile) ;

pause(2)
close();



%%


Tab =[E1.RA, E1.Dec, E1.G_Bp, T];
    

%% Save table
%monthyear       = E1.Data.Date;
%montyear.Format = 'MMM-uuuu';
TabName         = [NewStamp,'_','Table_Results_',E1.Data.FieldID,'.mat']
save_path = [E1.Data.save_to,TabName];

save(save_path,'Tab','-v7.3')
%% Save RMS Results

RMS = {{E1.Data.Results.RMS_zp};{E2.Data.Results.RMS_zp}};
%TabName1         = ['Table_Results_',FieldNames{FieldIdx(1)},'_',num2str(date.Day),'-',num2str(date2.Day),'-',char(monthyear),'_',DataPath(24:36),'RMS.mat']

TabName1  = [E1.Data.DataStamp,'_','Results_',E1.Data.FieldID,'RMS.mat']
save_path = [E1.Data.save_to,TabName1];

save(save_path,'RMS','-v7.3')
RMSsys = {{E1.Data.Results.RMS_sys};{E2.Data.Results.RMS_sys}};
%TabName12         = ['Table_Results_',FieldNames{FieldIdx(1)},'_',num2str(date.Day),'-',num2str(date2.Day),'-',char(monthyear),'_',DataPath(24:36),'RMSsys.mat']

TabName2  = [E1.Data.DataStamp,'_','Results_',E1.Data.FieldID,'RMSsys.mat']
save_path = [E1.Data.save_to,TabName2];
save(save_path,'RMSsys','-v7.3')












close all
clear all

%% 21-22/08 2nd field

% Initilize WDs Object


F354_39N1 = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


F354_39N1.Path =  '/last06e/data1/archive/LAST.01.06.01/2023/08/21/proc'; % Manual at the moment.

F354_39N1.Data.save_to =  '/home/ocs/Documents/WD_survey/Thesis/2108_354+39/';


F354_39N2 = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


F354_39N2.Path =  '/last06e/data1/archive/LAST.01.06.01/2023/08/22/proc'; % Manual at the moment.

F354_39N2.Data.save_to =  '/home/ocs/Documents/WD_survey/Thesis/2108_354+39/';


%%

F354_39N1 = ListFields(F354_39N1) % List All Fields in Path

%% Get field FWHM LimMAG ra,dec during the obs
F354_39N1.FieldID = '354+39';
F354_39N2.FieldID = '354+39';
F354_39N1 = getObsInfo(F354_39N1,'FN',F354_39N1.FieldID);


%% Now you can look for WD within the field and add to the Objecyt


%% targets in field
Names = [' WDJ234148.89+405206.10  ',
' WDJ233848.60+404803.82  ',
' WDJ233711.04+405528.65  ',
' WDJ234455.61+410205.84  ',
' WDJ234430.64+401335.27  ',
' WDJ234353.09+421356.46  ',
' WDJ233908.52+415113.20  ',
' WDJ234528.68+394643.87  ',
' WDJ234308.54+394704.38  ',
  ];

TargetList = [
355.45394982465615	40.86828201073664	17.954098	17.991573	17.896652
354.7024130895557	40.80094430838397	17.861652	17.752888	18.053242
354.29542313660403	40.924405481641855	17.72469	17.852596	17.527641
356.2317656825857	41.03491645058881	17.845179	17.861067	17.890863
356.12768379552614	40.22636324837267	17.588142	17.53654	17.723686
355.9709837761857	42.23229259304931	18.775362	18.775148	18.862213
354.7855917221327	41.85359970643012	18.82793	18.933926	18.80077
356.3691792452376	39.77873267382704	17.13777	17.030838	17.374538
355.7855648575773	39.7845200121956	19.116732	18.981464	19.325449


];


F354_39N1.Name = Names ;
F354_39N1.RA = TargetList(:,1);
F354_39N1.Dec = TargetList(:,2);
F354_39N1.G_g  = TargetList(:,3);
F354_39N1.G_Bp = TargetList(:,4);
F354_39N1.G_Rp =TargetList(:,5);
F354_39N1.Color = F354_39N1.G_Bp  - F354_39N1.G_Rp ;

%% Visit Inspection
F354_39N1 = VisitInspection(F354_39N1)

%% Batch Sorting:
[F354_39N1,Results_N1_160823] = BatchSort(F354_39N1)

%% get 2vis light curves:

[F354_39N1] = get2VisLC(F354_39N1,'Results1',Results_N1_160823)

%% 2nd night
% Initilize WDs Object




%%

F354_39N2 = ListFields(F354_39N2) % List All Fields in Path

%% Get field FWHM LimMAG ra,dec during the obs

F354_39N2 = getObsInfo(F354_39N2,'FN',F354_39N2.FieldID);


%% Now you can look for WD within the field and add to the Objecyt


%% targets in field

%% targets in field


F354_39N2.Name = Names ;
F354_39N2.RA = TargetList(:,1);
F354_39N2.Dec = TargetList(:,2);
F354_39N2.G_g  = TargetList(:,3);
F354_39N2.G_Bp = TargetList(:,4);
F354_39N2.G_Rp =TargetList(:,5);
F354_39N2.Color = F354_39N2.G_Bp  - F354_39N2.G_Rp ;

%% Visit Inspection
F354_39N2 = VisitInspection(F354_39N2)

%% Batch Sorting:
[F354_39N2,Results_N2_1608] = BatchSort(F354_39N2)

%% get 2vis light curves:

[F354_39N2] = get2VisLC(F354_39N2,'Results1',Results_N2_1608)


%% Connect 2 nights , Save Results
E1 = F354_39N1;
E2 = F354_39N2;
[~,SortTicks] = sort(E1.G_Bp);

%
figure('Color','White','units','normalized','outerposition',[0 0 1 1])
Ticks = [];
for Iwd = 1 : numel(E1.RA)
    
    tick = num2str(E1.G_Bp(SortTicks(Iwd)));
    Ticks = [Ticks ; tick(1:5)];

end


T = E1.Data.Results.TotalObs + E2.Data.Results.TotalObs;

bar(T(SortTicks), 'FaceColor', [0.5 0.7 0.9])
%ylim([0,105]);
xticklabels(Ticks)
xlabel('$B_p$ [mag]','Interpreter','latex')
ylabel('Actuall Time','Interpreter','latex')

%title(sprintf('Available visits length ; Entire Observation (%s) hrs',obs_len+obs_len2),'Interpreter','latex')
ObsLen = E1.Data.Results.obs_len +E2.Data.Results.obs_len;
title(sprintf('Available visits length ; Entire Observation (%s) hrs $N_{WD} = %i$ - %s',ObsLen,length(E1.RA),E1.Data.DataStamp),'Interpreter','latex')
NewStamp = [E1.Data.DataStamp,'__',E2.Data.DataStamp(end-2:end)];
file_name = [sprintf('Available \\ Visits \\ Obs \\ Time \\ %s \\ ID \\ %s \\ %i \\ Vis \\ %s \\ %s',ObsLen,NewStamp),'.png'];
sfile = strcat(E1.Data.save_to,file_name);
sfile= strrep(sfile, ' ', '');


sfile = strrep(sfile, '\', '_');
         

saveas(gcf,sfile) ;

pause(2)
close();



%%


Tab =[E1.RA, E1.Dec, E1.G_Bp, T];
    

%% Save table
%monthyear       = E1.Data.Date;
%montyear.Format = 'MMM-uuuu';
TabName         = [NewStamp,'_','Table_Results_',E1.Data.FieldID,'.mat']
save_path = [E1.Data.save_to,TabName];

save(save_path,'Tab','-v7.3')
%% Save RMS Results

RMS = {{E1.Data.Results.RMS_zp};{E2.Data.Results.RMS_zp}};
%TabName1         = ['Table_Results_',FieldNames{FieldIdx(1)},'_',num2str(date.Day),'-',num2str(date2.Day),'-',char(monthyear),'_',DataPath(24:36),'RMS.mat']

TabName1  = [E1.Data.DataStamp,'_','Results_',E1.Data.FieldID,'RMS.mat']
save_path = [E1.Data.save_to,TabName1];

save(save_path,'RMS','-v7.3')
RMSsys = {{E1.Data.Results.RMS_sys};{E2.Data.Results.RMS_sys}};
%TabName12         = ['Table_Results_',FieldNames{FieldIdx(1)},'_',num2str(date.Day),'-',num2str(date2.Day),'-',char(monthyear),'_',DataPath(24:36),'RMSsys.mat']

TabName2  = [E1.Data.DataStamp,'_','Results_',E1.Data.FieldID,'RMSsys.mat']
save_path = [E1.Data.save_to,TabName2];

save(save_path,'RMSsys','-v7.3')



clear all;
close all;


%% 27-28/08
%% All Data Analysis


%% 27-28/08            

%% Field 1 night 1 
% Initilize WDs Object


F312_25N1 = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


F312_25N1.Path =  '/last06e/data1/archive/LAST.01.06.01/2023/08/27/proc'; % Manual at the moment.

F312_25N1.Data.save_to =  '/home/ocs/Documents/WD_survey/Thesis/2708_312+25/';



%% 2nd night
% Initilize WDs Object


F312_25N2 = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


F312_25N2.Path =  '/last06e/data1/archive/LAST.01.06.01/2023/08/28/proc'; % Manual at the moment.

F312_25N2.Data.save_to =  '/home/ocs/Documents/WD_survey/Thesis/2708_312+25/';



%%

F312_25N1 = ListFields(F312_25N1) % List All Fields in Path

%% Get field FWHM LimMAG ra,dec during the obs
F312_25N1.FieldID = '312+26';
F312_25N2.FieldID = '312+26';
F312_25N1 = getObsInfo(F312_25N1,'FN',F312_25N1.FieldID);


%% Now you can look for WD within the field and add to the Objecyt


%% targets in field
Names = [
 ' WDJ205020.65+263040.76  ',
' WDJ205536.94+252949.07  ',
' WDJ205723.17+271835.76  ',
' WDJ205306.48+281923.30  ',
' WDJ205351.74+270555.08  ',
' WDJ205348.75+273651.98  ',
' WDJ204922.92+262517.50  ',
' WDJ205407.78+273429.31  ',
' WDJ205234.30+280925.69  ',
' WDJ205216.18+273233.61  ',
' WDJ205032.28+274612.67  ',
' WDJ204955.79+275813.09  ',
' WDJ205616.92+274308.50  ',
' WDJ205243.27+271555.51  ',
' WDJ205235.18+280043.17  ',
' WDJ205203.97+281901.88  ',
' WDJ205217.56+262332.65  ',
' WDJ205005.59+282051.93  ',
' WDJ205332.37+283143.64  ',
' WDJ205529.30+263109.96  ',
' WDJ205151.31+252819.32  ',
  ];

TargetList = [
312.58292951577954	26.50929493179775	15.392575	15.875806	14.750393
313.9029619815036	25.497928233565563	18.990204	19.68148	18.292528
314.34619542801437	27.309650747341262	17.840637	18.131847	17.404312
313.277828703193	28.324202134344496	18.562443	18.931597	18.101706
313.46556420228586	27.0979824065975	18.278	18.295464	18.271189
313.45356336438437	27.614356004389315	18.28263	18.420675	18.08326
312.34633962034144	26.42164730086486	16.367678	16.35375	16.434814
313.53229017523347	27.5744680644453	18.931469	19.0113	18.837626
313.1434600560436	28.157396721113063	17.794346	17.799982	17.840828
313.06751760077475	27.542628616819268	18.297436	18.17757	17.883076
312.6345741161502	27.770167393257136	18.817163	18.929684	18.751158
312.4824330605919	27.970084256496268	19.121191	19.204605	19.124413
314.07051841777803	27.71888781171748	18.901178	18.925589	18.962254
313.180108398807	27.265284172533356	18.663216	18.662575	18.787134
313.14661487220064	28.012085146977366	18.924099	18.949707	18.913239
313.0164134817829	28.317078710223903	19.115	19.075726	19.354246
313.07309429515334	26.392364510093454	19.104748	19.079174	19.338295
312.5233242797192	28.3477621578998	17.920069	17.769743	18.144474
313.3849116554792	28.528768222152365	18.48703	18.348284	18.715155
313.87188143604027	26.519197548336546	19.093662	19.122234	19.0487
312.9638213829198	25.472018830267576	19.162369	19.062635	19.323294


];


F312_25N1.Name = Names ;
F312_25N1.RA = TargetList(:,1);
F312_25N1.Dec = TargetList(:,2);
F312_25N1.G_g  = TargetList(:,3);
F312_25N1.G_Bp = TargetList(:,4);
F312_25N1.G_Rp =TargetList(:,5);
F312_25N1.Color = F312_25N1.G_Bp  - F312_25N1.G_Rp ;

%% Visit Inspection
F312_25N1 = VisitInspection(F312_25N1)

%% Batch Sorting:
[F312_25N1,Results_N1_160823] = BatchSort(F312_25N1)

%% get 2vis light curves:

[F312_25N1] = get2VisLC(F312_25N1,'Results1',Results_N1_160823)

%% 2nd night


%%

F312_25N2 = ListFields(F312_25N2) % List All Fields in Path

%% Get field FWHM LimMAG ra,dec during the obs

F312_25N2 = getObsInfo(F312_25N2,'FN',F312_25N2.FieldID);


%% Now you can look for WD within the field and add to the Objecyt


%% targets in field

F312_25N2.Name = Names ;
F312_25N2.RA = TargetList(:,1);
F312_25N2.Dec = TargetList(:,2);
F312_25N2.G_g  = TargetList(:,3);
F312_25N2.G_Bp = TargetList(:,4);
F312_25N2.G_Rp =TargetList(:,5);
F312_25N2.Color = F312_25N2.G_Bp  - F312_25N2.G_Rp ;

%% Visit Inspection
F312_25N2 = VisitInspection(F312_25N2)

%% Batch Sorting:
[F312_25N2,Results_N2_1608] = BatchSort(F312_25N2)

%% get 2vis light curves:

[F312_25N2] = get2VisLC(F312_25N2,'Results1',Results_N2_1608)


%% Connect 2 nights , Save Results
E1 = F312_25N1;
E2 = F312_25N2;
[~,SortTicks] = sort(E1.G_Bp);

%
figure('Color','White','units','normalized','outerposition',[0 0 1 1])
Ticks = [];
for Iwd = 1 : numel(E1.RA)
    
    tick = num2str(E1.G_Bp(SortTicks(Iwd)));
    Ticks = [Ticks ; tick(1:5)];

end


T = E1.Data.Results.TotalObs + E2.Data.Results.TotalObs;

bar(T(SortTicks), 'FaceColor', [0.5 0.7 0.9])
%ylim([0,105]);
xticklabels(Ticks)
xlabel('$B_p$ [mag]','Interpreter','latex')
ylabel('Actuall Time','Interpreter','latex')

%title(sprintf('Available visits length ; Entire Observation (%s) hrs',obs_len+obs_len2),'Interpreter','latex')
ObsLen = E1.Data.Results.obs_len +E2.Data.Results.obs_len;
title(sprintf('Available visits length ; Entire Observation (%s) hrs $N_{WD} = %i$ - %s',ObsLen,length(E1.RA),E1.Data.DataStamp),'Interpreter','latex')
NewStamp = [E1.Data.DataStamp,'__',E2.Data.DataStamp(end-2:end)];
file_name = [sprintf('Available \\ Visits \\ Obs \\ Time \\ %s \\ ID \\ %s \\ %i \\ Vis \\ %s \\ %s',ObsLen,NewStamp),'.png'];
sfile = strcat(E1.Data.save_to,file_name);
sfile= strrep(sfile, ' ', '');


sfile = strrep(sfile, '\', '_');
         

saveas(gcf,sfile) ;

pause(2)
close();



%%


Tab =[E1.RA, E1.Dec, E1.G_Bp, T];
    

%% Save table
%monthyear       = E1.Data.Date;
%montyear.Format = 'MMM-uuuu';
TabName         = [NewStamp,'_','Table_Results_',E1.Data.FieldID,'.mat']
save_path = [E1.Data.save_to,TabName];

save(save_path,'Tab','-v7.3')
%% Save RMS Results

RMS = {{E1.Data.Results.RMS_zp};{E2.Data.Results.RMS_zp}};
%TabName1         = ['Table_Results_',FieldNames{FieldIdx(1)},'_',num2str(date.Day),'-',num2str(date2.Day),'-',char(monthyear),'_',DataPath(24:36),'RMS.mat']

TabName1  = [E1.Data.DataStamp,'_','Results_',E1.Data.FieldID,'RMS.mat']
save_path = [E1.Data.save_to,TabName1];

save(save_path,'RMS','-v7.3')
RMSsys = {{E1.Data.Results.RMS_sys};{E2.Data.Results.RMS_sys}};
%TabName12         = ['Table_Results_',FieldNames{FieldIdx(1)},'_',num2str(date.Day),'-',num2str(date2.Day),'-',char(monthyear),'_',DataPath(24:36),'RMSsys.mat']

TabName2  = [E1.Data.DataStamp,'_','Results_',E1.Data.FieldID,'RMSsys.mat']
save_path = [E1.Data.save_to,TabName2];
save(save_path,'RMSsys','-v7.3')












close all
clear all

%% 21-22/08 2nd field

% Initilize WDs Object


F355_45_2708N1 = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


F355_45_2708N1.Path =  '/last06e/data1/archive/LAST.01.06.01/2023/08/27/proc'; % Manual at the moment.

F355_45_2708N1.Data.save_to =  '/home/ocs/Documents/WD_survey/Thesis/2708_355+45/';


F3555_45_N2_2708 = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


F3555_45_N2_2708.Path =  '/last06e/data1/archive/LAST.01.06.01/2023/08/28/proc'; % Manual at the moment.

F3555_45_N2_2708.Data.save_to =  '/home/ocs/Documents/WD_survey/Thesis/2708_355+45/';


%%

F355_45_2708N1 = ListFields(F355_45_2708N1) % List All Fields in Path

%% Get field FWHM LimMAG ra,dec during the obs
F355_45_2708N1.FieldID = '355+45';
F3555_45_N2_2708.FieldID = '355+45';
F355_45_2708N1 = getObsInfo(F355_45_2708N1,'FN',F355_45_2708N1.FieldID);


%% Now you can look for WD within the field and add to the Objecyt


%% targets in field
Names = [' WDJ234350.65+472548.22  ',
' WDJ234333.60+464912.45  ',
' WDJ234822.15+454448.99  ',
' WDJ235049.97+473414.69  ',
' WDJ235045.14+471106.49  ',
' WDJ234521.73+473650.69  ',
' WDJ234430.82+452847.61  ',
' WDJ234616.70+451531.51  ',
' WDJ234509.28+465817.29  ',
' WDJ234414.11+473404.58  ',
' WDJ235133.35+470818.15  ',
' WDJ234425.37+450813.86  ',
' WDJ235138.07+461053.38  ',
' WDJ234647.79+471619.93  ',
' WDJ235109.48+445436.15  ',
  ];

TargetList = [
355.96405047060506	47.429939779204794	17.95181	18.312582	17.460077
355.8899543580612	46.82027740393669	16.419102	16.391638	16.504595
357.0920721859262	45.746657397434106	18.921528	19.154058	18.568026
357.708083278203	47.57061822756939	18.964794	19.217396	18.57568
357.68787765848066	47.18530136218023	18.920631	19.095238	18.723969
356.34066494254614	47.61394589946431	17.517578	17.4671	17.635626
356.1283033466303	45.479561687482594	18.987017	19.06129	18.813332
356.5692079713612	45.25887792146558	19.172743	19.304314	19.007103
356.28872697052185	46.97156064036332	18.949417	19.039276	18.891258
356.05862734349745	47.567780866480824	18.729612	18.738134	18.835735
357.88921259493446	47.138417289446735	18.591522	18.551058	18.452003
356.1057593797253	45.13724271467892	18.967127	18.982796	19.088001
357.90856866427237	46.1814303416643	19.140165	19.15373	19.226692
356.6990104600057	47.27223951567298	19.078594	19.060246	19.101622
357.78944107908586	44.90996233081667	19.019133	18.910479	19.372461


];


F355_45_2708N1.Name = Names ;
F355_45_2708N1.RA = TargetList(:,1);
F355_45_2708N1.Dec = TargetList(:,2);
F355_45_2708N1.G_g  = TargetList(:,3);
F355_45_2708N1.G_Bp = TargetList(:,4);
F355_45_2708N1.G_Rp =TargetList(:,5);
F355_45_2708N1.Color = F355_45_2708N1.G_Bp  - F355_45_2708N1.G_Rp ;

%% Visit Inspection
F355_45_2708N1 = VisitInspection(F355_45_2708N1)

%% Batch Sorting:
[F355_45_2708N1,Results_N1_160823] = BatchSort(F355_45_2708N1)

%% get 2vis light curves:

[F355_45_2708N1] = get2VisLC(F355_45_2708N1,'Results1',Results_N1_160823)

%% 2nd night
% Initilize WDs Object




%%

F3555_45_N2_2708 = ListFields(F3555_45_N2_2708) % List All Fields in Path

%% Get field FWHM LimMAG ra,dec during the obs

F3555_45_N2_2708 = getObsInfo(F3555_45_N2_2708,'FN',F3555_45_N2_2708.FieldID);


%% Now you can look for WD within the field and add to the Objecyt


%% targets in field

%% targets in field


F3555_45_N2_2708.Name = Names ;
F3555_45_N2_2708.RA = TargetList(:,1);
F3555_45_N2_2708.Dec = TargetList(:,2);
F3555_45_N2_2708.G_g  = TargetList(:,3);
F3555_45_N2_2708.G_Bp = TargetList(:,4);
F3555_45_N2_2708.G_Rp =TargetList(:,5);
F3555_45_N2_2708.Color = F3555_45_N2_2708.G_Bp  - F3555_45_N2_2708.G_Rp ;

%% Visit Inspection
F3555_45_N2_2708 = VisitInspection(F3555_45_N2_2708)

%% Batch Sorting:
[F3555_45_N2_2708,Results_N2_1608] = BatchSort(F3555_45_N2_2708)

%% get 2vis light curves:

[F3555_45_N2_2708] = get2VisLC(F3555_45_N2_2708,'Results1',Results_N2_1608)


%% Connect 2 nights , Save Results
E1 = F355_45_2708N1;
E2 = F3555_45_N2_2708;
[~,SortTicks] = sort(E1.G_Bp);

%
figure('Color','White','units','normalized','outerposition',[0 0 1 1])
Ticks = [];
for Iwd = 1 : numel(E1.RA)
    
    tick = num2str(E1.G_Bp(SortTicks(Iwd)));
    Ticks = [Ticks ; tick(1:5)];

end


T = E1.Data.Results.TotalObs + E2.Data.Results.TotalObs;

bar(T(SortTicks), 'FaceColor', [0.5 0.7 0.9])
%ylim([0,105]);
xticklabels(Ticks)
xlabel('$B_p$ [mag]','Interpreter','latex')
ylabel('Actuall Time','Interpreter','latex')

%title(sprintf('Available visits length ; Entire Observation (%s) hrs',obs_len+obs_len2),'Interpreter','latex')
ObsLen = E1.Data.Results.obs_len +E2.Data.Results.obs_len;
title(sprintf('Available visits length ; Entire Observation (%s) hrs $N_{WD} = %i$ - %s',ObsLen,length(E1.RA),E1.Data.DataStamp),'Interpreter','latex')
NewStamp = [E1.Data.DataStamp,'__',E2.Data.DataStamp(end-2:end)];
file_name = [sprintf('Available \\ Visits \\ Obs \\ Time \\ %s \\ ID \\ %s \\ %i \\ Vis \\ %s \\ %s',ObsLen,NewStamp),'.png'];
sfile = strcat(E1.Data.save_to,file_name);
sfile= strrep(sfile, ' ', '');


sfile = strrep(sfile, '\', '_');
         

saveas(gcf,sfile) ;

pause(2)
close();



%%


Tab =[E1.RA, E1.Dec, E1.G_Bp, T];
    

%% Save table
%monthyear       = E1.Data.Date;
%montyear.Format = 'MMM-uuuu';
TabName         = [NewStamp,'_','Table_Results_',E1.Data.FieldID,'.mat']
save_path = [E1.Data.save_to,TabName];

save(save_path,'Tab','-v7.3')
%% Save RMS Results

RMS = {{E1.Data.Results.RMS_zp};{E2.Data.Results.RMS_zp}};
%TabName1         = ['Table_Results_',FieldNames{FieldIdx(1)},'_',num2str(date.Day),'-',num2str(date2.Day),'-',char(monthyear),'_',DataPath(24:36),'RMS.mat']

TabName1  = [E1.Data.DataStamp,'_','Results_',E1.Data.FieldID,'RMS.mat']
save_path = [E1.Data.save_to,TabName1];

save(save_path,'RMS','-v7.3')
RMSsys = {{E1.Data.Results.RMS_sys};{E2.Data.Results.RMS_sys}};
%TabName12         = ['Table_Results_',FieldNames{FieldIdx(1)},'_',num2str(date.Day),'-',num2str(date2.Day),'-',char(monthyear),'_',DataPath(24:36),'RMSsys.mat']

TabName2  = [E1.Data.DataStamp,'_','Results_',E1.Data.FieldID,'RMSsys.mat']
save_path = [E1.Data.save_to,TabName2];

save(save_path,'RMSsys','-v7.3')





