function fileList = loadFilesForPhotometry(baseDir, cropID)


    procDir = fullfile(baseDir, 'proc');
    visitDirs = dir(procDir);  % List all files/folders in procDir
    visitDirs = visitDirs([visitDirs.isdir]);  % Keep only directories
    visitDirs = visitDirs(~ismember({visitDirs.name}, {'.', '..'}));
    
    % Find all relevant files
    filePattern = sprintf('*%03d_sci_proc_Image_1.fits', cropID);  % Assuming .hdf format
     % Initialize an empty file list
    fileList = {};

    % Loop over each visit directory
    for i = 1:length(visitDirs)
        visitDirPath = fullfile(procDir, visitDirs(i).name);  % Full path to the visit directory
        % Search for files matching the Crop ID pattern inside the visit directory
        
        files = dir(fullfile(visitDirPath, filePattern));

        % Add each found file to the fileList
        for j = 1:length(files)
            fileList{end+1} = fullfile(files(j).folder, files(j).name); %#ok<AGROW>
        end
    end
    
    % Display results
    if isempty(fileList)
        fprintf('No files found for Crop ID %s.\n', cropID);
    else
        fprintf('Found %d files for Crop ID %s.\n', numel(fileList), cropID);
    end


end