function [WD,Results1] = BatchSort(WD,Args)

arguments
    
    WD WDss
    Args.None = {};
    
end


%% 2 Visits

DataPath = WD.Path;
cd(DataPath)

Results = WD.Data.Results;
List  = WD.Data.List ;
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
                 
                 
                 
               
                     
                 
                 cd(list.Folder{1})
                 if exist(list.FileName{1},'file') > 0
                     cd ..
                     cd(list.Folder{2})
                     if exist(list.FileName{2},'file') > 0
                         cd ..  
                           %L = MatchedSources.rdirMatchedSourcesSearch('CropID',Sub_Frames(Isf),'MinJD',MinJD,'MaxJD',MaxJD);            
               % Upload all files to a MatchedSources object
                            matched_source = MatchedSources.readList(list); 
                            % Merge all MatchedSources elkement into a single element object
                            MSU = mergeByCoo( matched_source, matched_source(1));
                           Main{Ibatch,Isf} = MSU.copy();
                           VN{Ibatch,Isf}   = list.Folder{1}(end-7:end);
                     else
                         cd ..
                         fprintf('\NCouldnt find MergedMatfile for Sub frame %i Visit %s :',Isf,list.Folder{2}(end-7:end))
                     end
                 else
                     cd ..
                     fprintf('\NCouldnt find MergedMatfile for Sub frame %i Visit %s :',Isf,list.Folder{1}(end-7:end))
                 end
              
          
               
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
             
           cd(list.Folder{1})
                 if exist(list.FileName{1},'file') > 0
                     cd ..
                     cd(list.Folder{2})
                     if exist(list.FileName{2},'file') > 0
                         cd ..  
                           %L = MatchedSources.rdirMatchedSourcesSearch('CropID',Sub_Frames(Isf),'MinJD',MinJD,'MaxJD',MaxJD);            
               % Upload all files to a MatchedSources object
                            matched_source = MatchedSources.readList(list); 
                            % Merge all MatchedSources elkement into a single element object
                            MSU = mergeByCoo( matched_source, matched_source(1));
                           Main{Ibatch,Isf} = MSU.copy();
                           VN{Ibatch,Isf}   = list.Folder{1}(end-7:end);
                     else
                         cd ..
                         fprintf('\NCouldnt find MergedMatfile for Sub frame %i Visit %s :',Isf,list.Folder{2}(end-7:end))
                     end
                 else
                     cd ..
                     fprintf('\NCouldnt find MergedMatfile for Sub frame %i Visit %s :',Isf,list.Folder{1}(end-7:end))
                 end
                
            
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

          
                cd(list.Folder{1})
                 if exist(list.FileName{1},'file') > 0
                     cd ..
                     cd(list.Folder{2})
                     if exist(list.FileName{2},'file') > 0
                         cd ..  
                           %L = MatchedSources.rdirMatchedSourcesSearch('CropID',Sub_Frames(Isf),'MinJD',MinJD,'MaxJD',MaxJD);            
               % Upload all files to a MatchedSources object
                            matched_source = MatchedSources.readList(list); 
                            % Merge all MatchedSources elkement into a single element object
                            MSU = mergeByCoo( matched_source, matched_source(1));
                           Main{Ibatch,Isf} = MSU.copy();
                           VN{Ibatch,Isf}   = list.Folder{1}(end-7:end);
                     else
                         cd ..
                         fprintf('\NCouldnt find MergedMatfile for Sub frame %i Visit %s :',Isf,list.Folder{2}(end-7:end))
                     end
                 else
                     cd ..
                     fprintf('\NCouldnt find MergedMatfile for Sub frame %i Visit %s :',Isf,list.Folder{1}(end-7:end))
                 end
              
            end
            counter = counter+2
        end
    
   end
end


% Store in Results (for now)

Results.Main   = Main;
Results.SFcol  = Sub_Frames;
Results.VisMap = {};
Results.VN     =  VN;

Results1 = Results;

end