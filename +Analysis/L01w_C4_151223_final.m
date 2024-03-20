%%

addpath('/home/ocs/Documents/WDsurvey/')


%% All Field analysis :



%% List Fields In Path

DataPath = '/last01w/data2/archive/LAST.01.01.04/2023/12/14/proc';

cd(DataPath)

Visits = dir;

FieldNames = [] ;

for Ivis = 3 : numel(Visits)
    
    cd(Visits(Ivis).name)
    
    Cats = dir;
    
    VisitCenter = '010_001_015_sci_proc_Cat_1.fits';
    
    IDX = find(contains({Cats.name},VisitCenter));
    
    H   = AstroHeader(Cats(IDX).name,3);
    
    FieldNames = [FieldNames ; {H.Key.FIELDID}]
    
    
    cd ..
        
    
end
    
    
   
    
%% Read from Cats by FieldID

% FOV center by subframe

Subframe = '015';
FieldIdx = 1;
Results  = ReadFromCat(DataPath,'Field',FieldNames{length(FieldIdx)},'SubFrame',Subframe,'getAirmass',true);


% Store Results for :

% Subframe Airmass Vs time


% Sub frame Lim Mag Vs time

date = datetime(Results.JD(1),'convertfrom','jd')

save_to   = '/home/ocs/Documents/WD_survey/Thesis/'
file_name = ['Field_Results_',FieldNames{1},'_',char(date),'.mat']

save([save_to,file_name],'Results','-v7.3') ;



%% targets in field
Names = ['WDJ035351.72+623032.68',
'WDJ035115.83+615244.91',
'WDJ035343.30+613617.69',
'WDJ035807.61+610146.84',
'WDJ035937.17+630440.88',
'WDJ035243.80+613312.87'
  ]

TargetList = [
58.46422900381937	62.5089936141672	18.225742	18.336258	18.020775
57.81691460463136	61.87868551986923	17.714863	17.724045	17.718267
58.42941457743876	61.605021109785056	19.103441	19.278852	18.793915
59.531971368694485	61.0294975821714	18.78826	18.750568	18.938765
59.904766037423286	63.078010801721796	19.19191	19.26389	19.266926
58.18278606079824	61.55359591356678	19.055426	19.022543	19.196217

];



Pathway = [DataPath,'/000401v0']



E = WDs(Pathway,Names,TargetList(:,1)	,TargetList(:,2)	,TargetList(:,3)    ,TargetList(:,4)	,TargetList(:,5),'Batch',[],'getForcedData',false,'plotTargets',true,...
    'FieldId',FieldNames{FieldIdx})



%% Look for targets in ALL Visits:


cd(DataPath)

Visits = dir;

List = MatchedSources.rdirMatchedSourcesSearch('CropID',15);      
                           % Consider only visits with the same Field ID
visits = find(contains(List.FileName,FieldNames{FieldIdx}));
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



%%
%
Main ={};
Nvis = numel(List.Folder);





even = rem(Nvis,2) == 0;

if even  
    
    counter = 1;
    for Ibatch = 1 : Nvis/2 -1
    
          % Batches of two 
            list.FileName = List.FileName(counter:counter+1);
            list.Folder   = List.Folder(counter:counter+1);
          
            cd(list.Folder{1})
            files  = dir(fullfile(pwd,'*001_001_001_sci_proc_Cat_1.fits'));
            files  = {files.name};
            AH = AstroHeader(files{1},3);
            MinJD = AH.Key.JD - 0.0001 ; % miin 10 sec
            cd ..
            cd(list.Folder{end})
            files  = dir(fullfile(pwd,'*020_001_001_sci_proc_Cat_1.fits'));
            files  = {files.name};
            AH = AstroHeader(files{1},3);
            MaxJD = AH.Key.JD + 0.0001 ; % miin 10 sec
            cd ..
            

          
          
          % Given the 2 visits : 
          
          for Isf = 1 : numel(Sub_Frames)
              
              
          
                 L = MatchedSources.rdirMatchedSourcesSearch('CropID',Sub_Frames(Isf),'MinJD',MinJD,'MaxJD',MaxJD);            
               % Upload all files to a MatchedSources object
                 matched_source = MatchedSources.readList(L); 
               % Merge all MatchedSources elkement into a single element object
                 MSU = mergeByCoo( matched_source, matched_source(1));
                 Main{Ibatch,Isf} = MSU.copy();
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
            
            cd(list.Folder{1})
            files  = dir(fullfile(pwd,'*001_001_001_sci_proc_Cat_1.fits'));
            files  = {files.name};
            AH = AstroHeader(files{1},3);
            MinJD = AH.Key.JD - 0.0001 ; % miin 10 sec
            cd ..
            cd(list.Folder{end})
            files  = dir(fullfile(pwd,'*020_001_001_sci_proc_Cat_1.fits'));
            files  = {files.name};
            AH = AstroHeader(files{1},3);
            MaxJD = AH.Key.JD + 0.0001 ; % miin 10 sec
            cd ..
            
            
           
          
          % Given the 2 visits : solve for what ever you want !
          
            for Isf = 1 : numel(Sub_Frames)
             
          
                 L = MatchedSources.rdirMatchedSourcesSearch('CropID',Sub_Frames(Isf),'MinJD',MinJD,'MaxJD',MaxJD);            
               % Upload all files to a MatchedSources object
                 matched_source = MatchedSources.readList(L); 
               % Merge all MatchedSources elkement into a single element object
                 MSU = mergeByCoo( matched_source, matched_source(1));
                 Main{Ibatch,Isf} = MSU.copy();
            
            
            end
            counter = counter+3
            
            
            
        else
            
    
            % Batches of two 
   
            list.FileName = List.FileName(counter:counter+1);
            list.Folder   = List.Folder(counter:counter+1);
            
            cd(list.Folder{1})
            files  = dir(fullfile(pwd,'*001_001_001_sci_proc_Cat_1.fits'));
            files  = {files.name};
            AH = AstroHeader(files{1},3);
            MinJD = AH.Key.JD - 0.0001 ; % miin 10 sec
            cd ..
            cd(list.Folder{end})
            files  = dir(fullfile(pwd,'*020_001_001_sci_proc_Cat_1.fits'));
            files  = {files.name};
            AH = AstroHeader(files{1},3);
            MaxJD = AH.Key.JD + 0.0001 ; % miin 10 sec
            cd ..
          
          % Given the 2 visits : solve for what ever you want !
          
            for Isf = 1 : numel(Sub_Frames)

          
                 L = MatchedSources.rdirMatchedSourcesSearch('CropID',Sub_Frames(Isf),'MinJD',MinJD,'MaxJD',MaxJD);            
               % Upload all files to a MatchedSources object
                 matched_source = MatchedSources.readList(L); 
               % Merge all MatchedSources elkement into a single element object
                 MSU = mergeByCoo( matched_source, matched_source(1));
                 Main{Ibatch,Isf} = MSU.copy();
            end
            counter = counter+2
        end
    
   end
end


% Store in Results (for now)

Results.Main = Main;
Results.SFcol = Sub_Frames;


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

wdIdx = 6;




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







