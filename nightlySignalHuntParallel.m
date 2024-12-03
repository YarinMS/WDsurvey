function MetaTable = nightlySignalHuntParallel(MetaTable, year, month, day, Args)

arguments
    MetaTable % Initial input table (can be empty)
    year
    month
    day
    Args.Nvisits = 2;
    Args.ID = '20Vis';
end

%% Setup
Mounts = [6,8,10,5,4,3,2,1];
[MountsGrid, ItelsGrid] = ndgrid(Mounts, 1:4);
numTasks = numel(MountsGrid);

% Prepare a cell array to store results
MetaTables = cell(numTasks, 1); % Each worker outputs one table

% Ensure function availability on workers
pool = gcp();
addAttachedFiles(pool, {'/home/yarinms/Documents/WDsurvey/nightlySignalHuntParallel.m'})%, ...
                        %'/home/yarinms/Documents/WDsurvey/SignalHunter2.m'}); % Attach dependencies

%% Parallel Loop
parfor taskIdx = 1:numTasks
    Imount = MountsGrid(taskIdx);
    Itel = ItelsGrid(taskIdx);

    % Skip unnecessary iterations
    if (Imount == 4 || Imount == 5) && Itel ~= 1
        continue
    end

    % Construct directory path
    checkDir = sprintf('~/marvin/LAST.01.%02d.%02d/%04d/%02d/%02d/proc', Imount, Itel, year, month, day);

    % Check if directory exists
    if isfolder(checkDir)
        fprintf('Processing: Mount %i, Tel %i\n', Imount, Itel);
        try
            % Each worker creates its own table
            MetaTables{taskIdx} = SignalHunter2(table(), Imount, Itel, year, month, day, Args.Nvisits, ...
                                               'PlotNSave', false, 'ID', Args.ID);
        catch ME
            % Handle errors gracefully
            warning('Error on Mount %i, Tel %i: %s', Imount, Itel, ME.message);
            MetaTables{taskIdx} = table(); % Return an empty table on error
        end
    else
        MetaTables{taskIdx} = table(); % If directory doesn't exist, return an empty table
    end
end

%% Combine All Tables
% Concatenate all individual tables into the final MetaTable
MetaTable = vertcat(MetaTables{:});

%% Save Results
save(sprintf('/media/yarinms/Data2/Projects/MarvinRuns/%s/Results_Table_LAST.%04d.%02d.%02d_%s.mat', ...
    Args.ID, year, month, day, Args.ID), 'MetaTable', '-v7.3');
end
