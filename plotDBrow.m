function plotDBrow(dataRow, Args)
    % dataRow: a single row from dataTable that we're constructing a path for
    % dataTable: the entire data table containing all observations for grouping

    arguments 

        dataRow table
        Args.GroupSize = 2;
        Args.plotNvis  = 2;
    end

    PWD = pwd;
    
    % Step a: Construct the Marvin path
    marvinPath = constructMarvinPath(dataRow);
    cd(marvinPath)




    
    % Step b:
    % Organize visits into batches for processing
    
    batchez = organizeBatches(marvinPath, Args.GroupSize);
    %

    % cd -> group -> get the right group -> transit analysis.

    targetFieldID = dataRow.FieldID;
    targetVisitID = dataRow.VisitID;
    targetCropID  = dataRow.CropID;
    targetTime = str2double(extractBetween(dataRow.Date, 10, 15));

    % List visit directories in marvinPath
    visitDirs = dir(fullfile(marvinPath, '*v0'));
    
    % Extract the HHMMSS start times from each directory name
    visitTimestamps = [];
    for i = 1:length(visitDirs)
        visitName = visitDirs(i).name;
        if length(visitName) >= 6
            startTime = str2double(visitName(1:6)); % First six characters are HHMMSS start time
            visitTimestamps = [visitTimestamps; startTime];
        end
    end
    
    % Calculate absolute time differences to the targetTime
    timeDiffs = abs(visitTimestamps - targetTime);
    
    % Sort visits by time difference to the targetTime
    [~, sortedIndices] = sort(timeDiffs);
    
    % Select the nearest visits (target and closest neighbors)
    numToSelect = min(Args.plotNvis, length(sortedIndices));
    selectedIndices = sortedIndices(1:numToSelect);
    
    % Construct full paths for the selected batch directories
    batches = visitDirs(selectedIndices);

    [fitsFilesBatch, hdf5FilesBatch, fitsFilesNames, hdf5FilesNames, fitsFilesFolders, hdf5FilesFolders] = ...
    extractDataFilez(batches, marvinPath,targetFieldID,targetCropID);
 

    
    mms = constructMS(targetCropID,hdf5FilesNames,hdf5FilesFolders)
    Src = mms.coneSearch(dataRow.RA,dataRow.Dec,6);
    FPAI = AstroHeader(fitsFilesBatch,3);
    % Extract relevant photometry data for analysis
    nFiles       = numel(FPAI);  
    args.LimMag  = NaN(nFiles, 1); 
    args.airmass = NaN(nFiles, 1);
    args.catJD   = NaN(nFiles, 1);
    args.FWHM    = NaN(nFiles, 1);
    args.FieldID = cell(nFiles, 1);

    try

    args.LimMag = arrayfun(@(x) x.Key.LIMMAG, FPAI)';
    args.airmass = arrayfun(@(x) x.Key.AIRMASS, FPAI)';
    args.catJD = arrayfun(@(x) x.Key.JD, FPAI)';
    args.FWHM = arrayfun(@(x) x.Key.FWHM, FPAI)';
    args.FieldID = arrayfun(@(x) x.Key.FIELDID, FPAI,'UniformOutput',false);

    catch
        args.LimMag = 20*ones(length(FPAI),1);
        args.airmass =2*ones(length(FPAI),1);;
        args.catJD = arrayfun(@(x) x.Key.JD, FPAI)';
        args.FWHM = arrayfun(@(x) x.Key.FWHM, FPAI)';
        args.FieldID = arrayfun(@(x) x.Key.FIELDID, FPAI,'UniformOutput',false);

    end
     [lcDataCat,res] = getCatLC3(mms,dataRow,args)

       % Plot the first light curve (results)
    if ~isempty(res)
         plotLightCurve2({res}, 1, 1, lcDataCat{1}, res.Methods, lcDataCat{1}.relFlux,res.FluxMethods);
    end
    
    % Plot the catalog light curve
      %  plotLightCurveSpec({res}, 1, 1, lcDataCat{1}, res.Methods, lcDataCat{1}.relFlux, res.FluxMethods);


   
end

function marvinPath = constructMarvinPath(dataRow)
    % Construct the Marvin path string
    telescopeID = dataRow.Telescope;  % Extract Telescope as a string
    year = dataRow.Year;
    month = dataRow.Month;
    day = dataRow.Day;
    marvinPath = sprintf('~/marvin/%s/%04d/%02d/%02d/proc', telescopeID, year, month, day);
end

function plotLightCurve(groupData)
    % Assuming Gmag vs Date for the light curve plot
    % Convert Date strings to datetime if needed
    dates = datetime(groupData.Date, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss'); % Adjust format as needed
    gmag = groupData.Gmag; % Get the Gmag column for light curve
    
    % Plot the light curve
    figure;
    plot(dates, gmag, '-o', 'MarkerSize', 6, 'LineWidth', 1.5);
    title('Light Curve');
    xlabel('Date');
    ylabel('Gmag');
    grid on;
end



