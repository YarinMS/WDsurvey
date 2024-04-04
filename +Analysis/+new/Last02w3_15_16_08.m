
addpath('~/Documents/WDsurvey/')
%% Initilize WDs Object


FN_278_13 = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


FN_278_13.Path =  '/last02w/data1/archive/LAST.01.02.03/2023/08/15/proc'; % Manual at the moment.

FN_278_13.Data.save_to =  '/home/ocs/Documents/WD_survey/Thesis/1508_278_13/';



%%

FN_278_13 = ListFields(FN_278_13) % List All Fields in Path

%% Get field FWHM LimMAG ra,dec during the obs
FN_278_13.FieldID = '278+13';
FN_278_13 = getObsInfo(FN_278_13,'FN',FN_278_13.FieldID);


%% Now you can look for WD within the field and add to E


%% targets in field
Names = [' WDJ182524.24+113557.34  ',
' WDJ182624.44+112049.58  ',
' WDJ182417.72+120945.86  ',
' WDJ182458.45+121316.82  ',
' WDJ182215.02+114223.07  ',
' WDJ182324.16+104906.78  ',
' WDJ182625.79+115247.43  ',
' WDJ182406.08+121028.01  ',
' WDJ182520.22+105220.12  ',
' WDJ183019.60+123302.36  ',
' WDJ182710.05+110058.70  ',
' WDJ182742.40+121947.92  ',
' WDJ182628.26+111119.44  ',
' WDJ182651.16+125224.56  ',
' WDJ182758.19+112737.77  ',
' WDJ182213.90+123402.07  ',
' WDJ182416.32+110825.67  ',
' WDJ182620.15+104727.41  ',
' WDJ182642.10+104420.82  ',
' WDJ182418.03+132317.27  ',
' WDJ182410.91+121225.30  ',
' WDJ182849.27+110459.73  ',
  ];

TargetList = [
276.3487527200631	11.599563930665513	16.300005	16.788107	15.642944
276.6017282614052	11.345215803053172	16.96168	17.438145	16.28547
276.0741626862613	12.160774070960388	17.359898	17.783651	16.729012
276.24160400084656	12.214072582853818	18.528856	19.260303	17.717615
275.5627995716641	11.705651282402254	18.040401	18.169184	17.680088
275.85116096659357	10.818259495093905	19.19811	19.570448	18.804756
276.6070796345024	11.879840333614654	18.887508	19.046162	18.688597
276.02529980435366	12.174357763324924	18.21506	18.29221	18.141678
276.3342639786979	10.872266682593478	19.143505	19.264309	18.493355
277.5820471010015	12.55075579386497	18.4519	18.548965	18.424723
276.7920100251332	11.016200123266934	19.157564	19.186739	18.948948
276.9265944400963	12.32990453288445	18.724953	18.810057	18.708282
276.61775154068835	11.188748992099693	18.66118	18.711815	18.678219
276.71309469113464	12.873587012028395	18.731997	18.77813	18.80261
276.9925388366922	11.460374796880918	18.641699	18.61127	18.722984
275.55782913161255	12.567095222485568	19.188732	19.226555	19.211834
276.0679801555102	11.140322676881983	18.818575	18.757809	18.946928
276.5839791134279	10.790941199520624	18.865166	18.854988	19.071928
276.67544649625813	10.739139191063419	18.068407	18.003	18.023598
276.0751720051965	13.38807790837421	19.19521	19.161291	19.319265
276.04547985802833	12.207048487776133	19.106722	19.012136	19.31667
277.2052770342132	11.083232780594905	18.284117	18.23534	18.465946


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

%% Initilize WDs Object


FN_294_42 = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


FN_294_42.Path =  '/last02w/data1/archive/LAST.01.02.03/2023/08/16/proc'; % Manual at the moment.

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
