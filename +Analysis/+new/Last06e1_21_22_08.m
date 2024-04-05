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
