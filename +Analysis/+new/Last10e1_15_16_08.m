%% All Data Analysis

%% 15-16/08            

%% Field 1 night 1 
% Initilize WDs Object


F312_25N1 = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


F312_25N1.Path =  '/las10e/data1/archive/LAST.01.10.01/2023/08/15/proc'; % Manual at the moment.

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
    Ticks = [Ticks ; tick(1:4)];

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










