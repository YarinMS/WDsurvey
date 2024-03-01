function averagedData = binAndAverage(timeSeries, numBins)

    
    % Calculate the bin size
    dataSize = length(timeSeries);
    binSize = ceil(dataSize / numBins);
    
 
    binStart = 1;
    binEnd = binSize;
    averagedData = zeros(1, numBins);
    
    for i = 1:numBins
        
        if binEnd > dataSize
            binEnd = dataSize;
        end
        

        currentBinData = timeSeries(binStart:binEnd);

        averagedData(i) = mean(currentBinData,'omitnan');
        
  
        binStart = binEnd + 1;
        binEnd = binEnd + binSize;
    end
end
