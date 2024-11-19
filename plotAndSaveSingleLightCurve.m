function plotAndSaveSingleLightCurve(results, lcData, saveDir, wdSources, Iwd)
    % Helper function to plot a single light curve and save it
    
    % Create a new figure
    figure();
    
    % Plot the light curve
    plotLightCurve3({results}, 1, 1, lcData, results.res.Methods, lcData.relFlux, results.res.FluxMethods,wdSources(Iwd,:));
    axis tight;
    % Retrieve RA and Dec for naming purposes
    RA = wdSources.RA(Iwd);
    Dec = wdSources.Dec(Iwd);
    
    % Generate filename with RA and Dec in the name
    filename = sprintf('%sRA_%.6f_Dec_%.6f_Observation_%d_LC.png', saveDir, RA, Dec, Iwd);
    
    % Save the figure
    saveas(gcf, filename);
    
    % Save relevant data as .mat file
    dataFile = sprintf('%sRA_%.6f_Dec_%.6f_Observation_%d_NoCat_Info.mat', saveDir, RA, Dec, Iwd);
    save(dataFile, 'results', 'lcData');
end