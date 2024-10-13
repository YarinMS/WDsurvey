function insertLCDataToDB(lcData, results, dbPath)
    % Open or create the SQLite database
    dbConn = sqlite(dbPath, 'connect');

    % Create the table if it doesn't exist (same as before)
    createTableSQL = ['CREATE TABLE IF NOT EXISTS LightCurveData (', ...
        'ID INTEGER PRIMARY KEY AUTOINCREMENT, WD_Name TEXT, RA DOUBLE, Dec DOUBLE, ', ...
        'P_wd DOUBLE, B_p DOUBLE, Date TEXT, Telescope TEXT, FieldID INTEGER, CropID INTEGER, ', ...
        'NptsDet INTEGER, BadFlags INTEGER, NonDetectPts INTEGER, Neighbors INTEGER, LimMag DOUBLE, ', ...
        'FWHM DOUBLE, Airmass DOUBLE, LC_Quality TEXT, STDEvent DOUBLE, Depth DOUBLE, ', ...
        'meanX DOUBLE, meanY DOUBLE, SimbadLink TEXT, ImageLink TEXT, lc BLOB, lc_2 BLOB, ', ...
        'lc_3 BLOB, lcErr BLOB, relFlux BLOB, NanCount INTEGER, ConsecutiveNans BOOLEAN, ', ...
        'BadFlagCount INTEGER, NonBadFlagCount INTEGER, TypicalSD DOUBLE, TypScatter DOUBLE, ', ...
        'DetectionCount INTEGER, QualityFlag TEXT);'];
    execute(dbConn, createTableSQL);

    % Initialize arrays for column names and values
    columnNames = {};
    columnValues = {};

    % Helper function to add column and value if it exists
    function addColumn(colName, colValue)
        columnNames{end+1} = colName;  % Add column name
        % Add value: wrap strings in single quotes
        if isnumeric(colValue)
            columnValues{end+1} = num2str(colValue);
        elseif islogical(colValue)
            columnValues{end+1} = num2str(colValue);  % Convert logical to numeric (0 or 1)
        else
            columnValues{end+1} = sprintf('''%s''', colValue);  % Add quotes around strings
        end
    end

    % Check each field, add if it exists
    if isfield(lcData, 'WD_Name'), addColumn('WD_Name', lcData.WD_Name); end
    if isfield(lcData, 'Coords')
        addColumn('RA', lcData.Coords(1));
        addColumn('Dec', lcData.Coords(2));
    end
    if isfield(lcData, 'Pwd'), addColumn('P_wd', lcData.Pwd); end
    if isfield(lcData, 'Bp'), addColumn('B_p', lcData.Bp); end
    if isfield(lcData, 'Date'), addColumn('Date', lcData.Date); end
    if isfield(lcData, 'Tel'), addColumn('Telescope', lcData.Tel); end
    if isfield(lcData, 'Table')
        if isfield(lcData.Table, 'FieldID'), addColumn('FieldID', lcData.Table.FieldID); end
        if isfield(lcData.Table, 'CropID'), addColumn('CropID', lcData.Table.CropID); end
        if isfield(lcData.Table, 'Neighbors'), addColumn('Neighbors', lcData.Table.Neighbors); end
        if isfield(lcData.Table, 'FWHM'), addColumn('FWHM', lcData.Table.FWHM); end
        if isfield(lcData.Table, 'Airmass'), addColumn('Airmass', lcData.Table.Airmass); end
        if isfield(lcData.Table, 'SimbadLink'), addColumn('SimbadLink', lcData.Table.SimbadLink); end
        if isfield(lcData.Table, 'ImageLink'), addColumn('ImageLink', lcData.Table.ImageLink); end
    end
    if isfield(lcData, 'NptsDet'), addColumn('NptsDet', lcData.NptsDet); end
    if isfield(lcData, 'Flags') && isfield(lcData.Flags, 'BFcounts')
        addColumn('BadFlags', lcData.Flags.BFcounts);
        addColumn('BadFlagCount', sum(lcData.Flags.BFcounts));
        %addColumn('NonBadFlagCount',sum(lcData.Flags.BFcounts));
    end
    if isfield(lcData, 'nanIndices')
        addColumn('NonDetectPts', sum(lcData.nanIndices));
        addColumn('NanCount', sum(isnan(lcData.lc)));
        addColumn('ConsecutiveNans', any(diff(find(isnan(lcData.lc))) == 1));
    end
    if isfield(lcData, 'limMag'), addColumn('LimMag', lcData.limMag); end
    if isfield(lcData, 'LC_Quality'), addColumn('LC_Quality', lcData.LC_Quality); end
    if isfield(lcData, 'typicalSD'), addColumn('STDEvent', lcData.typicalSD); end
    if isfield(lcData, 'typScatter'), addColumn('TypScatter', lcData.typScatter); end
    if isfield(lcData, 'x'), addColumn('meanX', lcData.x); end
    if isfield(lcData, 'y'), addColumn('meanY', lcData.y); end

    % Convert arrays to strings for BLOBs
    if isfield(lcData, 'lc'), addColumn('lc', mat2str(lcData.lc)); end
    if isfield(lcData, 'lc_2'), addColumn('lc_2', mat2str(lcData.lc_2)); end
    if isfield(lcData, 'lc_3'), addColumn('lc_3', mat2str(lcData.lc_3)); end
    if isfield(lcData, 'lcErr'), addColumn('lcErr', mat2str(lcData.lcErr)); end
    if isfield(lcData, 'relFlux'), addColumn('relFlux', mat2str(lcData.relFlux)); end

    % Fields from results
    if isfield(results, 'detection1') && isfield(results.detection1, 'Depth')
        addColumn('Depth', results.detection1.Depth);
    end

    % Add static field 'QualityFlag'
    addColumn('QualityFlag', 'High');  % Example placeholder

    % Construct the SQL query dynamically
    columnsStr = strjoin(columnNames, ', ');
    valuesStr = strjoin(columnValues, ', ');

    insertSQL = sprintf('INSERT INTO LightCurveData (%s) VALUES (%s);', columnsStr, valuesStr);

    % Execute the insert statement
    execute(dbConn, insertSQL);

    % Close the database connection
    close(dbConn);

    disp('Data inserted successfully.');
end
