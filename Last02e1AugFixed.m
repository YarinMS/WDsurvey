addpath('~/Documents/WDsurvey/')
%% Initilize WDs Object


FN_278_13 = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


FN_278_13.Path =  '/last02e/data1/archive/LAST.01.02.01/2023/08/15/proc'; % Manual at the moment.

FN_278_13.Data.save_to =  '/home/ocs/Documents/WD_survey/Thesis/1508__268_13/';



%%

FN_278_13 = ListFields(FN_278_13) % List All Fields in Path

%% Get field FWHM LimMAG ra,dec during the obs
FN_278_13.FieldID = '278+13';
FN_278_13 = getObsInfo(FN_278_13,'FN',FN_278_13.FieldID);


%% Now you can look for WD within the field and add to E


%% targets in field
Names = [' WDJ183630.91+145105.59  ',
' WDJ183711.02+162655.77  ',
' WDJ183706.87+144903.33  ',
' WDJ183751.54+161203.89  ',
' WDJ183751.64+153010.45  ',
' WDJ183151.87+153526.55  ',
' WDJ183627.77+133645.22  ',
' WDJ183013.55+153416.36  ',
  ];

TargetList = [
279.1284393345867	14.850637436210528	18.057463	18.290157	17.690727
279.2963269824645	16.448058003979565	19.070307	19.664959	18.388618
279.27860093637224	14.817792223070612	18.909126	19.068396	18.685026
279.4648805301538	16.201322893177927	18.265223	18.404182	18.091648
279.46495958410776	15.502630966976119	19.182926	19.334333	18.816795
277.96614709127226	15.590607418890583	19.195232	19.3245	19.096043
279.115542080862	13.612500948250908	18.6631	18.819796	18.516842
277.5564133289239	15.571165318100453	18.754116	18.734941	18.870409

];


FN_278_13.Name = Names ;
FN_278_13.RA = TargetList(:,1);
FN_278_13.Dec = TargetList(:,2);
FN_278_13.G_g  = TargetList(:,3);
FN_278_13.G_Bp = TargetList(:,4);
FN_278_13.G_Rp =TargetList(:,5);
FN_278_13.Color = FN_278_13.G_Bp  - FN_278_13.G_Rp ;

%% Visit Inspection
FN_278_13 = VisitInspection(FN_278_13)

%% Batch Sorting:
[FN_278_13,Results1] = BatchSort(FN_278_13)

%% get 2vis light curves:

[FN_278_13] = get2VisLC(FN_278_13,'Results1',Results1)



%% all night data



[~,SortTicks] = sort(FN_278_13.G_Bp);

%
figure('Color','White','units','normalized','outerposition',[0 0 1 1])
Ticks = [];
for Iwd = 1 : numel(FN_278_13.RA)
    
    tick = num2str(FN_278_13.G_Bp(SortTicks(Iwd)));
    Ticks = [Ticks ; tick(1:5)];

end


T = FN_278_13.Data.Results.TotalObs;  %+ TotalObs2;

bar(T(SortTicks), 'FaceColor', [0.5 0.7 0.9])
%ylim([0,105]);
xticklabels(Ticks)
xlabel('$B_p$ [mag]','Interpreter','latex')
ylabel('Actuall Time','Interpreter','latex')

%title(sprintf('Available visits length ; Entire Observation (%s) hrs',obs_len+obs_len2),'Interpreter','latex')

title(sprintf('Available visits length ; Entire Observation (%s) hrs $N_{WD} = %i$ - %s',FN_278_13.Data.Results.obs_len,length(FN_278_13.RA),FN_278_13.Data.DataStamp),'Interpreter','latex')

file_name = [sprintf('Available \\ Visits \\ Obs \\ Time \\ %s \\ ID \\ %s \\ %i \\ Vis \\ %s \\ %s',FN_278_13.Data.Results.obs_len,FN_278_13.Data.DataStamp),'.png'];
sfile = strcat(FN_278_13.Data.save_to,file_name);
sfile= strrep(sfile, ' ', '');


sfile = strrep(sfile, '\', '_');
         

saveas(gcf,sfile) ;

pause(2)
close();



%%


Tab =[FN_278_13.RA, FN_278_13.Dec, FN_278_13.G_Bp, T]
    
%% If only E1 , Save Results
%% Save table
%monthyear       = E1.Data.Date;
%montyear.Format = 'MMM-uuuu';
TabName         = [FN_278_13.Data.DataStamp,'_','Table_Results_',FN_278_13.Data.FieldID,'.mat']
save_path = [FN_278_13.Data.save_to,TabName];

save(save_path,'Tab','-v7.3')
%% Save RMS Results

RMS = FN_278_13.Data.Results.RMS_zp;
%TabName1         = ['Table_Results_',FieldNames{FieldIdx(1)},'_',num2str(date.Day),'-',num2str(date2.Day),'-',char(monthyear),'_',DataPath(24:36),'RMS.mat']

TabName1  = [FN_278_13.Data.DataStamp,'_','Results_',FN_278_13.Data.FieldID,'RMS.mat']
save_path = [FN_278_13.Data.save_to,TabName1];

save(save_path,'RMS','-v7.3')
RMSsys =FN_278_13.Data.Results.RMS_sys;
%TabName12         = ['Table_Results_',FieldNames{FieldIdx(1)},'_',num2str(date.Day),'-',num2str(date2.Day),'-',char(monthyear),'_',DataPath(24:36),'RMSsys.mat']
TabName2  = [FN_278_13.Data.DataStamp,'_','Results_',FN_278_13.Data.FieldID,'RMSsys.mat']
save_path = [FN_278_13.Data.save_to,TabName2];


save(save_path,'RMSsys','-v7.3')

%%

close all;
clear all;








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
NewStamp = [E1.Data.DataStamp]; %,'__',E2.Data.DataStamp(end-2:end)];
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







clear all;
close all;




%% All Data Analysis


%% 27-28/08            

%% Field 1 night 1 
% Initilize WDs Object


F291_34N1_2108 = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


F291_34N1_2108.Path =  '/last02w/data1/archive/LAST.01.02.03/2023/08/27/proc'; % Manual at the moment.

F291_34N1_2108.Data.save_to =  '/home/ocs/Documents/WD_survey/Thesis/2708__292_39/';



%% 2nd night
% Initilize WDs Object


F291_34N2_2108 = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


F291_34N2_2108.Path =  '/last02e/data1/archive/LAST.01.02.01/2023/08/28/proc'; % Manual at the moment.

F291_34N2_2108.Data.save_to =  '/home/ocs/Documents/WD_survey/Thesis/2708_292_39/';



%%

F291_34N1_2108 = ListFields(F291_34N1_2108) % List All Fields in Path

%% Get field FWHM LimMAG ra,dec during the obs
F291_34N1_2108.FieldID = '292+39';
F291_34N2_2108.FieldID = '292+39';
F291_34N1_2108 = getObsInfo(F291_34N1_2108,'FN',F291_34N1_2108.FieldID);


%% Now you can look for WD within the field and add to the Objecyt


%% targets in field
Names = [
    ' WDJ191858.63+384321.48  ',
' WDJ192453.39+375114.12  ',
' WDJ191829.64+385120.92  ',
' WDJ192119.12+381228.77  ',
' WDJ192433.08+373416.64  ',
' WDJ192210.31+361303.48  ',
' WDJ192251.93+390207.59  ',
' WDJ192408.26+365518.06  ',
' WDJ192549.15+363350.90  ',
' WDJ192603.04+370316.18  ',
' WDJ192228.51+380643.83  ',
' WDJ192006.75+365229.07  ',
' WDJ192616.15+383401.00  ',
' WDJ191914.79+363440.09  ',
' WDJ192704.18+381616.56  ',
' WDJ192056.80+372118.05  ',
' WDJ192135.56+370944.26  ',
  ];

TargetList = [
289.7445123416303	38.720937211680216	14.468728	14.70764	14.069847
291.22130959977767	37.85345137566349	18.742365	19.004896	18.368837
289.6236914365616	38.855705421924526	18.47594	18.626867	18.337448
290.3296502242715	38.20815802780617	17.561943	17.677254	17.410595
291.13900149070173	37.571650855336344	18.153393	18.201235	18.05303
290.5429602929434	36.21766077524346	17.472574	17.3519	17.521475
290.7164423365314	39.03559889547563	19.070604	19.19868	19.027458
291.0344369137689	36.921800392823755	18.062197	18.052776	18.197077
291.45474338310873	36.564198608203164	18.19943	18.23068	18.199593
291.51273237638975	37.054617441879465	19.012222	19.042492	19.135777
290.6187902902786	38.112215772571666	19.011774	19.01941	19.09882
290.0282841392444	36.87460163385959	18.815098	18.816214	18.944126
291.56714792247834	38.56675266126871	18.810986	18.700867	18.942148
289.8116154469776	36.57790681333144	18.36311	18.261122	18.529402
291.7674598281449	38.271320110293736	19.173668	19.113625	19.512377
290.23671111460834	37.35503802436986	18.680408	18.563673	19.02728
290.39798086878716	37.16220909976764	18.88919	18.802715	18.962502


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


%%

F291_34N2_2108 = ListFields(F291_34N2_2108) % List All Fields in Path

%% Get field FWHM LimMAG ra,dec during the obs

F291_34N2_2108 = getObsInfo(F291_34N2_2108,'FN',F291_34N2_2108.FieldID);


%% Now you can look for WD within the field and add to the Objecyt


%% targets in field

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


F356_334_N1_2108.Path =  '/last02w/data1/archive/LAST.01.02.03/2023/08/27/proc'; % Manual at the moment.

F356_334_N1_2108.Data.save_to =  '/home/ocs/Documents/WD_survey/Thesis/2708__358_34/';


F356_34_N2_2108 = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


F356_34_N2_2108.Path =  '/last02w/data2/archive/LAST.01.02.03/2023/08/28/proc'; % Manual at the moment.

F356_34_N2_2108.Data.save_to =  '/home/ocs/Documents/WD_survey/Thesis/2708__358_34/';


%%

F356_334_N1_2108 = ListFields(F356_334_N1_2108) % List All Fields in Path

%% Get field FWHM LimMAG ra,dec during the obs
F356_334_N1_2108.FieldID = '358+34';
F356_34_N2_2108.FieldID = '358+34';
F356_334_N1_2108 = getObsInfo(F356_334_N1_2108,'FN',F356_334_N1_2108.FieldID);


%% Now you can look for WD within the field and add to the Objecyt


%% targets in field
Names = [' WDJ234350.72+323246.73  ',
' WDJ234544.58+341050.85  ',
' WDJ234926.19+333504.32  ',
' WDJ234419.71+340729.22  ',
' WDJ234926.58+335058.73  ',
' WDJ234716.83+340157.33  ',
' WDJ235036.87+330245.69  ',
' WDJ234354.19+312742.57  ',
' WDJ234856.31+314207.82  ',
' WDJ235106.81+321828.52  ',
' WDJ234347.61+341319.26  ',
  ];

TargetList = [
355.9596124985845	32.545909990764116	12.966921	12.964135	13.007412
356.4360622155066	34.18135549560884	18.028858	18.399742	17.52324
357.35921203692845	33.58335219477887	16.824327	16.835466	16.839817
356.08191372524146	34.12455773608384	18.991856	19.111227	18.899755
357.36093099193283	33.8496925282637	18.721958	18.710783	18.824137
356.82014641232183	34.03249437502928	17.828075	17.737906	18.048447
357.65361942413665	33.045968121719426	19.003864	18.979767	19.107862
355.9757635441623	31.46182049697991	18.071423	17.97854	18.327915
357.23473735770335	31.70209966366189	19.097359	19.106815	19.209877
357.7784967105386	32.307768713675294	18.955025	18.888506	19.079998
355.94846848835095	34.22199293551438	19.17017	19.162964	19.343512

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




%%

F356_34_N2_2108 = ListFields(F356_34_N2_2108) % List All Fields in Path

%% Get field FWHM LimMAG ra,dec during the obs

F356_34_N2_2108 = getObsInfo(F356_34_N2_2108,'FN',F356_34_N2_2108.FieldID);


%% Now you can look for WD within the field and add to the Objecyt


%% targets in field

%% targets in field


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


