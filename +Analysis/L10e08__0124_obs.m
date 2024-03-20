%%

addpath('/home/ocs/Documents/WDsurvey/')


%% All Field analysis :



%% List Fields In Path

DataPath = '/last10e/data1/archive/LAST.01.10.01/2024/01/08/proc';

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
    
    
   
    
%% Read from Cats by FieldID

% FOV center by subframe

Subframe = '015';




% FieldIdx = 1;

FieldIdx = find(contains(FieldNames,'J0438+635'))

Results  = ReadFromCat(DataPath,'Field',FieldNames{FieldIdx(1)},'SubFrame',Subframe,'getAirmass',true);


% Store Results for :

% Subframe Airmass Vs time


% Sub frame Lim Mag Vs time

date = datetime(Results.JD(1),'convertfrom','jd')

save_to   = '/home/ocs/Documents/WD_survey/Thesis/'
file_name = ['Field_Results_',FieldNames{FieldIdx(1)},'_',char(date),'.mat']

save([save_to,file_name],'Results','-v7.3') ;



%% targets in field
Names = ['WDJ045023.67+601612.40',
'WDJ044607.08+611322.63',
'WDJ045125.26+615149.63',
'WDJ044408.42+625936.20',
'WDJ044325.90+601417.15',
'WDJ045202.79+620744.93'
  ]

TargetList = [
72.59845652446606	60.26985627455262	18.44043	18.437971	18.455566
71.52972847150532	61.2229879953418	18.704784	18.774593	18.72257
72.85528729893993	61.86365362072636	19.164312	19.234558	19.180351
71.03504266955606	62.99340825334809	18.448313	18.42186	18.583466
70.85799740655987	60.23803014824192	18.981178	19.009478	19.026443
73.01171544591399	62.128987027025175	19.033812	19.107725	19.06821
];



Pathway = [DataPath,'/',Visits(FieldIdx(2)).name]



E = WDs(Pathway,Names,TargetList(:,1)	,TargetList(:,2)	,TargetList(:,3)    ,TargetList(:,4)	,TargetList(:,5),'Batch',[],'getForcedData',false,'plotTargets',true,'FieldId',FieldNames{FieldIdx(1)})



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

title(sprintf('Proportion of Detection Relative to the entire Observation (%s) hrs',obs_len),'Interpreter','latex')




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
                  sprintf('Found_%i_WD_%i_Bno_%i_SF_%i_V_%s',Ifind,wdIdx,Ibatch,Results.SFcol(MainCol),VN{Ibatch,MainCol}),'WD',E,'wdIdx',wdIdx);
        
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

DataPath2 = '/last04e/data1/archive/LAST.01.04.01/2024/03/11/proc';

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
    
    
   
    
%% Read from Cats by FieldID

% FOV center by subframe

Subframe = '015';




% FieldIdx = 1;

FieldIdx2 = find(contains(FieldNames2,'WIREDJ130558'))

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



wdIdx2 = 7;

for i = 1 : numel(E.RA)

wdIdx2 = i;


for Icol = 1 : numel(Results2.SubFrame{wdIdx2})
    
    MainCol2 = find(Results2.SFcol == Results2.SubFrame{wdIdx2}(1,Icol));
   
    
    for Ibatch = 1 : size(Results2.Main,1)
    
    Found_Index2 = Results2.Main{Ibatch,MainCol2}.coneSearch(E.RA(wdIdx2),E.Dec(wdIdx2)).Ind;
    
    if ~isempty(Found_Index2)
        
        for Ifind = 1: length(Found_Index2)
        
              [maso,event,Npts] = getLCsys( Results2.Main{Ibatch,MainCol2},'SourceIdx',Found_Index2(Ifind),'SaveTo',save_to,'Serial',...
                  sprintf('Found_%i_WD_%i_Bno_%i_SF_%i_V_%s',Ifind,wdIdx2,Ibatch,Results2.SFcol(MainCol2),VN2{Ibatch,MainCol2}),'WD',E,'wdIdx',wdIdx2);
        
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

Tab = table(E.Name, E.RA, E.Dec, E.G_Bp, T, ...
    'VariableNames', {'WD_Name', 'RA', 'Dec', 'B_p_Magnitude', 'Observation_Time'});


%% Save table
monthyear       = date;
montyear.Format = 'MMM-uuuu';
TabName         = ['Table_Results_',FieldNames{FieldIdx(1)},'_',num2str(date.Day),'-',num2str(date2.Day),'-',char(monthyear),'.csv']
save_path = [save_to,TabName];

% Save table to a file
save(save_path,'TabName','-v7.3')

%% Save Results

save([save_to,file_name],'Results','-v7.3') ;

save([save_to,file_name2],'Results2','-v7.3') ;