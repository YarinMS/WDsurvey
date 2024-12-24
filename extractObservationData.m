function obsData = extractObservationData(AH)
    % EXTRACTOBSERVATIONDATA Extracts relevant observation data from AstroHeader (AH) structure
    % Inputs:
    %   AH - AstroHeader object array containing observation metadata
    % Outputs:
    %   obsData - Structure with fields LimMag, airmass, catJD, FWHM, and FieldID

    % Determine the number of files
    nFiles = numel(AH); 

    % Initialize obsData structure with default NaN values
    obsData.LimMag  = NaN(nFiles, 1);
    obsData.airmass = NaN(nFiles, 1);
    obsData.catJD   = NaN(nFiles, 1);
    obsData.FWHM    = NaN(nFiles, 1);
    obsData.FieldID = cell(nFiles, 1);

    % Loop through each entry in AH and populate obsData
    for i = 1:nFiles
        % Limiting Magnitude: check if LIMMAG exists, otherwise calculate with AIRMASS if available
        if isfield(AH(i).Key, 'LIMMAG')
            obsData.LimMag(i) = AH(i).Key.LIMMAG;
        end

        % Airmass
        if isfield(AH(i).Key, 'AIRMASS')

            if ~isempty(AH(i).Key.AIRMASS)
     
            obsData.airmass(i) = AH(i).Key.AIRMASS;
            end
        end

        % Julian Date
        if isfield(AH(i).Key, 'JD')
            obsData.catJD(i) = AH(i).Key.JD;
        end

        % Full Width at Half Maximum (FWHM)
        if isfield(AH(i).Key, 'FWHM')
            obsData.FWHM(i) = AH(i).Key.FWHM;
        end

        % Field ID (stored as a cell array for text data)
        if isfield(AH(i).Key, 'FIELDID')
            obsData.FieldID{i} = AH(i).Key.FIELDID;
        end
    end
end
