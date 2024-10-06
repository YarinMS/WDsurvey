function groupedMS = groupMS(MSvisits, Nvisits)
    % Get the total number of visits
    totalVisits = numel(MSvisits);
    
    % Calculate the number of full groups and the remainder
    numGroups = floor(totalVisits / Nvisits);
    remainder = mod(totalVisits, Nvisits);
    
    % Preallocate the groupedMS cell array
    groupedMS = cell(1, numGroups + (remainder > 0));
    
    % Loop through and group the visits
    for i = 1:numGroups
        startIdx = (i-1) * Nvisits + 1;
        endIdx = i * Nvisits;
        groupedMS{i} = MSvisits(startIdx:endIdx);
    end
    
    % Handle the remainder if there is one
    if remainder > 0
        startIdx = numGroups * Nvisits + 1;
        groupedMS{end} = MSvisits(startIdx:end);
    end
end