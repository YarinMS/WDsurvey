function loadFitsInDS9(destinationDir)
    % loadFitsInDS9 Loads the .fits files from the destination directory into DS9 with Z-scale applied.
    %
    % INPUT:
    %   destinationDir - Directory containing uncompressed .fits files
    %
    % Example:
    % loadFitsInDS9('~/Documents/to/unpack/')
    % Authors : Yarin Shani & ChatGPT

    % Ensure DS9 is installed and accessible via system command
    [status, cmdout] = system('which ds9');
    if status ~= 0
        error('DS9 is not installed or not found in the system path. %s', cmdout);
    end

    % Find all .fits files in the destination directory
    fitsFiles = dir(fullfile(destinationDir, '*.fits'));
    
    if isempty(fitsFiles)
        error('No .fits files found in the directory: %s', destinationDir);
    end

    % Loop over each .fits file and load it into DS9 with Z-scale
    for i = 1:length(fitsFiles)
        fitsFile = fullfile(fitsFiles(i).folder, fitsFiles(i).name);
        fprintf('Loading FITS file in DS9: %s\n', fitsFile);
        
        % Construct the DS9 command to load the FITS file with Z-scale
        ds9Command = sprintf('ds9 %s -zscale &', fitsFile);
        
        % Execute the command to open DS9 with the FITS file
        system(ds9Command);
    end
end
