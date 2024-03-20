%%

addpath('/home/ocs/Documents/WDsurvey/')


%% All Field analysis :



%% List Fields In Path

DataPath = '/last10e/data1/archive/LAST.01.10.01/2023/09/15/proc';

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

FieldIdx = find(contains(FieldNames,'field1144'))

Results  = ReadFromCat(DataPath,'Field',FieldNames{FieldIdx(1)},'SubFrame',Subframe,'getAirmass',true);


% Store Results for :

% Subframe Airmass Vs time


% Sub frame Lim Mag Vs time

date = datetime(Results.JD(1),'convertfrom','jd')

save_to   = '/home/ocs/Documents/WD_survey/Thesis/'
file_name = ['Field_Results_',FieldNames{1},'_',char(date),'.mat']

save([save_to,file_name],'Results','-v7.3') ;



%% targets in field
Names = ['WDJ012717.62+310214.22',
'WDJ012648.49+290214.04',
'WDJ012649.38+284130.34',
'WDJ012615.80+302748.34',
'WDJ012529.35+304518.35',
'WDJ012459.08+310216.02',
'WDJ013209.96+302257.60',
'WDJ012534.66+285145.57',
'WDJ013217.82+293753.07',
'WDJ012758.38+305348.01',
'WDJ012654.96+311523.40',
'WDJ013222.94+290913.23'
  ]

TargetList = [
21.82369578660985	31.03718360701838	17.348127	17.304295	17.455854
21.702476995244243	29.037191156527562	19.092482	19.229544	18.852041
21.706281948904117	28.69157231303221	18.906353	19.058205	18.702333
21.566380191047934	30.4635459492792	16.523085	16.45724	16.690811
21.372473080989277	30.75488754191175	18.384247	18.399372	18.384048
21.24641571905274	31.037683598766538	19.000166	19.087465	18.950876
23.041743078742307	30.382623610831768	17.877016	17.824406	18.05135
21.394602246088887	28.862690825457136	18.948942	18.977503	18.998983
23.07441843269316	29.631376894865635	18.905878	18.98281	18.79909
21.993098927428445	30.896526080658646	18.582531	18.590137	18.662083
21.72912239494797	31.25643931032193	18.939234	18.834433	19.08452
23.095713051243653	29.153649421768133	17.55129	17.411814	17.711397
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

wdIdx = 11;




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



%%
    %   Upload all files to a MatchedSources object
Et = MatchedSources.readList(List);
ET = mergeByCoo( Et, Et(1));


%%
tgt_ind  = ET.coneSearch(E.RA(1),E.Dec(1)) ; 



e = WDs(Pathway,Names,TargetList(:,1)	,TargetList(:,2)	,TargetList(:,3)    ,TargetList(:,4)	,TargetList(:,5),'Batch',[],'getForcedData',false,'plotTargets',false,...
    'FieldId',FieldNames{1})


%% plot a source to check it

Idx = 1;
SourceIdx = ET.coneSearch(E.RA(Idx),E.Dec(Idx)).Ind

t = ET.JD;
y_noZP = ET.Data.MAG_PSF(:,SourceIdx);

figure('Color','white');
plot(t,y_noZP,'o')
hold on
 R = lcUtil.zp_meddiff(ET,'MagField','MAG_PSF','MagErrField','MAGERR_PSF')
[ET,ApplyToMagFieldr] = applyZP(ET, R.FitZP,'ApplyToMagField','MAG_PSF');

t = ET.JD;
y_ZPpsf = ET.Data.MAG_PSF(:,SourceIdx);
plot(t,y_ZPpsf,'x')
hold off

%% RMS plot

figure('Color','white')

RMSpsf  = ET.plotRMS('FieldX','MAG_PSF','PlotColor','red')
Xdata = RMSpsf.XData;
Ydata = RMSpsf.YData;

hold on
RMSraw  = ET.plotRMS('FieldX','MAG_PSF','PlotColor','black')
hold off
% with sysrem:
%%

BitMask =  BitDictionary ; 

Bits    =  BitMask.Class(ET.Data.FLAGS);

BadBits =  {'Saturated','NaN','Negative','CR_DeltaHT','NearEdge'};

Remove  = zeros(size(Bits));

for b = BadBits
    
    BitIdx = find(contains(BitMask.Dic.BitName,b))
    
    Remove =  Remove | bitget(Bits,BitIdx);

end

% Remove Bad points
MS = ET.copy();

MS.Data.MAG_PSF(Remove)       = NaN ;
MS.Data.MAGERR_PSF(Remove)    = NaN ;
MS.Data.MAG_APER_2(Remove)    = NaN ;
MS.Data.MAGERR_APER_2(Remove) = NaN ;

% Take only points with more than 50 % measurements

NaNcut = sum(isnan(MS.Data.MAG_PSF))/length(MS.JD) > 0.5;

% Make sure your WD isnt mask 

if NaNcut(SourceIdx)
    
    NaNcut(SourceIdx) = 0;
    
end
    

% Copy Just to prevent confusion

ms = MS.copy();

clear MS

% Survivng source list
Nsrc = [1:ms.Nsrc] ;
ms.addMatrix(Nsrc(~NaNcut),'SrcIdx') ;
ms.addMatrix(sum(~NaNcut),'Nsources') ;

% Cut off Bad sources
ms.Data.MAG_PSF       = ms.Data.MAG_PSF(:,~NaNcut) ;
ms.Data.MAGERR_PSF    = ms.Data.MAGERR_PSF(:,~NaNcut) ;
ms.Data.MAG_APER_2    = ms.Data.MAG_APER_2(:,~NaNcut) ;
ms.Data.MAGERR_APER_2 = ms.Data.MAGERR_APER_2(:,~NaNcut) ;
ms.Data.FLAGS         = ms.Data.FLAGS(:,~NaNcut) ;
NewIdx = find(ms.Data.SrcIdx == SourceIdx);

% For model

model = ms.copy();

figure('Color','white');


ms.plotRMS('FieldX','MAG_PSF','plotColor','red','PlotSymbol',['x'])

hold on

% semilogy(Xdata(~NaNcut),Ydata(~NaNcut),'b.')

ms.sysrem('MagFields' ,{'MAG_PSF'} , 'MagErrFields',{'MAGERR_PSF'},'sysremArgs',{'Niter',2});

RMSsys = ms.plotRMS('FieldX','MAG_PSF','plotColor','cyan','PlotSymbol',['.'])
xdata  = RMSsys.XData;
ydata  = RMSsys.YData;


% Mark your WD
semilogy(Xdata(SourceIdx),Ydata(SourceIdx),'p','MarkerSize',10,'MarkerFaceColor','cyan','MarkerFaceColor','black')
semilogy(xdata(NewIdx),ydata(NewIdx),'p','MarkerSize',10,'MarkerFaceColor','cyan','MarkerFaceColor','black')




Leg = legend('ZP','SysRem',['rms zp = ',num2str(Ydata(SourceIdx))],['rms zp = ',num2str(ydata(NewIdx))])
title('RMS MAG PSF')






%% plot a source to check it



figure('Color','white');

t = ms.JD;
[~,s] = sort(t);
t = t(s);
t = datetime(t,'convertfrom','jd');
plot(t,y_ZPpsf(s),'x')

hold on

t = ms.JD;
[~,s] = sort(t);
t = t(s);
t = datetime(t,'convertfrom','jd');

y_sys = ms.Data.MAG_PSF(s,NewIdx);
plot(t,y_sys,'o')
hold on
plot(t,Results.LimMag,'k--')
set(gca,'Ydir','reverse')


hold off
legend('ZP','SysRem','Lim Mag')
title('MAG PSF LC','Interpreter','latex')


%% Model 
% get ext color
model.addExtMagColor


%%
Color = model.SrcData.ExtColor(~NaNcut);
Mag   = model.SrcData.ExtMag(~NaNcut);

Color(isnan(Color)) = 0;

if Color(NewIdx) == 0
    
    Color(NewIdx) = e.Color(Idx);
    
end

if isnan(Mag(NewIdx) )
    
    Mag(NewIdx) = e.G_Bp(Idx);
    
end

