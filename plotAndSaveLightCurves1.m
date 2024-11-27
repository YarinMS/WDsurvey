function plotAndSaveLightCurves1(results, lcData, resCat, lcDataCat, saveDir, wdSources, Iwd)
    % Helper function to plot two light curves on top of each other and save them
    
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
    filename = sprintf('%sRA_%.6f_Dec_%.6f_Observation_%d_LC.png', saveDir, RA, Dec, Iwd);
    
    % Save the figure
    saveas(gcf, filename);
    
    % Save relevant data as .mat file
    dataFile = sprintf('%sRA_%.6f_Dec_%.6f_Observation_%d_Info.mat', saveDir, RA, Dec, Iwd);
    save(dataFile, 'results', 'lcData', 'resCat', 'lcDataCat');
end