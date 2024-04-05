%% All Data Analysis


%% 16/08            

%% Field 1 night 1 
% Initilize WDs Object


F291_34N1_2108 = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


F291_34N1_2108.Path =  '/last02e/data1/archive/LAST.01.02.01/2023/08/21/proc'; % Manual at the moment.

F291_34N1_2108.Data.save_to =  '/home/ocs/Documents/WD_survey/Thesis/2108_291_34/';



%%

F291_34N1_2108 = ListFields(F291_34N1_2108) % List All Fields in Path

%% Get field FWHM LimMAG ra,dec during the obs
F291_34N1_2108.FieldID = '291+34';
F291_34N1_2108 = getObsInfo(F291_34N1_2108,'FN',F291_34N1_2108.FieldID);


%% Now you can look for WD within the field and add to the Objecyt


%% targets in field
Names = [' WDJ191850.20+333602.29  ',
' WDJ192335.45+330831.93  ',
' WDJ191932.56+333921.41  ',
' WDJ191932.08+341511.09  ',
' WDJ191832.08+331418.13  ',
' WDJ191541.08+330532.22  ',
' WDJ192002.24+313202.09  ',
' WDJ192228.62+331554.24  ',
' WDJ192101.55+313719.09  ',
  ];

TargetList = [
289.7094549484325	33.60085321578618	15.38009	15.310585	15.542366
290.8980022189275	33.14215491220664	19.08762	19.243336	18.896708
289.8856319709547	33.655552959698724	17.84095	17.78671	17.780664
289.88387712619163	34.25336844198777	18.902767	18.962078	18.814564
289.6338057591615	33.23845071968322	18.814407	18.84506	18.939518
288.9212518726139	33.09247535043707	17.569145	17.515594	17.733358
290.0093217344574	31.533753696851036	19.061079	19.164232	18.964184
290.61926547111943	33.2651353137878	18.765287	18.756676	18.943771
290.2563806956743	31.62189157355558	17.371897	17.222736	17.628555
];


F291_34N1_2108.Name = Names ;
F291_34N1_2108.RA = TargetList(:,1);
F291_34N1_2108.Dec = TargetList(:,2);
F291_34N1_2108.G_g  = TargetList(:,3);
F291_34N1_2108.G_Bp = TargetList(:,4);
F291_34N1_2108.G_Rp =TargetList(:,5);
F291_34N1_2108.Color = F291_34N1_2108.G_Bp  - F291_34N1_2108.G_Rp ;

%% Visit Inspection
F291_34N1_2108 = VisitInspection(F291_34N1_2108)

%% Batch Sorting:
[F291_34N1_2108,Results_N1_160823] = BatchSort(F291_34N1_2108)

%% get 2vis light curves:

[F291_34N1_2108] = get2VisLC(F291_34N1_2108,'Results1',Results_N1_160823)

%% 2nd night
% Initilize WDs Object


F291_34N2_2108 = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


F291_34N2_2108.Path =  '/last02w/data1/archive/LAST.01.02.03/2023/08/22/proc'; % Manual at the moment.

F291_34N2_2108.Data.save_to =  '/home/ocs/Documents/WD_survey/Thesis/2108__291_34/';



%%

F291_34N2_2108 = ListFields(F291_34N2_2108) % List All Fields in Path

%% Get field FWHM LimMAG ra,dec during the obs
F291_34N2_2108.FieldID = '291+34';
F291_34N2_2108 = getObsInfo(F291_34N2_2108,'FN',F291_34N2_2108.FieldID);


%% Now you can look for WD within the field and add to the Objecyt


%% targets in field
Names = [' WDJ191850.20+333602.29  ',
' WDJ192335.45+330831.93  ',
' WDJ191932.56+333921.41  ',
' WDJ191932.08+341511.09  ',
' WDJ191832.08+331418.13  ',
' WDJ191541.08+330532.22  ',
' WDJ192002.24+313202.09  ',
' WDJ192228.62+331554.24  ',
' WDJ192413.45+313523.29  ',
' WDJ192101.55+313719.09  ',
  ];

TargetList = [
289.7094549554428	33.60085322110846	15.38009	15.310585	15.542366
290.89800222569846	33.142154911054945	19.08762	19.243336	18.896708
289.8856319696676	33.6555529501104	17.84095	17.78671	17.780664
289.8838771308025	34.25336844893861	18.902767	18.962078	18.814564
289.63380576293906	33.23845072168746	18.814407	18.84506	18.939518
288.921251874637	33.09247535511054	17.569145	17.515594	17.733358
290.00932173469175	31.5337536930403	19.061079	19.164232	18.964184
290.61926547119276	33.26513531547096	18.765287	18.756676	18.943771
291.05609702790986	31.589816550914897	18.91517	18.706144	18.791208
290.2563806941694	31.621891571698153	17.371897	17.222736	17.628555

];

F291_34N2_2108.Name = Names ;
F291_34N2_2108.RA = TargetList(:,1);
F291_34N2_2108.Dec = TargetList(:,2);
F291_34N2_2108.G_g  = TargetList(:,3);
F291_34N2_2108.G_Bp = TargetList(:,4);
F291_34N2_2108.G_Rp =TargetList(:,5);
F291_34N2_2108.Color = F291_34N2_2108.G_Bp  - F291_34N2_2108.G_Rp ;

%% Visit Inspection
F291_34N2_2108 = VisitInspection(F291_34N2_2108)

%% Batch Sorting:
[F291_34N2_2108,Results_N2_1608] = BatchSort(F291_34N2_2108)

%% get 2vis light curves:

[F291_34N2_2108] = get2VisLC(F291_34N2_2108,'Results1',Results_N2_1608)


%% Connect 2 nights , Save Results
E1 = F291_34N1_2108;
E2 = F291_34N2_2108;
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


F356_334_N1_2108 = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


F356_334_N1_2108.Path =  '/last02w/data1/archive/LAST.01.02.03/2023/08/21/proc'; % Manual at the moment.

F356_334_N1_2108.Data.save_to =  '/home/ocs/Documents/WD_survey/Thesis/2108_356_34/';



%%

F356_334_N1_2108 = ListFields(F356_334_N1_2108) % List All Fields in Path

%% Get field FWHM LimMAG ra,dec during the obs
F356_334_N1_2108.FieldID = '356+34';
F356_334_N1_2108 = getObsInfo(F356_334_N1_2108,'FN',F356_334_N1_2108.FieldID);


%% Now you can look for WD within the field and add to the Objecyt


%% targets in field
Names = [' WDJ234350.72+323246.73  ',
' WDJ233906.51+342600.88  ',
' WDJ233837.28+315239.09  ',
' WDJ233831.35+322849.16  ',
' WDJ234116.99+315521.99  ',
' WDJ234419.71+340729.22  ',
' WDJ234029.69+342855.94  ',
' WDJ233922.53+315048.93  ',
' WDJ233921.01+313338.00  ',
' WDJ234113.87+332625.87  ',
' WDJ233811.82+330424.99  ',
' WDJ233812.50+325500.34  ',
' WDJ233952.17+333919.09  ',
' WDJ234144.39+333146.21  ',
' WDJ234347.61+341319.26  ',
' WDJ233734.76+341716.80  ',
' WDJ233810.88+341231.31  ',
  ];

TargetList = [
355.95961254210147	32.54591000093663	12.966921	12.964135	13.007412
354.7787843788512	34.43349292489475	18.42964	18.672813	18.06403
354.65571305057364	31.877465980921915	16.531513	16.44796	16.648706
354.63059972855064	32.4800886829767	18.374657	18.419008	18.32083
355.32085377767186	31.92271024256805	18.078344	18.147907	18.06168
356.081913730237	34.124557741705814	18.991856	19.111227	18.899755
355.12358976325476	34.482111172581966	18.585178	18.6131	18.863245
354.8436971944706	31.846578924741507	18.223053	18.213219	18.29234
354.8377245194968	31.560568198954105	18.950603	19.045794	18.914639
355.30781161718926	33.44044945697359	18.918423	18.984863	18.954275
354.54946359693645	33.073718705749215	18.766129	18.822252	18.795982
354.5519489498529	32.91671161460904	18.504887	18.455414	18.620508
354.9675677184517	33.65518800168322	18.845003	18.819942	18.929028
355.43507025552424	33.52950868377666	18.62299	18.52807	18.860481
355.9484684855514	34.221992936108556	19.17017	19.162964	19.343512
354.3947204324147	34.287904558510625	18.02109	17.913382	18.229877
354.545363361888	34.2086754103326	19.028955	18.951708	19.330477

];


F356_334_N1_2108.Name = Names ;
F356_334_N1_2108.RA = TargetList(:,1);
F356_334_N1_2108.Dec = TargetList(:,2);
F356_334_N1_2108.G_g  = TargetList(:,3);
F356_334_N1_2108.G_Bp = TargetList(:,4);
F356_334_N1_2108.G_Rp =TargetList(:,5);
F356_334_N1_2108.Color = F356_334_N1_2108.G_Bp  - F356_334_N1_2108.G_Rp ;

%% Visit Inspection
F356_334_N1_2108 = VisitInspection(F356_334_N1_2108)

%% Batch Sorting:
[F356_334_N1_2108,Results_N1_160823] = BatchSort(F356_334_N1_2108)

%% get 2vis light curves:

[F356_334_N1_2108] = get2VisLC(F356_334_N1_2108,'Results1',Results_N1_160823)

%% 2nd night
% Initilize WDs Object


F356_34_N2_2108 = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


F356_34_N2_2108.Path =  '/last02w/data2/archive/LAST.01.02.03/2023/08/22/proc'; % Manual at the moment.

F356_34_N2_2108.Data.save_to =  '/home/ocs/Documents/WD_survey/Thesis/2108_356_34/';



%%

F356_34_N2_2108 = ListFields(F356_34_N2_2108) % List All Fields in Path

%% Get field FWHM LimMAG ra,dec during the obs
F356_34_N2_2108.FieldID = '356+34';
F356_34_N2_2108 = getObsInfo(F356_34_N2_2108,'FN',F356_34_N2_2108.FieldID);


%% Now you can look for WD within the field and add to the Objecyt


%% targets in field

%% targets in field
Names = [' WDJ234350.72+323246.73  ',
' WDJ233906.51+342600.88  ',
' WDJ233837.28+315239.09  ',
' WDJ233831.35+322849.16  ',
' WDJ234116.99+315521.99  ',
' WDJ234419.71+340729.22  ',
' WDJ234029.69+342855.94  ',
' WDJ233922.53+315048.93  ',
' WDJ233921.01+313338.00  ',
' WDJ234113.87+332625.87  ',
' WDJ233811.82+330424.99  ',
' WDJ233812.50+325500.34  ',
' WDJ233952.17+333919.09  ',
' WDJ234144.39+333146.21  ',
' WDJ234347.61+341319.26  ',
' WDJ233734.76+341716.80  ',
' WDJ233810.88+341231.31  ',
  ];

TargetList = [
355.95961254210147	32.54591000093663	12.966921	12.964135	13.007412
354.7787843788512	34.43349292489475	18.42964	18.672813	18.06403
354.65571305057364	31.877465980921915	16.531513	16.44796	16.648706
354.63059972855064	32.4800886829767	18.374657	18.419008	18.32083
355.32085377767186	31.92271024256805	18.078344	18.147907	18.06168
356.081913730237	34.124557741705814	18.991856	19.111227	18.899755
355.12358976325476	34.482111172581966	18.585178	18.6131	18.863245
354.8436971944706	31.846578924741507	18.223053	18.213219	18.29234
354.8377245194968	31.560568198954105	18.950603	19.045794	18.914639
355.30781161718926	33.44044945697359	18.918423	18.984863	18.954275
354.54946359693645	33.073718705749215	18.766129	18.822252	18.795982
354.5519489498529	32.91671161460904	18.504887	18.455414	18.620508
354.9675677184517	33.65518800168322	18.845003	18.819942	18.929028
355.43507025552424	33.52950868377666	18.62299	18.52807	18.860481
355.9484684855514	34.221992936108556	19.17017	19.162964	19.343512
354.3947204324147	34.287904558510625	18.02109	17.913382	18.229877
354.545363361888	34.2086754103326	19.028955	18.951708	19.330477

];

F356_34_N2_2108.Name = Names ;
F356_34_N2_2108.RA = TargetList(:,1);
F356_34_N2_2108.Dec = TargetList(:,2);
F356_34_N2_2108.G_g  = TargetList(:,3);
F356_34_N2_2108.G_Bp = TargetList(:,4);
F356_34_N2_2108.G_Rp =TargetList(:,5);
F356_34_N2_2108.Color = F356_34_N2_2108.G_Bp  - F356_34_N2_2108.G_Rp ;

%% Visit Inspection
F356_34_N2_2108 = VisitInspection(F356_34_N2_2108)

%% Batch Sorting:
[F356_34_N2_2108,Results_N2_1608] = BatchSort(F356_34_N2_2108)

%% get 2vis light curves:

[F356_34_N2_2108] = get2VisLC(F356_34_N2_2108,'Results1',Results_N2_1608)


%% Connect 2 nights , Save Results
E1 = F356_334_N1_2108;
E2 = F356_34_N2_2108;
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













