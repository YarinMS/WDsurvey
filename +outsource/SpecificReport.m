function [MS] = SpecificReport(MS,Args)
% SpecificReport - Generate a variability report for specific source.
%   The function generates a detailed variability report for a
%   specified source within a MatchedSources object (MS). It calculates
%   and visualizes various statistics and characteristics of the source's
%   light curve, including periodograms, RMS vs. mean magnitude plots,
%   polynomial subtraction, and more. Users can customize the report by
%   providing optional Args parameters.
%
%   Inputs:
%     - MS (MatchedSources): A MatchedSources object containing source data.
%     select source identification method:
%       - RAD: [RA, Dec] position in degrees.
%       - ID: Source identification method, [sub image index, source index]
%     optional fields:
%       - SearchRadius: Radius for searching source if [RA, Dec]is used (default: 3).
%       - MagField: Name of the magnitude field (default: it choosing according to lower Std).
%       - MagErrField: Name of the magnitude error field.
%       - FreqThreshold: Frequency threshold range for periodogram (default: [100, 1000]).
%       - NumPeaks: Number of significant peaks to identify (default: 5).
%       - Maxorder: Maximum polynomial order for subtraction (default: 5).
%       - Flags: Cell array of source flags to consider (default: {'Saturated','NaN','Negative','CR_DeltaHT','NearEdge','Overlap'}).
%       - BinRmsStep: RMS curve binning step size (default: 0.5).
%       - BinRmsRange: RMS curve binning range (default: [10, 19]).
%
%   Outputs:
%     figure containing:
%       - 4 graphs: periodogram, RMS curve, light curve, folded light curve
%       - Data that relevant to the report
%
%   Example usage:
%     SpecificReport(MS,'RAD',[RA,Dec],'SearchRadius',6);
    
    arguments
        MS(1,1) MatchedSources
        Args.RAD                    =[NaN,NaN];
        Args.ID                     =[0,0];
        Args.SearchRadius           = 3;
        Args.MagField char          = 'Default';
        Args.MagErrField char       = 'MAGERR_APER_3';
        Args.SysremNiter            = 2;
        Args.FreqThreshold          = [100, 1000];
        Args.PowerThreshold         = 15;
        Args.NumPeaks               = 5;
        Args.Maxorder               = 5;
        Args.HardFlags              = {'NearEdge','Saturated','NaN','Negative'};
        Args.InterestFlags       = {};
        Args.BinRmsStep             = 0.5;
        Args.BinRmsRange            = [10 19];
        Args.FlagChekOrder          = {'CR_DeltaHT','BiasFlaring','DarkHighVal','HighRN'};
    end
    %% creat Flag mask
    Nsrc = MS.Nsrc;
    Nepoch = MS.Nepoch;
    FlagsMasks = struct();
    FlagcombinedMask = false(Nepoch,Nsrc);
    for i=1 : numel(Args.HardFlags)
        FlagsMasks.(Args.HardFlags{i}) = FlagIdentification(MS, 'FlagsList', {Args.HardFlags{i}});
        FlagcombinedMask = FlagcombinedMask | FlagsMasks.(Args.HardFlags{i});
    end
    %% Data choosing and preparation
    % finding source index according to source identification method
    if all(isnan(Args.RAD)) && any(Args.ID ~= [0, 0])
        ind = Args.ID(2);
        Args.RAD = [mean(MS.Data.RA(:,ind), 'omitnan'),mean(MS.Data.Dec(:,ind), 'omitnan')];
    elseif ~any(isnan(Args.RAD)) && isequal(Args.ID, [0, 0])
        result = coneSearch(MS, Args.RAD(1),Args.RAD(2),Args.SearchRadius);
        ind = result.Ind(min(result.Dist)==result.Dist);
        if isempty(ind)
            error('No source was detected, search radius is probably too small');
        end
    else
        error('At least one and only one source identification method should be used ');
    end
    
    %choosing which Mag fielde to use, finding ZP and sysrem
    if strcmp(Args.MagField, 'Default')
        MSCopy = copy(MS);
        MS = FitZPFlagsNan(MS,'MagField','MAG_APER_3' ,'MagErrField','MAGERR_APER_3','HardFlagsMask',FlagcombinedMask);
        MSCopy = FitZPFlagsNan(MSCopy,'MagField','MAG_PSF' ,'MagErrField','MAGERR_PSF','HardFlagsMask',FlagcombinedMask);
        Args.MagField = 'MAG_APER_3';
        % need to think what to do if ind is not in SourceNum
        ind = find(MS.Data.SourceNum == ind);
        StDMask = std(MSCopy.Data.MAG_PSF,'omitnan') < std(MS.Data.MAG_APER_3,'omitnan');
        AllStd = std(MS.Data.MAG_APER_3,'omitnan');
        AllMean = mean(MS.Data.MAG_APER_3,'omitnan');
        AllStdPsf = std(MS.Data.MAG_PSF,'omitnan');
        AllMeanPsf = mean(MS.Data.MAG_PSF,'omitnan');
        AllStd(StDMask) = AllStdPsf(StDMask);
        AllMean(StDMask) = AllMeanPsf(StDMask);
    
        if StDMask(ind)
            MS = copy(MSCopy);
            Args.MagField = 'MAG_PSF';
            Args.MagErrField = 'MAGERR_PSF';
        end
    else
        MS = FitZPFlagsNan(MS,'MagField',Args.MagField ,'MagErrField',Args.MagErrField,'HardFlagsMask',FlagcombinedMask);
        ind = find(MS.Data.SourceNum==ind);
    end
    %MS.addExtMagColor;
    % preparing data
    mag = getMatrix(MS, Args.MagField);
    err = getMatrix(MS, Args.MagErrField);
    IndM = mag(:,ind);
    IndE = err(:,ind);
        
    %% Periodogram 
    t_jd = MS.JD;
    StepFreq = 1./(2.*range(t_jd));
    FreqVec = (Args.FreqThreshold(1): StepFreq : Args.FreqThreshold(2));
    [FreqVec,PS] = timeSeries.period.periodmulti_norm(t_jd, IndM, FreqVec);
    [pks, locs] = findpeaks(PS, 'SortStr', 'descend', 'NPeaks',Args.NumPeaks);
    freq = FreqVec(locs);
    period = 1440 ./ freq;

    %% Finding mean, std, rstd, median
    if ~exist('StDMask', 'var')
        AllMean = mean(mag, 'omitnan');    
        AllStd = std(mag,'omitnan');
    end
    
    IndMean = AllMean(ind);
    IndStd = AllStd(ind);
    IndRstd = tools.math.stat.nanrstd(mag(:,ind));  
    MagRange = max(IndM) - min(IndM);

    %% Delta std from rms curve
    RMSData = [AllMean' , AllStd'];
    [B,OutCol] = timeSeries.bin.binning(RMSData,Args.BinRmsStep,Args.BinRmsRange);
    Vq = interp1(B(:,1),(B(:,3:5)),AllMean);
    StdDeltaRms = (AllStd-Vq(:,1)')./Vq(:,3)';
    IndStdDeltaRms = StdDeltaRms(ind);
    
    %% Delta chi testing:
    %Fit polynomials of various orders and calculate chi^2 and std after
    %subtracting the polynomials
    IndNanMask = ~isnan(IndM);
    if all(~IndNanMask)
        warning('all curvelight values are NaN');
    else
        Chistruct = timeSeries.obsolete.fit_polys_deltachi2([t_jd(IndNanMask) ,IndM(IndNanMask) ,IndE(IndNanMask)] , 'MaxOrder', Args.Maxorder);
    end
    %% Polynomial Subtraction
    params = polyfit(t_jd(IndNanMask), IndM(IndNanMask), Chistruct.PreferredModel); 
    fit = polyval(params, t_jd);
    IndMSub = IndM - fit;
    %% External catalogue data
    [ExtCat,ExtColCell,ExtColUnits]=catsHTM.cone_search('GAIADR3', convert.angular('deg','rad',Args.RAD(1)),convert.angular('deg','rad',Args.RAD(2)), 10);
    %% Finding relevant flags and summing over all epochs
    DefultBM=BitDictionary;
    flags = int32(MS.Data.FLAGS);
%     sumers =zeros(numel(Args.InterestFlags),1);
%     for i = 1:numel(Args.InterestFlags)
%         fieldindex = find(strcmp(DefultBM.Dic.BitName, Args.InterestFlags{i}));
%         if ~isempty(fieldindex)
%             sumers(i) = sum(bitget(flags(:,ind),fieldindex));
%         else
%             warning('Field "%s" not found in dictionary', Args.InterestFlags{i});
%         end
%     end
    %% Find reference source and calculate LC
    NearMagMask = abs(AllMean-IndMean) < 0.25 & abs(AllMean-IndMean) ~= 0;
    NearMagIndices = MS.Data.SourceNum(NearMagMask);
    D = celestial.coo.sphere_dist_fast(Args.RAD(1),Args.RAD(2),...
        mean(MS.Data.RA(:,NearMagIndices), 'omitnan'),mean(MS.Data.Dec(:,NearMagIndices), 'omitnan'));
    RefLCi = NearMagIndices(D == min(D));
    RefLCi = find(MS.Data.SourceNum == RefLCi);
    % Delta chi testing:
    RefNanMask = ~isnan(mag(:,RefLCi));
    if all(~RefNanMask)
        warning('all reference curvelight values are NaN');
    else
        RefChistruct = timeSeries.obsolete.fit_polys_deltachi2([t_jd(RefNanMask) ,mag(RefNanMask,RefLCi) ,err(RefNanMask,RefLCi)] , 'MaxOrder', Args.Maxorder);
    end
    % Polynomial Subtraction
    RefParams = polyfit(t_jd(RefNanMask), mag(RefNanMask,RefLCi), RefChistruct.PreferredModel); 
    Reffit = polyval(RefParams, t_jd);
    RefMSub = mag(:,RefLCi) - Reffit;
    [RefCorr,RefProb]=tools.math.stat.corrsim(IndMSub, RefMSub);

    %% Ploting time - plot the report
    figure('Name', sprintf('VRIABILITY REPORT \t ID(%.f,%.f) \t RA:%.2f Dec:%.2f \t file name: %s \t magfield used: %s'...
        ,Args.ID(1),Args.ID(2),Args.RAD(1),Args.RAD(2),inputname(1), string(Args.MagField)));
    
    % plot Periodogram
    subplot(3,2,1);
    plot(FreqVec, PS, '-');
    hold on;
    plot(freq(pks>Args.PowerThreshold), pks(pks>Args.PowerThreshold), 'ro', 'MarkerSize', 5);
    xlim(Args.FreqThreshold);
    xlabel('Frequency(1/day)', 'FontSize', 8);
    ylabel('Power (\sigma)', 'FontSize', 8);
    title('Power Spectra', 'FontSize', 10);

    % plot RMS
    subplot(3, 2, 2);
    plot(AllMean, AllStd, 'k.');
    hold on;
    plot(IndMean, IndStd, 'r.', 'MarkerSize', 30);
    plot(AllMean(RefLCi), AllStd(RefLCi), 'b.', 'MarkerSize', 20);
    hold off; 
    set(gca, 'YScale', 'log'); 
    xlabel('Calibrated Mean Mag(mag)', 'FontSize', 8);
    ylabel('RMS(mag)', 'FontSize', 8);
    title('RMS vs Mean Magnitude', 'FontSize', 10);
   
    %plot LC
    subplot(3,2,3);
    %set time to scale of the first day - 
    day = floor(t_jd(1));
    t = t_jd - day;
    plot(t, IndMSub, '.','MarkerSize', 7, 'MarkerEdgeColor', [0.5 0.5 0.5], ... 
          'MarkerFaceColor', [0.5 0.5 0.5], 'HandleVisibility', 'off');
    hold on;
    test_results = zeros(size(t));
    FlagSums =zeros(numel(Args.FlagChekOrder),1);
    % Loop through each test
    for i = 1:numel(Args.FlagChekOrder)
        fieldindex = find(strcmp(DefultBM.Dic.BitName, Args.FlagChekOrder{i}));
        if ~isempty(fieldindex)
            FlagMask = bitget(flags(:,ind),fieldindex);   %mask for flaged points
            FlagSums(i) = sum(FlagMask);
            NecessaryFlagMask = FlagMask == 1 & test_results == 0; %mask for points both far from the average and flaged
            test_results(NecessaryFlagMask) = i;
            plot(t(NecessaryFlagMask), IndMSub(NecessaryFlagMask), '.','MarkerSize', 7, 'DisplayName', Args.FlagChekOrder{i});
        else
            error('Field "%s" not found in dictionary', Args.FlagChekOrder{i});
        end
        
    end
    colormap(jet(numel(Args.FlagChekOrder)));
    if any(test_results~=0)
        legend('show');
        legend('FontSize',6,'Orientation','horizontal','Location','south');
    end
    set(gca, 'YDir', 'reverse'); % Reverse the magnitude axis (since higher 
    % magnitudes reflect dimmer objects, and vice versa)
    ylabel('Subtracted Magnitude(mag)', 'FontSize', 7);
    xlabel(sprintf('Time (Mjd - %d)', day-24*10^5), 'FontSize', 8);
    title('Light Curve', 'FontSize', 10);
    hold off;

    % Plot folded light curve
    % Calculate phase for each data point in folded time series
    lcmatrix_folded = timeSeries.fold.folding([t_jd, IndMSub], 1/freq(pks == max(pks)));
    lcmatrix_folded_binned = timeSeries.bin.binning(lcmatrix_folded);
    mean_y = lcmatrix_folded_binned(:,3);
    stdo_y = lcmatrix_folded_binned(:,5);
    n_el = lcmatrix_folded_binned(:,2);
    std_y = stdo_y ./ sqrt(n_el);

    subplot(3, 2, 4);
    plot(lcmatrix_folded(:,1), lcmatrix_folded(:,2), '.','MarkerSize', 7, 'MarkerEdgeColor',...
        [0.5 0.5 0.5], 'MarkerFaceColor', [0.5 0.5 0.5]);
    hold on;
    errorbar(lcmatrix_folded_binned(:,1), mean_y, std_y, '.','MarkerEdgeColor',...
        [0.5 0.5 0.5], 'MarkerFaceColor', [0.5 0.5 0.5], 'LineWidth', 3);       
    set(gca, 'YDir', 'reverse'); 
    xlabel('Phase', 'FontSize', 8);
    ylabel('Subtracted Magnitude', 'FontSize', 8);
    title(sprintf('Folded Light Curve (T = %.2f mins)', period(pks == max(pks))),'FontSize',10);

    %plot values
    subplot(3,2,[5,6]);
    text(-0.1, 1.05, sprintf('Mean Mag: %.3f   Std: %.3f    RStd: %.3f     Mag range: %.3f   \t min xy: [%.2f,%.2f] \t max xy: [%.2f,%.2f]',...
        IndMean, IndStd, IndRstd, MagRange,min(MS.Data.X1(:,ind)),min(MS.Data.Y1(:,ind)),max(MS.Data.X1(:,ind)), max(MS.Data.Y1(:,ind))));
    text(-0.1, 0.9, sprintf('External catalog data: RA: %.2f \t Dec: %.2f \t G: %.2f \t B: %.2f \t R: %.2f', convert.angular('rad','deg',ExtCat(1)),...
        convert.angular('rad','deg',ExtCat(2)),ExtCat(27),ExtCat(29),ExtCat(31)));


    text(-0.1, 0.75, sprintf('Delta std from Rms curve: %.2f     peaks:', IndStdDeltaRms));
    text(0.2, 0.65, sprintf('periods:'));
    for i=1:Args.NumPeaks
        text(0.2+i*0.1, 0.75, sprintf('%.f: %.2f',i, pks(i)));
        text(0.2+i*0.1, 0.65, sprintf('%.f: %.2f',i, period(i)));
    end
    
    text(-0.1, 0.5, sprintf('Subtracted polinomial order: %.f    ChiRed for order:', Chistruct.PreferredModel));
    text(0.151, 0.4, 'Std after subtracting:');
    for i=1:numel(Chistruct.NewChi2)
        text(0.253+i*0.1, 0.5, sprintf('%.f: %.2f',i, Chistruct.NewChi2(i)));
        text(0.253+i*0.1, 0.4, sprintf('%.f: %.3f',i, Chistruct.Std(i)));
    end
    
    text(-0.1, 0.3, sprintf('Nepoch: %.f', Nepoch));
    text(-0.1, 0.15, 'Hard flags:');
    for i=1:numel(Args.HardFlags)
        text(-0.1+i * 0.15, 0.15, sprintf('%s: %.f',Args.HardFlags{i}, sum(FlagsMasks.(Args.HardFlags{i})(:,Args.ID(2)))));
    end
    text(-0.1, 0, 'Soft flags:');
    for i=1:numel(Args.FlagChekOrder)
        text(-0.1+i * 0.15, 0, sprintf('%s: %.f',Args.FlagChekOrder{i}, FlagSums(i)));
    end
    
    text(0,-0.3,sprintf('VRIABILITY REPORT \t ID(%.f,%.f) \t RA:%.2f Dec:%.2f \t file name: %s \t magfield used: %s'...
        ,Args.ID(1),Args.ID(2),Args.RAD(1),Args.RAD(2),inputname(1), string(Args.MagField)),'FontSize', 11);
    axis off;
    % Adjust the figure size 
    set(gcf, 'Position', [100, 100, 1000, 700]); 
    hold off;
    
    %plot reference LC
    figure('Position', [100, 100, 400, 400]);
    subplot(2,1,1);
    plot(t, RefMSub, '.','MarkerSize', 7, 'MarkerEdgeColor', [0.5 0.5 0.5], ... 
          'MarkerFaceColor', [0.5 0.5 0.5], 'HandleVisibility', 'off');
%     hold on;
%     test_results = zeros(size(t));
%     % Loop through each test
%     for i = 1:numel(Args.FlagChekOrder)
%         fieldindex = find(strcmp(DefultBM.Dic.BitName, Args.FlagChekOrder{i}));
%         if ~isempty(fieldindex)
%             FlagMask = bitget(flags(:,RefLCi),fieldindex);   %mask for flaged points
%             FlagSums(i) = sum(FlagMask);
%             NecessaryFlagMask = FlagMask == 1 & test_results == 0; %mask for points both far from the average and flaged
%             test_results(NecessaryFlagMask) = i;
%             plot(t(NecessaryFlagMask), RefMSub(NecessaryFlagMask), '.', 'DisplayName', Args.FlagChekOrder{i});
%         else
%             error('Field "%s" not found in dictionary', Args.FlagChekOrder{i});
%         end
%         
%     end
%     colormap(jet(numel(Args.FlagChekOrder)));
%     if any(test_results~=0)
%         legend('show');
%         legend('FontSize',6,'Orientation','horizontal','Location','south');
%     end
    set(gca, 'YDir', 'reverse'); % Reverse the magnitude axis (since higher 
    % magnitudes reflect dimmer objects, and vice versa)
    ylabel('Subtracted Magnitude(mag)', 'FontSize', 7);
    xlabel(sprintf('Time (Mjd - %d)', day-24*10^5), 'FontSize', 8);
    title('Refrence Light Curve', 'FontSize', 10);
    hold off;
    subplot(2,1,2);
    text(-0.1, 1, sprintf('Reference LC correlation: %.3f \nProbability for better correlation: %.3f', RefCorr, RefProb));
    axis off;
end
