for Iobj = 9 : e.Nsrc
    
    if e.Data.Catalog.InCat(Iobj) 
        

for Ibatch = 1 : length(e.Data.Catalog.ms(Iobj,:))
    
    if ~isempty(e.Data.Catalog.ms{Iobj,Ibatch})
    
    
    wdInd = e.Data.Catalog.ms{Iobj,Ibatch}.coneSearch(obj.RA(Iobj),obj.Dec(Iobj)).Ind
    
    if ~isempty(wdInd)
         if numel(wdInd) == 1 
             e.plotCatBatch(e,'Iobj',Iobj,'Ibatch',Ibatch,'filename',...
                  ['/last10w/data1/archive/LAST.01.10.03/2024/01/08/proc/Exp/WD_',num2str(Iobj),...
                  'Batch_',num2str(Ibatch),'_Cat_Data.png'])
        
         else
            wdInd = wdInd(1)
            
             e.plotCatBatch(e,'Iobj',Iobj,'Ibatch',Ibatch,'filename',...
                  ['/last10w/data1/archive/LAST.01.10.03/2024/01/08/proc/Exp/WD_',num2str(Iobj),...
                  'Batch_',num2str(Ibatch),'_Cat_Data.png'])
         end
         
    else
        
        printf('Couldnt find WD %i in Batch # %i',Iobj,Ibatch)
        
    end
    end
        
end

    end
    end
%% forced
for Iobj = 11 : e.Nsrc
    
     

       for Ibatch = 1 : length(e.Data.ForcedBatch.MS{Iobj,1})
    
    
    
    

             e.plotForcedBatch(e,'Iobj',Iobj,'Ibatch',Ibatch,'filename',...
                  ['/last10w/data1/archive/LAST.01.10.03/2024/01/08/proc/Exp/zWD_',num2str(Iobj),...
                  'Batch_',num2str(Ibatch),'_Forced_Data.png'])

        
      end


end

 
%% Print forced corrected:
E = e;
for Iobj = 1 : 9
    
    
    Nbatch = length(E.Data.ForcedBatch.MS{Iobj,1});
    
    for Ibatch = 1 : Nbatch
        
        

    E = E.getRMSvis(E,'Iobj',Iobj,'BatchNum',Ibatch,'LimMag',LimMag_vec,'Limtimes',times_vec,'filename',...
        ['~/Documents/WD/080124/T3/aWD_',num2str(Iobj),...
        'Batch_',num2str(Ibatch),'_Forced_Final.png'])
    
    end
    
    
    
end
