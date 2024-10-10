%% Initilize the lastFP Class.
lFP = lastFP('last08e')
%%
lFP.processObservations(2024, 10, 8);



%% Drafts
visitTimes = arrayfun(@(x) sscanf(x.name, '%*[^_]_%08d.%06d'), visitDirs, 'UniformOutput', false);
visitTimes = cell2mat(visitTimes)