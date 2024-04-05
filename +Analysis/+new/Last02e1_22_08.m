%% All Data Analysis



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
E1 = F291_34N2_2108;
%E2 = F291_34N2_2108;
[~,SortTicks] = sort(E1.G_Bp);

%
figure('Color','White','units','normalized','outerposition',[0 0 1 1])
Ticks = [];
for Iwd = 1 : numel(E1.RA)
    
    tick = num2str(E1.G_Bp(SortTicks(Iwd)));
    Ticks = [Ticks ; tick(1:5)];

end


T = E1.Data.Results.TotalObs% + E2.Data.Results.TotalObs;

bar(T(SortTicks), 'FaceColor', [0.5 0.7 0.9])
%ylim([0,105]);
xticklabels(Ticks)
xlabel('$B_p$ [mag]','Interpreter','latex')
ylabel('Actuall Time','Interpreter','latex')

%title(sprintf('Available visits length ; Entire Observation (%s) hrs',obs_len+obs_len2),'Interpreter','latex')
ObsLen = E1.Data.Results.obs_len %+E2.Data.Results.obs_len;
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

RMS = {{E1.Data.Results.RMS_zp}};%;{E2.Data.Results.RMS_zp}};
%TabName1         = ['Table_Results_',FieldNames{FieldIdx(1)},'_',num2str(date.Day),'-',num2str(date2.Day),'-',char(monthyear),'_',DataPath(24:36),'RMS.mat']

TabName1  = [E1.Data.DataStamp,'_','Results_',E1.Data.FieldID,'RMS.mat']
save_path = [E1.Data.save_to,TabName1];

save(save_path,'RMS','-v7.3')
RMSsys = {{E1.Data.Results.RMS_sys}} ;%;{E2.Data.Results.RMS_sys}};
%TabName12         = ['Table_Results_',FieldNames{FieldIdx(1)},'_',num2str(date.Day),'-',num2str(date2.Day),'-',char(monthyear),'_',DataPath(24:36),'RMSsys.mat']

TabName2  = [E1.Data.DataStamp,'_','Results_',E1.Data.FieldID,'RMSsys.mat']
save_path = [E1.Data.save_to,TabName2];
save(save_path,'RMSsys','-v7.3')












close all
clear all

%% 21-22/08 2nd field



%% 2nd night
% Initilize WDs Object


F356_34_N2_2108 = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


F356_34_N2_2108.Path =  '/last02e/data1/archive/LAST.01.02.01/2023/08/22/proc'; % Manual at the moment.

F356_34_N2_2108.Data.save_to =  '/home/ocs/Documents/WD_survey/Thesis/2108__356_34/';



%%

F356_34_N2_2108 = ListFields(F356_34_N2_2108) % List All Fields in Path

%% Get field FWHM LimMAG ra,dec during the obs
F356_34_N2_2108.FieldID = '356+34';
F356_34_N2_2108 = getObsInfo(F356_34_N2_2108,'FN',F356_34_N2_2108.FieldID);


%% Now you can look for WD within the field and add to the Objecyt


%% targets in field

%% targets in field
Names = [' WDJ235300.03+365723.82  ',
' WDJ235430.18+343745.73  ',
' WDJ235425.63+360451.07  ',
' WDJ235355.00+361128.46  ',
' WDJ234615.05+354107.18  ',
' WDJ235137.15+361058.94  ',
' WDJ235343.17+362228.63  ',
' WDJ235353.60+355725.51  ',
' WDJ235233.66+361929.47  ',
' WDJ234934.16+345816.07  ',
' WDJ235148.36+362011.25  ',
' WDJ234844.89+344457.86  ',
' WDJ234602.97+344714.36  ',
' WDJ234804.68+371125.64  ',
' WDJ235115.08+355156.23  ',
' WDJ234902.81+355301.08  ',
  ];

TargetList = [
358.2490786372035	36.95602019242748	17.766068	18.02604	17.360794
358.6262040044346	34.629178069507404	17.730215	17.766941	17.666399
358.60691829894745	36.080867915255354	17.409506	17.480482	17.320492
358.4791566999056	36.191144233288874	17.282484	17.303087	17.30017
356.56322881707945	35.68584156079553	17.480652	17.51233	17.46241
357.9048310804486	36.18297355668468	19.155947	19.294252	19.05411
358.42991799227474	36.37460306534316	17.795748	17.53455	17.361908
358.47370661484814	35.95695843937606	18.35812	18.366528	18.452127
358.1404258710068	36.32479792290022	17.94189	17.892187	18.01698
357.39202436545224	34.97099708987863	19.085083	19.03908	18.907814
357.95105279670605	36.33621917732026	17.724937	17.673506	17.882141
357.18689661636387	34.74919241333775	18.758278	18.797411	18.808025
356.5124009830615	34.78724115911146	17.932756	17.877626	18.098137
357.01950955702785	37.19043010949823	18.573198	18.6289	18.589886
357.8128765670505	35.86549336287511	18.908047	18.907557	19.00362
357.2615900230666	35.88360345698252	18.608028	18.544827	18.818508


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
E1 = F356_334_N2_2108;
%E2 = F356_34_N2_2108;
[~,SortTicks] = sort(E1.G_Bp);

%
figure('Color','White','units','normalized','outerposition',[0 0 1 1])
Ticks = [];
for Iwd = 1 : numel(E1.RA)
    
    tick = num2str(E1.G_Bp(SortTicks(Iwd)));
    Ticks = [Ticks ; tick(1:5)];

end


T = E1.Data.Results.TotalObs% + E2.Data.Results.TotalObs;

bar(T(SortTicks), 'FaceColor', [0.5 0.7 0.9])
%ylim([0,105]);
xticklabels(Ticks)
xlabel('$B_p$ [mag]','Interpreter','latex')
ylabel('Actuall Time','Interpreter','latex')

%title(sprintf('Available visits length ; Entire Observation (%s) hrs',obs_len+obs_len2),'Interpreter','latex')
ObsLen = E1.Data.Results.obs_len %+E2.Data.Results.obs_len;
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

RMS = {{E1.Data.Results.RMS_zp}};%;{E2.Data.Results.RMS_zp}};
%TabName1         = ['Table_Results_',FieldNames{FieldIdx(1)},'_',num2str(date.Day),'-',num2str(date2.Day),'-',char(monthyear),'_',DataPath(24:36),'RMS.mat']

TabName1  = [E1.Data.DataStamp,'_','Results_',E1.Data.FieldID,'RMS.mat']
save_path = [E1.Data.save_to,TabName1];

save(save_path,'RMS','-v7.3')
RMSsys = {{E1.Data.Results.RMS_sys}};%;{E2.Data.Results.RMS_sys}};
%TabName12         = ['Table_Results_',FieldNames{FieldIdx(1)},'_',num2str(date.Day),'-',num2str(date2.Day),'-',char(monthyear),'_',DataPath(24:36),'RMSsys.mat']

TabName2  = [E1.Data.DataStamp,'_','Results_',E1.Data.FieldID,'RMSsys.mat']
save_path = [E1.Data.save_to,TabName2];

save(save_path,'RMSsys','-v7.3')













