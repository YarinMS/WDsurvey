function [formattedName] = automateRemoteProcessingMarv(Data)
    % Inputs:
    % r - structure containing eventInfo and remotePath
    
    % Extract information from the struct
    ipAddress = Data.ipAddress;
    ra = Data.ra;
    dec = Data.dec;
    cropID = Data.cropID;
    remotePath = Data.remotePath;
    computerID = Data.telescope;
    dateStr = sprintf('%04d-%02d-%02d',Data.year,Data.month,Data.day);  % Date from eventInfo
    
    % Adjust path to point to processed files by adding "_re"
    basePath = fileparts(remotePath);  % One level up from 'raw'
    part = strsplit(basePath, '/');
    
    % Create the default rePath
    rePath = fullfile(['/' part{2}], part{3}, part{4}, strcat(part{5}, '_re'), part{6}, part{7}, part{8}, 'proc/');

    % Convert date (year, month, day) to datetime
    eventDate = datetime(Data.year, Data.month, Data.day);
    
    % SSH command to check if rePath exists
    checkPathCommand = sprintf('sshpass -p "physics" ssh ocs@%s "test -d %s"', ipAddress, rePath);
    status = system(checkPathCommand);
    
    % If rePath doesn't exist, decrement the day and create a new rePath
    if status ~= 0
        fprintf('Path does not exist, trying one day earlier...\n');
        % Decrement the day by 1
        newDate = eventDate - days(1);
        
        % Create a new rePath with the updated day
        rePath = fullfile(['/' part{2}], part{3}, part{4}, strcat(part{5}, '_re'), part{6}, part{7}, sprintf('%02d', day(newDate)), 'proc/');
        
        % Recheck if the new rePath exists
        checkPathCommand = sprintf('/usr/local/bin/sshpass -p "physics" ssh ocs@%s "test -d %s"', ipAddress, rePath);
        status = system(checkPathCommand);
        
        if status ~= 0
            error('Processed directory does not exist even for the previous day.');
        else
            fprintf('Found processed directory for the previous day: %s\n', rePath);
        end
    else
        fprintf('Found processed directory: %s\n', rePath);
        
        
    end

    part = strsplit(rePath, 'proc/');
    removePath = part{1};  % One level up from 'proc'

     % Ensure ~/Documents/Temp/ exists on the remote machine
    saveDir = '~/Documents/WD_survey/TempMarvinRun';
    createDirCommand = sprintf('sshpass -p "physics" ssh ocs@%s "mkdir -p %s"', ipAddress, saveDir);
    system(createDirCommand);  % Create Temp directory if it doesn't exist
    
    % Define the save filename format
    formattedName = sprintf('%.6f_%.6f_%s_%s_%d_%s_Row%i', ra, dec, computerID, dateStr, cropID, Data.fieldID{:},Data.tabID);
    matFilePath = fullfile(saveDir, [formattedName, '.mat']);
    pngFilePath = fullfile(saveDir, [formattedName, '.png']);


    marvinFP.generateForcedPhotometryScriptMarv(rePath, cropID, ra, dec, matFilePath, removePath);
        
    
    % Push the script to the remote machine
    marvinFP.ensureRemoteForcedPhotometryScriptExistsMarv(ipAddress);

    % Build the MATLAB command to run the forced photometry script remotely
    %isWD([],ra,dec)
    matlabCommand = sprintf('ForcedPhotometryRemote(%d, %f, %f); exit;', cropID, ra, dec);
    
    % SSH command to execute the MATLAB script remotely
    remoteMatlabCommand = sprintf('sshpass -p "physics" ssh ocs@%s "matlab -nodesktop -nodisplay -r ''%s''"', ...
        ipAddress, matlabCommand);
    
    % Execute the remote MATLAB command via SSH
status = system(remoteMatlabCommand);
    
    % Check for execution success
    if status == 0
        fprintf('Forced photometry executed successfully on remote machine %s.\n', ipAddress);
        % Command to synchronize results from the remote machine to your local machine
    
    else
        fprintf('Failed to execute forced photometry on remote machine %s.\n', ipAddress);
    end


    localResultsDir = '~/Projects/MarvinRunRes/';
    remoteResultsDir = '/home/ocs/Documents/WD_survey/TempMarvinRun/';
    bringHomeCommand = sprintf('sshpass -p "physics" rsync -avzr ocs@%s:%s %s', ipAddress, remoteResultsDir, localResultsDir);
    
    % Execute the rsync command
    rsyncStatus = system(bringHomeCommand);
    % YOU SHOULD DELETE ALL
    % cleanLastComputer = sprintf('sshpass -p "physics" cd &s && rm -f *.mat',remoteResultsDir )
    % cleanStatus = system(cleanLastComputer);
    % Check for rsync success
    if rsyncStatus == 0
        fprintf('Results successfully synced from %s to %s.\n', ipAddress, localResultsDir);
    else
        error('Failed to sync results from the remote machine.');
    end
end




function ipAddress = calculateIpAddress(eventInfo)
    % Extract the ComputerNumber from the telescope string
    computerNumber = str2double(eventInfo.telescope(9:10)); % XX from LAST.01.XX.YY
    
    % Determine East or West based on Telescope Number (1-2 = East, 3-4 = West)
    telescopeNumber = str2double(eventInfo.telescope(12:13));
    
    if telescopeNumber == 1 || telescopeNumber == 2
        % East: IP address = computerNumber * 2 - 1
        ipAddress = sprintf('10.23.1.%d', computerNumber * 2 - 1);
    elseif telescopeNumber == 3 || telescopeNumber == 4
        % West: IP address = computerNumber * 2
        ipAddress = sprintf('10.23.1.%d', computerNumber * 2);
    else
        error('Invalid Telescope Number');
    end
end