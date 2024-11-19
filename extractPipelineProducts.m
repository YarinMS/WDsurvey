% Function to extract pipeline products for a given directory in Batch
function [catFP, MS_FP, imageFP] = extractPipelineProducts(dirInfo, cropID)
    % Catalog Files
    catFN = dir(fullfile(dirInfo.folder, dirInfo.name, sprintf('*_001_%03d_sci_proc_Cat_1.fits', cropID)));
    catFP = arrayfun(@(x) fullfile(x.folder, x.name), catFN, 'UniformOutput', false);
    
    % Merged Catalogs
    MS_FP = dir(fullfile(dirInfo.folder, dirInfo.name, sprintf('*_001_%03d_sci_merged_MergedMat_1.hdf5', cropID)));
    %MS_FP = arrayfun(@(x) fullfile(x.folder, x.name), MS_FN, 'UniformOutput', false);
    
    % Processed Images
    imageFN = dir(fullfile(dirInfo.folder, dirInfo.name, sprintf('*_001_%03d_sci_proc_Image_1.fits', cropID)));
    imageFP = arrayfun(@(x) fullfile(x.folder, x.name), imageFN, 'UniformOutput', false);
end