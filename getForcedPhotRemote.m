function getForcedPhotRemote(rePath, cropID, ra, dec, matFilePath, pngFilePath, removePath)
    % Navigate to the path with processed data
    cd(rePath);
    
    % Load files for photometry
    AI = loadFilesForPhotometry(pwd, cropID);
    
    % Perform forced photometry
    FP = imProc.sources.forcedPhot(AI, 'Coo', [ra, dec], ...
        'ColNames', {'RA', 'Dec', 'X', 'Y', 'Xstart', 'Ystart', 'Chi2dof', ...
        'FLUX_PSF', 'FLUXERR_PSF', 'MAG_PSF', 'MAGERR_PSF', 'BACK_ANNULUS', ...
        'STD_ANNULUS', 'FLUX_APER', 'FLAG_POS', 'FLAGS'});
    
    % Extract important values from the header
    limMag = arrayfun(@(x) x.Key.LIMMAG, AI)';
    airmass = arrayfun(@(x) x.Key.AIRMASS, AI)';
    JD = arrayfun(@(x) x.Key.JD, AI)';
    FWHM = arrayfun(@(x) x.Key.FWHM, AI)';
    
    % Process forced photometry results
    mms = FP.setBadPhotToNan('BadFlags', {'Saturated', 'Negative', 'NaN', 'Spike', 'Hole', 'NearEdge'}, ...
                             'MagField', 'MAG_PSF', 'CreateNewObj', true);
    r = lcUtil.zp_meddiff(mms, 'MagField', {'MAG_PSF'}, 'MagErrField', {'MAGERR_PSF'});
    [ms, ~] = applyZP(mms, r.FitZP, 'ApplyToMagField', {'MAG_PSF'});
    
    % Filter and clean photometry data
    NdetGood = sum(~isnan(ms.Data.MAG_PSF), 1);
    Fndet = NdetGood > ms.Nepoch - 4;
    Fndet(1) = 1;
    ms = ms.selectBySrcIndex(Fndet, 'CreateNewObj', false);
    
    % Construct light curve data
    lcData.lc = ms.Data.MAG_PSF(:,1);
    lcData.JD = ms.JD;
    lcData.limMag = limMag;
    lcData.catJD = JD;
    [~, fname, ~] = fileparts(AI(1).Key.FILENAME);
    part = strsplit(fname, '_');
    lcData.Tel = part{1};
    lcData.Date = part{2};
    lcData.Table.RA = ra;
    lcData.Table.Dec = dec;
    lcData.Table.Gmag = 0;
    
    % Get control group and calculate relative flux
    lcData.Ctrl = WDtransits3.getCloseControl(ms, 1, {}, ra, dec);
    enssembeleLC = lcData.Ctrl.medLc;
    deltaMag = lcData.lc - enssembeleLC;
    relFlux = 10.^(-0.4 * (deltaMag));
    lcData.relFlux = relFlux / median(relFlux, 'omitnan');
    
    % Detect transits
    lcData.typicalSD = std(lcData.lc, 'omitnan');
    lcData.typScatter = std(lcData.relFlux, 'omitnan');
    lcData.nanIndices = isnan(lcData.lc);
    args.Ndet = sum(~isnan(lcData.lc));
    args.Nvisits = 100000;
    args.runMeanFilterArgs = {'Threshold', 5, 'StdFun', 'OutWin'};
    results = WDtransits3.detectTransits(lcData, args);
    
    % Store results
    results = {results};
    Iwd = 1;
    Ibatch = 1;
    
    % Check which detection methods found events
    Detected = ~isempty(results{Iwd, Ibatch}.detection1.events) || ...
               ~isempty(results{Iwd, Ibatch}.detection2.events);
    FluxDetected = ~isempty(results{Iwd, Ibatch}.detection1flux.events) || ...
                   ~isempty(results{Iwd, Ibatch}.detection2flux.events);
    
    % Plot the light curve and save the results
    Methods = [~isempty(results{Iwd, Ibatch}.detection1.events), ...
               ~isempty(results{Iwd, Ibatch}.detection2.events)];
    FluxMethods = [~isempty(results{Iwd, Ibatch}.detection1flux.events), ...
                   ~isempty(results{Iwd, Ibatch}.detection2flux.events)];
    
    figure('Visible', 'off');  % Create figure without displaying
    WDtransits3.plotLightCurve(results, Iwd, Ibatch, lcData, Methods, lcData.relFlux, FluxMethods);
    
    % Save light curve data and plot
    save(matFilePath, 'lcData');
    saveas(gcf, pngFilePath);
    
    % Cleanup: Remove the processed directory
    rmdir(removePath, 's');
end
