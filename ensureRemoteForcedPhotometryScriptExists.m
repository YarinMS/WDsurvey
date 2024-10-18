function ensureRemoteForcedPhotometryScriptExists(ipAddress)
    localScriptPath = '~/WDsurvey/WDsurvey/ForcedPhotometryRemote.m'; % Local path of the script
    remoteScriptPath = '/home/ocs/Documents/MATLAB/ForcedPhotometryRemote.m'; % Remote path

    % SCP command to copy the script to the remote machine
    scpCommand = sprintf('/usr/local/bin/sshpass -p "physics" scp %s ocs@%s:%s', ...
        localScriptPath, ipAddress, remoteScriptPath);
    
    % Execute SCP command
    system(scpCommand);

    fprintf('Script pushed to remote machine %s at %s.\n', ipAddress, remoteScriptPath);
end
