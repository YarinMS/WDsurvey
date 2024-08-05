
function [newM,newS] = SigmaClips(Data,Args)

arguments
    Data
    Args.SigmaThreshold = 3; %default
    Args.MaxIter   = 5;
    Args.plot      = true;
    Args.MeanClip  = false;
    
end

% Sigma cliping
if Args.MeanClip % Clip by mean

   for Iiter = 1 : Args.MaxIter
    

        
        Mean  = mean(Data,'omitnan');
        SD    = std(Data,'omitnan');
        
        % Flag outliers
        Outliers = abs(Data - Mean) > Args.SigmaThreshold*SD;
        
        % Remove
        
        Data = Data(~Outliers);
        
        % Break if no out liers :
        
        if sum(Outliers) == 0 
            break;
            
        end
        
        
       
   end
    
    

   newM = mean(Data,'omitnan') ;
   newS = std(Data,'omitnan') ;
   
   
else
    
    
    for Iiter = 1 : Args.MaxIter
    

        
        Mean  = median(Data,'omitnan');
        SD    = std(Data,'omitnan');
        
        % Flag outliers
        Outliers = abs(Data - Mean) > Args.SigmaThreshold*SD;
        
        % Remove
        
        Data = Data(~Outliers);
        
        % Break if no out liers :
        
        if sum(Outliers) == 0 
            break;
            
        end
        
        
       
   end
    
   newM = median(Data,'omitnan') ;
   newS = std(Data,'omitnan') ;   
    
end


end

