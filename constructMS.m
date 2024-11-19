function mms = constructMS(cropID, subframeHdf5Names,subframeHdf5Folders)



    List.FileName = subframeHdf5Names;
    List.Folder   = subframeHdf5Folders;
    List.CropID   = cropID;
    MS = MatchedSources.readList(List);

    args.BadFlags = {'Saturated', 'Negative', 'NaN', 'Spike', 'Hole', 'NearEdge'};
    try 
        mms =  cleanNzp(MS,args);
    catch
        mms =[];
    end



end

