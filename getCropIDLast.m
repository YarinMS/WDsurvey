function [RES] = getCropIDLast(Mount,Camera,year,month,day,targetFieldID)

if mod(Camera,2)
    dataDir = 'data1';
else
    dataDir = 'data2';
end

if Camera <=2
    computer = sprintf('last%02de',Mount);
else
    computer = sprintf('last%02dw',Mount);
end



% pathForTgt = sprintf('/%s/%s/archive/LAST.01.%02d.%02d/%04d/%02d/%02d/proc/*v0/*.hdf5',computer,dataDir,Mount,Camera,year,month,day)

pathForTgt  = sprintf('~/marvin/LAST.01.%02d.%02d/%04d/%02d/%02d/proc/*v0/*.hdf5',Mount,Camera,year,month,day)





allMerged = dir(pathForTgt);

allFN = {allMerged.name}';

% fieldPat   = regexp(allFN,'clear_(.*?)_000','tokens'); For all fieldIDs

% filedsIDs  = cellfun(@(x) x{1}, fieldPat(~cellfun('isempty',fieldPat)))

matches = ~cellfun('isempty',regexp(allFN,['clear_' targetFieldID '_000']));



mergedField = allMerged(matches);


%%

%%
allMS = {};
MScoords = {};
cropIDs ={};
h = waitbar(0);
for Ivis = 1 : numel(mergedField)
    MS = MatchedSources.read(fullfile(mergedField(Ivis).folder,mergedField(Ivis).name));

    
    allMS{end+1,1} = {MS};
    meanRA = mean(mean(MS.Data.RA,'omitnan'));
    meanDec = mean(mean(MS.Data.Dec,'omitnan'));
    MScoords{end+1,1} = {[meanRA meanDec]};
    s = regexp(MS.FileName, '.*_(?<cropID>.+?)_sci_merged', 'names');

    % Retrieve the cropID from the structure
    cropID  = str2num(s.cropID);

    cropIDs{end+1,1} = cropID; 
end

RES.MSall = allMS;
RES.MScoords = MScoords;
RES.IDs = cropIDs;
end
