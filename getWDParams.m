function [AbsMag, Plx, Dist, NonSingleStar, Neighbors, Identifiers] = getWDParams(ra, dec)
    RAD = 180 / pi;
    PWD = pwd;
    % Initialize the output values
    AbsMag = -1;
    Plx = -1;
    Dist = -1;
    NonSingleStar = -1;
    Neighbors = 0;
    Identifiers = {'None', 'None'};
    
    % Gaia catalog query
    cd('~/marvin/catalogs/GAIA/DR3/');
    AC = catsHTM.cone_search('GAIADR3', ra / RAD, dec / RAD, 3, 'OutType', 'AstroCatalog');
    
    if ~isempty(AC.Table)
        if size(AC.Table, 1) == 1
            NonSingleStar = AC.Table.non_single_star;
            AbsMag = AC.Table.phot_bp_mean_mag - (5 * log10(1000 / AC.Table.Plx) - 5);
            Plx = AC.Table.Plx;
            Dist = 1000 / AC.Table.Plx;
        elseif size(AC.Table, 1) > 1
            NonSingleStar = AC.Table.non_single_star(1);
            AbsMag = AC.Table.phot_bp_mean_mag(1) - (5 * log10(1000 / AC.Table.Plx(1)) - 5);
            Plx = AC.Table.Plx(1);
            Dist = 1000 / AC.Table.Plx(1);
            Neighbors = size(AC.Table, 1) - 1;
        end
    end
    cd(PWD)
    
    % SIMBAD query


    queryURL = sprintf('http://simbad.u-strasbg.fr/simbad/sim-coo?Coord=%f+%f&Radius=%f&Radius.unit=arcsec&output.format=ASCII', ra, dec, 4);
    
    options = weboptions('Timeout', 15);
    try
        % Attempt to read the response with custom timeout options
        response = webread(queryURL, options);
    catch ME
        % If an error occurs (e.g., timeout or server issue), handle it
        warning('Failed to fetch data from SIMBAD: %s',num2str(ra));
        response = '';  % Set response to empty or handle it in another way
    end
 
    
    if ~isa(response, 'uint8')
        startIdx = strfind(response, 'Identifiers (');
        if ~isempty(startIdx)
            idSection = extractAfter(response, 'Identifiers (');
            firstColonIdx = strfind(idSection, ':');
            if ~isempty(firstColonIdx)
                idText = extractAfter(idSection(firstColonIdx(1):end), ':');
                firstIdentifier = regexp(idText, '[A-Za-z0-9.]+ [A-Za-z0-9.+-]+', 'match', 'once');
            else
                firstIdentifier = 'None';
            end
            
            gaiaID = regexp(idSection, 'Gaia DR3 \S+', 'match', 'once');
            if isempty(gaiaID)
                gaiaID = regexp(idSection, 'Gaia DR2 \S+', 'match', 'once');
            end
            if isempty(gaiaID)
                gaiaID = 'None';
            end
            Identifiers = {firstIdentifier, gaiaID};
        end
    end
end
