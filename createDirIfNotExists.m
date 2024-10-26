function createDirIfNotExists(dirPath)
    % Check if the input path exists as a directory
    if ~isfolder(dirPath)
        % If it doesn't exist, create the directory (and any necessary parent directories)
        mkdir(dirPath);
        fprintf('Directory created: %s\n', dirPath);
    else
        % Directory already exists
        %fprintf('Directory already exists: %s\n', dirPath);
    end
end
