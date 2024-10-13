function insertWDData(dbConn, wdData,dbName)
    % insertWDData Inserts White Dwarf metadata into the SQLite database.
    % dbConn: SQLite database connection object
    % wdData: Structure containing metadata for a WD observation
    
    % Check if dbConn is open
    if ~isopen(dbConn)
        error('The database connection is not open.');
    end
    
    % Query the database for the available column names in the WhiteDwarfs table
    
    tableInfo = fetch(dbConn, 'PRAGMA table_info(LAST_WDs1);');
    dbColumns = tableInfo(:, 2);  % Get the column names (2nd column in the result)

    % Extract the field names from the wdData structure (columns provided by the user)
    dataFields = fieldnames(wdData);

    % Find the common columns between the database and wdData
    columnsToInsert = intersect(dbColumns, dataFields);
    
    % For the columns that exist in the database but not in wdData, insert NULLs
    missingColumns = setdiff(dbColumns, dataFields);

    % Build the SQL query dynamically based on the columns to insert
    columns = strjoin(columnsToInsert, ', ');              % Column names part
    valuesPlaceholders = repmat('?, ', 1, numel(columnsToInsert));  % Placeholder for provided values
    valuesPlaceholders = valuesPlaceholders(1:end-2);      % Remove trailing comma and space

    % Add NULL placeholders for missing columns
    if ~isempty(missingColumns)
        columns = [columns, ', ', strjoin(missingColumns, ', ')];   % Add missing columns to the column list
        nullPlaceholders = repmat('NULL, ', 1, numel(missingColumns));  % Add 'NULL' for missing columns
        valuesPlaceholders = [valuesPlaceholders, ', ', nullPlaceholders(1:end-2)];
    end

    % Full SQL insert query
    insertSQL = sprintf('INSERT INTO WhiteDwarfs (%s) VALUES (%s);', columns, valuesPlaceholders);

    % Extract the values for the provided fields in the order of columnsToInsert
    values = struct2cell(rmfield(wdData, missingColumns));  % Remove missing fields from wdData
    
    % Insert the White Dwarf data into the database
    try
        exec(dbConn, insertSQL, values);
        disp('Data inserted successfully.');
    catch ME
        disp('Error occurred while inserting data:');
        disp(ME.message);
    end
end
