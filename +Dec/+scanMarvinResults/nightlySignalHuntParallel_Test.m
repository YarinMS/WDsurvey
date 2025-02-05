%%
% Define the base path where the telescope directories are located
baseDir = '~/marvin'; 

% List all telescope directories
telescopes = dir(fullfile(baseDir, 'LAST.*')); 
telescopes = telescopes([telescopes.isdir]); % Filter directories only



% Outer loop over days
year = 2025;
month = [1];
startDay = 1;
endDay = 31;
Nvis = 3;
ID = '3Vis';
for m = 1
for day = startDay:endDay

   

    yearStr = sprintf('%04d', year);
            monthStr = sprintf('%02d', m);
            dayStr = sprintf('%02d', day);

            % Flag to check if data exists for this day
            dataExists = false;
            
            % Loop over all telescopes
            for t = 1:length(telescopes)
                telescopeDir = fullfile(baseDir, telescopes(t).name);
                
                % Build the full path for the year, month, and day
                dayDir = fullfile(telescopeDir, yearStr, monthStr, dayStr);
                
                % Check if this day directory exists
                if isfolder(dayDir)
                    dataExists = true; % Mark data as found
                    break; % No need to check other telescopes
                end
            end

if ~dataExists
    fprintf('\nNo Data for %04d-%02d-%02d\n',year,month,day)
    continue;
end
FNcheck = sprintf('/media/yarinms/Data2/Projects/NightlyRun1/%s/Results_Table_p_%04d_%02d_%02d_%s.mat',...
    ID, year, m, day,ID)
check = dir(FNcheck)

if ~isempty(check)
    fprintf('\nSkipping %04d-%02d-%02d . File already exist. \n',year,m,day)
    continue;
end


    try
        fprintf('Processing day: %02d-%02d-%04d\n', day, m, year);

        % Run the nightly processing function
        MetaTable = nightlySignalHuntParallel2(table(), year, m, day,'Nvisits',Nvis,'ID',ID);
        % Get the current parallel pool
        pool = gcp('nocreate'); % Returns the current pool if it exists, otherwise returns []
        
        % Delete the pool if it exists
        if ~isempty(pool)
            delete(pool);
        end

       
        %% Save Results
        if ~isempty(MetaTable)
            save(        sprintf('/media/yarinms/Data2/Projects/NightlyRun2/%s/Results_Table_p_%04d_%02d_%02d_%s.mat',...
                ID, year, m, day,ID), 'MetaTable', '-v7.3');
            MetaTables = {};
            MetaTable ={};
        end
  
        
    catch ME
        % Log any errors for this day and continue
        sprintf('Error on %02d-%02d-%04d: %s\n', day, month, year, ME.message);
        % logFile = sprintf('Marvin_run_error_log_%04d_%02d_%02d.txt', year, month, day);
        % fid = fopen(logFile, 'a');
        % fprintf(fid, 'Error: %s\n', ME.message);
        % fclose(fid);
    end

    % Clear variables to free memory
    clear MetaTable;
end
end