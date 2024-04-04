%% Initilize WDs Object


E1 = WDss({},{},{}	,{}	,[]  ,[]	,[],'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',{},'Isempty',true)


E1.Path =  '/last04w/data1/archive/LAST.01.04.03/2023/09/16/proc'; % Manual at the moment.

E1.Data.save_to =  '/home/ocs/Documents/WD_survey/Thesis/160923/';



%%

E1 = ListFields(E1) % List All Fields in Path

%% Get field FWHM LimMAG ra,dec during the obs
E1.FieldID = 'WD1856+534b';
E1 = getObsInfo(E1,'FN',E1.FieldID);


%% Now you can look for WD within the field and add to E


%% targets in field
Names = [' WDJ185739.34+533033.30  ',
' WDJ190151.48+543853.29  ',
' WDJ185638.59+541204.54  ',
' WDJ185540.92+540804.36  ',
' WDJ185638.24+551232.36  ',
' WDJ190409.18+524527.83  ',
' WDJ185809.96+523905.92  ',
' WDJ185536.06+545736.87  ',
' WDJ185625.50+552311.76  ',
' WDJ190118.84+522048.74  ',
' WDJ185648.26+532433.63  ',
' WDJ190045.59+552133.28  ',
' WDJ190125.42+530929.27  ',
  ];

TargetList = [
284.4166583277366	53.50889693218234	16.942257	17.473812	16.261986
285.46451695922866	54.647770254136596	17.45239	17.482496	17.01931
284.16094523353115	54.201532385066535	19.130383	19.18167	19.055906
283.92056526210166	54.13468664394657	19.197979	19.262983	19.330141
284.1594201741717	55.209191838332124	18.252651	18.181692	18.473812
286.03842862902314	52.75767645065096	19.055567	19.154284	19.129427
284.5414019337373	52.6515912033341	18.29842	18.221693	18.502737
283.90041906191317	54.96022418598208	18.284151	18.206831	18.479376
284.1060836190738	55.386561671665326	19.036299	19.004124	19.176504
285.3284705831294	52.34666307539199	19.082624	19.10867	19.254377
284.2011639434593	53.4093267287269	18.48324	18.368637	18.819489
285.1900539393304	55.35922561367326	18.412605	18.277262	18.649376
285.3559366286103	53.15816246805412	18.038101	17.954721	18.30376

];


E1.Name = Names ;
E1.RA = TargetList(:,1);
E1.Dec = TargetList(:,2);
E1.G_g  = TargetList(:,3);
E1.G_Bp = TargetList(:,4);
E1.G_Rp =TargetList(:,5);
E1.Color = E1.G_Bp  - E1.G_Rp ;

%% Visit Inspection
E1 = VisitInspection(E1)

%% Batch Sorting:
[E1,Results1] = BatchSort(E1)

%% get 2vis light curves:

[E1] = get2VisLC(E1,'Results1',Results1)



%% all night data



[~,SortTicks] = sort(E1.G_Bp);

%
figure('Color','White','units','normalized','outerposition',[0 0 1 1])
Ticks = [];
for Iwd = 1 : numel(E1.RA)
    
    tick = num2str(E1.G_Bp(SortTicks(Iwd)));
    Ticks = [Ticks ; tick(1:5)];

end


T = E1.Data.Results.TotalObs;  %+ TotalObs2;

bar(T(SortTicks), 'FaceColor', [0.5 0.7 0.9])
%ylim([0,105]);
xticklabels(Ticks)
xlabel('$B_p$ [mag]','Interpreter','latex')
ylabel('Actuall Time','Interpreter','latex')

%title(sprintf('Available visits length ; Entire Observation (%s) hrs',obs_len+obs_len2),'Interpreter','latex')

title(sprintf('Available visits length ; Entire Observation (%s) hrs $N_{WD} = %i$ - %s',E1.Data.Results.obs_len,length(E1.RA),E1.Data.DataStamp),'Interpreter','latex')

file_name = [sprintf('Available \\ Visits \\ Obs \\ Time \\ %s \\ ID \\ %s \\ %i \\ Vis \\ %s \\ %s',E1.Data.Results.obs_len,E1.Data.DataStamp),'.png'];
sfile = strcat(E1.Data.save_to,file_name);
sfile= strrep(sfile, ' ', '');


sfile = strrep(sfile, '\', '_');
         

saveas(gcf,sfile) ;

pause(2)
close();



%%


Tab =[E1.RA, E1.Dec, E1.G_Bp, T]
    
%% If only E1 , Save Results
%% Save table
%monthyear       = E1.Data.Date;
%montyear.Format = 'MMM-uuuu';
TabName         = [E1.Data.DataStamp,'_','Table_Results_',E1.Data.FieldID,'.mat']
save_path = [save_to,TabName];

save(E1.Data.Save_to,'Tab','-v7.3')
%% Save RMS Results

RMS = E1.Data.Results.RMS_zp;
%TabName1         = ['Table_Results_',FieldNames{FieldIdx(1)},'_',num2str(date.Day),'-',num2str(date2.Day),'-',char(monthyear),'_',DataPath(24:36),'RMS.mat']

TabName1  = [E1.Data.DataStamp,'_','Results_',E1.Data.FieldID,'RMS.mat']
save_path = [save_to,TabName1];

save(save_path,'RMS','-v7.3')
RMSsys =E1.Data.Results.RMS_sys;
%TabName12         = ['Table_Results_',FieldNames{FieldIdx(1)},'_',num2str(date.Day),'-',num2str(date2.Day),'-',char(monthyear),'_',DataPath(24:36),'RMSsys.mat']
save_path = [save_to,TabName12];
TabName2  = [E1.Data.DataStamp,'_','Results_',E1.Data.FieldID,'RMSsys.mat']

save(save_path,'RMSsys','-v7.3')

