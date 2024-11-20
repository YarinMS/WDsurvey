function visualizeEvents(WDtable, saveDir)
    % VISUALIZEEVENTS scans WDtable for detected events, plots them, and saves the results.
    %
    % Inputs:
    %   WDtable - Table containing WDs and their associated BatchData.
    %   saveDir - Directory to save light curve plots and event data.
    %
    % Outputs:
    %   Saves plots and relevant data for each event detected in BatchData.

    % Ensure the save directory exists
    if ~exist(saveDir, 'dir')
        mkdir(saveDir);
    end

    % Scan through each WD in the WDtable
    for Iwd = 1:height(WDtable)
        % Access BatchData for the current WD
        batchDataArray = WDtable.BatchData{Iwd};

        % Skip if BatchData is empty
        if isempty(batchDataArray)
            continue;
        end

        % Iterate through batches for this WD
        for batchIdx = 1:numel(batchDataArray)
            batchData = batchDataArray{batchIdx};

            % Check if an event is detected in this batch
            if isfield(batchData, 'Event') && batchData.Event
                % Extract light curve data and results
                if isfield(batchData, 'lcData') && isfield(batchData, 'Results')
                    lcData = batchData.lcData;
                    results = batchData.Results;

                    % Create a new figure
                    figure();
                    
                    % Plot the light curve
                    lcData.Tel = batchData.TelescopeID;
                    lcData.Date = batchData.Date;
                    plotLightCurve3({results}, 1, 1, lcData, batchData.Methods, ...
                                    lcData.relFlux, batchData.FluxMethods, WDtable(Iwd, :));
                    axis tight;

                    % Retrieve RA and Dec for naming purposes
                    RA = WDtable.RA(Iwd);
                    Dec = WDtable.Dec(Iwd);

                    % Generate filenames for the plot and data
                    filename = sprintf('%sRA_%.6f_Dec_%.6f_WD_%d_Batch_%d_LC.png', ...
                                       saveDir, RA, Dec, Iwd, batchIdx);
                    dataFile = sprintf('%sRA_%.6f_Dec_%.6f_WD_%d_Batch_%d_Data.mat', ...
                                       saveDir, RA, Dec, Iwd, batchIdx);

                    % Save the figure
                    saveas(gcf, filename);
                    close;

                    % Save relevant data as a .mat file
                    save(dataFile, 'results', 'lcData');
                end
            end
        end
    end
end
