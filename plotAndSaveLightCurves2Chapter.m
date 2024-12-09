function plotAndSaveLightCurves2Chapter(results, lcData, resCat, lcDataCat, saveDir, wdSources, Iwd,chapter,Args)

    arguments 
    results
    lcData
    resCat
    lcDataCat
    saveDir
    wdSources   
    Iwd
    chapter
    Args.catRMS = [];
    Args.forcedRMS =[];

    end
    % Helper function to plot two light curves on top of each other and save them
    import mlreportgen.report.*
    import mlreportgen.dom.*
    % Create a new figure
    figure();
    
    % Plot the first light curve (results)
    WDtransits3.plotLightCurve({results}, 1, 1, lcData, results.res.Methods, lcData.relFlux, results.res.FluxMethods);
    hold on;
    
    % Plot the catalog light curve
    plotLightCurveSpec({resCat}, 1, 1, lcDataCat{1}, resCat.Methods, lcDataCat{1}.relFlux, resCat.FluxMethods);
    hold off;
    %axis tight;
    % Tighten the x-axis only
    
    % Retrieve RA and Dec for naming purposes
    RA = wdSources.RA(Iwd);
    Dec = wdSources.Dec(Iwd);
    
    % Generate filename with RA and Dec in the name
    filename = sprintf('%s/%s_%s_%s_RA_%.6f_Dec_%.6f_Observation_%d_LC.png', saveDir,lcData.Tel,lcData.Date,lcData.Table.FieldID, RA, Dec, Iwd);
    
    % Save the figure
    saveas(gcf, filename);
    close;

   % Add WD parameters

        wdParagraph = Paragraph();
        wdParagraph.Style = {FontSize('12pt')}; % Optional: Adjust font size

        append(wdParagraph, Text('WD Parameters:'));
        append(wdParagraph, LineBreak());
        add(chapter, wdParagraph);
        wdParagraph = Paragraph();
        wdParagraph.Style = {FontSize('11pt')};
        append(wdParagraph, Text(sprintf('RA: %.6f, Dec: %.6f', RA, Dec)));
        append(wdParagraph, LineBreak());
        %
        add(chapter, wdParagraph);
        wdParagraph = Paragraph();
        wdParagraph.Style = {FontSize('11pt')};
        append(wdParagraph, Text('Pwd: '));
        append(wdParagraph, Text(sprintf('%.3f ', wdSources.Pwd(Iwd))));
        append(wdParagraph, Text('G: '));
        append(wdParagraph, Text(sprintf('%.2f ', wdSources.Gmag(Iwd))));
        append(wdParagraph, LineBreak());
        append(wdParagraph, Text('B_p: '));
        append(wdParagraph, Text(sprintf('%.2f ',  wdSources.BPmag(Iwd))));
        append(wdParagraph, Text(', R_p: '));
        append(wdParagraph, Text(sprintf('%.2f ', wdSources.RPmag(Iwd))));
        append(wdParagraph, LineBreak());
        append(wdParagraph, Text(' Color: '));
        append(wdParagraph, Text(sprintf('%.2f ',   wdSources.BPmag(Iwd)-wdSources.RPmag(Iwd))));
        append(wdParagraph, LineBreak());
        add(chapter, wdParagraph);
        wdParagraph = Paragraph();
        wdParagraph.Style = {FontSize('11pt')};

        append(wdParagraph, Text(sprintf('Plx: %.2f mas, Abs G: %.2f ', wdSources.Plx(Iwd), lcData.Table.AbsMag(Iwd))));
        append(wdParagraph, LineBreak());
        add(chapter, wdParagraph);
        wdParagraph = Paragraph();
        wdParagraph.Style = {FontSize('11pt')};
        append(wdParagraph, Text(sprintf('Field ID: %s ',  wdSources.FieldID(Iwd))));
        append(wdParagraph, LineBreak());
        append(wdParagraph, Text(sprintf('Telescope ID: %s ', lcData.Tel)));
        append(wdParagraph, LineBreak());
        append(wdParagraph, Text(sprintf('Visit ID: %s ',lcData.Date)));
        append(wdParagraph, LineBreak());
        append(wdParagraph, Text(sprintf('Crop ID: %i ',lcData.Table.Subframe)));

    
        % Append the paragraph to the chapter
        add(chapter, wdParagraph);

         % --- Add a SIMBAD query link ---
        simbadQuery = sprintf('http://simbad.u-strasbg.fr/simbad/sim-coo?Coord=%.6f+%.6f&Radius=1&Radius.unit=arcmin', RA, Dec);
        simbadLink = ExternalLink(simbadQuery, 'SIMBAD Query (1 arcmin around RA/Dec)');
        add(chapter, Paragraph(simbadLink));
        
    % Add to section WD table with the following parameters: ra,dec,gmag,bp,bp-rp as
    % color,plx, absMag,
    % we also want to insert visit ID from lcData.Date
    % we also want to add a simbad link witht a query of 1 arc min around
    % RA and Dec
    img = Image(filename);
    img.Style = {ScaleToFit(true), Width('100%')};
    %img.width = '5in';
    %img.height = '7in';

    add(chapter,img)
    % RMS plots
    if ~isempty(Args.catRMS)
        
        plotRMS2(lcDataCat{1},lcDataCat{1}.Ind,'ResRMS',Args.catRMS,'SubPlot',false)
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
    
    % Save relevant data as .mat file
    dataFile = sprintf('%sRA_%.6f_Dec_%.6f_Observation_%d_Info.mat', saveDir, RA, Dec, Iwd);
    save(dataFile, 'results', 'lcData', 'resCat', 'lcDataCat');
end