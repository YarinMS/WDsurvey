function remotePath = buildRemotePath(eventInfo)
    % Extract ComputerNumber and TelescopeNumber from the telescope name
    parts = split(eventInfo.telescope, '.');
    
    computerNumber = str2double(parts{3});  % Extract ComputerNumber (XX)
    telescopeNumber = str2double(parts{4}); % Extract TelescopeNumber (1-4)
    
    % Determine if it's east (1,2) or west (3,4)
    if telescopeNumber == 1 || telescopeNumber == 2
        direction = 'e'; % East
    elseif telescopeNumber == 3 || telescopeNumber == 4
        direction = 'w'; % West
    else
        error('Invalid Telescope Number');
    end
    
    % Determine if it's data1 or data2
    if mod(telescopeNumber, 2) == 1
        dataDir = 'data1'; % Odd telescope number: 1 or 3
    else
        dataDir = 'data2'; % Even telescope number: 2 or 4
    end
    
    % Build the final path using the extracted info
    remotePath = sprintf('/last%02d%s/%s/archive/%s/%s/%s/%s/raw', ...
        computerNumber, direction, dataDir, eventInfo.telescope, ...
        eventInfo.year, eventInfo.month, eventInfo.day);
end
