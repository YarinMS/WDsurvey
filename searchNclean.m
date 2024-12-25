function [mms,nanIdx] = searchNclean(ms,wdTable,args)

% Look for source in batch:
Src = ms.coneSearch(wdTable.RA,wdTable.Dec,6);
IndValues = {Src.Ind};

% Check for non-empty 'Ind' values
firstNonEmptyInd = find(cellfun(@(x) ~isempty(x), IndValues), 1);

% Analyze the result
if ~isempty(firstNonEmptyInd)
    args.mergeBy = firstNonEmptyInd;
    args.RA = wdTable.RA ; args.Dec = wdTable.Dec;
else
   
    %disp('Ind is empty for all elements.');
    mms =[];
    nanIdx =[];
    return
end
                    
[mms,nanIdx] =  cleanMatchedSources3(ms, args);




end