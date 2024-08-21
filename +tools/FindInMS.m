function [msu,Res] = FindInMS(List,Args)

    arguments
        List
        Args.CropID = {};
        Args.Coords  = {};

    end
    msu = [];
    Res = [];
    % Create matched sources list And look for target
    Nfiles = numel(List);

    for Ifile = 1 : Nfiles

         list =  MatchedSources.rdirMatchedSourcesSearch('Path', List{Ifile}{1});

  %%      
         
      if isempty(Args.CropID) 
        Results = tools.ScanMS(list,"Coords",Args.Coords);
        if ~isempty(Results)
            Args.CropID = Results.CropID;
            fprintf('Source Found In CropID %i (visit %s)',Args.CropID,List{Ifile}{1}(end-7:end))
        else
             fprintf('Source cannot be found Found In visit %s',List{Ifile}{1}(end-7:end))
             msu = [];
             res = [];
             return
        end

      else
        Results = tools.ScanMS(list,"Coords",Args.Coords);
        if isempty(Results)
            fprintf('\nSearchID is empty (visit %s)',List{Ifile}{1}(end-7:end))

        elseif Results.CropID == Args.CropID
            fprintf('\nSearchID and CropID agree %i; (visit %s)',Args.CropID,List{Ifile}{1}(end-7:end))
        else
            fprintf('SearchID and CropID DO NOT agree, Continue with CropID %i; (visit %s)',Args.CropID,List{Ifile}{1}(end-7:end))
        end


     end

        
%%
        % create all MS
        Blist.FileName = {};
        Blist.Folder = {};
        Blist.CropID = Args.CropID;
        Nvis = numel(List{Ifile});
        for Ivis = 1 :Nvis

            ms = MatchedSources.rdirMatchedSourcesSearch('Path', List{Ifile}{Ivis},'CropID',Args.CropID);

            Blist.FileName{end+1,1} = ms.FileName{:};
            Blist.Folder{end+1,1} = ms.Folder{:};


        end

        msu = [msu; MatchedSources.readList(Blist)];
        Res = [Res;Results];







     end

   


end