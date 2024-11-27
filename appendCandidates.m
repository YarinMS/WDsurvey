function CandidateTable = appendCandidates(WDcand, CandidateTable, year, month, day, TelescopeID, FieldID, BatchSize,Batches,totalVisits)
    % appendCandidates - Adds candidates to an existing CandidateTable
    %
    % INPUTS:
    %   WDcand          - Cell array of candidate structs (e.g., WDcand or Cand).
    %   CandidateTable  - Existing table to which the candidates will be appended.
    %   year, month, day - Date of observation (numerical).
    %   TelescopeID     - String identifier for the telescope (e.g., 'LAST.01.01.01').
    %   Date            - String representation of the observation date.
    %   BatchSize       - Numerical value indicating the batch size.
    %   Nbatch          - Number of batches processed.
    %
    % OUTPUT:
    %   CandidateTable  - Updated table with new candidate rows appended.

    % Iterate over each candidate in WDcand
    for iCand = 1:length(WDcand)
        candStruct = WDcand{iCand};

        % Convert the struct to a table row
        candRow = struct2table(candStruct, 'AsArray', true);

        % Add additional metadata
        candRow.Year = year;
        candRow.Month = month;
        candRow.Day = day;
        candRow.TelescopeID = TelescopeID;
        candRow.FieldID = FieldID ;
        candRow.BatchSize = BatchSize;
        candRow.Nbatch = length(Batches);
        candRow.totalVisits = totalVisits;

        % Append the row to CandidateTable
        CandidateTable = [CandidateTable; candRow];
    end
end
