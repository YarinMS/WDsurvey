function result = querySimbadByCoordsJSON(ra, dec, radius)
    % Query SIMBAD by coordinates and retrieve results in JSON format.
    %
    % Parameters:
    %   ra: Right Ascension in degrees
    %   dec: Declination in degrees
    %   radius: Search radius (e.g., '5s' for 5 arcseconds)
    %
    % Returns:
    %   result: MATLAB structure parsed from JSON response

    % Base URL for SIMBAD coordinate query
    baseURL = 'http://simbad.u-strasbg.fr/simbad/sim-coo';
    
    % Construct the coordinate string (e.g., '88.792939 7.407064')
    coordString = sprintf('%f %f', ra, dec); % RA and Dec in degrees separated by space
    
    % Construct the query URL with JSON output format
    queryURL = sprintf('%s?Coord=%s&Radius=%s&output.format=JSON', ...
                        baseURL, coordString, radius);
    
    try
        % Use webread to fetch JSON response
        rawResult = webread(queryURL);
        disp('Query successful!');
        
        % Parse the JSON response into MATLAB structure
        result = jsondecode(rawResult);
        disp('Response parsed successfully!');
    catch ME
        % Handle errors
        disp('Error querying SIMBAD or parsing response:');
        disp(ME.message);
        result = [];
    end
end

% Example usage:
ra = 88.792939; % Right Ascension in degrees
dec = 7.407064; % Declination in degrees
radius = '1s';  % Search radius (5 arcseconds)

% Query SIMBAD and display results
result = querySimbadByCoordsJSON(ra, dec, radius);
disp(result);
