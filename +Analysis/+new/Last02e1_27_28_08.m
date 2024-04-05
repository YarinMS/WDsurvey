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










