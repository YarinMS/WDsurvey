function [fitsFilesBatch, hdf5FilesBatch, fitsFilesNames, hdf5FilesNames, fitsFilesFolders, hdf5FilesFolders] = extractDataFiles(batch, fullPath)
    % EXTRACTDATAFILES Extracts FITS and HDF5 files from a batch of visits
    % Inputs:
    %   batch - A cell array containing visit directories
    %   fullPath - Base path to the batch directories
    % Outputs:
    %   fitsFilesBatch, hdf5FilesBatch - Full paths of FITS and HDF5 files
    %   fitsFilesNames, hdf5FilesNames - File names of FITS and HDF5 files
    %   fitsFilesFolders, hdf5FilesFolders - Folders containing FITS and HDF5 files

    fitsFilesBatch = {};
    hdf5FilesBatch = {};
    fitsFilesNames = {};
    hdf5FilesNames = {};
    fitsFilesFolders = {};
    hdf5FilesFolders = {};
    
    for i = 1:length(batch)
        visitPath = fullfile(fullPath, batch(i).name);
        fitsFiles = dir(fullfile(visitPath, '*proc_Image_1.fits'));
        hdf5Files = dir(fullfile(visitPath, '*.hdf5'));

        % Add files to the batch lists
        fitsFilesBatch = [fitsFilesBatch; fullfile({fitsFiles.folder}, {fitsFiles.name})']; %#ok<AGROW>
        hdf5FilesBatch = [hdf5FilesBatch; fullfile({hdf5Files.folder}, {hdf5Files.name})']; %#ok<AGROW>
        fitsFilesNames = [fitsFilesNames; {fitsFiles.name}'];
        hdf5FilesNames = [hdf5FilesNames; {hdf5Files.name}'];
        fitsFilesFolders = [fitsFilesFolders; {fitsFiles.folder}'];
        hdf5FilesFolders = [hdf5FilesFolders; {hdf5Files.folder}'];
    end
end
