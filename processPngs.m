function Res = processPngs(directory)
    % Get list of all .png files matching 'Mag*.png'
    pngFiles = dir(fullfile(directory, 'Mag*.png'));
    Res ={};
    for i = 1:length(pngFiles)
        pngFilePath = fullfile(directory, pngFiles(i).name);

        % Step 1: Read and Apply OCR to the Image
        img = imread(pngFilePath);
        ocrResults = ocr(img);
        extractedText = ocrResults.Text;
        
        % Step 2: Parse the Extracted Text
        eventInfo = parseTextFromOCR(extractedText);
        
        % Step 3: Build Path and Time Window Based on Event Info
        remotePath = buildRemotePath(eventInfo);
        timeWindow = calculateTimeWindow(eventInfo.dateStr);

        % Display the results
        fprintf('Processing Image: %s\n', pngFiles(i).name);
        fprintf('Remote Path: %s\n', remotePath);
        fprintf('Time Window: %s to %s\n', timeWindow.startTime, timeWindow.endTime);
    
        % Store results
        Res(i).eventInfo  = eventInfo;
        Res(i).remotePath = remotePath;
        Res(i).timeWindow = timeWindow;
    
    end
end
