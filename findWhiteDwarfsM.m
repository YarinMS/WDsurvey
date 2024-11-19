function wdSources = findWhiteDwarfsM(RA, Dec, fieldCoords)
    PWD = pwd;
    cd('~/marvin/catsHTM/WD/WDEDR3/')
    % FINDWHITEDWARFS Queries and finds white dwarf candidates in the field
    % Inputs:
    %   RA, Dec - Coordinates of the image field center
    %   fieldCoords - Struct containing boundary coordinates of the field
    % Outputs:
    %   wdSources - Table of potential White Dwarf sources in the field
    
    % Define cone search radius based on field coordinates
    coneSearchRadius = sqrt(abs(fieldCoords.raMax - fieldCoords.raMin)^2 + ...
                            abs(fieldCoords.decMax - fieldCoords.decMin)^2) / 2 + 0.01;

    % Query the WD catalog (using AstroPack's catsHTM or custom method)
    wdSources = catsHTM.cone_search('WDEDR3', RA * pi / 180, Dec * pi / 180, ...
                                    3600 * coneSearchRadius, 'OutType', 'AstroCatalog');

    % Filter the sources by magnitude or other criteria
    wdTable = wdSources.Table;
    wdTable.RA = wdTable.RA / pi * 180;
    wdTable.Dec = wdTable.Dec / pi * 180;
    withinRaRange = (wdTable.RA >= fieldCoords.raMin) & (wdTable.RA <= fieldCoords.raMax);
    withinDecRange = (wdTable.Dec >= fieldCoords.decMin) & (wdTable.Dec <= fieldCoords.decMax);
    withinMagRange = wdTable.BPmag < 19.6;
    
    % Return only White Dwarfs in the field
    wdSources = wdTable(withinRaRange & withinDecRange & withinMagRange, :);
    cd(pwd)
end