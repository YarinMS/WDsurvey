function updateLASTComputers()
    % Define the list of computer numbers and east/west identifiers
    computerNumbers = [1, 2, 3, 4, 5, 6, 7, 8, 10];  % Exclude 9 as per instructions
    directions = {'e', 'w'};  % East ('e') and West ('w')

    % Iterate over all computers
    for i = 1:length(computerNumbers)
        computerNumber = computerNumbers(i);

        for j = 1:length(directions)
            direction = directions{j};
            
            % Generate the IP address based on computer number and direction
            ipAddress = getIPAddress(computerNumber, direction);

            % Construct the SSH command to navigate to the directory, pull from git, and checkout Linux
            sshCommand = sprintf([ ...
                '/usr/local/bin/sshpass -p "physics" ssh ocs@%s ', ...
                '"cd ~/Documents/WDsurvey && git pull && git checkout Linux"'], ipAddress);

            % Execute the SSH command
            fprintf('Connecting to %s (%s)...\n', ipAddress, strcat('last', sprintf('%02d', computerNumber), direction));
            status = system(sshCommand);

            % Check the status of the command
            if status == 0
                fprintf('Successfully updated %s.\n', strcat('last', sprintf('%02d', computerNumber), direction));
            else
                fprintf('Failed to update %s.\n', strcat('last', sprintf('%02d', computerNumber), direction));
            end
        end
    end
end

function ipAddress = getIPAddress(computerNumber, direction)
    % Define IP address based on computer number and east/west (e/w)
    if direction == 'e'
        ipAddress = sprintf('10.23.1.%d', computerNumber * 2 - 1);  % East IP
    elseif direction == 'w'
        ipAddress = sprintf('10.23.1.%d', computerNumber * 2);      % West IP
    else
        error('Invalid direction: must be ''e'' or ''w''.');
    end
end
