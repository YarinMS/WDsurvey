function navigateAndMatchInDS9SeparateCommands(destinationDir, frameToFocus, x, y, radius)
    % navigateAndMatchInDS9SeparateCommands Loads all .fits files and manipulates DS9 using separate system() calls.
    %
    % INPUT:
    %   destinationDir - Directory containing uncompressed .fits files
    %   frameToFocus   - Frame number to focus on
    %   x, y           - X and Y coordinates of the pixel to pan to
    %   radius         - Radius of the circular aperture (region)
    %
    % Example:
    % navigateAndMatchInDS9SeparateCommands('~/Documents/to/unpack/', 1, 500, 500, 20)

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

    % Open DS9 and start loading images (initial DS9 launch)
    system('ds9 &');  % Start DS9 in the background

    % Loop over each file and load it as a frame with zscale
    for i = 1:length(fitsFiles)
        fitsFile = fullfile(fitsFiles(i).folder, fitsFiles(i).name);
        % Load each file into a new frame in DS9
        system(sprintf('ds9 -frame new %s -zscale', fitsFile));
    end

    % Set DS9 to tile all the frames
    system('ds9 -tile');

    % Focus on a specific frame and pan to the (x, y) coordinate
    system(sprintf('ds9 -frame %d -pan to %f %f', frameToFocus, x, y));

    % Add a circular region (aperture) at the (x, y) coordinates
    system(sprintf('ds9 -regions command "circle(%f, %f, %f)"', x, y, radius));

    % Match the pan, scale, and regions across all frames
    system('ds9 -match crop -match scale -match regions');
end
