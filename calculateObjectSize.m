function totalMB = calculateObjectSize(var)
    info = whos('var');
    totalBytes = info.bytes;

    if isstruct(var) || isobject(var)
        % Get field names of the structure or object
        fields = fieldnames(var);
        for i = 1:numel(fields)
            fieldData = var.(fields{i});
            % Recursively calculate the size of each field
            totalBytes = totalBytes + calculateObjectSize(fieldData);
        end
    elseif iscell(var)
        % Recursively calculate size for each cell element
        for i = 1:numel(var)
            totalBytes = totalBytes + calculateObjectSize(var{i});
        end
    end
    
    % Convert to MB
    totalMB = totalBytes / 1e6;
end
