function generateForcedPhotometryScriptMarv(rePath, cropID, ra, dec, matFilePath,  removePath)
    % Path to save the script locally
    localScriptPath = '~/Documents/WDsurvey/ForcedPhotometryRemote.m'; 

    % Open the script file for writing
    fid = fopen(localScriptPath, 'w');
    
    % Write the MATLAB script content with hardcoded values
    fprintf(fid, 'function ForcedPhotometryRemote(cropID, ra, dec)\n');
    fprintf(fid, '    addpath(''%s'');\n', '~/Documents/WDsurvey/');
    fprintf(fid, '    rePath = ''%s'';\n', rePath);
    fprintf(fid, '    matFilePath = ''%s'';\n', matFilePath);
    fprintf(fid, '    removePath = ''%s'';\n', removePath);
    fprintf(fid, '    AI = loadFilesForPhotometry(rePath, cropID);\n');
    fprintf(fid, '    FP = imProc.sources.forcedPhot(AI, ''Coo'', [ra, dec], ...\n');
    fprintf(fid, '        ''ColNames'', {''RA'', ''Dec'', ''X'', ''Y'', ''Xstart'', ''Ystart'', ''Chi2dof'', ...\n');
    fprintf(fid, '        ''FLUX_PSF'', ''FLUXERR_PSF'', ''MAG_PSF'', ''MAGERR_PSF'', ''BACK_ANNULUS'', ...\n');
    fprintf(fid, '        ''STD_ANNULUS'', ''FLUX_APER'', ''FLAG_POS'', ''FLAGS''}, ...\n');
    fprintf(fid, '        ''MomentMaxIter'', 10, ''UseMomCoo'', true, ''HeaderZP'', true, ''ReconstructPSF'', false);\n');
    fprintf(fid, '    mms = FP.setBadPhotToNan(''BadFlags'', {''Saturated'', ''Negative'', ''NaN'', ''Spike'', ''Hole'', ''NearEdge''}, ...\n');
    fprintf(fid, '        ''MagField'', ''MAG_PSF'', ''CreateNewObj'', true);\n\n');
    fprintf(fid, '    FP\n');
    fprintf(fid, '    r = lcUtil.zp_meddiff(mms, ''MagField'', {''MAG_PSF''}, ''MagErrField'', {''MAGERR_PSF''}, ''MinNsrc'', 1);\n');
    fprintf(fid, '    [ms, ~] = applyZP(mms, r.FitZP, ''ApplyToMagField'', {''MAG_PSF''});\n\n');
    fprintf(fid, '    %% Filter detections\n');
    fprintf(fid, '    NdetGood = sum(~isnan(ms.Data.MAG_PSF), 1);\n');
    fprintf(fid, '    Fndet = NdetGood > ms.Nepoch - 4;\n');
    fprintf(fid, '    Fndet(1) = 1;\n');
    fprintf(fid, '    ms = ms.selectBySrcIndex(Fndet, ''CreateNewObj'', false);\n\n');
    % Save lcData (light curve data) as a MAT file
    fprintf(fid, '    save(matFilePath, ''ms'');\n');
    fprintf(fid, '    fprintf(''Complete'')\n');
    % Clean up the processed directory
    fprintf(fid, '    rmdir(removePath, ''s'');\n');
    fprintf(fid, 'end\n');
    
    % Close the file
    fclose(fid);

    fprintf('Generated ForcedPhotometryRemote.m locally at %s.\n', localScriptPath);
end
