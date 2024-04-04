%% All Data Analysis


%% 16/08            

%% Field 1 night 1 
% Initilize WDs Object


F1N1_1608 = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


F1N1_1608.Path =  '/last04w/data2/archive/LAST.01.04.04/2023/08/15/proc'; % Manual at the moment.

F1N1_1608.Data.save_to =  '/home/ocs/Documents/WD_survey/Thesis/150823/';



%%

F1N1_1608 = ListFields(F1N1_1608) % List All Fields in Path

%% Get field FWHM LimMAG ra,dec during the obs
F1N1_1608.FieldID = '247+41';
F1N1_1608 = getObsInfo(F1N1_1608,'FN',F1N1_1608.FieldID);


%% Now you can look for WD within the field and add to the Objecyt


%% targets in field
Names = [' WDJ162830.49+404837.14  ',
' WDJ162601.97+400946.29  ',
' WDJ163217.23+420926.28  ',
' WDJ163150.72+423341.92  ',
' WDJ162932.38+405208.36  ',
' WDJ162831.45+415033.75  ',
' WDJ163344.73+414745.41  ',
' WDJ163218.84+404619.03  ',
' WDJ163030.59+423305.78  ',
  ];

TargetList = [
247.12664455529932	40.81060912104537	16.200327	16.109932	16.400946
246.5085585719456	40.16224311740737	17.6773	17.750221	17.645666
248.07163659544923	42.15732248570079	18.63655	18.618105	18.614834
247.96121239389333	42.56137318758711	18.332224	18.302517	18.446785
247.3852935272853	40.86833223363235	19.0826	19.167768	19.138664
247.13113190407762	41.84278653985253	18.800753	18.70535	18.497404
248.43654629689723	41.79592700740951	19.048695	19.098642	18.979486
248.0785962652575	40.77185230037336	18.442522	18.35069	18.6663
247.6274725060328	42.55156431584502	19.181662	19.206911	19.35357
];


F1N1_1608.Name = Names ;
F1N1_1608.RA = TargetList(:,1);
F1N1_1608.Dec = TargetList(:,2);
F1N1_1608.G_g  = TargetList(:,3);
F1N1_1608.G_Bp = TargetList(:,4);
F1N1_1608.G_Rp =TargetList(:,5);
F1N1_1608.Color = F1N1_1608.G_Bp  - F1N1_1608.G_Rp ;

%% Visit Inspection
F1N1_1608 = VisitInspection(F1N1_1608)

%% Batch Sorting:
[F1N1_1608,Results_N1_160823] = BatchSort(F1N1_1608)

%% get 2vis light curves:

[F1N1_1608] = get2VisLC(F1N1_1608,'Results1',Results_N1_160823)

%% 2nd night
% Initilize WDs Object


F1N2_1608 = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


F1N2_1608.Path =  '/last04w/data2/archive/LAST.01.04.04/2023/08/16/proc'; % Manual at the moment.

F1N2_1608.Data.save_to =  '/home/ocs/Documents/WD_survey/Thesis/150823/';



%%

F1N2_1608 = ListFields(F1N2_1608) % List All Fields in Path

%% Get field FWHM LimMAG ra,dec during the obs
F1N2_1608.FieldID = '247+41';
F1N2_1608 = getObsInfo(F1N2_1608,'FN',F1N2_1608.FieldID);


%% Now you can look for WD within the field and add to the Objecyt


%% targets in field
Names = [' WDJ162830.49+404837.14  ',
' WDJ162601.97+400946.29  ',
' WDJ163217.23+420926.28  ',
' WDJ163150.72+423341.92  ',
' WDJ162932.38+405208.36  ',
' WDJ162831.45+415033.75  ',
' WDJ163344.73+414745.41  ',
' WDJ163218.84+404619.03  ',
' WDJ163030.59+423305.78  ',
  ];

TargetList = [
247.12664455529932	40.81060912104537	16.200327	16.109932	16.400946
246.5085585719456	40.16224311740737	17.6773	17.750221	17.645666
248.07163659544923	42.15732248570079	18.63655	18.618105	18.614834
247.96121239389333	42.56137318758711	18.332224	18.302517	18.446785
247.3852935272853	40.86833223363235	19.0826	19.167768	19.138664
247.13113190407762	41.84278653985253	18.800753	18.70535	18.497404
248.43654629689723	41.79592700740951	19.048695	19.098642	18.979486
248.0785962652575	40.77185230037336	18.442522	18.35069	18.6663
247.6274725060328	42.55156431584502	19.181662	19.206911	19.35357
];


F1N2_1608.Name = Names ;
F1N2_1608.RA = TargetList(:,1);
F1N2_1608.Dec = TargetList(:,2);
F1N2_1608.G_g  = TargetList(:,3);
F1N2_1608.G_Bp = TargetList(:,4);
F1N2_1608.G_Rp =TargetList(:,5);
F1N2_1608.Color = F1N2_1608.G_Bp  - F1N2_1608.G_Rp ;

%% Visit Inspection
F1N2_1608 = VisitInspection(F1N2_1608)

%% Batch Sorting:
[F1N2_1608,Results_N2_1608] = BatchSort(F1N2_1608)

%% get 2vis light curves:

[F1N2_1608] = get2VisLC(F1N2_1608,'Results1',Results_N2_1608)


%% Connect 2 nights , Save Results
E1 = F1N1_1608;
E2 = F1N2_1608;
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

%% 15-16/08 2nd field

% Initilize WDs Object


F2N1_1608 = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


F2N1_1608.Path =  '/last04w/data2/archive/LAST.01.04.04/2023/08/15/proc'; % Manual at the moment.

F2N1_1608.Data.save_to =  '/home/ocs/Documents/WD_survey/Thesis/160823/';



%%

F2N1_1608 = ListFields(F2N1_1608) % List All Fields in Path

%% Get field FWHM LimMAG ra,dec during the obs
F2N1_1608.FieldID = '265+61';
F2N1_1608 = getObsInfo(F2N1_1608,'FN',F2N1_1608.FieldID);


%% Now you can look for WD within the field and add to the Objecyt


%% targets in field
Names = [' WDJ173901.82+604329.26  ',
' WDJ173732.37+610413.34  ',
' WDJ174127.06+595620.79  ',
' WDJ174238.01+610115.57  ',
' WDJ174227.13+624421.38  ',
' WDJ174207.64+600055.89  ',
' WDJ173922.74+602900.15  ',
  ];

TargetList = [
264.75731142810787	60.72629823024616	17.375256	17.606108	17.017109
264.38473809581546	61.07025380221967	18.797182	18.90069	18.567614
265.3628017714121	59.93924730101572	18.414871	18.503933	18.288239
265.6581180420617	61.02096571899463	19.0833	19.192778	18.83785
265.6126645033986	62.739372233688556	18.747953	18.79176	18.74789
265.53179391275563	60.01547618736302	19.03499	19.035263	19.183008
264.84436462988293	60.48313835713747	18.099682	17.987616	18.359116
];


F2N1_1608.Name = Names ;
F2N1_1608.RA = TargetList(:,1);
F2N1_1608.Dec = TargetList(:,2);
F2N1_1608.G_g  = TargetList(:,3);
F2N1_1608.G_Bp = TargetList(:,4);
F2N1_1608.G_Rp =TargetList(:,5);
F2N1_1608.Color = F2N1_1608.G_Bp  - F2N1_1608.G_Rp ;

%% Visit Inspection
F2N1_1608 = VisitInspection(F2N1_1608)

%% Batch Sorting:
[F2N1_1608,Results_N1_160823] = BatchSort(F2N1_1608)

%% get 2vis light curves:

[F2N1_1608] = get2VisLC(F2N1_1608,'Results1',Results_N1_160823)

%% 2nd night
% Initilize WDs Object


F2N2_1608 = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


F2N2_1608.Path =  '/last04w/data2/archive/LAST.01.04.04/2023/08/16/proc'; % Manual at the moment.

F2N2_1608.Data.save_to =  '/home/ocs/Documents/WD_survey/Thesis/160823/';



%%

F2N2_1608 = ListFields(F2N2_1608) % List All Fields in Path

%% Get field FWHM LimMAG ra,dec during the obs
F2N2_1608.FieldID = '265+61';
F2N2_1608 = getObsInfo(F2N2_1608,'FN',F2N2_1608.FieldID);


%% Now you can look for WD within the field and add to the Objecyt


%% targets in field

%% targets in field
Names = [' WDJ173901.82+604329.26  ',
' WDJ173732.37+610413.34  ',
' WDJ174127.06+595620.79  ',
' WDJ174238.01+610115.57  ',
' WDJ174227.13+624421.38  ',
' WDJ174207.64+600055.89  ',
' WDJ173922.74+602900.15  ',
  ];

TargetList = [
264.75731142810787	60.72629823024616	17.375256	17.606108	17.017109
264.38473809581546	61.07025380221967	18.797182	18.90069	18.567614
265.3628017714121	59.93924730101572	18.414871	18.503933	18.288239
265.6581180420617	61.02096571899463	19.0833	19.192778	18.83785
265.6126645033986	62.739372233688556	18.747953	18.79176	18.74789
265.53179391275563	60.01547618736302	19.03499	19.035263	19.183008
264.84436462988293	60.48313835713747	18.099682	17.987616	18.359116
];


F2N2_1608.Name = Names ;
F2N2_1608.RA = TargetList(:,1);
F2N2_1608.Dec = TargetList(:,2);
F2N2_1608.G_g  = TargetList(:,3);
F2N2_1608.G_Bp = TargetList(:,4);
F2N2_1608.G_Rp =TargetList(:,5);
F2N2_1608.Color = F2N2_1608.G_Bp  - F2N2_1608.G_Rp ;

%% Visit Inspection
F2N2_1608 = VisitInspection(F2N2_1608)

%% Batch Sorting:
[F2N2_1608,Results_N2_1608] = BatchSort(F2N2_1608)

%% get 2vis light curves:

[F2N2_1608] = get2VisLC(F2N2_1608,'Results1',Results_N2_1608)


%% Connect 2 nights , Save Results
E1 = F2N1_1608;
E2 = F2N2_1608;
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













%% 21-22/08




%% 04-09 ???




%% 15-16/09



