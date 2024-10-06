function processPlots(Path)
    % PROCESSIMAGES processes a list of image files by extracting information
    % and performing light curve extraction and matching.
    % It also stores the SIMBAD link for each source into a new text file.
    % If the file exists, it will be overwritten.
    %
    % Input:
    %   imageFiles    : Cell array of image file names
    %   outputFileName: Name of the text file to store the SIMBAD links



    cd(Path)
    imageFiles = dir ;


    

    % Iterate over each image file
    for i = 3:numel(imageFiles)
        fileName = imageFiles(i).name;
        
        % Check if the file exists
        if ~exist(fileName, 'file')
            fprintf('Warning: File does not exist - %s\n', fileName);
           % fprintf(fid, 'Warning: File does not exist - %s\n\n', fileName);
            continue;  % Skip to the next file if this one doesn't exist
        end

        try


        



            % Step 1: Extract RA, Dec, CropID, full path, and telescope folder
            [ra, dec, cropID, fullPath,Tel, FieldID] = extractInfoFromFileName(fileName);
            
            % Step 2: Call extractLCFromObs to retrieve Matched Sources
            PWD = pwd;
            cd(fullPath)
            Template = sprintf('*_%s_*%03d_sci_*.hdf5',FieldID,cropID);
            
            list = MatchedSources.rdirMatchedSourcesSearch('FileTemplate',Template);
            matchedSources = MatchedSources.readList(list);
            cd(PWD)
            
            % Step 3: Create a table with the necessary information
            Table.CropID = cropID;
            Table.RA = ra;
            Table.Dec = dec;
            Table.Nvisits = length(matchedSources);  % Assuming 3 visits as a constant for now
            Table.Name = sprintf('Source_%03d', i);  % Generate source name

            % Step 3.5 look in Gentile fussilo catalog.
            cd('~/marvin/catsHTM/WD/WDEDR3/')
            RAD = pi./180;

            WDS  = catsHTM.cone_search('WDEDR3',ra.*RAD, dec.*RAD, 10, 'OutType','AstroCatalog');
            cd(PWD);

            if height(WDS.Table) > 0
                Savedir = sprintf('~/Projects/WD_survey/10.2WhiteDwarfsRandom/%s_%.4f_%.4f/', Table.Name,ra,dec);

            else

                Savedir = sprintf('~/Projects/WD_survey/10.2LCs/%s_%.4f_%.4f/', Table.Name,ra,dec);
            end

            % Step 4: Group Matched Sources and get light curve
            MSgroups = groupMS(matchedSources, Table.Nvisits);
            Res = getLCfromMS(MSgroups, Table, ...
                Savedir);
                simbadLink = sprintf('https://simbad.u-strasbg.fr/simbad/sim-coo?Coord=%.6f+%.6f&CooFrame=ICRS&Radius=2&Radius.unit=arcmin', ra, dec);
            
            % Step 5: Write the SIMBAD link to the text file
            outputFileName = sprintf('%sText.txt',Savedir)
            system(sprintf('touch %s',outputFileName))
            system(sprintf("printf '\nSource %s: RA=%.6f, Dec=%.6f, CropID=%d\n' > %s" ,Table.Name, ra, dec, cropID,outputFileName))
            system(sprintf("printf '\nSIMBAD link: %s\n\n'", simbadLink))
           

        catch ME
            % Handle any other unexpected errors during processing
            fprintf('Error processing file: %s\n', fileName);
            fprintf('MATLAB error: %s\n', ME.message);
            fprintf(fid, 'Error processing file: %s\nMATLAB error: %s\n\n', fileName, ME.message);
        end
    end

  
