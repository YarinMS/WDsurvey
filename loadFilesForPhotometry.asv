function AI = loadFilesForPhotometry(baseDir, cropID)


    %procDir = fullfile(baseDir, 'proc');
    cd(baseDir)
    procDir   = baseDir;
    visitDirs = dir(procDir);  % List all files/folders in procDir
    visitDirs = visitDirs([visitDirs.isdir]);  % Keep only directories
    visitDirs = visitDirs(~ismember({visitDirs.name}, {'.', '..'}));

    
    % Find all relevant files
    filePattern = sprintf('*%03d_sci_proc_Image_1.fits', cropID);  % Assuming .hdf format
     % Initialize an empty file list
    fileList = {};
    AI = [];
    % Loop over each visit directory
    PWD = pwd;
    for i = 1:length(visitDirs)
        
        visitDirPath = fullfile(procDir, visitDirs(i).name);  % Full path to the visit directory
        % Search for files matching the Crop ID pattern inside the visit directory
        cd(visitDirPath )
 
        fn    = FileNames.generateFromFileName(fullfile(visitDirPath, filePattern));
   
        AI = [AI  AstroImage.readFileNamesObj(fn)];
       
        % Add each found file to the fileList

    end
    cd(PWD)
    
    % Display results
    if isempty(AI)
        fprintf('No files found for Crop ID %s.\n Path: %s \n', cropID,baseDir);
    else
        fprintf('Found %d files for Crop ID %s.\n', numel(AI), cropID);
    end


end