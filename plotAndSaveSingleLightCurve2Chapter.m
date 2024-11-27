function plotAndSaveSingleLightCurve2Chapter(results, lcData, saveDir, wdSources, Iwd,chapter, Args)


    % Helper function to plot a single light curve and save it
    arguments
        results
        lcData
        saveDir
        wdSources
        Iwd
        chapter
        Args.catRMS =[];
        Args.forcedRMS = [];
    end

    import mlreportgen.report.*
    import mlreportgen.dom.*
    % Create a new figure
    figure();
    
    % Plot the light curve
    plotLightCurve3({results}, 1, 1, lcData, results.res.Methods, lcData.relFlux, results.res.FluxMethods,wdSources(Iwd,:));
    %axis tight;
    
    % Retrieve RA and Dec for naming purposes
    RA = wdSources.RA(Iwd);
    Dec = wdSources.Dec(Iwd);
    
    % Generate filename with RA and Dec in the name
    filename = sprintf('%s/%s_%s_%s_RA_%.6f_Dec_%.6f_Observation_%d_LC.png', saveDir,lcData.Tel,lcData.Date,lcData.Table.FieldID, RA, Dec, Iwd);
    
    % Save the figure
    saveas(gcf, filename);
    close;

    wdParagraph = Paragraph();
        wdParagraph.Style = {FontSize('12pt')}; % Optional: Adjust font size

        append(wdParagraph, Text('WD Parameters:'));
        append(wdParagraph, LineBreak());
        add(chapter, wdParagraph);
        wdParagraph = Paragraph();
        wdParagraph.Style = {FontSize('11pt')};
        append(wdParagraph, Text(sprintf('RA: %.3f, Dec: %.3f', RA, Dec)));
        append(wdParagraph, LineBreak());
        %
        add(chapter, wdParagraph);
        wdParagraph = Paragraph();
        wdParagraph.Style = {FontSize('11pt')};
        append(wdParagraph, Text('G: '));
        append(wdParagraph, Text(sprintf('%.2f', wdSources.Gmag(Iwd))));
        append(wdParagraph, LineBreak());
        append(wdParagraph, Text('B_p: '));
        append(wdParagraph, Text(sprintf('%.2f',  wdSources.BPmag(Iwd))));
        append(wdParagraph, Text(', R_p: '));
        append(wdParagraph, Text(sprintf('%.2f', wdSources.RPmag(Iwd))));
        append(wdParagraph, LineBreak());
        append(wdParagraph, Text(' Color: '));
        append(wdParagraph, Text(sprintf('%.2f',   wdSources.BPmag(Iwd)-wdSources.RPmag(Iwd))));
        append(wdParagraph, LineBreak());
        add(chapter, wdParagraph);
        wdParagraph = Paragraph();
        wdParagraph.Style = {FontSize('11pt')};

        append(wdParagraph, Text(sprintf('Plx: %.2f mas, Abs G: %.2f', wdSources.Plx(Iwd), lcData.Table.AbsMag(Iwd))));
        append(wdParagraph, LineBreak());
        add(chapter, wdParagraph);
        wdParagraph = Paragraph();
        wdParagraph.Style = {FontSize('11pt')};
        append(wdParagraph, Text(sprintf('Field ID: %s',  wdSources.FieldID(Iwd))));
        append(wdParagraph, LineBreak());
        append(wdParagraph, Text(sprintf('Telescope ID: %s', lcData.Tel)));
        append(wdParagraph, LineBreak());
        append(wdParagraph, Text(sprintf('Visit ID: %s',lcData.Date)));

    
        % Append the paragraph to the chapter
        add(chapter, wdParagraph);

        % --- Add a SIMBAD query link ---
        simbadQuery = sprintf('http://simbad.u-strasbg.fr/simbad/sim-coo?Coord=%.6f+%.6f&Radius=1&Radius.unit=arcmin', RA, Dec);
        simbadLink = ExternalLink(simbadQuery, 'SIMBAD Query (1 arcmin around RA/Dec)');
        add(chapter, Paragraph(simbadLink));



    img = Image(filename);
    img.Style = {ScaleToFit(true), Width('100%')};
    %img.width = '5in';
    %img.height = '7in';
    add(chapter,img);


    % RMS plots
    if ~isempty(Args.catRMS)
        
        plotRMS2(lcData,lcData.Ind,'ResRMS',Args.catRMS,'SubPlot',false)
        filename = sprintf('%s/%s_%s_%s_RA_%.6f_Dec_%.6f_Observation_%d_RMS.png', saveDir,lcData.Tel,lcData.Date,lcData.Table.FieldID, RA, Dec, Iwd);
    
        % Save the figure
        saveas(gcf, filename);
        close;
        add(chapter,Paragraph('Catalogs RMS :'))
        img = Image(filename);
        img.Style = {ScaleToFit(true), Width('100%')};
        add(chapter,img);
    end

    if ~isempty(Args.forcedRMS)
        
        plotRMS2(lcData,1,'ResRMS',Args.forcedRMS,'SubPlot',false)
        filename = sprintf('%s/%s_%s_%s_RA_%.6f_Dec_%.6f_Observation_%d_RMS.png', saveDir,lcData.Tel,lcData.Date,lcData.Table.FieldID, RA, Dec, Iwd);
    
        % Save the figure
        saveas(gcf, filename);
        close;
        add(chapter,Paragraph('Forced Photometry RMS :'))
        img = Image(filename);
        img.Style = {ScaleToFit(true), Width('100%')};
        add(chapter,img);
    end

    add(chapter,PageBreak());

    
   % dataFile = sprintf('%sRA_%.6f_Dec_%.6f_Observation_%d_NoCat_Info.mat', saveDir, RA, Dec, Iwd);
   % save(dataFile, 'results', 'lcData');
end