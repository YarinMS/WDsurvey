function writeNumberedLines(filePath, newText)
    % Open the file in append mode
        % Check if log file exists
    if exist(filePath, 'file') == 2
        % Open log file in append mode
        fid = fopen(filePath, 'a');
    else
        % Create new log file
        fid = fopen(filePath, 'w');
    end
    
    % Check if the file was opened successfully
    if fid == -1
        error('Error: Unable to open file.');
    end
    
    % Count the number of lines in the file
    lineCount = countLines(filePath);
    
    % Write the new line with its number
    fprintf(fid, '%d: %s\n', lineCount + 1, newText);
    
    % Close the file
    fclose(fid);
end

function count = countLines(filePath)
    % Open the file
    fid = fopen(filePath, 'r');
    
    % Check if the file was opened successfully
    if fid == -1
        error('Error: Unable to open file.');
    end
    
    % Initialize line count
    count = 0;
    
    % Read lines until EOF
    while ~feof(fid)
        % Read a line
        line = fgetl(fid);
        if ischar(line)
            % Increment line count
            count = count + 1;
        end
    end
    
    % Close the file
    fclose(fid);
end
