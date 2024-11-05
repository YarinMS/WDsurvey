function [Cand, WDcand, FlagComb,resultChapter] = findVariableCandidates3(ms, Args)
    % Function to find variable candidates based on criteria in FlagInfo
    % Arguments:
    %   ms - Main data object containing MS and other information
    %   Args - Structure with fields:
    %       MinDet    - Minimum detection threshold
    %       RAField   - Field name for Right Ascension data
    %       DecField  - Field name for Declination data
    %       MagField  - Field name for Magnitude data
    %       Plot      - Boolean, if true, plot results
    %   catalogChapter - Chapter object to append report details into
    % Outputs:
    %   Cand      - Structure array of candidates
    %   FlagComb  - Combined logical array indicating which sources are candidates

    arguments
        ms
        Args.MinDet (1,1) double = ms.Nepoch - 0.15*ms.Nepoch;
        Args.RAField (1,:) char = 'RA'
        Args.DecField (1,:) char = 'Dec'
        Args.MagField (1,:) char = 'Mag'
        Args.Plot (1,1) logical = false
        Args.Report (1,1) logical = false
        Args.thresholdRMF (1,1) double = 5.5;
        Args.winSizeRMF (1,1) double = 2;
        Args.args
        Args.catalogChapter = {};
    end
    
    Obj = pipeline.last.SearchMatchedSources;
    Obj.MS = ms;
    
    % Initial check
    [Flag, FlagInfo, Summary] = findVariableMS2(Obj,'thresholdRMF',Args.thresholdRMF,'winSizeRMF',2);
    FlagComb0 = FlagInfo.N(:) >= Args.MinDet & Flag.FlagGood(:) & ...
               (Flag.PS(:) | Flag.RMS(:) | Flag.Poly(:) | Flag.RunMeanFilt(:));

    [Flag1, FlagInfo1, Summary1] = findVariableMS2(Obj,'thresholdRMF',Args.thresholdRMF,'winSizeRMF',3);
    FlagComb1 = FlagInfo1.N(:) >= Args.MinDet & Flag1.FlagGood(:) & ...
               (Flag1.PS(:) | Flag1.RMS(:) | Flag1.Poly(:) | Flag1.RunMeanFilt(:));

    [Flag2, FlagInfo2, Summary2] = findVariableMS2(Obj,'thresholdRMF',Args.thresholdRMF,'winSizeRMF',4);
    FlagComb2 = FlagInfo2.N(:) >= Args.MinDet & Flag2.FlagGood(:) & ...
               (Flag2.PS(:) | Flag2.RMS(:) | Flag2.Poly(:) | Flag2.RunMeanFilt(:));

    [Flag3, FlagInfo3, Summary3] = findVariableMS2(Obj,'thresholdRMF',Args.thresholdRMF,'winSizeRMF',5);
    FlagComb3 = FlagInfo3.N(:) >= Args.MinDet & Flag3.FlagGood(:) & ...
               (Flag3.PS(:) | Flag3.RMS(:) | Flag3.Poly(:) | Flag3.RunMeanFilt(:));


    FlagComb  = FlagComb0 | FlagComb1 | FlagComb2 | FlagComb3 ;  
    flag.FlagGood = Flag.FlagGood | Flag1.FlagGood | Flag2.FlagGood | Flag3.FlagGood ;
    flag.PS = Flag.PS | Flag1.PS | Flag2.PS | Flag3.PS ;
    flag.RMS = Flag.RMS | Flag1.RMS | Flag2.RMS | Flag3.RMS ;
    flag.Poly = Flag.Poly | Flag1.Poly | Flag2.Poly | Flag3.Poly ;
    flag.RunMeanFilt = Flag.RunMeanFilt | Flag1.RunMeanFilt | Flag2.RunMeanFilt | Flag3.RunMeanFilt ;

    Cand = struct([]);
    WDcand = struct([]);
    
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
                RA = median(Obj.MS.Data.(Args.RAField)(:, IndSrc), 1, 'omitnan');
                Dec = median(Obj.MS.Data.(Args.DecField)(:, IndSrc), 1, 'omitnan');
                
                % Check if in WD catalog.
                WD = isWD2(Obj, RA, Dec);
                if ~isempty(WD.Table)
                    Iwd = Iwd + 1;
                    WDcand{Iwd} = createCandidateStruct(IndSrc, Ncand, flag, Summary, Obj, RA, Dec);
                    WDcand{Iwd}.WD = WD;
                    % Append details to the chapter - ***
                    if ~isempty(Args.catalogChapter)
                          Args.WD = true;
                          Args.WDtable = WD.Table;
                          appendToReport(Args.catalogChapter, Obj, WDcand{Iwd}, flag, RA, Dec, Args.args);
                          plotCandidateAndAppend(Obj, IndSrc, RA, Dec, Args.catalogChapter,Args);
                     
                          resultChapter = Args.catalogChapter;
                    end
                else
                    Icand = Icand + 1;
                    Cand{Icand} = createCandidateStruct(IndSrc, Ncand, flag, Summary, Obj, RA, Dec);
            
                    Args.WD = false;
                    % Append details to the chapter - ***
                    if ~isempty(Args.catalogChapter)
                          appendToReport(Args.catalogChapter, Obj, Cand{Icand}, flag, RA, Dec, Args);
                          plotCandidateAndAppend(Obj, IndSrc, RA, Dec, Args.catalogChapter,Args.args);
                     
                          resultChapter = Args.catalogChapter;
                    end
                end 
                % Plot if required and append images to chapter
                if Args.Plot
                   
                end
            else
                resultChapter = Args.catalogChapter;
            end
            
        end
    else
        resultChapter =  Args.catalogChapter;
    end
end




%%%% Helper functions
function plotCandidateAndAppend(Obj, IndSrc, RA, Dec, chapter,Args)
    import mlreportgen.dom.*
    import mlreportgen.report.*
    
    % Create a temporary directory for saving plots
    %f = figure('Visible', 'off');
    
    % Plot light curve, RMS, 
    figLC  = plotLC(Obj, IndSrc);
    figRMS = plotRMS(Obj, IndSrc, 'NsigmaPredRMS', 7);
   
     % Define the file path where the plot will be saved
       % plotFile = fullfile(Args.saveDir, sprintf('plotnow_Subframe_%s_Plot.png', IndSrc));

        % Save the figure
        %saveas(f, plotFile);

        % Create the image for the report with specified dimensions
        %img = Image(plotFile);
        %img.Style = {Height('4in'), Width('6in')};  % Set both height and width to control scaling

        % Append the image to the report section
        %append(chapter, img);
        %close(f)
        % Delete the image file after it has been added to the report
        %delete(plotFile);
        
        % Capture the figure as a frame
    % Use mlreportgen.report.Figure to capture the current figure
    fig = Figure(gcf);
    fig.Snapshot.Height = '5in';
    fig.Snapshot.Width = '7in';

    % Append the figure directly to the report chapter
    append(chapter, fig);
    %close all;  % Close the figure after appending

    pageBreak = PageBreak();
    append(chapter, pageBreak);
  
    
    % Save the figures as PNGs
    
   
    % Clean up temporary directory
    %close(gcf)
   
end


function sec1 = appendToReport(ch1, Obj, Cand, Flag, RA, Dec, Args)
    import mlreportgen.report.*;
    import mlreportgen.dom.*;
    
    sec1 = Section;
     % Define the text that will be displayed in the paragraph
    FlagsType = sprintf('PS: %d, RMS: %d, Poly: %d, RMF: %d', ...
                        Flag.PS(Cand.IndSrc), Flag.RMS(Cand.IndSrc), ...
                        Flag.Poly(Cand.IndSrc), Flag.RunMeanFilt(Cand.IndSrc));

    if ~Args.WD

        sec1.Title = sprintf('RA = %.3f Dec = %.3f', RA, Dec);

    else
        sec1.Title = sprintf('RA = %.3f Dec = %.3f Pwd = %.4f', RA, Dec, Args.WDtable.Pwd);
    end
    
    AbsMag = calcAbsMag(Obj, RA, Dec);
    Color = calcColor(Obj, RA, Dec);
    
    para = Text(sprintf('RA=%.6f Dec=%.6f\n AbsMag=%.2f Color=%.2f\n', RA, Dec, AbsMag, Color));
    append(sec1, para);
    % append(sec1,Paragraph(FlagsType))

    [simbadLink, ~] = WDtransits3.generateURLs(RA, Dec, 180/pi);

     % Use Hyperlink instead of ExternalLink
  %  link = ExternalLink(simbadLink.URL,'Simbad Link');  % Create the hyperlink
  %  append(link, Text('Simbad Link'));  % Set the display text of the link
    %par1 = Paragraph();
    % Insert the link into a paragraph and add to the chapter
   % append(par1, Paragraph(link));

    insertLinkToChapter(sec1,simbadLink.URL,'Simbad Link');

 
    % Flag if WD
    if Args.WD
        
    % Create the section and the formatted paragraph
    paraWD = Paragraph();
    
    % Create and format the text for the Pwd value
    highlightedText = Text(sprintf('Pwd = %.4f', Args.WDtable.Pwd));
    highlightedText.Bold = true;         % Make text bold
    highlightedText.Color = '#FF8C00';       % Change text color to red
    highlightedText.FontSize = '14pt';   % Increase font size
    
    % Append the formatted text to the paragraph and add it to the section
    append(paraWD, highlightedText);
    append(sec1, paraWD);
  


    end
    append(ch1, sec1);
end




%%% to delete
function appendCandidateToReport(chapter, Obj, Cand, Flag, RA, Dec, Args)
    import mlreportgen.dom.*
    
   % Create a paragraph for the candidate information
    sec1 = Paragraph();  % No Title property needed for Paragraph

    % Define the text that will be displayed in the paragraph
    FlagsType = sprintf('PS: %d, RMS: %d, Poly: %d, RMF: %d', ...
                        Flag.PS(Cand.IndSrc), Flag.RMS(Cand.IndSrc), ...
                        Flag.Poly(Cand.IndSrc), Flag.RunMeanFilt(Cand.IndSrc));
    paraText = sprintf('Flags: %s\n', RA, Dec, FlagsType);

    % Add the text to the paragraph
    append(sec1, paraText);
     
    AbsMag = calcAbsMag(Obj, RA, Dec);
    Color = calcColor(Obj, RA, Dec);
    
    % Add candidate details
    para = Paragraph(sprintf('RA=%.6f Dec=%.6f\n AbsMag=%.2f Color=%.2f\n', RA, Dec, AbsMag, Color));
    append(sec1, para);
    
    % Append candidate section to the chapter
    append(chapter, sec1);
end
%^^^^^ delete



% ---------- Helper funciton 1st edition
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


function AbsMag = calcAbsMag(Obj, RA, Dec)
    % Calculate absolute magnitude
    PWD = pwd;
    %cd('~/marvin/catalogs/GAIA/DR3/');
    AC = catsHTM.cone_search('GAIADR3', RA*pi./180, Dec*pi./180, 3, 'OutType', 'AstroCatalog');
    cd(PWD);
    
    AbsMag = AC.Table.phot_g_mean_mag - (5 * log10(1000 ./ AC.Table.Plx) - 5);
end

function Color = calcColor(Obj, RA, Dec)
    % Calculate color
    PWD = pwd;
    %cd('~/marvin/catalogs/GAIA/DR3/');
    AC = catsHTM.cone_search('GAIADR3', RA*pi./180, Dec*pi./180, 3, 'OutType', 'AstroCatalog');
    cd(PWD);
    
    Color = AC.Table.phot_bp_mean_mag - AC.Table.phot_rp_mean_mag;
end


% ----- Ploting funciton imported from SearchMatchedSources (Eran Ofek) and
% modified
        function Fig=plotLC(Obj, IndSrc, Args)
            %

            arguments
                Obj
                IndSrc
                Args.MS                    = []; 

                Args.SubPlot logical       = true;
                Args.FigN                  = 1;
                Args.MagField              = 'MAG_BEST';
                Args.UnitsTime             = 'day';
                Args.DispUnitsTime         = 'min';
                Args.SubT0 logical         = true;

                Args.BD                    = BitDictionary;
                Args.FlagsField            = 'FLAGS';
                Args.DefaultSymbol         = {'ko-','MarkerFaceColor','k','MarkerSize',4};
                Args.ListFlags             = {'Saturated',{'b^'}; ...
                                              'NaN',{'r>'}; ...
                                              'Negative',{'rv'}; ...
                                              'CR_DeltaHT',{'b<'}};

            end
            

            figure('Visible', 'off');

            if ~isempty(Args.MS)
                Obj.MS = Args.MS;
            end
            
            JD = Obj.MS.JD;
            if Args.SubT0
                JD = JD - min(JD);
            end
            Time = convert.timeUnits(Args.UnitsTime, Args.DispUnitsTime, JD);

            if Args.SubPlot
                subplot(2,1, Args.FigN);
                Fig = Args.FigN;
                cla;
                box on;
            else
                Fig=figure(Args.FigN);
                cla;
                box on;
            end

            Nflag = size(Args.ListFlags,1);
            FlagPlot = false(Obj.MS.Nepoch, Nflag);
            for Iflag=1:1:Nflag
                VecFlag = Obj.MS.Data.(Args.FlagsField)(:,IndSrc);
                VecFlag(isnan(VecFlag)) = 0;
                FlagPlot(:,Iflag) = Args.BD.findBit(VecFlag, Args.ListFlags(Iflag,1), 'Method','any');

                plot(Time(FlagPlot(:,Iflag)), Obj.MS.Data.(Args.MagField)(FlagPlot(:,Iflag),IndSrc))
                hold on;

            end

            FlagG = all(~FlagPlot, 2);
            plot(Time(FlagG), Obj.MS.Data.(Args.MagField)(FlagG,IndSrc), Args.DefaultSymbol{:});

            
            %plot(Time, Obj.MS.Data.(Args.MagField)(:,IndSrc))
            plot.invy;

            H = xlabel(sprintf('Time [%s]',Args.DispUnitsTime));
            H.FontSize = 14;
            H.Interpreter = 'latex';
            H = ylabel('Magnitude');
            H.FontSize = 14;
            H.Interpreter = 'latex';

            hold off;


        end

        function Fig=plotRMS(Obj, IndSrc, Args)
            %

            arguments
                Obj
                IndSrc

                Args.SubPlot logical  = true;
                Args.FigN    = 2;
                Args.ResRMS  = [];

                Args.MagField              = 'MAG_BEST';
                
                Args.NsigmaPredRMS         = 5;
                Args.MinDetRMS             = 15;
            end

            if isempty(Args.ResRMS)
                ResRMS   = Obj.MS.rmsMag('MagField',Args.MagField, 'MinDetRmsVar',Args.MinDetRMS, 'NsigmaPred',Args.NsigmaPredRMS);
            else
                ResRMS = Args.ResRMS;
            end

            if Args.SubPlot
                subplot(2,1, Args.FigN);
                Fig = Args.FigN;
                cla;
                box on;
            else
                Fig=figure(Args.FigN)
                cla;
                box on;
            end
            %MS.plotRMS;
         
            semilogy(ResRMS.MeanMag, ResRMS.StdPar, '.', 'Color', [0.5, 0.5, 0.5], 'MarkerSize', 7);  % Dark grey
            alpha(0.5);  % Set opacity to 0.5 (only applies if this figure supports transparency)
            
            hold on
            
            % Sort the data by MeanMag and plot a burnt orange thicker line
            [~, SI] = sort(ResRMS.MeanMag);
            semilogy(ResRMS.MeanMag(SI), ResRMS.InterpMeanStd(SI), '-', 'Color', [0, 0, 0.5], 'LineWidth', 1.25);  % Burnt orange color, thicker line
            
            % Plot the InterpMeanStd + InterpPredStd with navy blue thicker dashed line
            semilogy(ResRMS.MeanMag(SI), ResRMS.InterpMeanStd(SI) + ResRMS.InterpPredStd(SI) .* Args.NsigmaPredRMS, '--', ...
                'Color',[0.8, 0.33, 0.0] , 'LineWidth', 1.25);  % Navy blue, thicker dashed line
            
            % Plot the data point for IndSrc in dark red
            plot(ResRMS.MeanMag(IndSrc), ResRMS.StdPar(IndSrc), '.', 'Color',  [255, 160, 122]./255, 'MarkerSize', 14);  % Dark red marker
            axis tight;
            % Adjust axis labels
            H = xlabel('Magnitude');
            H.FontSize = 14;
            H.Interpreter = 'latex';
            
            H = ylabel('RMS [mag]');
            H.FontSize = 14;
            H.Interpreter = 'latex';
            
            % Add a legend with 'RMS' for the grey points
            legend({'RMS', 'Interp Mean Std', 'Predicted Std', 'Source'}, 'FontSize', 8, 'Interpreter', 'latex', 'Location', 'best');

            hold off;
        end






function insertLinkToChapter(chapter, linkURL, linkText)
    % Insert a hyperlink into a report chapter
    import mlreportgen.dom.*;  % Ensure the required class is imported
    
    link = ExternalLink(linkURL, linkText);  % Create the external link
    append(chapter, Paragraph(link));  % Insert it into a paragraph and add to chapter
end

