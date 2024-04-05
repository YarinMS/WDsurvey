function [WD] = get2VisLC(WD,Args)

% Arguments

arguments
    
    WD WDss
    %Args.DataPath = WD.Data.DataPath;
    Args.Results1 = {};
    
end



%% loop over all tagrets.

Results   = Args.Results1;
DataPath  = WD.Path;
VN        = Results.VN; % Visit Name
DataStamp = WD.Data.DataStamp;

Vistat = {};

Rms0 = zeros(numel(WD.RA),size(Results.Main,1));
Rms1 = zeros(numel(WD.RA),size(Results.Main,1));


for i = 1 : numel(WD.RA)

wdIdx = i;


for Icol = 1 : numel(Results.SubFrame{wdIdx})
    
    MainCol = find(Results.SFcol == Results.SubFrame{wdIdx}(1,Icol));
   
    
    for Ibatch = 1 : size(Results.Main,1)
    if ~isempty(Results.Main{Ibatch,MainCol})
    Found_Index = Results.Main{Ibatch,MainCol}.coneSearch(WD.RA(wdIdx),WD.Dec(wdIdx)).Ind;
    
    if ~isempty(Found_Index)
        
        for Ifind = 1: length(Found_Index)
        
              [maso,event,Npts,RMS0,RMS1] = getLCsysC2( Results.Main{Ibatch,MainCol},'SourceIdx',Found_Index(Ifind),'SaveTo',WD.Data.save_to,'Serial',...
                  sprintf('F \\ %i \\ WD \\ %i \\ Batch \\ %i \\ SF \\ %i \\ Vis \\ %s \\ %s',Ifind,wdIdx,Ibatch,Results.SFcol(MainCol),VN{Ibatch,MainCol},DataStamp),'WD',WD,'wdIdx',wdIdx,...
                  'SDcluster',true);
             %  [maso,event,Npts] = getLCsys( Results.Main{Ibatch,MainCol},'SourceIdx',Found_Index(Ifind),'SaveTo',save_to,'Serial',...
              %    sprintf('Found \\ %i \\ WD \\ %i \\ Batch \\ %i \\ SF \\ %i \\ Vis \\  %s \\ %s',Ifind,wdIdx,Ibatch,Results.SFcol(MainCol),VN{Ibatch,MainCol},DataStamp),'WD',E,'wdIdx',wdIdx);
              Rms0(wdIdx,Ibatch,MainCol) = RMS0;
              Rms1(wdIdx,Ibatch,MainCol) = RMS1;
              if event
                
                  save([WD.Data.save_to,'Event_In_',  sprintf('Found  %i  WD  %i  Batch  %i  SF  %i  Vis  %s  %s',Ifind,wdIdx,Ibatch,Results.SFcol(MainCol),VN{Ibatch,MainCol},DataStamp),'_.mat'],'maso','-v7.3')
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

end

%%

%Results = Results1;
Vistat = zeros(length(WD.RA),size(Results.VisMap,1));

for Iwd = 1 : length(WD.RA)
    
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
WD.Data.Results.TotalObs = TotalObs;
[~,SortTicks] = sort(WD.G_Bp);

%
figure('Color','White','units','normalized','outerposition',[0 0 1 1])
Ticks = [];
for Iwd = 1 : numel(WD.RA)
    
    tick = num2str(WD.G_Bp(SortTicks(Iwd)));
    Ticks = [Ticks ; tick(1:4)];

end

WD.Data.Results.RMS_zp  = Rms0;
WD.Data.Results.RMS_sys = Rms1;

bar(TotalObs(SortTicks), 'FaceColor', [0.5 0.7 0.9])
%ylim([0,105]);
xticklabels(Ticks)
xlabel('$B_p$ [mag]','Interpreter','latex')
ylabel('Actual Time','Interpreter','latex')

title(sprintf('Available visits length ; Entire Observation (%s) hrs',WD.Data.Results.obs_len),'Interpreter','latex')


file_name = [sprintf('One \\ night \\ Obs \\ Time \\ %s \\ ID \\ %s \\ %i \\ Vis \\ %s \\ %s',WD.Data.Results.obs_len,DataStamp),'.png'];
sfile = strcat(WD.Data.save_to,file_name);
sfile= strrep(sfile, ' ', '');


sfile = strrep(sfile, '\', '_');
         

saveas(gcf,sfile) ;

close();



end