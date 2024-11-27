%% drafts
tm = table();
ML = [];
mmm = []

for i = [2:30]
[tm,mmm,ML] = tools.MSHunter2(ML,mmm,tm,4, 1, 2024, 10, i, 30,'PlotNSave',false)
end


%%
matchedSourcesArray = [];

% Loop through the cell array and concatenate the contents
for i = 2:numel(mmm)
    matchedSourcesArray = [matchedSourcesArray, mmm{i}];
end

% Check the result
disp(matchedSourcesArray)

MMS =mergeByCoo(matchedSourcesArray,matchedSourcesArray(1))


MMS.coneSearch(60.2176,34.0772)
MMS.bestMag
MMS.plotLC(635)