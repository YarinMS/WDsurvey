% Function to get relevant PDFs and extract info
function RES = processPdfs(directory)

    % Get list of all files matching 'Mag*.pdf'
    pdfFiles = dir(fullfile(directory, 'Mag*.pdf'));
    RES = {};

    for i = 1:length(pdfFiles)
        pdfFilePath = fullfile(directory, pdfFiles(i).name);
        textData = extractFileText(pdfFilePath);

        % Parse extracted text to get information
        eventInfo = parsePdfInfo(textData);

        % Build path and time range for fetching images
        remotePath = buildRemotePath(eventInfo);
        timeWindow = calculateTimeWindow(eventInfo.date);
        
        % Display the result (or use it for further processing)
        fprintf('Event: %s\n', pdfFiles(i).name);
        fprintf('Remote Path: %s\n', remotePath);
        fprintf('Time Window: %s to %s\n', timeWindow.startTime, timeWindow.endTime);
        
        RES(i).remotePath = remotePath;
        RES(i).timeWindow = timeWindow;
        % Add further steps here to send commands to remote systems or store results
    end
end
