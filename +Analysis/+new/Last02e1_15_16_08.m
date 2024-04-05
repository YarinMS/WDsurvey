
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




%% 16/08 2 fields !

%% Data path dont exist in last so far!!!

%% Initilize WDs Object


FN_294_42 = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


FN_294_42.Path =  '/last02e/data1/archive/LAST.01.02.01/2023/08/16/proc'; % Manual at the moment.

FN_294_42.Data.save_to =  '/home/ocs/Documents/WD_survey/Thesis/1608_294_42/';



%%

FN_294_42 = ListFields(FN_294_42) % List All Fields in Path

%% Get field FWHM LimMAG ra,dec during the obs
FN_294_42.FieldID = '294+42';
FN_294_42 = getObsInfo(FN_294_42,'FN',FN_294_42.FieldID);


%% Now you can look for WD within the field and add to E


%% targets in field
Names = [' WDJ193416.72+420422.22  ',
' WDJ193215.26+395105.39  ',
' WDJ193352.72+395314.88  ',
' WDJ192854.92+410022.17  ',
' WDJ193353.40+394406.09  ',
' WDJ192827.40+421501.37  ',
' WDJ192815.81+395847.79  ',
' WDJ192903.03+403124.32  ',
' WDJ193301.15+401626.02  ',
' WDJ193301.71+395322.96  ',
' WDJ192807.41+420310.77  ',
' WDJ192715.38+411414.63  ',
' WDJ192814.19+392954.94  ',
' WDJ193212.06+421053.63  ',
' WDJ193256.06+421843.56  ',
' WDJ192834.69+410130.39  ',
' WDJ192550.24+410534.15  ',
' WDJ193101.01+405618.16  ',
  ];

TargetList = [
293.5695349039523	42.07311684173408	18.323532	18.424025	18.197035
293.0635206376985	39.851284305292126	18.17214	18.275583	18.040125
293.4696478446458	39.8874648400524	17.891073	17.937714	17.88088
292.2290013178072	41.00628935514555	17.912794	17.90692	18.004904
293.472198956649	39.73455000539417	19.031443	19.145157	18.364264
292.1142593909622	42.250309399296775	18.135462	18.12724	18.292643
292.0658260457915	39.97967664235458	18.858063	18.94985	18.749283
292.26263528025834	40.52350657976699	18.675386	18.65655	18.75758
293.25466691884606	40.273852361919815	17.814104	17.792267	17.909739
293.2571975998188	39.88962406923462	18.415854	18.397877	18.572512
292.0308552836175	42.053214106120805	19.14914	19.225788	19.205633
291.81404126999735	41.23735256099267	19.02422	19.08059	19.121107
292.0588078867415	39.49842853060371	18.686182	18.627823	18.696827
293.0501914935464	42.181384678448474	18.852354	18.878942	18.932806
293.2337928597883	42.31217256422311	19.196405	19.140982	19.271328
292.1445956376102	41.02500057271579	18.67594	18.595945	18.923225
291.4593580844328	41.09280663630829	19.012161	18.948875	19.249592
292.75417079896755	40.93837574394382	18.554184	18.40719	18.852842

];


FN_294_42.Name = Names ;
FN_294_42.RA = TargetList(:,1);
FN_294_42.Dec = TargetList(:,2);
FN_294_42.G_g  = TargetList(:,3);
FN_294_42.G_Bp = TargetList(:,4);
FN_294_42.G_Rp =TargetList(:,5);
FN_294_42.Color = FN_294_42.G_Bp  - FN_294_42.G_Rp ;

%% Visit Inspection
FN_294_42 = VisitInspection(FN_294_42)

%% Batch Sorting:
[FN_294_42,Results1] = BatchSort(FN_294_42)

%% get 2vis light curves:

[FN_294_42] = get2VisLC(FN_294_42,'Results1',Results1)



%% all night data



[~,SortTicks] = sort(FN_294_42.G_Bp);

%
figure('Color','White','units','normalized','outerposition',[0 0 1 1])
Ticks = [];
for Iwd = 1 : numel(FN_294_42.RA)
    
    tick = num2str(FN_294_42.G_Bp(SortTicks(Iwd)));
    Ticks = [Ticks ; tick(1:5)];

end


T = FN_294_42.Data.Results.TotalObs;  %+ TotalObs2;

bar(T(SortTicks), 'FaceColor', [0.5 0.7 0.9])
%ylim([0,105]);
xticklabels(Ticks)
xlabel('$B_p$ [mag]','Interpreter','latex')
ylabel('Actuall Time','Interpreter','latex')

%title(sprintf('Available visits length ; Entire Observation (%s) hrs',obs_len+obs_len2),'Interpreter','latex')

title(sprintf('Available visits length ; Entire Observation (%s) hrs $N_{WD} = %i$ - %s',FN_294_42.Data.Results.obs_len,length(FN_294_42.RA),FN_294_42.Data.DataStamp),'Interpreter','latex')

file_name = [sprintf('Available \\ Visits \\ Obs \\ Time \\ %s \\ ID \\ %s \\ %i \\ Vis \\ %s \\ %s',FN_294_42.Data.Results.obs_len,FN_294_42.Data.DataStamp),'.png'];
sfile = strcat(FN_294_42.Data.save_to,file_name);
sfile= strrep(sfile, ' ', '');


sfile = strrep(sfile, '\', '_');
         

saveas(gcf,sfile) ;

pause(2)
close();



%%


Tab =[FN_294_42.RA, FN_294_42.Dec, FN_294_42.G_Bp, T]

%% If only E1 , Save Results
%% Save table
%monthyear       = E1.Data.Date;
%montyear.Format = 'MMM-uuuu';
TabName         = [FN_249_42.Data.DataStamp,'_','Table_Results_',FN_249_42.Data.FieldID,'.mat']
save_path = [FN_249_42.Data.save_to,TabName];

save(save_path,'Tab','-v7.3')
%% Save RMS Results

RMS = FN_249_42.Data.Results.RMS_zp;
%TabName1         = ['Table_Results_',FieldNames{FieldIdx(1)},'_',num2str(date.Day),'-',num2str(date2.Day),'-',char(monthyear),'_',DataPath(24:36),'RMS.mat']

TabName1  = [FN_249_42.Data.DataStamp,'_','Results_',FN_249_42.Data.FieldID,'RMS.mat']
save_path = [FN_249_42.Data.save_to,TabName1];

save(save_path,'RMS','-v7.3')
RMSsys =FN_249_42.Data.Results.RMS_sys;
%TabName12         = ['Table_Results_',FieldNames{FieldIdx(1)},'_',num2str(date.Day),'-',num2str(date2.Day),'-',char(monthyear),'_',DataPath(24:36),'RMSsys.mat']
TabName2  = [FN_249_42.Data.DataStamp,'_','Results_',FN_249_42.Data.FieldID,'RMSsys.mat']
save_path = [FN_249_42.Data.save_to,TabName2];


save(save_path,'RMSsys','-v7.3')



%%
clear all;
close all;


%%
%% 16/08 2nd Field


%% Initilize WDs Object


FN_342_21 = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


FN_342_21.Path =  '/last02w/data1/archive/LAST.01.02.03/2023/08/16/proc'; % Manual at the moment.

FN_342_21.Data.save_to =  '/home/ocs/Documents/WD_survey/Thesis/1608_352_21/';



%%

FN_342_21 = ListFields(FN_342_21) % List All Fields in Path

%% Get field FWHM LimMAG ra,dec during the obs
FN_342_21.FieldID = '352+21';
FN_342_21 = getObsInfo(FN_342_21,'FN',FN_342_21.FieldID);


%% Now you can look for WD within the field and add to E


%% targets in field
Names = [' WDJ232257.93+210803.07  ',
' WDJ232435.20+205633.83  ',
' WDJ232331.77+185610.23  ',
' WDJ232827.00+204044.96  ',
' WDJ232442.82+190837.65  ',
' WDJ232544.59+203145.63  ',
' WDJ232814.09+204211.91  ',
' WDJ232452.27+182223.06  ',
' WDJ232712.82+195636.47  ',
' WDJ232305.89+194442.44  ',
' WDJ232447.50+194937.21  ',
' WDJ232243.31+210712.75  ',
  ];

TargetList = [
350.7394101000056	21.132626573576157	17.91574	18.305508	17.368986
351.146410486043	20.94263902313934	15.562886	15.561338	15.611873
350.88221829308185	18.935726499255132	18.418001	18.613937	18.084864
352.1128693318813	20.678841099929585	18.029955	18.176569	17.796492
351.17870393286466	19.143897303463156	19.057571	19.348698	18.674469
351.43614441732404	20.528776472398594	16.746397	16.682844	16.918774
352.0587466070194	20.70307312909068	18.067667	18.108465	18.057043
351.2181423621212	18.37323515219932	18.05962	18.11082	17.955128
351.80360096960214	19.943467871257827	17.886946	17.852495	17.946587
350.77426582758204	19.744963100623785	18.004492	17.869314	17.985554
351.1979776475152	19.826836503267188	17.926273	17.87957	18.015371
350.6803420343602	21.12015421738512	19.085272	19.189425	19.024258

];


FN_342_21.Name = Names ;
FN_342_21.RA = TargetList(:,1);
FN_342_21.Dec = TargetList(:,2);
FN_342_21.G_g  = TargetList(:,3);
FN_342_21.G_Bp = TargetList(:,4);
FN_342_21.G_Rp =TargetList(:,5);
FN_342_21.Color = FN_342_21.G_Bp  - FN_342_21.G_Rp ;

%% Visit Inspection
FN_342_21 = VisitInspection(FN_342_21)

%% Batch Sorting:
[FN_342_21,Results1] = BatchSort(FN_342_21)

%% get 2vis light curves:

[FN_342_21] = get2VisLC(FN_342_21,'Results1',Results1)



%% all night data



[~,SortTicks] = sort(FN_342_21.G_Bp);

%
figure('Color','White','units','normalized','outerposition',[0 0 1 1])
Ticks = [];
for Iwd = 1 : numel(FN_342_21.RA)
    
    tick = num2str(FN_342_21.G_Bp(SortTicks(Iwd)));
    Ticks = [Ticks ; tick(1:5)];

end


T = FN_342_21.Data.Results.TotalObs;  %+ TotalObs2;

bar(T(SortTicks), 'FaceColor', [0.5 0.7 0.9])
%ylim([0,105]);
xticklabels(Ticks)
xlabel('$B_p$ [mag]','Interpreter','latex')
ylabel('Actuall Time','Interpreter','latex')

%title(sprintf('Available visits length ; Entire Observation (%s) hrs',obs_len+obs_len2),'Interpreter','latex')

title(sprintf('Available visits length ; Entire Observation (%s) hrs $N_{WD} = %i$ - %s',FN_342_21.Data.Results.obs_len,length(FN_342_21.RA),FN_342_21.Data.DataStamp),'Interpreter','latex')

file_name = [sprintf('Available \\ Visits \\ Obs \\ Time \\ %s \\ ID \\ %s \\ %i \\ Vis \\ %s \\ %s',FN_342_21.Data.Results.obs_len,FN_342_21.Data.DataStamp),'.png'];
sfile = strcat(FN_342_21.Data.save_to,file_name);
sfile= strrep(sfile, ' ', '');


sfile = strrep(sfile, '\', '_');
         

saveas(gcf,sfile) ;

pause(2)
close();



%%


Tab =[FN_342_21.RA, FN_342_21.Dec, FN_342_21.G_Bp, T]
    
%% If only E1 , Save Results
%% Save table
%monthyear       = E1.Data.Date;
%montyear.Format = 'MMM-uuuu';
TabName         = [FN_342_21.Data.DataStamp,'_','Table_Results_',FN_342_21.Data.FieldID,'.mat']
save_path = [FN_342_21.Data.save_to,TabName];

save(save_path,'Tab','-v7.3')
%% Save RMS Results

RMS = FN_342_21.Data.Results.RMS_zp;
%TabName1         = ['Table_Results_',FieldNames{FieldIdx(1)},'_',num2str(date.Day),'-',num2str(date2.Day),'-',char(monthyear),'_',DataPath(24:36),'RMS.mat']

TabName1  = [FN_342_21.Data.DataStamp,'_','Results_',FN_342_21.Data.FieldID,'RMS.mat']
save_path = [FN_342_21.Data.save_to,TabName1];

save(save_path,'RMS','-v7.3')
RMSsys =FN_342_21.Data.Results.RMS_sys;
%TabName12         = ['Table_Results_',FieldNames{FieldIdx(1)},'_',num2str(date.Day),'-',num2str(date2.Day),'-',char(monthyear),'_',DataPath(24:36),'RMSsys.mat']
TabName2  = [FN_342_21.Data.DataStamp,'_','Results_',FN_342_21.Data.FieldID,'RMSsys.mat']
save_path = [FN_342_21.Data.save_to,TabName2];


save(save_path,'RMSsys','-v7.3')

%%
close all; 
clear all;
