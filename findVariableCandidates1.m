function [Cand, WDcand, FlagComb, ReportFile,Rpt,ch1] = findVariableCandidates1(ms,Rpt,ch1, Args)
    % Function to find variable candidates based on criteria in FlagInfo
    % Function to find variable candidates based on criteria in FlagInfo
    % Arguments:
    %   Obj  - Main data object containing MS and other information
    %   Args - Structure with fields:
    %       MinDet    - Minimum detection threshold
    %       RAField   - Field name for Right Ascension data
    %       DecField  - Field name for Declination data
    %       MagField  - Field name for Magnitude data
    %       Plot      - Boolean, if true, plot results
    %       Report    - Boolean, if true, generate a report
    % Outputs:
    %   Cand      - Structure array of candidates
    %   FlagComb  - Combined logical array indicating which sources are candidates
    %   ReportFile - Filename of the generated report (if applicable)
    
    arguments
        ms
        Rpt
        ch1
        Args.MinDet (1,1) double = ms.Nepoch - 0.15*ms.Nepoch;
        Args.RAField (1,:) char = 'RA'
        Args.DecField (1,:) char = 'Dec'
        Args.MagField (1,:) char = 'Mag'
        Args.Plot (1,1) logical = false
        Args.Report (1,1) logical = false
        Args.thresholdRMF (1,1) double = 6;
        Args.winSizeRMF (1,1) double   = 2;
        Args.outputDir = '~/Documents/Temp/All'
    end

   % persistent Rpt ch1 reportInitialized;
    
    % Only initialize the report once, on the first call
    %if Args.Report && isempty(reportInitialized)
     %   [Rpt, ch1] = initializeReport(Args.outputDir);
      %  reportInitialized = true;  % Mark the report as initialized
    %end
    
    % Initial setup for candidate finding
    Obj = pipeline.last.SearchMatchedSources;
    Obj.MS = ms;
    [Flag, FlagInfo, Summary] = findVariableMS2(Obj);
    FlagComb = FlagInfo.N(:) >= Args.MinDet & Flag.FlagGood(:) & ...
               (Flag.PS(:) | Flag.RMS(:) | Flag.Poly(:) | Flag.RunMeanFilt(:));
    
    Cand = struct([]);
    WDcand = struct([]);
    ReportFile = '';
    
    if any(FlagComb)
        IndCand = find(FlagComb);
        Ncand = numel(IndCand);
        Icand = 0;
        Iwd = 0;

        % Loop through candidates
        for I = 1:Ncand
            IndSrc = IndCand(I);
            [FlagGood, ResPhotAstCorr] = flagCorr(Obj, IndSrc);
            
            if FlagGood
                RA = median(Obj.MS.Data.(Args.RAField)(:,IndSrc), 1, 'omitnan');
                Dec = median(Obj.MS.Data.(Args.DecField)(:,IndSrc), 1, 'omitnan');
                
                % Check if in WD catalog
                WD = isWD(Obj, RA, Dec);
                if ~isempty(WD.Table)
                    Iwd = Iwd + 1;
                    WDcand{Iwd} = createCandidateStruct(IndSrc, Ncand, Flag, Summary, Obj, RA, Dec);
                else
                    Icand = Icand + 1;
                    Cand{Icand} = createCandidateStruct(IndSrc, Ncand, Flag, Summary, Obj, RA, Dec);
                end
                
                % Plot if required
                if Args.Plot
                    plotCandidate(Obj, IndSrc, RA, Dec, Args.outputDir);
                end
                
                % Append to the report
                if Args.Report
                    appendToReport(Rpt, ch1, Obj, Cand{Icand}, Flag, RA, Dec, Args);
                end
            end
        end
    end
end

% ----------- Sub-functions --------------
function Cand = createCandidateStruct(IndSrc, Ncand, Flag, Summary, Obj, RA, Dec)
    Cand.IndSrc = IndSrc;
    Cand.NcandInSubImage = Ncand;
    Cand.Flag = Flag;
    Cand.MS = Obj.MS;
    Cand.FlagGood = Flag.FlagGood(IndSrc);
    Cand.FlagPS = Flag.PS(IndSrc);
    Cand.FlagRMS = Flag.RMS(IndSrc);
    Cand.FlagPoly = Flag.Poly(IndSrc);
    Cand.MaxPS = Summary.MaxPS(IndSrc);
    Cand.MaxFreq = Summary.MaxFreq(IndSrc);
    Cand.RA = RA;
    Cand.Dec = Dec;
end

function plotCandidate(Obj, IndSrc, RA, Dec,dirPath)
    % Plot light curve, RMS, and power spectrum for the candidate
    figureHandle = figure('Units', 'Inches', 'Position', [0, 0, 6, 4]); 
    FigLC = Obj.plotLC(IndSrc);
    FigRMS = Obj.plotRMS(IndSrc, 'NsigmaPredRMS', 7);
    H = gca;
    H.YLim(1) = 1e-3;
    [FigPS, FigPh] = Obj.plotPS(IndSrc);
    
    % Save figures
    createDirIfNotExists(dirPath)
    
    filename = sprintf('%.6f_%.6f_IND_%i.png', RA, Dec, IndSrc);
    saveas(FigLC, fullfile(dirPath,filename));
end

function AbsMag = calcAbsMag(Obj, RA, Dec)
    % Calculate absolute magnitude
    PWD = pwd;
    cd('~/marvin/catalogs/GAIA/DR3/');
    AC = catsHTM.cone_search('GAIADR3', RA, Dec, 3, 'OutType', 'AstroCatalog');
    cd(PWD);
    
    AbsMag = AC.Table.phot_bp_mean_mag - (5 * log10(1000 ./ AC.Table.Plx) - 5);
end

function Color = calcColor(Obj, RA, Dec)
    % Calculate color
    PWD = pwd;
    cd('~/marvin/catalogs/GAIA/DR3/');
    AC = catsHTM.cone_search('GAIADR3', RA, Dec, 3, 'OutType', 'AstroCatalog');
    cd(PWD);
    
    Color = AC.Table.phot_bp_mean_mag - AC.Table.phot_rp_mean_mag;
end



% ----------- Sub-functions 2 --------------

function [Rpt, ch1] = initializeReport(outputDir)
    % Initialize a PDF report if not already initialized
    import mlreportgen.report.*;
    import mlreportgen.dom.*;
    
    reportFileName = fullfile(outputDir, 'Variable_Candidates_Report.pdf');
    Rpt = Report(reportFileName, 'pdf');
    
    % Create title page and table of contents
    tp = TitlePage;
    tp.Title = 'Variable Candidates Report';
    tp.Author = 'Yarin Shani';
    append(Rpt, tp);
    append(Rpt, TableOfContents);
    
    % Create the first chapter for the report
    ch1 = Chapter;
    ch1.Title = 'Variable Candidates';
end

function appendToReport(Rpt, ch1, Obj, Cand, Flag, RA, Dec, Args)
    % Append a new section for each candidate
    import mlreportgen.report.*;
    import mlreportgen.dom.*;
    
    sec1 = Section;
    FlagsType = sprintf('%d %d %d %d', Flag.PS(Cand.IndSrc), Flag.RMS(Cand.IndSrc), Flag.Poly(Cand.IndSrc), Flag.RunMeanFilt(Cand.IndSrc));
    sec1.Title = sprintf('RA=%.6f Dec=%.6f - Flags: %s', RA, Dec, FlagsType);
    
    % Add candidate details
    AbsMag = calcAbsMag(Obj, RA, Dec);
    Color = calcColor(Obj, RA, Dec);
    para = Text(sprintf('RA=%.6f Dec=%.6f\n AbsMag=%.2f Color=%.2f\n', RA, Dec, AbsMag, Color));
    append(sec1, para);
    
    % Generate links and append
    [simbadLink, SDSSLink] = WDtransits3.generateURLs(RA, Dec, 180/pi);
    paraLinks = Text(sprintf('Simbad: %s\nSDSS: %s', simbadLink.URL, SDSSLink{1}));
    append(sec1, paraLinks);
    
    % Add the figure to the report
    fig = Figure(gcf);
    fig.Snapshot.Height = '4in';
    fig.Snapshot.Width = '6in';
    append(sec1, fig);
    
    % Append the section to the chapter
    append(ch1, sec1);
end

function finalizeReport()
    % Finalize and close the report once all sections have been appended
    persistent Rpt ch1 reportInitialized;
    
    if reportInitialized
        append(Rpt, ch1);  % Append chapter to the report
        close(Rpt);  % Close and save the report
        disp('PDF Report finalized and saved.');
        
        % Clear persistent variables
        reportInitialized = [];
        Rpt = [];
        ch1 = [];
    end
end
