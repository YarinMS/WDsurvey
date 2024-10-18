function generateForcedPhotometryScript1(rePath, cropID, ra, dec, matFilePath, pngFilePath, removePath)
    % Path to save the script locally
    localScriptPath = '~/WDsurvey/WDsurvey/ForcedPhotometryRemote.m'; 

    % Open the script file for writing
    fid = fopen(localScriptPath, 'w');
    
    % Write the MATLAB script content with hardcoded values
    fprintf(fid, 'function ForcedPhotometryRemote(cropID, ra, dec)\n');
    fprintf(fid, '    addpath(''%s'');\n', '~/Documents/WDsurvey/');
    fprintf(fid, '    rePath = ''%s'';\n', rePath);
    fprintf(fid, '    matFilePath = ''%s'';\n', matFilePath);
    fprintf(fid, '    pngFilePath = ''%s'';\n', pngFilePath);
    fprintf(fid, '    removePath = ''%s'';\n', removePath);
    fprintf(fid, '    AI = loadFilesForPhotometry(rePath, cropID);\n');
    fprintf(fid, '    FP = imProc.sources.forcedPhot(AI, ''Coo'', [ra, dec], ...\n');
    fprintf(fid, '''ColNames'', {''RA'', ''Dec'', ''X'', ''Y'', ''Xstart'', ''Ystart'', ''Chi2dof'', ''FLUX_PSF'', ''FLUXERR_PSF'', ''MAG_PSF'', ''MAGERR_PSF'', ''BACK_ANNULUS'', ''STD_ANNULUS'', ''FLUX_APER'', ''FLAG_POS'', ''FLAGS''});\n');
    
    % Extract headers
    fprintf(fid, '    limMag = arrayfun(@(x) x.Key.LIMMAG, AI)'';\n');
    fprintf(fid, '    airmass = arrayfun(@(x) x.Key.AIRMASS, AI)'';\n');
    fprintf(fid, '    JD = arrayfun(@(x) x.Key.JD, AI)'';\n');
    fprintf(fid, '    FWHM = arrayfun(@(x) x.Key.FWHM, AI)'';\n');
    
    % Photometry data filtering and corrections
    fprintf(fid, '    mms = FP.setBadPhotToNan(''BadFlags'', {''Saturated'', ''Negative'', ''NaN'', ''Spike'', ''Hole'', ''NearEdge''}, ''MagField'', ''MAG_PSF'', ''CreateNewObj'', true);\n');
    fprintf(fid, '    r = lcUtil.zp_meddiff(mms, ''MagField'', {''MAG_PSF''}, ''MagErrField'', {''MAGERR_PSF''});\n');
    fprintf(fid, '    [ms, ~] = applyZP(mms, r.FitZP, ''ApplyToMagField'', {''MAG_PSF''});\n');
    fprintf(fid, '    NdetGood = sum(~isnan(ms.Data.MAG_PSF), 1);\n');
    fprintf(fid, '    Fndet = NdetGood > ms.Nepoch - 4;\n');
    fprintf(fid, '    Fndet(1) = 1;\n');
    fprintf(fid, '    ms = ms.selectBySrcIndex(Fndet, ''CreateNewObj'', false);\n');
    
    % Create the light curve data
    fprintf(fid, '    lcData.lc = ms.Data.MAG_PSF(:,1);\n');
    fprintf(fid, '    lcData.JD = ms.JD;\n');
    fprintf(fid, '    lcData.limMag = limMag;\n');
    fprintf(fid, '    lcData.catJD = JD;\n');
    fprintf(fid, '    lcData.Table.RA = ra;\n');
    fprintf(fid, '    lcData.Table.Dec = dec;\n');
    fprintf(fid, '    lcData.Table.Gmag = 0;\n');

    % Handle Filename (for lcData.Tel and lcData.Date)
    fprintf(fid, '    [~, fname, ~] = fileparts(AI(1).Key.FILENAME);\n');
    fprintf(fid, '    part = strsplit(fname, ''_'');\n');
    fprintf(fid, '    lcData.Tel = part{1};\n');
    fprintf(fid, '    lcData.Date = part{2};\n');
    
    % Calculate control and relative flux
    fprintf(fid, '    lcData.Ctrl = WDtransits3.getCloseControl(ms, 1, {}, ra, dec);\n');
    fprintf(fid, '    enssembeleLC = lcData.Ctrl.medLc;\n');
    fprintf(fid, '    deltaMag = lcData.lc - enssembeleLC;\n');
    fprintf(fid, '    relFlux = 10.^(-0.4 * deltaMag);\n');
    fprintf(fid, '    lcData.relFlux = relFlux / median(relFlux, ''omitnan'');\n');
    
    % Additional light curve data processing
    fprintf(fid, '    lcData.typicalSD = std(lcData.lc, ''omitnan'');\n');
    fprintf(fid, '    lcData.typScatter = std(lcData.relFlux, ''omitnan'');\n');
    fprintf(fid, '    lcData.nanIndices = isnan(lcData.lc);\n');
    fprintf(fid, '    args.Ndet = sum(~isnan(lcData.lc));\n');
    fprintf(fid, '    args.Nvisits = 100000;\n');
    fprintf(fid, '    args.runMeanFilterArgs = {''Threshold'', 5, ''StdFun'', ''OutWin''};\n');
    
    % Detect transits
    fprintf(fid, '    results = WDtransits3.detectTransits(lcData, args);\n');
    
    % Check for detections
    fprintf(fid, '    results = {results};\n');
    fprintf(fid, '    Iwd = 1; Ibatch = 1;\n');
    fprintf(fid, '    Detected = ~isempty(results{Iwd, Ibatch}.detection1.events) || ~isempty(results{Iwd, Ibatch}.detection2.events);\n');
    fprintf(fid, '    FluxDetected = ~isempty(results{Iwd, Ibatch}.detection1flux.events) || ~isempty(results{Iwd, Ibatch}.detection2flux.events);\n');
    
    % Determine detection methods
    fprintf(fid, '    Methods = [~isempty(results{Iwd, Ibatch}.detection1.events), ~isempty(results{Iwd, Ibatch}.detection2.events)];\n');
    fprintf(fid, '    FluxMethods = [~isempty(results{Iwd, Ibatch}.detection1flux.events), ~isempty(results{Iwd, Ibatch}.detection2flux.events)];\n');
    
    % Plot the light curve
    fprintf(fid, '    figure(''Visible'', ''off'');\n');
    fprintf(fid, '    WDtransits3.plotLightCurve(results, Iwd, Ibatch, lcData, Methods, lcData.relFlux, FluxMethods);\n');
    
    % Save the result files with high resolution
    fprintf(fid, '    set(gcf, ''PaperPositionMode'', ''auto'');\n');  % Ensure the paper size fits the figure size
    fprintf(fid, '    set(gcf, ''PaperUnits'', ''inches'');\n');       % Set paper units to inches
    fprintf(fid, '    set(gcf, ''PaperPosition'', [0 0 12 8]);\n');    % Set paper size (12 inches by 8 inches)\n');
    fprintf(fid, '    print(gcf, ''%s'', ''-dpng'', ''-r300'');\n', pngFilePath);  % Save PNG with 300 DPI\n');
    
    % Save lcData (light curve data) as a MAT file
    fprintf(fid, '    save(matFilePath, ''lcData'');\n');
    
    % Clean up the processed directory
    fprintf(fid, '    rmdir(removePath, ''s'');\n');
    fprintf(fid, 'end\n');
    
    % Close the file
    fclose(fid);

    fprintf('Generated ForcedPhotometryRemote.m locally at %s.\n', localScriptPath);
end
