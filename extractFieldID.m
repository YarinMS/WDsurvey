function fieldID = extractFieldID(filename)
    % Extract Field ID using regular expressions
    tokens = regexp(filename, '_clear_([^_]+)_', 'tokens');
    if ~isempty(tokens)
        fieldID = tokens{1}{1};
    else
        fieldID = ''; % Return empty if no match is found
    end
    
    
end
