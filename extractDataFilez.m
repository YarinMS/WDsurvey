function [fitsFilesBatch, hdf5FilesBatch, fitsFilesNames, hdf5FilesNames, fitsFilesFolders, hdf5FilesFolders] = ...
    extractDataFilez(batch, fullPath, FieldID, CropID)
    % EXTRACTDATAFILES Extracts FITS and HDF5 files from a batch of visits,
    % matching specified FieldID and CropID.
    %
    % Inputs:
    %   batch - A cell array containing visit directories
    %   fullPath - Base path to the batch directories
    %   FieldID - Field ID to match in HDF5 file names
    %   CropID - Crop ID to match at the start of file names
    %
    % Outputs:
    %   fitsFilesBatch, hdf5FilesBatch - Full paths of matching FITS and HDF5 files
    %   fitsFilesNames, hdf5FilesNames - File names of matching FITS and HDF5 files
    %   fitsFilesFolders, hdf5FilesFolders - Folders containing the matching FITS and HDF5 files

    % Initialize outputs as empty cell arrays
    fitsFilesBatch = {};
    hdf5FilesBatch = {};
    fitsFilesNames = {};
    hdf5FilesNames = {};
    fitsFilesFolders = {};
    hdf5FilesFolders = {};

    % Loop over each directory in the batch
    for i = 1:length(batch)
        visitPath = fullfile(fullPath, batch(i).name);
        
        % Find HDF5 files that contain the FieldID and start with the CropID
        hdf5Files = dir(fullfile(visitPath, '*.hdf5'));
        
        if ~any(contains({hdf5Files.name},FieldID)) && i ==1
            return;
        end

        matchingHdf5Files = hdf5Files(contains({hdf5Files.name}, FieldID) & ...
                                      contains({hdf5Files.name}, sprintf('%03d_sci_merged_MergedMat_1', CropID)));

        % Find FITS files that start with the CropID and follow the standard pattern

        fitsFiles = dir(fullfile(visitPath, sprintf('*_%03d_sci_proc_Cat_1.fits', CropID)));
        
        % Collect HDF5 files that match FieldID and CropID
        if ~isempty(matchingHdf5Files)
            hdf5FilesBatch = [hdf5FilesBatch; fullfile({matchingHdf5Files.folder}, {matchingHdf5Files.name})']; %#ok<AGROW>
            hdf5FilesNames = [hdf5FilesNames; {matchingHdf5Files.name}'];
            hdf5FilesFolders = [hdf5FilesFolders; {matchingHdf5Files.folder}'];
            
            % Collect matching FITS files (if they exist in the directory)
            if ~isempty(fitsFiles)
                fitsFilesBatch = [fitsFilesBatch; fullfile({fitsFiles.folder}, {fitsFiles.name})']; %#ok<AGROW>
                fitsFilesNames = [fitsFilesNames; {fitsFiles.name}'];
                fitsFilesFolders = [fitsFilesFolders; {fitsFiles.folder}'];
            end
        end
    end
end
