% Define dates and ComputerID
dates = [2024, 10, 10;
         2024, 10, 22;
         2024, 10, 23;
         2024, 10, 24;
         2024, 10, 26;
         2024, 10, 28]; 

ComputerID = [4, 1];

% Define batch size and source coordinates
batchSize = 5;  % Group visits in batches of 5
sourceRA = 60.2175670304; % Right Ascension of the target source
sourceDec = 34.0772904188; % Declination of the target source

% Call the processing function
observations = processObservingNights(dates, ComputerID, batchSize, sourceRA, sourceDec);

% Display the resulting observations structure
disp(observations);
