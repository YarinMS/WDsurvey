%% visualize results template.
%% load telescope data from one night (usually two fields)

% Inside '~/Documents/MainTest/' there are directories patterned with yyyy-mm-dd.
% In each date directory, there are WD tables from different telescopes named like:
% Results_table_LAST.01.<Mount>.<telescope>_yyyy-mm-dd.mat
% We are building a function that iterates over these tables and creates a
% report. Each file usually contains two tables. Each table forms a chapter
% in the report, while we also store data to a summary report.

% Example:
Tab = load('~/Documents/MainTest/2024-11-07/Results_table_LAST.01.04.01_2024-11-07.mat');
tab = Tab.tab; % tab is a 1 x 2 table (two fields)

%% Iterate over WD tables from different telescopes
% As part of the summary, besides the statistics, we would like to
% visualize the light curves of sources.

% Store these images in a folder specific for their date and telescope ID
% and field ID. Later, for every field ID, we can create a chapter in the
% nightly report. Alternatively, we could consider a smarter way to populate the report.

% For the first page of each chapter, I want to have:
% - Number of WDs in the field.
% - Number detected at least once.
% - Total events: {catalog detections; forced detections; both detections}

% Additional plots:
% - Detection probability plot.
% - HR diagram of targets (100 pc on background, function available).

% More informative plots:
% For every event, I want:
% - A point on a plot representing magnitude vs. standard deviation out of event.
% - Each point should have text next to it indicating the source number.

% Light curve images should be included on later pages.

% If created, we need to check batchData and batchDataF for field name ResultRMS.
% If available, also plot the RMS plot (function available for plotting this).
% - The plot should be centered around the light curve (y-limits) with min and
% max values at approximately 5-6 standard deviations of the light curve.

%% Main function to generate reports and visualize results
datesDir = dir('~/Documents/MainTest/');
datesDir = datesDir([datesDir.isdir] & ~ismember({datesDir.name}, {'.', '..'}));

for iDate = 1:length(datesDir)
    datePath = fullfile(datesDir(iDate).folder, datesDir(iDate).name);
    telescopeFiles = dir(fullfile(datePath, 'Results_table_LAST.01.*.*_*.mat'));
    
    for iFile = 1:length(telescopeFiles)
        % Load the telescope data
        filePath = fullfile(telescopeFiles(iFile).folder, telescopeFiles(iFile).name);
        Tab = load(filePath);
        tab = Tab.tab;
        if ~isempty(tab)
            % Extract telescope and field information from filename
            tokens = regexp(telescopeFiles(iFile).name, 'Results_table_LAST\.01\.(\d+)\.(\d+)_\d{4}-\d{2}-\d{2}', 'tokens','once');
            mountID = tokens{1}{1};
            telescopeID = tokens{1}{2};
            args.Tel =  sprintf('LAST.01.%s.%s',mountID,telescopeID);
            
            % Create directory to store images
            saveDir = fullfile('~/Documents/MainTest/Reports', datesDir(iDate).name, ['Mount_', mountID, '_Telescope_', telescopeID]);
            if ~exist(saveDir, 'dir') 
                mkdir(saveDir);
            end
            
            % Generate summary for each table (usually two fields)
            for iField = 1:width(tab)
                currentTable = tab{iField};
                % Generate statistics and visualizations
                numWDs = height(currentTable);
                 % Handle catalog and forced detections
                 % Handle catalog and forced detections
                NcatDetected = 0;
                NforcedDetected = 0;
                if any(strcmp(currentTable.Properties.VariableNames, 'catDetected'))
                    NcatDetected = sum(currentTable.catDetected);
                end
                if any(strcmp(currentTable.Properties.VariableNames, 'forcedDetected'))
                    NforcedDetected = sum(currentTable.forcedDetected);
                end
                
                % Total events
                totalEvents = {NcatDetected, NforcedDetected, NcatDetected + NforcedDetected};
                
                  
                % Save summary information
                summaryFile = fullfile(saveDir, ['Summary_Field_', num2str(iField), '.txt']);
                fid = fopen(summaryFile, 'w');
                fprintf(fid, 'Number of WDs in the field: %d\n', numWDs);
                fprintf(fid, 'Number detected at least once: %d\n', numDetected);
                fprintf(fid, 'Total events: Catalog Detections: %d, Forced Detections: %d, Both Detections: %d\n', totalEvents{:});
                fclose(fid);

                if any(totalEvents)
                    
                
                %% ### TODO Plot Detection Probability
                % detectionProbPlot(currentTable, saveDir, iField);
                
                %% ### TODO  Plot HR Diagram (assuming a function is available)
                %hrDiagramPlot(currentTable, saveDir, iField);
                
                %% TODO Plot Magnitude vs Std Deviation
                
                 %plotMagnitudeVsStd(currentTable, saveDir, iField);
            end
            
            % Loop over WDs within the table to plot light curves
            for Itgt = 1:height(currentTable)
                WD = currentTable(Itgt,:);
                if any(strcmp(WD.Properties.VariableNames, 'BatchData'))
                    %plotBatchLightCurves(tab(Itgt, :), saveDir);
                    plotBatchLightCurves1(WD, saveDir)
                elseif  isfield(WD,'batchDataF')
                    %
                end
            end
            
            % Plot RMS if ResultRMS is available
            if isfield(Tab, 'batchData') && isfield(Tab.batchData, 'ResultRMS')
                plotRMS(Tab.batchData, saveDir);
            end
        end
    end
end

%% Helper function: detectionProbPlot
function detectionProbPlot(currentTable, saveDir, fieldID)
    % Assuming DetectionProbability is a column in currentTable
    figure;
    histogram(currentTable.DetectionProbability);
    title(['Detection Probability - Field ', num2str(fieldID)]);
    xlabel('Probability');
    ylabel('Count');
    saveas(gcf, fullfile(saveDir, ['DetectionProbability_Field_', num2str(fieldID), '.png']));
    close;
end

%% Helper function: hrDiagramPlot
function hrDiagramPlot(currentTable, saveDir, fieldID)
    % Assuming HR diagram data is in currentTable
    figure;
    scatter(currentTable.ColorIndex, currentTable.AbsoluteMagnitude);
    title(['HR Diagram - Field ', num2str(fieldID)]);
    xlabel('Color Index');
    ylabel('Absolute Magnitude');
    saveas(gcf, fullfile(saveDir, ['HRDiagram_Field_', num2str(fieldID), '.png']));
    close;
end

%% Helper function: plotMagnitudeVsStd
function plotMagnitudeVsStd(currentTable, saveDir, fieldID)
    figure;
    scatter(currentTable.Magnitude, currentTable.StdOutOfEvent);
    text(currentTable.Magnitude, currentTable.StdOutOfEvent, string(currentTable.SourceNumber));
    title(['Magnitude vs Std Deviation - Field ', num2str(fieldID)]);
    xlabel('Magnitude');
    ylabel('Standard Deviation');
    saveas(gcf, fullfile(saveDir, ['MagnitudeVsStd_Field_', num2str(fieldID), '.png']));
    close;
end
