function [Cand, WDcand, WDtable, CandidateTable] = findVariableCandidatesTable(ms, Args)
    % Function to find variable candidates and store results in a table
    % Arguments:
    %   ms - Main data object containing MS and other information
    %   Args - Structure with optional fields:
    %       MinDet    - Minimum detection threshold
    %       RAField   - Field name for Right Ascension data
    %       DecField  - Field name for Declination data
    %       MagField  - Field name for Magnitude data
    %       Plot      - Boolean, if true, plot results
    % Outputs:
    %   Cand           - Structure array of candidates
    %   WDcand         - Structure array of white dwarf candidates
    %   FlagComb       - Combined logical array indicating candidate sources
    %   CandidateTable - Table with details of detected candidates

    arguments
        ms
        Args.MinDet (1,1) double = ms.Nepoch - 0.15 * ms.Nepoch;
        Args.RAField (1,:) char = 'RA';
        Args.DecField (1,:) char = 'Dec';
        Args.MagField (1,:) char = 'Mag';
        Args.Plot (1,1) logical = false;
        Args.thresholdRMF (1,1) double = 5.5;
    end

    Obj = pipeline.last.SearchMatchedSources;
  %  ms.bestMag;
    Obj.MS = ms;
    
    % Perform initial checks with different window sizes
    FlagComb = false(ms.Nsrc, 1);

    %doc.PS   = false(ms.Nsrc, 1);
    %doc.RMS  = false(ms.Nsrc, 1);
    %doc.Poly = false(ms.Nsrc, 1);
    %doc.RMF  = false(ms.Nsrc, 1);
    %for winSize = 2:6
        [Flag, FlagInfo,summary] = findVariableMS2(Obj, 'thresholdRMF', Args.thresholdRMF);
        FlagComb = FlagComb | (FlagInfo.N(:) >= Args.MinDet & Flag.FlagGood(:) & ...
                  (Flag.PS(:) | Flag.RMS(:) | Flag.Poly(:) | Flag.RunMeanFilt(:)));
     
        %doc.PS   = doc.PS | Flag.PS(:);
        %doc.RMS  = doc.RMS | Flag.RMS(:);
        %doc.Poly = doc.Poly | Flag.Poly(:);
        %doc.RMF  = doc.RMF | Flag.RunMeanFilt(:);
    %end

    Cand = struct([]);
    WDcand = struct([]);
    WDtable = table();
    CandidateTable = table([], [], [], [], [], [], ...
        'VariableNames', {'RA', 'Dec', 'AbsMag', 'Color', 'IsWD', 'Pwd'});

    if any(FlagComb)
        IndCand = find(FlagComb);
        for IndSrc = IndCand'
            %[FlagGood, ResPhotAstCorr] = flagCorr(Obj, IndSrc,'PosProbThresh',0.999);
            FlagGood = true;
            if FlagGood
                RA = median(Obj.MS.Data.(Args.RAField)(:, IndSrc), 1, 'omitnan');
                Dec = median(Obj.MS.Data.(Args.DecField)(:, IndSrc), 1, 'omitnan');

                % Check if in White Dwarf (WD) catalog
                WD = isWD(Obj, RA, Dec);
                try
                    IsWD = ~isempty(WD.Table);
                catch
                    IsWD = false;
                end
                
                
                if IsWD
                    Pwd = IsWD * WD.Table.Pwd;
                else
                    Pwd = 0;
                end

                AbsMag = nan;
                Color = nan;
                %Color = calcColor(Obj, RA, Dec);

                % Store in table
                CandidateTable = [CandidateTable; {RA, Dec, AbsMag, Color, IsWD, Pwd}];
                
                % Plot light curve, RMS, and power spectrum for the candidate
                if Args.Plot
                    figureHandle = figure('Units', 'Inches', 'Position', [0, 0, 6, 4]); 
                    FigLC = Obj.plotLC(IndSrc);
                    xlabel(sprintf('Time [min] (Pwd = %.3f)',Pwd))
                    FigRMS = Obj.plotRMS(IndSrc, 'NsigmaPredRMS', 7);
                    xlabel(sprintf('Mag ; Std from Median = %.2f', summary.ResRMS.NsigmaStd(IndSrc)))
                    H = gca;
                    H.YLim(1) = 1e-3;
                    [FigPS, FigPh] = Obj.plotPS(IndSrc);
                    xlabel(sprintf('Max PS = %.2f', summary.MaxPS(IndSrc)))

                end
                % Store in structures for further processing if needed
                if IsWD
                    [AbsMag,Color] = calcAbsMagNColor(Obj, RA, Dec);
                    WDcand{end + 1} = createCandidateStruct(IndSrc, numel(IndCand),Flag, summary, RA, Dec, AbsMag, Color, Pwd,ms);
                    WDtable = [WDtable;WD.Table];
                    Cand{end + 1} = createCandidateStruct(IndSrc, numel(IndCand),Flag, summary, RA, Dec, AbsMag, Color, Pwd,ms);
                else
                    Cand{end + 1} = createCandidateStruct(IndSrc, numel(IndCand),Flag, summary, RA, Dec, AbsMag, Color, Pwd,ms);
                end
            end
        end
    end
end

% Helper functions


function [AbsMag,Color] = calcAbsMagNColor(Obj, RA, Dec)
    % Calculate color
    PWD = pwd;
    cd('~/marvin/catsHTM/GAIA/DR3/')
    AC = catsHTM.cone_search('GAIADR3', RA * pi / 180, Dec * pi / 180, 3, 'OutType', 'AstroCatalog');
    if height(AC.Table) == 1
        AbsMag = AC.Table.phot_g_mean_mag - (5 * log10(1000 ./ AC.Table.Plx) - 5);
        Color = AC.Table.phot_bp_mean_mag - AC.Table.phot_rp_mean_mag;
    elseif height(AC.Table) > 1
        ac.Table = AC.Table(1,:);
        AbsMag = ac.Table.phot_g_mean_mag - (5 * log10(1000 ./ ac.Table.Plx) - 5);
        Color = ac.Table.phot_bp_mean_mag - ac.Table.phot_rp_mean_mag;

    else
        AbsMag = 0;
        Color = 0;

    end
    
    cd(PWD)
end

function Cand = createCandidateStruct(IndSrc, Ncand,Flag,summary, RA, Dec, AbsMag, Color, Pwd,ms)
    Cand.RA = RA;
    Cand.Dec = Dec;
    Cand.CropID = ms.UserData.CropID;
    Cand.IndSrc = IndSrc;
    Cand.NcandInSubImage = Ncand;
    Cand.Pwd = Pwd;
    Cand.AbsMag = AbsMag;
    Cand.BpRp = Color;
    Cand.RMF = Flag.RunMeanFilt(IndSrc);
    Cand.RMS = Flag.RMS(IndSrc);
    Cand.PS = Flag.PS(IndSrc);
    Cand.Poly = Flag.Poly(IndSrc);
    Cand.MaxPS = summary.MaxPS(IndSrc);
    Cand.MaxFreq = summary.MaxFreq(IndSrc);
    Cand.RMSNsigma = summary.ResRMS.NsigmaStd(IndSrc);
    %Cand.resPoly = summary.ResPolyHP;
    %Cand.resRMS = summary.ResRMS;
    Cand.maxRMF = max(abs(summary.RMF.Z(:,IndSrc)));
    %Cand.resRMF = summary.RMF;
    Cand.FileNames = {ms.FileName};
    Cand.JD        = ms.JD;
    Cand.MAG_PSF   = ms.Data.MAG_PSF(:,IndSrc);
    %Cand.MAGERR_PSF = ms.Data.MAGERR_PSF(:,IndSrc);
    Cand.MAG_APER_3 = ms.Data.MAG_APER_3(:,IndSrc);
    %Cand.MAGERR_APER_3 = ms.Data.MAGERR_APER_3(:,IndSrc);
    Cand.FreqVec = summary.FreqVec;
    Cand.PSfull = summary.PS(:,IndSrc);

   
    
    
end
