function insertLCDataToDB4(lcData, results, dbPath)
    % Open or create the SQLite database
    dbConn = sqlite(dbPath, 'create');

    % Create the table if it doesn't exist
    createTableSQL = ['CREATE TABLE IF NOT EXISTS LightCurveData (', ...
        'ID INTEGER PRIMARY KEY AUTOINCREMENT, WD_Name TEXT, RA DOUBLE, Dec DOUBLE, ', ...
        'P_wd DOUBLE, B_p DOUBLE, Date TEXT, Telescope TEXT, FieldID INTEGER, CropID INTEGER, ', ...
        'NptsDet INTEGER, BadFlags BLOB, NonDetectPts BLOB, Neighbors TEXT, LimMag DOUBLE, ', ...
        'FWHM DOUBLE, Airmass DOUBLE, LC_Quality TEXT, STDEvent DOUBLE, Depth DOUBLE, ', ...
        'meanX DOUBLE, meanY DOUBLE, SimbadLink TEXT, ImageLink TEXT, lc BLOB, lc_2 BLOB, ', ...
        'lc_3 BLOB, lcErr BLOB, relFlux BLOB, NanCount INTEGER, ConsecutiveNans BOOLEAN, ', ...
        'BadFlagCount INTEGER, NonBadFlagCount INTEGER, TypicalSD DOUBLE, TypScatter DOUBLE, ', ...
        'DetectionCount INTEGER, QualityFlag TEXT);'];
    execute(dbConn, createTableSQL);

    % Initialize lists for column names and values (as cell arrays)
    columnNames = {};
    columnValues = {};

    % Helper function to add column and value if it exists
    function addColumn(colName, colValue)
        if ~isempty(colValue)  % Ensure the value is not empty
            columnNames{end+1} = colName;  % Add column name
            
            % Convert BLOB fields to byte stream if needed
            if ismatrix(colValue)
                columnValues{end+1} = getByteStreamFromArray(colValue);  % Convert arrays to byte streams
            else
                columnValues{end+1} = colValue;  % Other values can remain as they are
            end
        end
    end

    % Check each field, add if it exists
    addColumn('WD_Name', lcData.WD_Name);
    addColumn('RA', lcData.Coords(1));
    addColumn('Dec', lcData.Coords(2));
    addColumn('P_wd', lcData.Pwd);
    addColumn('B_p', lcData.Bp);
    addColumn('Date', lcData.Date);
    addColumn('Telescope', lcData.Tel);
    addColumn('FieldID', lcData.Table.FieldID);
    addColumn('CropID', lcData.Table.CropID);
    addColumn('NptsDet', lcData.NptsDet);
    addColumn('BadFlags', lcData.Flags.BFcounts);  % Stored as BLOB
    addColumn('NanCount', sum(isnan(lcData.lc)));
    addColumn('NonDetectPts', sum(lcData.nanIndices));  % Stored as BLOB if needed
    addColumn('lc', lcData.lc);  % Light curve stored as BLOB
    addColumn('lc_2', lcData.lc_2);  % Second light curve stored as BLOB
    addColumn('lc_3', lcData.lc_3);  % Third light curve stored as BLOB
    addColumn('lcErr', lcData.lcErr);  % Error stored as BLOB
    addColumn('relFlux', lcData.relFlux);  % Relative flux stored as BLOB

    % Fields from results
    if isfield(results, 'detection1') && isfield(results.detection1, 'Depth')
        addColumn('Depth', results.detection1.Depth);
    end

    % Add static field 'QualityFlag'
    addColumn('QualityFlag', 'High');  % Example placeholder

    % Build the SQL insert query
    insertSQL = ['INSERT INTO LightCurveData (', strjoin(columnNames, ', '), ') VALUES (', repmat('?, ', 1, length(columnValues) - 1), '?)'];

    % Execute the insert statement
    execute(dbConn, insertSQL, columnValues{:});

    % Close the database connection
    close(dbConn);

    disp('Data inserted successfully.');
end
