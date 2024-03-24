%%

addpath('/home/ocs/Documents/WDsurvey/')


%% All Field analysis :



%% List Fields In Path

DataPath = '/last02w/data1/archive/LAST.01.02.03/2023/09/15/proc';

cd(DataPath)

Visits = dir;

FieldNames = [] ;

for Ivis = 3 : numel(Visits)
    
    cd(Visits(Ivis).name)
    
    Cats = dir;
    
    VisitCenter = '010_001_015_sci_proc_Cat_1.fits';
    
    IDX = find(contains({Cats.name},VisitCenter));
    
    if isempty(IDX)
        
        IDX =  find(contains({Cats.name}, '001_001_015_sci_proc_Cat_1.fits'));
        
    end
    
    H   = AstroHeader(Cats(IDX).name,3);
    
    FieldNames = [FieldNames ; {H.Key.FIELDID}]
    
    
    cd ..
        
    
end
    
    
DataStamp = [DataPath(24:36),'-',DataPath(38:41),'-',DataPath(43:44),'-',DataPath(46:47)]
    
%% Read from Cats by FieldID

% FOV center by subframe

Subframe = '016';




% FieldIdx = 1;

FieldIdx = find(contains(FieldNames,'field1064'))

Results  = ReadFromCat(DataPath,'Field',FieldNames{FieldIdx(1)},'SubFrame',Subframe,'getAirmass',true);


% Store Results for :

% Subframe Airmass Vs time


% Sub frame Lim Mag Vs time

date = datetime(Results.JD(1),'convertfrom','jd')

save_to   = '/home/ocs/Documents/WD_survey/Thesis/'
file_name = ['Field_Results_',FieldNames{FieldIdx(1)},'_',char(DataStamp),'.mat']

save([save_to,file_name],'Results','-v7.3') ;



%% targets in field
Names = [' WDJ013308.60+200812.85  ',
' WDJ013101.71+223931.88  ',
' WDJ013105.28+200924.38  ',
' WDJ013701.16+220815.86  ',
' WDJ013505.41+222936.07  ',
' WDJ013603.93+215533.41  ',
' WDJ013012.10+202243.43  ',
' WDJ013437.32+213108.79  ',
' WDJ013148.42+214252.12  ',
' WDJ013649.76+221502.36  ',
' WDJ013344.15+202913.70  ',
' WDJ013638.22+200139.86  ',
' WDJ013756.19+202055.00  ',
' WDJ013357.51+212454.77  ',
' WDJ013254.93+201804.81  ',
' WDJ013228.61+210522.98  ',
' WDJ013350.21+201305.29  '
  ]

TargetList = [
23.28684800866559	20.13666392085198	17.447458	17.639208	17.141003
22.757585552259446	22.65792865223831	18.922604	19.36332	18.287981
22.77399665481584	20.15682204376322	16.686377	16.75457	16.574608
24.25676996780493	22.1368971013961	19.198763	19.436268	18.491539
23.772805596951592	22.493300227540782	17.12926	17.108295	17.245388
24.016847418603117	21.926172996263787	19.159946	19.358484	18.72344
22.55035489323601	20.378341093616623	18.507906	18.642212	18.410074
23.655696766651694	21.519130675121936	17.94741	17.917995	18.069656
22.952204874688054	21.7143069500553	18.869852	19.001274	18.774254
24.20746480386658	22.250502558223992	18.503004	18.546051	18.51596
23.433902566669364	20.487082269020757	18.111885	18.086502	18.26762
24.159566581899956	20.027905318929047	18.056427	18.019995	18.261898
24.484079075580805	20.348626285756815	19.18932	19.20853	19.18307
23.489576500056092	21.41511303770853	18.91787	18.957825	18.88258
23.22893797649343	20.3012342281222	19.129847	19.153898	19.148558
23.119021798181844	21.089463528670592	17.058338	16.929102	17.335806
23.45914263578131	20.21805993387003	19.042343	19.049355	19.145393];



Pathway = [DataPath,'/',Visits(FieldIdx(2)).name]



E = WDs(Pathway,Names,TargetList(:,1)	,TargetList(:,2)	,TargetList(:,3)    ,TargetList(:,4)	,TargetList(:,5),'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',FieldNames{FieldIdx(1)})



% look at the entire data first:

for Iwd =1 : numel(E.RA)
    
 if ~isempty( E.Data.Catalog.PSF2{Iwd})
    
    source_index = E.Data.Catalog.PSF2{Iwd}.coneSearch(E.RA(Iwd),E.Dec(Iwd)).Ind;
    
    if ~isempty(source_index)
        figure('color','white');
        t = E.Data.Catalog.PSF2{Iwd}.JD;
        y = E.Data.Catalog.PSF2{Iwd}.Data.MAG_PSF(:,source_index);
        
        plot(t,y,'k.');
        set(gca, 'YDir','reverse')
        title(E.Name(Iwd,:))
        
       
        
    end
    
 end 
end
    
    
    




%% Look for targets in ALL Visits:


cd(DataPath)

Visits = dir;

List = MatchedSources.rdirMatchedSourcesSearch('CropID',16);      
                           % Consider only visits with the same Field ID
visits = find(contains(List.FileName,FieldNames{FieldIdx(1)}));
List.FileName = List.FileName(visits);
List.Folder   = List.Folder(visits);
List.CropID   = List.CropID;

%tgt_ind = 1 ; 

FoundIN= zeros(24,length(E.RA),numel(List.Folder)) ;


for Ivis = 1 : numel(List.Folder)
    
    cd(List.Folder{Ivis})
    
    for Icrop =  1 : 24
    
         L = MatchedSources.rdirMatchedSourcesSearch('CropID',Icrop);            
         %   Upload all files to a MatchedSources object
         if ~isempty(L.FileName)
              matched = MatchedSources.readList(L); 
         
         
         
         for Iwd = 1 : numel(E.RA)
             
             FoundInd = matched.coneSearch(E.RA(Iwd),E.Dec(Iwd)).Ind;
             
             if ~isempty(FoundInd)
                 
                 LenEl   = length(List.Folder{Ivis});
                 VisName = List.Folder{Ivis}(LenEl-7:LenEl);
                 
                 fprintf('\nWD # %i , Found In Vis : %i : %s ; Sub Frame = %i \n',...
                     Iwd,Ivis,VisName,Icrop)
                 
                 FoundIN(Icrop,Iwd,Ivis) = 1;
                 
             end
             
             
         end
         end
         
         
         
         
    end
           
       
    
    
    cd ..
        
    
end
    

%% Detection Statistics for catalog

Nvisits = zeros(numel(E.RA),1);
Doubles = zeros(numel(E.RA),1);

for Iwd = 1 : numel(E.RA)
    
    for Ivis = 1 : numel(FoundIN(1,1,:))
        
        
        found = sum(FoundIN(:,Iwd,Ivis));
        
        if found > 0 
            
              Nvisits(Iwd) = Nvisits(Iwd) + 1 ;
              
        end
        
        if found > 1
            
            fprintf('\nWD # % i appears in more than one subframe; Vis %i , Subframes : %s \n', Iwd,Ivis,num2str(find( FoundIN(:,Iwd,Ivis) > 0 )'))

            Doubles(Iwd) = Doubles(Iwd) + 1;
            
        end
              
        
        
    end
    
    
    
    
    
end

Results.Nwd     = numel(E.RA);
Results.CoordWD = [E.RA,E.Dec];
Results.Bp      = E.G_Bp;
Results.Nvisits = Nvisits;


%% Get Final Subframes



WD_sf = cell(size(FoundIN,2),1) ; 


for Iwd = 1 : numel(E.RA)
    
    subframes = [];
    
    for Isf = 1 : size(FoundIN,1)
        
        if any(FoundIN(Isf,Iwd,:))
            
            subframes = [subframes, Isf];
            
        end
 
        
    end
    
    WD_sf{Iwd} = subframes;
    
    
end

Results.SubFrame = WD_sf;



%%



% get obs length

dates = datetime(Results.JD,'convertfrom','jd');
obs_len = dates(end) - dates(1);


%% Plot Detection Rate [IN CATALOG]
[~,SortTicks] = sort(E.G_Bp);

%
figure('Color','White')
Ticks = [];
for Iwd = 1 : numel(E.RA)
    
    tick = num2str(E.G_Bp(SortTicks(Iwd)));
    Ticks = [Ticks ; tick(1:5)];

end

bar(100*Nvisits(SortTicks)/numel(FoundIN(1,1,:)), 'FaceColor', [0.5 0.7 0.9])
ylim([0,105]);
xticklabels(Ticks)
xlabel('$B_p$ [mag]','Interpreter','latex')
ylabel('Detection rate $\%$','Interpreter','latex')

title(sprintf('Proportion of Detection Relative to the entire Observation (%s) hrs %s',obs_len,DataStamp),'Interpreter','latex')




%% 2 Visits

% From every two visits take :

% Coord
% mag & err
% Ref - stars ???


% create batches :
cd(DataPath)



% sort visits by date:

[List.FileName,SortedList] = sort(List.FileName);
List.Folder = List.Folder(SortedList);


%% Consider only SF with WDs
Sub_Frames = [];

for Isf = 1 : numel(Results.SubFrame)
    
    if ~isempty(Results.SubFrame{Isf})
        
        nsf = numel(Results.SubFrame{Isf});
        
        for Insf = 1 :nsf
            
             if isempty(find(Sub_Frames == Results.SubFrame{Isf}(Insf)))
                 
                   
                 
                    Sub_Frames = [Sub_Frames ; Results.SubFrame{Isf}(Insf)];
             end
        end
    end
end


%% New 2 vis !




%% 3rd version of :
%%
%
Main ={};
Nvis = numel(List.Folder);
VN   = {};





even = rem(Nvis,2) == 0;

if even  
    
    counter = 1;
    for Ibatch = 1 : Nvis/2 -1
    
          % Batches of two 
            list.FileName = List.FileName(counter:counter+1);
            list.Folder   = List.Folder(counter:counter+1);
            
          
            
            

          
          
          % Given the 2 visits : 
          
          for Isf = 1 : numel(Sub_Frames)
              
                 list.CropID = Sub_Frames(Isf);
                 ID          = num2str(list.CropID);
                 if length(ID) > 1
                     
                     ID = ['0' ID];
                     
                 else
                     
                     ID = ['00' ID];
                 end
                 
                 for Iid = 1 : length(list.FileName)
                     
                      list.FileName{Iid}(end-30:end-28) = ID;
                 end
                 
                 
                 
               
                     
                 
                 
              
              
          
                 %L = MatchedSources.rdirMatchedSourcesSearch('CropID',Sub_Frames(Isf),'MinJD',MinJD,'MaxJD',MaxJD);            
               % Upload all files to a MatchedSources object
                 matched_source = MatchedSources.readList(list); 
               % Merge all MatchedSources elkement into a single element object
                 MSU = mergeByCoo( matched_source, matched_source(1));
                 Main{Ibatch,Isf} = MSU.copy();
                 VN{Ibatch,Isf}   = list.Folder{1}(end-7:end);
          end
          counter = counter+2
    end
    
    
    
else
    
    % Batch of three and than batches of 2;
    counter = 1;
    for Ibatch = 1 : Nvis/2 
        
        
        if Ibatch == 1
            
            % Batches of three 
   
            list.FileName = List.FileName(counter:counter+2);
            list.Folder   = List.Folder(counter:counter+2);
            
   
            
            
           
          
          % Given the 2 visits : solve for what ever you want !
          
            for Isf = 1 : numel(Sub_Frames)
                
                list.CropID = Sub_Frames(Isf);
                 ID          = num2str(list.CropID);
                 if length(ID) > 1
                     
                     ID = ['0' ID];
                     
                 else
                     
                     ID = ['00' ID];
                 end
                 
                 for Iid = 1 : length(list.FileName)
                     
                      list.FileName{Iid}(end-30:end-28) = ID;
                 end
             
          
               % L = MatchedSources.rdirMatchedSourcesSearch('CropID',Sub_Frames(Isf),'MinJD',MinJD,'MaxJD',MaxJD);            
               % Upload all files to a MatchedSources object
                 matched_source = MatchedSources.readList(list); 
               % Merge all MatchedSources elkement into a single element object
                 MSU = mergeByCoo( matched_source, matched_source(1));
                 Main{Ibatch,Isf} = MSU.copy();
                 VN{Ibatch,Isf}   = list.Folder{1}(end-7:end);
            
            
            end
            counter = counter+3
            
            
            
        else
            
    
            % Batches of two 
   
            list.FileName = List.FileName(counter:counter+1);
            list.Folder   = List.Folder(counter:counter+1);
            
    

          % Given the 2 visits : solve for what ever you want !
          
            for Isf = 1 : numel(Sub_Frames)
                
                
                list.CropID = Sub_Frames(Isf);
                 ID          = num2str(list.CropID);
                 if length(ID) > 1
                     
                     ID = ['0' ID];
                     
                 else
                     
                     ID = ['00' ID];
                 end
                 
                 for Iid = 1 : length(list.FileName)
                     
                      list.FileName{Iid}(end-30:end-28) = ID;
                 end

          
               % L = MatchedSources.rdirMatchedSourcesSearch('CropID',Sub_Frames(Isf),'MinJD',MinJD,'MaxJD',MaxJD);            
               % Upload all files to a MatchedSources object
                 matched_source = MatchedSources.readList(list); 
               % Merge all MatchedSources elkement into a single element object
                 MSU = mergeByCoo( matched_source, matched_source(1));
                 Main{Ibatch,Isf} = MSU.copy();
                 VN{Ibatch,Isf}   = list.Folder{1}(end-7:end);
            end
            counter = counter+2
        end
    
   end
end


% Store in Results (for now)

Results.Main = Main;
Results.SFcol = Sub_Frames;


Results.VisMap = {}
%% First compare two vis sys to no sys


% loop over all tagrets.
Vistat = {};
% Chose a WD

wdIdx = 7;


for i = 1 : length(E.RA)
wdIdx = i;


for Icol = 1 : numel(Results.SubFrame{wdIdx})
    
    MainCol = find(Results.SFcol == Results.SubFrame{wdIdx}(1,Icol));
   
    
    for Ibatch = 1 : size(Results.Main,1)
    
    Found_Index = Results.Main{Ibatch,MainCol}.coneSearch(E.RA(wdIdx),E.Dec(wdIdx)).Ind;
    
    if ~isempty(Found_Index)
        
        for Ifind = 1: length(Found_Index)
        
              [maso,event,Npts] = getLCsys( Results.Main{Ibatch,MainCol},'SourceIdx',Found_Index(Ifind),'SaveTo',save_to,'Serial',...
                  sprintf('Found \\ %i \\ WD \\ %i \\ Batch \\ %i \\ SF \\ %i \\ Vis \\  %s \\ %s',Ifind,wdIdx,Ibatch,Results.SFcol(MainCol),VN{Ibatch,MainCol},DataStamp),'WD',E,'wdIdx',wdIdx);
        
              if event
                
                  save([save_to,'Event_In_',VN{Ibatch,MainCol},'_.mat'],'maso','-v7.3')
                  fprintf('\nDetected event stored, WD %i Batch  %i SF %i V %s \n Found #_',wdIdx,Ibatch,Results.SFcol(MainCol),VN{Ibatch,MainCol},Ifind)
            
              end
              
              if (Npts )> 20 & ( Ifind == 1) 
                  Results.VisMap{Ibatch,wdIdx} =  [1 Ibatch Results.SFcol(MainCol) wdIdx ] %[ 1 Ibatch,
                  
                  Results.VisMapR{Ibatch,wdIdx} = { [1] [ sprintf('Batch : %i  SF : %i ; WD %i ; idx: %i',Ibatch, Results.SFcol(MainCol), wdIdx,Ifind )]}
             
              
              end
              if (Npts )> 20  & (Icol> 1 )
                  Results.VisMap2{Ibatch,wdIdx} =  [1 Ibatch Results.SFcol(MainCol) wdIdx ] %[ 1 Ibatch,
                  
                  Results.VisMapR2{Ibatch,wdIdx} = { [1] [ sprintf('Batch : %i  SF : %i ; WD %i ; idx: %i',Ibatch, Results.SFcol(MainCol), wdIdx,Ifind )]}
 
              end
         
              
        end
    end
        
    
    end

end
end

%%
Vistat = zeros(length(E.RA),size(Results.VisMap,1));

for Iwd = 1 : length(E.RA)
    
    BatchCount = 1;
  
    
    
        
     for Icol = 1 : size(Results.VisMap,2)
         
            
            
                
                 CellData = Results.VisMap(:,Icol);
            
            for Irow = 1 : size(Results.VisMap,1)
                
                if ~isempty(CellData{Irow})
                
            
                  if CellData{Irow}(4) == Iwd
                      
                      Vistat(Iwd,Irow) = 1;
                      
                      fprintf('\nFound wd %i IN batch %i on col %i  \n',Iwd,Irow,Icol)
                      
                      if CellData{Irow}(2) ~= Irow
                          
                          fprintf('\nwd %i IN batch %i Contradicition found in %i  \n',Iwd,Irow,CellData{Irow}(2))
                          
                      end
                          
                          
                
                  end
                
                
                end
            
             end
            
        
        
        
        
        
        
    end
    
    
    
    
    
    
    
end





%% Vis statistics

TotalObs = sum(Vistat,2)*800/3600

figure('Color','white')



bar(TotalObs(SortTicks), 'FaceColor', [0.5 0.7 0.9])
%ylim([0,105]);
xticklabels(Ticks)
xlabel('$B_p$ [mag]','Interpreter','latex')
ylabel('Actuall Time','Interpreter','latex')

title(sprintf('Available visits length ; Entire Observation (%s) hrs',obs_len),'Interpreter','latex')





%% Next obs

%%

addpath('/home/ocs/Documents/WDsurvey/')


%% All Field analysis :



%% List Fields In Path

DataPath2 = '/last02w/data1/archive/LAST.01.02.03/2023/09/16/proc';

cd(DataPath2)

Visits2 = dir;

FieldNames2 = [] ;

for Ivis = 3 : numel(Visits2)
    
    cd(Visits2(Ivis).name)
    
    Cats2 = dir;
    
    VisitCenter = '010_001_015_sci_proc_Cat_1.fits';
    
    IDX2 = find(contains({Cats2.name},VisitCenter));
    
    if isempty(IDX2)
        
        IDX2 =  find(contains({Cats2.name}, '001_001_015_sci_proc_Cat_1.fits'));
        
    end
    
    H2   = AstroHeader(Cats2(IDX2).name,3);
    
    FieldNames2 = [FieldNames2 ; {H2.Key.FIELDID}]
    
    
    cd ..
        
    
end
    
    
       
DataStamp2 = [DataPath2(24:36),'-',DataPath2(38:41),'-',DataPath2(43:44),'-',DataPath2(46:47)]
    
%% Read from Cats by FieldID

% FOV center by subframe

Subframe = '015';




% FieldIdx = 1;

FieldIdx2 = find(contains(FieldNames2,'field1064'))

Results2  = ReadFromCat(DataPath2,'Field',FieldNames2{FieldIdx2(1)},'SubFrame',Subframe,'getAirmass',true);


% Store Results for :

% Subframe Airmass Vs time


% Sub frame Lim Mag Vs time

date2 = datetime(Results2.JD(1),'convertfrom','jd')

save_to   = '/home/ocs/Documents/WD_survey/Thesis/'
file_name2 = ['Field_Results_',FieldNames2{FieldIdx2(1)},'_',char(date2),'.mat']

save([save_to,file_name2],'Results','-v7.3') ;



%% targets in field



Pathway2 = [DataPath2,'/',Visits2(FieldIdx2(2)).name]





%% Look for targets in ALL Visits:


cd(DataPath2)

Visits2 = dir;

List2 = MatchedSources.rdirMatchedSourcesSearch('CropID',16);      
                           % Consider only visits with the same Field ID
visits2 = find(contains(List2.FileName,FieldNames2{FieldIdx2(1)}));
List2.FileName = List2.FileName(visits2);
List2.Folder   = List2.Folder(visits2);
List2.CropID   = List2.CropID;

%tgt_ind = 1 ; 

FoundIN2 = zeros(24,length(E.RA),numel(List2.Folder)) ;


for Ivis = 1 : numel(List2.Folder)
    
    cd(List2.Folder{Ivis})
    
    for Icrop =  1 : 24
    
         L2 = MatchedSources.rdirMatchedSourcesSearch('CropID',Icrop);            
         %   Upload all files to a MatchedSources object
         matched2 = MatchedSources.readList(L2); 
         
         for Iwd = 1 : numel(E.RA)
             
             FoundInd = matched2.coneSearch(E.RA(Iwd),E.Dec(Iwd)).Ind;
             
             if ~isempty(FoundInd)
                 
                 LenEl2   = length(List2.Folder{Ivis});
                 VisName2 = List2.Folder{Ivis}(LenEl2-7:LenEl2);
                 
                 fprintf('\nWD # %i , Found In Vis : %i : %s ; Sub Frame = %i \n',...
                     Iwd,Ivis,VisName2,Icrop)
                 
                 FoundIN2(Icrop,Iwd,Ivis) = 1;
                 
             end
             
             
         end
         
         
         
         
    end
           
       
    
    
    cd ..
        
    
end
    

%% Detection Statistics for catalog

Nvisits2 = zeros(numel(E.RA),1);
Doubles2 = zeros(numel(E.RA),1);

for Iwd = 1 : numel(E.RA)
    
    for Ivis = 1 : numel(FoundIN2(1,1,:))
        
        
        found2 = sum(FoundIN2(:,Iwd,Ivis));
        
        if found2 > 0 
            
              Nvisits2(Iwd) = Nvisits2(Iwd) + 1 ;
              
        end
        
        if found2 > 1
            
            fprintf('\nWD # % i appears in more than one subframe; Vis %i , Subframes : %s \n', Iwd,Ivis,num2str(find( FoundIN2(:,Iwd,Ivis) > 0 )'))

            Doubles2(Iwd) = Doubles2(Iwd) + 1;
            
        end
              
        
        
    end
    
    
    
    
    
end

Results2.Nwd     = numel(E.RA);
Results2.CoordWD = [E.RA,E.Dec];
Results2.Bp      = E.G_Bp;
Results2.Nvisits = Nvisits2;


%% Get Final Subframes



WD_sf2 = cell(size(FoundIN2,2),1) ; 


for Iwd = 1 : numel(E.RA)
    
    subframes2 = [];
    
    for Isf = 1 : size(FoundIN2,1)
        
        if any(FoundIN2(Isf,Iwd,:))
            
            subframes2 = [subframes2, Isf];
            
        end
 
        
    end
    
    WD_sf2{Iwd} = subframes2;
    
    
end

Results2.SubFrame = WD_sf2;



%%



% get obs length

dates2 = datetime(Results2.JD,'convertfrom','jd');
obs_len2 = dates2(end) - dates2(1);


%% Plot Detection Rate [IN CATALOG]
[~,SortTicks2] = sort(E.G_Bp);

%
figure('Color','White')
Ticks2 = [];
for Iwd = 1 : numel(E.RA)
    
    tick2 = num2str(E.G_Bp(SortTicks2(Iwd)));
    Ticks2 = [Ticks2 ; tick2(1:5)];

end

bar(100*Nvisits2(SortTicks2)/numel(FoundIN2(1,1,:)), 'FaceColor', [0.5 0.7 0.9])
ylim([0,105]);
xticklabels(Ticks2)
xlabel('$B_p$ [mag]','Interpreter','latex')
ylabel('Detection rate $\%$','Interpreter','latex')

title(sprintf('Proportion of Detection Relative to the entire Observation (%s) hrs',obs_len2),'Interpreter','latex')




%% 2 Visits

% From every two visits take :

% Coord
% mag & err
% Ref - stars ???


% create batches :
cd(DataPath2)



% sort visits by date:

[List2.FileName,SortedList] = sort(List2.FileName);
List2.Folder = List2.Folder(SortedList);


%% Consider only SF with WDs
Sub_Frames2 = [];

for Isf = 1 : numel(Results2.SubFrame)
    
    if ~isempty(Results2.SubFrame{Isf})
        
        nsf2 = numel(Results2.SubFrame{Isf});
        
        for Insf = 1 :nsf2
            
             if isempty(find(Sub_Frames2 == Results2.SubFrame{Isf}(Insf)))
                 
                   
                 
                    Sub_Frames2 = [Sub_Frames2 ; Results2.SubFrame{Isf}(Insf)];
             end
        end
    end
end


%% New 2 vis !




%% 3rd version of :
%%
%
Main2 ={};
Nvis2 = numel(List2.Folder);
VN2   = {};





even2 = rem(Nvis2,2) == 0;

if even2  
    
    counter2 = 1;
    for Ibatch = 1 : Nvis2/2 -1
    
          % Batches of two 
            list2.FileName = List2.FileName(counter2:counter2+1);
            list2.Folder   = List2.Folder(counter2:counter2+1);
            
          
            
            

          
          
          % Given the 2 visits : 
          
          for Isf = 1 : numel(Sub_Frames2)
              
                 list2.CropID = Sub_Frames2(Isf);
                 ID2          = num2str(list2.CropID);
                 if length(ID2) > 1
                     
                     ID2 = ['0' ID2];
                     
                 else
                     
                     ID2 = ['00' ID2];
                 end
                 
                 for Iid = 1 : length(list2.FileName)
                     
                      list2.FileName{Iid}(end-30:end-28) = ID2;
                 end
                 
                 
                 
               
                     
                 
                 
              
              
          
                 %L = MatchedSources.rdirMatchedSourcesSearch('CropID',Sub_Frames(Isf),'MinJD',MinJD,'MaxJD',MaxJD);            
               % Upload all files to a MatchedSources object
                 matched_source2 = MatchedSources.readList(list2); 
               % Merge all MatchedSources elkement into a single element object
                 MSU2 = mergeByCoo( matched_source2, matched_source2(1));
                 Main2{Ibatch,Isf} = MSU2.copy();
                 VN2{Ibatch,Isf}   = list2.Folder{1}(end-7:end);
          end
          counter2 = counter2+2
    end
    
    
    
else
    
    % Batch of three and than batches of 2;
    counter2 = 1;
    for Ibatch = 1 : Nvis2/2 
        
        
        if Ibatch == 1
            
            % Batches of three 
   
            list2.FileName = List2.FileName(counter2:counter2+2);
            list2.Folder   = List2.Folder(counter2:counter2+2);
            
   
            
            
           
          
          % Given the 2 visits : solve for what ever you want !
          
            for Isf = 1 : numel(Sub_Frames2)
                
                list2.CropID = Sub_Frames2(Isf);
                 ID2          = num2str(list2.CropID);
                 if length(ID2) > 1
                     
                     ID2 = ['0' ID2];
                     
                 else
                     
                     ID2 = ['00' ID2];
                 end
                 
                 for Iid = 1 : length(list2.FileName)
                     
                      list2.FileName{Iid}(end-30:end-28) = ID2;
                 end
             
          
               % L = MatchedSources.rdirMatchedSourcesSearch('CropID',Sub_Frames(Isf),'MinJD',MinJD,'MaxJD',MaxJD);            
               % Upload all files to a MatchedSources object
                 matched_source2 = MatchedSources.readList(list2); 
               % Merge all MatchedSources elkement into a single element object
                 MSU2 = mergeByCoo( matched_source2, matched_source2(1));
                 Main2{Ibatch,Isf} = MSU2.copy();
                 VN2{Ibatch,Isf}   = list2.Folder{1}(end-7:end);
            
            
            end
            counter2 = counter2+3
            
            
            
        else
            
    
            % Batches of two 
   
            list2.FileName = List2.FileName(counter2:counter2+1);
            list2.Folder   = List2.Folder(counter2:counter2+1);
            
    

          % Given the 2 visits : solve for what ever you want !
          
            for Isf = 1 : numel(Sub_Frames2)
                
                
                list2.CropID = Sub_Frames2(Isf);
                 ID2          = num2str(list2.CropID);
                 if length(ID2) > 1
                     
                     ID2 = ['0' ID2];
                     
                 else
                     
                     ID2 = ['00' ID2];
                 end
                 
                 for Iid = 1 : length(list2.FileName)
                     
                      list2.FileName{Iid}(end-30:end-28) = ID2;
                 end

          
               % L = MatchedSources.rdirMatchedSourcesSearch('CropID',Sub_Frames(Isf),'MinJD',MinJD,'MaxJD',MaxJD);            
               % Upload all files to a MatchedSources object
                 matched_source2 = MatchedSources.readList(list2); 
               % Merge all MatchedSources elkement into a single element object
                 MSU2 = mergeByCoo( matched_source2, matched_source2(1));
                 Main2{Ibatch,Isf} = MSU2.copy();
                 VN2{Ibatch,Isf}   = list2.Folder{1}(end-7:end);
            end
            counter2 = counter2+2
        end
    
   end
end


% Store in Results (for now)

Results2.Main = Main2;
Results2.SFcol = Sub_Frames2;


Results2.VisMap = {}
%% First compare two vis sys to no sys


% loop over all tagrets.
Vistat2 = {};
% Chose a WD

rms0 = zeros(numel(E.RA),size(Results2.Main,1))
rms1 = zeros(numel(E.RA),size(Results2.Main,1))


for i = 1 : numel(E.RA)

wdIdx2 = i;


for Icol = 1 : numel(Results2.SubFrame{wdIdx2})
    
    MainCol2 = find(Results2.SFcol == Results2.SubFrame{wdIdx2}(1,Icol));
   
    
    for Ibatch = 1 : size(Results2.Main,1)
    
    Found_Index2 = Results2.Main{Ibatch,MainCol2}.coneSearch(E.RA(wdIdx2),E.Dec(wdIdx2)).Ind;
    
    if ~isempty(Found_Index2)
        
        for Ifind = 1: length(Found_Index2)
        
              [maso,event,Npts,RMS0,RMS1] = getLCsys( Results2.Main{Ibatch,MainCol2},'SourceIdx',Found_Index2(Ifind),'SaveTo',save_to,'Serial',...
                  sprintf('Found \\ %i \\ WD \\ %i \\ Batch \\ %i \\ SF \\ %i \\ Vis \\ %s \\ %s',Ifind,wdIdx2,Ibatch,Results2.SFcol(MainCol2),VN2{Ibatch,MainCol2},DataStamp2),'WD',E,'wdIdx',wdIdx2);
             %  [maso,event,Npts] = getLCsys( Results.Main{Ibatch,MainCol},'SourceIdx',Found_Index(Ifind),'SaveTo',save_to,'Serial',...
              %    sprintf('Found \\ %i \\ WD \\ %i \\ Batch \\ %i \\ SF \\ %i \\ Vis \\  %s \\ %s',Ifind,wdIdx,Ibatch,Results.SFcol(MainCol),VN{Ibatch,MainCol},DataStamp),'WD',E,'wdIdx',wdIdx);
              rms0(wdIdx2,Ibatch,MainCol2) = RMS0;
              rms1(wdIdx2,Ibatch,MainCol2) = RMS0;
              if event
                
                  save([save_to,'Event_In_',VN2{Ibatch,MainCol2},'_.mat'],'maso','-v7.3')
                  fprintf('\nDetected event stored, WD %i Batch  %i SF %i V %s \n Found #_',wdIdx2,Ibatch,Results2.SFcol(MainCol2),VN2{Ibatch,MainCol2},Ifind)
            
              end
              
              if (Npts )> 20 & ( Ifind == 1) 
                  Results2.VisMap{Ibatch,wdIdx2} =  [1 Ibatch Results2.SFcol(MainCol2) wdIdx2 ] %[ 1 Ibatch,
                  
                  Results2.VisMapR{Ibatch,wdIdx2} = { [1] [ sprintf('Batch : %i  SF : %i ; WD %i ; idx: %i',Ibatch, Results2.SFcol(MainCol2), wdIdx2,Ifind )]}
             
              
              end
              if (Npts )> 20  & (Icol> 1 )
                  Results2.VisMap2{Ibatch,wdIdx2} =  [1 Ibatch Results2.SFcol(MainCol2) wdIdx2 ] %[ 1 Ibatch,
                  
                  Results2.VisMapR2{Ibatch,wdIdx2} = { [1] [ sprintf('Batch : %i  SF : %i ; WD %i ; idx: %i',Ibatch, Results2.SFcol(MainCol2), wdIdx2,Ifind )]}
 
              end
         
              
        end
    end
        
    
    end

end

end

%%
Vistat2 = zeros(length(E.RA),size(Results2.VisMap,1));

for Iwd = 1 : length(E.RA)
    
    BatchCount = 1;
  
    
    
        
     for Icol = 1 : size(Results2.VisMap,2)
         
            
            
                
                 CellData2 = Results2.VisMap(:,Icol);
            
            for Irow = 1 : size(Results2.VisMap,1)
                
                if ~isempty(CellData2{Irow})
                
            
                  if CellData2{Irow}(4) == Iwd
                      
                      Vistat2(Iwd,Irow) = 1;
                      
                      fprintf('\nFound wd %i IN batch %i on col %i  \n',Iwd,Irow,Icol)
                      
                      if CellData2{Irow}(2) ~= Irow
                          
                          fprintf('\nwd %i IN batch %i Contradicition found in %i  \n',Iwd,Irow,CellData2{Irow}(2))
                          
                      end
                          
                          
                
                  end
                
                
                end
            
             end
            
        
        
        
        
        
        
    end
    
    
    
    
    
    
    
end





%% Vis statistics

TotalObs2 = sum(Vistat2,2)*800/3600

figure('Color','white')



bar(TotalObs2(SortTicks2), 'FaceColor', [0.5 0.7 0.9])
%ylim([0,105]);
xticklabels(Ticks2)
xlabel('$B_p$ [mag]','Interpreter','latex')
ylabel('Actuall Time','Interpreter','latex')

title(sprintf('Available visits length ; Entire Observation (%s) hrs',obs_len2),'Interpreter','latex')


%% Observation fusing

R.JD = [Results.JD;Results2.JD];
R.AM = [Results.AM;Results2.AM];

figure('Color','white')
plot(R.JD,R.AM,'.')
set(gca,'YDir','reverse')


%%
figure('Color','white')

T = TotalObs + TotalObs2;

bar(T(SortTicks2), 'FaceColor', [0.5 0.7 0.9])
%ylim([0,105]);
xticklabels(Ticks2)
xlabel('$B_p$ [mag]','Interpreter','latex')
ylabel('Actuall Time','Interpreter','latex')

title(sprintf('Available visits length ; Entire Observation (%s) hrs',obs_len+obs_len2),'Interpreter','latex')


%%

fprintf('WD Name\t\t\t Coordinates\t     B_p Mag  Observation Time (hours)\n');
for i = 1:length(E.RA)
    fprintf('%s\t & (%.2f°, %.2f°) & %.1f  & %.2f\n', ...
        E.Name(i,:), E.RA(i), E.Dec(i), E.G_Bp(i), T(i));
end

Tab =[E.RA, E.Dec, E.G_Bp, T]
    

%% Save table
monthyear       = date;
montyear.Format = 'MMM-uuuu';
TabName         = ['Table_Results_',FieldNames{FieldIdx(1)},'_',num2str(date.Day),'-',num2str(date2.Day),'-',char(monthyear),'_',DataPath(24:36),'.mat']
save_path = [save_to,TabName];

% Save table to a file
save(save_path,'Tab','-v7.3')
%% Save Results
