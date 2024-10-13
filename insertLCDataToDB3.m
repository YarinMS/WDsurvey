function insertLCDataToDB3(lcData, results, dbPath)
    % Open or create the SQLite database
    cd('~/Documents/MATLAB/')
    dbConn = sqlite(dbPath, 'connect');

    % Create the table if it doesn't exist (same as before)
    createTableSQL = ['CREATE TABLE IF NOT EXISTS LightCurveData (', ...
        'ID INTEGER PRIMARY KEY AUTOINCREMENT, WD_Name TEXT, RA DOUBLE, Dec DOUBLE, ', ...
        'P_wd DOUBLE, BPmag DOUBLE, Gmag DOUBLE, Plx DOUBLE, Abs_Mag DOUBLE, Date TEXT, Telescope TEXT, FieldID TEXT, CropID INTEGER, ', ...
        'NptsDet1 INTEGER, NptsDet2 INTEGER, BadFlags BLOB, NonDetectPts DOUBLE, Neighbors DOUBLE, LimMag DOUBLE, ', ...
        'FWHM DOUBLE, Airmass DOUBLE, VisitID TEXT, LC_Quality TEXT, ', ...
        'meanX DOUBLE, meanY DOUBLE, SimbadLink TEXT, ImageLink TEXT, lc BLOB, '...
        'SDNoEvent DOUBLE, MedNoEvent DOUBLE, EventDepth DOUBLE, ',...
        'SDNoEvent2 DOUBLE, MedNoEvent2 DOUBLE, EventDepth2 DOUBLE, ',...
        'SDNoEvent2Flux DOUBLE, MedNoEvent2Flux DOUBLE, EventDepth2flux DOUBLE, ',...
        'SDNoEvent1Flux DOUBLE, MedNoEvent1Flux DOUBLE, EventDepth1flux DOUBLE, ',...
        'NanCount INTEGER, ConsecutiveNans BOOLEAN, ', ...
        'NptsDet1_flux INTEGER, NptsDet2_flux INTEGER, ', ...
        'BadFlagCount INTEGER, NonBadFlagCount INTEGER, controlSD DOUBLE, fluxSD DOUBLE, magSD DOUBLE, ', ...
        'DetectionCount INTEGER, QualityFlag TEXT, LAST_ID TEXT, designation_id TEXT, ',...
        'Year INTEGER, Month INTEGER, Day INTEGER, Mount INTEGET, Camera INTEGER, ',...
        'Detection BOOLEAN, SN_3 DOUBLE, SN_2 DOUBLE, Nvisits INTEGER, NvalidPoints INTEGER, ',...
        'Identifier TEXT);'];
    execute(dbConn, createTableSQL);

    % Initialize lists for column names and values (as cell arrays)
    columnNames = {};
    columnValues = {};

    % Helper function to add column and value if it exists
    function addColumn(colName, colValue)
        if ~isempty(colValue)  % Ensure the value is not empty
            columnNames{end+1} = colName;  % Add column name
            
            % Convert the value to a string depending on its type
            if isnumeric(colValue) || islogical(colValue)
                columnValues{end+1} = num2str(colValue);  % Convert numbers/logicals to string
            elseif ischar(colValue)
                columnValues{end+1} = sprintf('''%s''', colValue);  % Wrap strings in quotes
            elseif iscell(colValue)
                % Handle cell arrays (if needed), convert cell to string using mat2str
                columnValues{end+1} = sprintf('''%s''', mat2str(colValue));
            else
                columnValues{end+1} = sprintf('''%s''', mat2str(colValue));  % Handle arrays
            end
        end
    end

    % Check each field, add if it exists
    if isfield(lcData.Table, 'AbsMag'), addColumn('Abs_Mag', lcData.Table.AbsMag); end
    if isfield(lcData.Table.Identifiers, 'Gaia'), addColumn('WD_Name', lcData.Table.Identifiers.Gaia); end
    if isfield(lcData, 'Coords')
        addColumn('RA', lcData.Coords(1));
        addColumn('Dec', lcData.Coords(2));
    end
    if isfield(lcData,'VisitID'), addColumn('VisitID',lcData.VisitID); end
    if isfield(lcData.Table, 'WDtable'), addColumn('P_wd', lcData.Table.WDtable.Pwd); end
    if isfield(lcData.Table, 'WDtable'), addColumn('BPmag', lcData.Table.WDtable.BPmag); end
    if isfield(lcData.Table, 'WDtable'), addColumn('Gmag', lcData.Table.WDtable.Gmag); end
    if isfield(lcData.Table, 'WDtable'), addColumn('Plx', lcData.Table.WDtable.Plx); end
    if isfield(lcData, 'Date'), addColumn('Date', lcData.Date); end
    if isfield(lcData, 'Tel'), addColumn('Telescope', lcData.Tel); end
    if isfield(lcData, 'Table')
        if isfield(lcData.Table, 'FieldID'), addColumn('FieldID', lcData.Table.FieldID{:}); end
        if isfield(lcData.Table, 'Subframe'), addColumn('CropID', lcData.Table.Subframe); end
        if isfield(lcData.Table, 'Neighbors'), addColumn('Neighbors', lcData.Table.Neighbors); end
        if isfield(lcData.Table, 'fwhm'), addColumn('FWHM', lcData.Table.fwhm); end
        if isfield(lcData.Table, 'airmass'), addColumn('Airmass', lcData.Table.airmass); end
        if isfield(lcData.Table, 'SimbadLink'), addColumn('SimbadLink', lcData.Table.SimbadLink); end
        if isfield(lcData.Table, 'ImageLink'), addColumn('ImageLink', lcData.Table.ImageLink); end
        if isfield(lcData.Table, 'Name'), addColumn('LAST_ID', lcData.Table.Name); end
        if isfield(lcData.Table.Identifiers, 'First'), addColumn('Identifier', lcData.Table.Identifiers.First); end
        if isfield(lcData.Table, 'designation_id'), addColumn('designation_id', lcData.Table.designation_id); end
        if isfield(lcData.Table, 'visTable'), addColumn('Nvisits', lcData.Table.visTable.Nvisits); end

        if isfield(lcData.Table, 'visTable'), addColumn('Year', lcData.Table.visTable.Year); end
        if isfield(lcData.Table, 'visTable'), addColumn('Month', lcData.Table.visTable.Month); end
        if isfield(lcData.Table, 'visTable'), addColumn('Day', lcData.Table.visTable.Day); end
        if isfield(lcData.Table, 'visTable'), addColumn('Mount', lcData.Table.visTable.Mount); end
        if isfield(lcData.Table, 'visTable'), addColumn('Camera', lcData.Table.visTable.Camera); end

    end
    %if isfield(lcData, 'NptsDet'), addColumn('NptsDet', lcData.NptsDet); end
    if isfield(lcData, 'Flags') && isfield(lcData.Flags, 'BFcounts')
   %     addColumn('BadFlags',uint8(getByteStreamFromArray(lcData.Flags)));
        addColumn('BadFlagCount', sum(lcData.Flags.BFcounts));
       
    end
    if isfield(lcData, 'nanIndices')
        addColumn('NonDetectPts', sum(lcData.nanIndices));
        addColumn('NanCount', sum(isnan(lcData.lc)));
        addColumn('NvalidPoints',length(lcData.lc) - sum(isnan(lcData.lc)))
        addColumn('ConsecutiveNans', any(diff(lcData.nanIndices) == 1));
    end
    if isfield(lcData, 'limMag'), addColumn('LimMag',median( lcData.limMag,'omitnan')); end
    if isfield(lcData, 'LC_Quality'), addColumn('LC_Quality', lcData.LC_Quality); end
    if isfield(lcData, 'typicalSD'), addColumn('controlSD', lcData.typicalSD); end
    if isfield(lcData, 'typScatter'), addColumn('fluxSD', std(lcData.relFlux,'omitnan')); end
    if isfield(lcData, 'x'), addColumn('meanX', median(lcData.x,'omitnan')); end
    if isfield(lcData, 'y'), addColumn('meanY', median(lcData.y,'omitnan')); end
    %if isfield(lcData, 'typicalSD'), addColumn('controlSD', lcData.typicalSD); end
    if isfield(lcData, 'SN_3'), addColumn('SN_3', median(lcData.SN_3,'omitnan')); end
    if isfield(lcData, 'SN_2'), addColumn('SN_2', median(lcData.SN_2,'omitnan')); end
    % Convert arrays to strings for BLOBs
   % if isfield(lcData, 'lc'), addColumn('lc', uint8(getByteStreamFromArray(lcData))); end
   % if isfield(lcData, 'lc_2'), addColumn('lc_2',uint8(getByteStreamFromArray(lcData.lc_2))); end
    %if isfield(lcData, 'lc_3'), addColumn('lc_3', uint8(getByteStreamFromArray(lcData.lc_3))); end
    %if isfield(lcData, 'lcErr'), addColumn('lcErr', mat2str(lcData.lcErr)); end
    %if isfield(lcData, 'relFlux'), addColumn('relFlux', mat2str(lcData.relFlux)); end

    % Fields from results
    if isfield(results, 'detection1') && isfield(results.detection1, 'Depth')
        %addColumn('Depth', results.detection1.Depth);
        addColumn('results', uint8(getByteStreamFromArray(results)));
    end

    mask = true(size(lcData.lc));
    if ~isempty(results.detection1.events)
        mask1 = mask;
        mask1(results.detection1.events) = false;
        addColumn('NptsDet1', length(results.detection1.events));
        lcWithoutEvent1 = lcData.lc(mask1);


        lcStdWithoutEvent1 = std(lcWithoutEvent1,'omitnan');
        lcMedWithoutEvent1 = median(lcWithoutEvent1,'omitnan');
        %depth = 
        eventDepth1 =  max(lcData.lc(~mask1)) - lcMedWithoutEvent1;
        addColumn('SDNoEvent', lcStdWithoutEvent1);
        addColumn('MedNoEvent', lcMedWithoutEvent1);
        addColumn('EventDepth', eventDepth1);
    
    end
    mask2 = true(size(lcData.lc));
    
    if ~isempty(results.detection2.events)
        addColumn('NptsDet2', length(results.detection2.events));
       
        mask = mask2;
        mask(results.detection2.events) = false;
      
        lcWithoutEvent2 = lcData.lc(mask);


        lcStdWithoutEvent2 = std(lcWithoutEvent2,'omitnan');
        lcMedWithoutEvent2 = median(lcWithoutEvent2,'omitnan');
        %depth = 
        eventDepth2 =  max(lcData.lc(~mask)) - lcMedWithoutEvent2;
        addColumn('SDNoEvent2', lcStdWithoutEvent2);
        addColumn('MedNoEvent2', num2str(lcMedWithoutEvent2));
        addColumn('EventDepth2', eventDepth2);
    
    end
    mask3 = true(size(lcData.lc));
    if ~isempty(results.detection1flux.events)
        addColumn('NptsDet1_flux', length(results.detection1flux.events));
        
        mask = mask3;
        mask(results.detection1flux.events) = false;
      
        lcWithoutEvent1flux = lcData.relFlux(mask);


        lcStdWithoutEvent1flux = std(lcWithoutEvent1flux,'omitnan');
        lcMedWithoutEvent1flux = median(lcWithoutEvent1flux,'omitnan');
        %depth = 
        eventDepth1flux =  max(lcData.relFlux(~mask)) - lcMedWithoutEvent1flux;
        addColumn('SDNoEvent1Flux', lcStdWithoutEvent1flux);
        addColumn('MedNoEvent1Flux', lcMedWithoutEvent1flux);
        addColumn('EventDepth1flux', eventDepth1flux);
    
    
    end
    mask4 = true(size(lcData.lc));
    if ~isempty(results.detection2flux.events)
        addColumn('NptsDet2_flux', length(results.detection2flux.events));
        
        mask = mask4;
        mask(results.detection2flux.events) = false;
      
        lcWithoutEvent2flux = lcData.relFlux(mask);


        lcStdWithoutEvent2flux = std(lcWithoutEvent2flux,'omitnan');
        lcMedWithoutEvent2flux = median(lcWithoutEvent2flux,'omitnan');
        %depth = 
        eventDepth2flux =  max(lcData.relFlux(~mask)) - lcMedWithoutEvent2flux;
        addColumn('SDNoEvent2Flux', lcStdWithoutEvent2flux);
        addColumn('MedNoEvent2Flux', lcMedWithoutEvent2flux);
        addColumn('EventDepth2flux', eventDepth2flux);
    
    
    
    end
    
    Detected =  ~isempty(results.detection2.events) || ~isempty(results.detection1.events);
    fluxDetected = ~isempty(results.detection1flux.events) || ~isempty(results.detection2flux.events);
    if Detected || fluxDetected
        addColumn('Detection',1 > 0);

    else
        addColumn('Detection',0 > 1);
    end
    % Initialize mask to true for all elements
    



    % Add static field 'QualityFlag'
    % addColumn('QualityFlag', 'High');  % Example placeholder
    addColumn('magSD', std(lcData.lc,'omitnan'))

    % Manually build the SQL query for insert
    insertSQL = 'INSERT INTO LightCurveData (';

    % Build the column names part of the query
    for i = 1:length(columnNames)
        if i == length(columnNames)
            insertSQL = [insertSQL, columnNames{i}, ') VALUES ('];  % Closing column names part
        else
            insertSQL = [insertSQL, columnNames{i}, ', '];  % Add a comma between column names
        end
    end

    % Build the values part of the query
    for i = 1:length(columnValues)
        if i == length(columnValues)
            insertSQL = [insertSQL, columnValues{i}, ');'];  % Close the query with the last value
        else
            insertSQL = [insertSQL, columnValues{i}, ', '];  % Add a comma between values
        end
    end

    % Display the final query for debugging (optional)
    %disp(insertSQL);

    % Execute the insert statement
    execute(dbConn, insertSQL);

    % Close the database connection
    close(dbConn);

    disp('Data inserted successfully.');
end
