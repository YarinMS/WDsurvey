function batches = createBatches(paths, Nvisits)
    numBatches = ceil(length(paths)/Nvisits);
    batches = cell(numBatches, 1);

    for i = 1:numBatches
        startIdx = (i-1)*Nvisits + 1;
        endIdx = min(i*Nvisits, length(paths));
        batches{i} = paths(startIdx:endIdx);
    end
end