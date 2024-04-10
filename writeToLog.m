function writeToLog(Add, logPath)
    % Check if log file exists
    if exist(logPath, 'file') == 2
        % Open log file in append mode
        logFile = fopen(logPath, 'a');
    else
        % Create new log file
        logFile = fopen(logPath, 'w');
    end

fprintf(logFile,['\n',Add,'\n']);

fclose(logFile);


end