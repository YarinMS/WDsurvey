
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
