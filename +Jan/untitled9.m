%% Base Query
baseUrl = 'http://gea.esac.esa.int/tap-server/tap/sync?REQUEST=doQuery&LANG=ADQL&FORMAT=csv&';

parallax_lower_limit=10;

query = ['QUERY=SELECT+*,+DISTANCE(151.4962,22.8254, ra, dec)+AS+ang_sep+FROM+gaiaedr3.gaia_source+' ...
    'WHERE+DISTANCE(151.4962,22.8254, ra, dec)+<+1./720+'...
    'ORDER+BY+ang_sep+ASC']

url = [baseUrl query];

options = weboptions('Timeout', timeout);
response = webread(url,options)



% response = webread(url);
%% Continue;
 
gaiaID = response.source_id(1)
simbadURL = sprintf('http://simbad.u-strasbg.fr/simbad/sim-id?Ident=Gaia+DR3+%d&output.format=json', gaiaID);
simbadData = webread(simbadURL)

simbadData = jsondecode(simbadData);
disp(simbadData);



%%




%%


%%




%%
function simbadInfo = parse_simbad_votable(votableData)
    % Parse a VOTable response from SIMBAD
    % Input: votableData (XML response as a string)
    % Output: simbadInfo (structure with parsed data)

    % Parse the XML response
    try
        xmlTree = xmlreadstring(votableData); % Parse XML string
    catch ME
        error('Failed to parse VOTable: %s', ME.message);
    end

    % Convert XML tree to MATLAB structure
    try
        dataStruct = xml2struct(xmlTree);
    catch ME
        error('Failed to convert XML to MATLAB structure: %s', ME.message);
    end

    % Extract relevant information from the structure
    % (This part depends on the SIMBAD VOTable format.)
    simbadInfo = struct();
    try
        fields = dataStruct.VOTABLE.RESOURCE.TABLE.DATA.TABLEDATA.TR; % Adjust to match your data structure

        % Loop through the fields and extract desired information
        for i = 1:length(fields)
            fieldName = fields{i}.TD{1}.Text; % Example for the first field
            simbadInfo.(fieldName) = fields{i}.TD{2}.Text; % Example for the second field
        end
    catch ME
        warning('Could not extract fields from VOTable: %s', ME.message);
    end
end




%%
 tempFile = [tempname, '.xml'];
    fid = fopen(tempFile, 'w');
    fwrite(fid, votableData);
    fclose(fid)




%% Define the star's coordinates
ra = 123.456; % Right Ascension in degrees
dec = -23.456; % Declination in degrees

% Query the Gaia catalog using the Gaia Data Explorer
% Ensure you have the Gaia Data Explorer installed from the File Exchange
% https://www.mathworks.com/matlabcentral/fileexchange/129934-gaia-data-explorer

% Perform a cone search around the given coordinates
radius = 5/3600; % Search radius in degrees (e.g., 5 arcseconds)
gaiaData = gaia_cone_search(ra, dec, radius);
