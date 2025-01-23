function dataCell = parse_votable(doc)
    % Find all <TABLEDATA> elements
    tableDataNodes = doc.getElementsByTagName('FIELDID');
    if tableDataNodes.getLength() < 1
        error('No TABLEDATA element found in the VOtable.');
    end

    % For simplicity, assume there is only one TABLEDATA section:
    tableDataNode = tableDataNodes.item(0);

    % Get all the row (TR) nodes inside TABLEDATA
    trNodes = tableDataNode.getElementsByTagName('TR');
    nRows = trNodes.getLength();

    % Prepare a cell array to hold the results
    dataCell = {};

    % Loop over each row
    for iRow = 0 : nRows-1
        thisRow = trNodes.item(iRow);
        tdNodes = thisRow.getElementsByTagName('TD');
        nCols = tdNodes.getLength();

        % Extract each cell's text
        rowData = cell(1, nCols);
        for iCol = 0 : nCols-1
            % Convert Java String to MATLAB char array
            rowData{iCol+1} = char(tdNodes.item(iCol).getTextContent());
        end

        % Append to our main data cell
        dataCell = [dataCell; rowData]; %#ok<AGROW>
    end
end
