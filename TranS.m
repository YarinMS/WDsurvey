classdef transitSearch
    properties (Constant)
        DEFAULT_ARGS = struct(...
            'MagField', {{'MAG_PSF'}}, ...
            'MagErrField', {{'MAGERR_PSF'}}, ...
            'BadFlags', {{'Saturated', 'Negative', 'NaN', 'Spike', 'Hole', 'CR_DeltaHT', 'NearEdge'}}, ...
            'EdgeFlags', {{'Overlap'}}, ...
            'runMeanFilterArgs', {{'Threshold', 5, 'StdFun', 'OutWin'}}, ...
            'Nvisits', 1, ...
            'Ndet', 17 ...
        );
    end
    
    methods (Static)

        function analyzeWDTransits(rootPath, args)
            if nargin < 2
                args = transitSearch.DEFAULT_ARGS;
            end
            txtRow = cell(0);

            [msCropID,fieldID] = transitSearch.findMatchedSources(rootPath);
            args.fieldID = fieldID.ID;
            args.allVisits = size(msCropID,2);

            % Get WD from catalog per CropID
tic
            [Results, wd] = transitSearch.findWhiteDwarfsInField(msCropID,args);
            Tab = transitSearch.createTable(Results,wd);
            wdInField = length(unique(Tab{:,3}));
            foundFlag  = (Tab{:,8} > 0);
            wdFoundInField = length(unique(Tab{foundFlag,3}));

            txtRow = [txtRow ;sprintf('Telescope : %s \n Time stamp : %s \n',fieldID.Tel,fieldID.Date);...
                sprintf('Number of visits: %i\n',args.allVisits);...
                sprintf('Out of %i WDs coordinates in Field %s\n',wdInField,fieldID.ID);...
                 sprintf('%i unique WDs found in catlaogs %s\n',wdFoundInField)];
          %  TranS.documentTableToPDF(Tab, Results, txtRow, fieldID)


            toc
           


            results = transitSearch.analyzeWhiteDwarfs(msCropID, Tab, Results, args);
            transitSearch.generateOutput(results);
        end
        
        function [msCropID,selectedField] = findMatchedSources(rootPath)
            cd(rootPath);
            list = MatchedSources.rdirMatchedSourcesSearch('FileTemplate','*.hdf5');
            
            allFileNames = {list(16).FileName};
            [fieldNames,DN,TN] = cellfun(@transitSearch.extractFieldNames, allFileNames, 'UniformOutput', false);
            [fieldNames,idx,c] = unique(fieldNames{:});
            
            fprintf('Available fields:\n');
            for i = 1:length(fieldNames)
                fprintf('%d. %s\n', i, fieldNames{i});
            end

             if isempty(fieldNames)
                error('\nCould not find field name in path.');
            end
            
            if length(fieldNames) > 1

               
            choice = input('Enter the number of the field you want to analyze: ');
            while ~isnumeric(choice) || choice < 1 || choice > length(fieldNames)
                choice = input('Invalid input. Please enter a valid number: ');
                
            end

            
            selectedField.ID = fieldNames{choice};
            Idx = idx(choise);
            selectedField.Date = DN{1}{Idx};
            selectedField.Tel  = TN{1}{Idx};
            fprintf('Selected field: %s\n', selectedField.ID);
            
            [~,visIdx] = transitSearch.filterListByFieldName(list(16).FileName, selectedField.ID);
            tic;
            msCropID = [];
            for Iid = 1:24
                list(Iid).FileName = list(Iid).FileName(visIdx);
                list(Iid).Folder   = list(Iid).Folder(visIdx);
                matchedSources = MatchedSources.readList(list(Iid));
                msCropID = [msCropID ; matchedSources]
            end
            
            times = toc;
            fprintf('\nCreated %i visits in %.2f sec',24*size(matchedSources,2),times)


            elseif length(fieldNames) == 1

            selectedField.ID = fieldNames{1};
            Idx = idx(1);
            selectedField.Date = DN{1}{Idx};
            selectedField.Tel  = TN{1}{Idx};
            
            fprintf('\nA single field exist: %s\n', selectedField.ID);
            
            [~,visIdx] = transitSearch.filterListByFieldName(list(16).FileName, selectedField.ID);
            tic;
            msCropID = [];
            for Iid = 1:24
                list(Iid).FileName = list(Iid).FileName(visIdx);
                list(Iid).Folder   = list(Iid).Folder(visIdx);
                matchedSources = MatchedSources.readList(list(Iid));
                msCropID = [msCropID ; matchedSources];
            end
            
            times = toc;
            fprintf('\nCreated %i visits in %.2f sec',24*size(matchedSources,2),times)


            end
             
       
        end
%%  CropID coords cross match with WD catalogs     
        function [Results, wd] = findWhiteDwarfsInField(matchedSources,args)
            % Search for white dwarfs in the field
            % This function should return the RA, Dec, and WD catalog data
            % TODO: Could add more catalog options
            % TODO: At the moment looking for sources by the first visit

            ra = []; dec = []; wd = [];
            
            RAD = pi./180;
            PWD = pwd;
            cd('~/Catalogs/WD/WDEDR3/') % Change to your catlaogs path if needed

            % A list per subframe:

                % Initialize summary counters
            totalWDs = 0;
            totalVisits = 0;
            totalContaminated = 0;
            totalDetections = 0;
            totalWDsWithDetections = 0;
     

            for Iid = 1 : 24 

               
                ms1 = matchedSources(Iid,1); % {}
                RA = mean(ms1.Data.RA,'omitnan');
                Dec = mean(ms1.Data.Dec,'omitnan');

                Width = abs(min(RA) - max(RA));
                Height = abs(min(Dec) - max(Dec));
                Area = Width*Height;

                Cra  = min(RA) +Width/2;
       
                Cdec = min(Dec) + Height/2;
         

                coneSearchRadius = sqrt(Width^2+Height^2)/2 +0.01; % in Deg
                WDS  = catsHTM.cone_search('WDEDR3',Cra.*RAD, Cdec.*RAD, 3600*coneSearchRadius, 'OutType','AstroCatalog');
                

                if ~isempty(WDS.Table)

                    AllWds = size(WDS.Table,1);
                    visWds = WDS.Table{:,11} < 19.5;
                    visWds = visWds & WDS.Table{:,7} > 0.75;
                    fprintf('\nOut of %i WDs %i are below Gmag 19.6 \n',AllWds,sum(visWds))


                    wd{Iid} = WDS.Table(visWds,:);
                    Res.ra  = WDS.Table{visWds,1}./RAD;
                    Res.Dec = WDS.Table{visWds,2}./RAD;
           
                    Nwds    = length(Res.ra);
                    Nvis =numel(matchedSources(Iid,:));

                    Res.Nvis = Nvis;
                    Res.Ind = cell(Nwds,Nvis);
                    Res.Flags = cell(Nwds,Nvis);
                    Res.Contaminated = zeros(Nwds,Nvis);
                    Res.Ndet = cell(Nwds,Nvis);

                    totalWDs = totalWDs + Nwds;
                    totalVisits = totalVisits + Res.Nvis;


                    

                    for Iwd = 1 : Nwds

                     for Ivis = 1 : Res.Nvis

                        ms1 = matchedSources(Iid,Ivis);

                        Ind = ms1.coneSearch(Res.ra(Iwd),...
                            Res.Dec(Iwd),6); % 6 arcsec search radius to flag contaminatiors 

                        if ~isempty(Ind.Ind)
                            if Ind.Nsrc >1
                                fprintf('\n Source # %i is probably contaminated - Visit %i(Gmag = %.2f)',Iwd,Ivis,wd{Iid}{Iwd,11})
                                Res.Contaminated(Iwd) = 1;
                                Res.Flags{Iwd,Ivis} = getFlags1(ms1,'SrcIdx',Ind.Ind(1));
                                Res.Ind{Iwd,Ivis} = Ind.Ind;
                            else
                               
                                Res.Ind{Iwd,Ivis} = Ind.Ind;
                                wdFlags = getFlags1(ms1,'SrcIdx',Ind.Ind);
                                Res.Flags{Iwd} = wdFlags;

                                fprintf('\nSource # %i Found in Visit %i(Gmag = %.2f)',Iwd,Ivis,wd{Iid}{Iwd,11})
                                fprintf('\nWith  %i Bad Flags and %i Overlap',sum(wdFlags.BFcounts),wdFlags.EFcounts)
                                Ndet = sum(~isnan(ms1.Data.MAG_PSF(:,Ind.Ind)));
                                fprintf('\nAnd %i Detections',Ndet);
                                Res.Ndet{Iwd,Ivis} = Ndet;
                                if ~isempty(Res.Ndet{Iwd, Ivis})
                                    totalDetections = totalDetections + Res.Ndet{Iwd, Ivis};
                                    totalWDsWithDetections = totalWDsWithDetections + 1;
                                end
                                

                              %  if Ivis == 12
                              %  figure();
                              %  plot(datetime(ms1.JD,'convertfrom','jd'),ms1.Data.MAG_PSF(:,Ind.Ind),'ok-')
                              %  set(gca,'Ydir','reverse')
                              %  ylabel('Mag PSF')
                              %  xlabel('Time')    
                              %  end


                              


                            end
                            


                        else
                             fprintf('\nCouldnt find Source # %i in visit # %i (Gmag = %.2f)',Iwd,Ivis,wd{Iid}{Iwd,11})

                        end

                    end


                    end


           

                    Results{Iid} = Res;

                else
                    wd{Iid} = {};
                    Results{Iid} = {};
                end
                
                
                %wd{Iid} = WD;
            end

           % Calculate raw averages
            averageDetectionsPerWD = totalDetections / totalWDsWithDetections;

            % Create summary structure
            summary = struct();
            summary.TotalWDs = totalWDs;
            summary.TotalVisits = totalVisits;
            %summary.TotalContaminated = totalContaminated;
            summary.AverageDetectionsPerWD = averageDetectionsPerWD;

            % Print summary
            fprintf('\nSummary:\n');
            fprintf('Total WDs Found: %i\n', totalWDs);
            fprintf('Total Visits Processed: %i\n', totalVisits);
            %fprintf('Total Contaminated WDs: %i\n', totalContaminated);
            fprintf('Average Detections per WD: %.2f\n', averageDetectionsPerWD);

    % Restore the original directory
            cd(PWD)





         

        %    subFrames = 24;
         %   ra = []; dec = []; wd = [];
            


        end
%%

        function results = analyzeWhiteDwarfs(matchedSources, table, Results, args)
            results = struct();
            Batch = transitSearch.groupVisits(table, matchedSources, Results, args);

            for Iwd = 1 : size(table,1)

                batch = Batch{Iwd};
                for Ibatch = 1 : length(batch)

                    mms = transitSearch.cleanMatchedSources(Batch(Ibatch), args);
                    lcData = transitSearch.extractLightCurve(mms, table.ra(Iwd), table.Dec(Iwd));
                    lcData = transitSearch.handleNaNValues(lcData, res);


                    results = detectTransits(lcData, args)

                end

            end



        end
        
        function [ms, res] = findSourceInMatchedSources(matchedSources, ra, dec)
            % Implement logic to find the source in matched sources
            % Placeholder implementation:
            ms = []; res = [];
            % TODO: Implement actual logic
        end
        
        function lcData = analyzeLightCurve(ms, res, ra, dec, args)
            mms = transitSearch.cleanMatchedSources(ms, args);
            lcData = transitSearch.extractLightCurve(mms, ra, dec);
            lcData = transitSearch.handleNaNValues(lcData, res);
        end
        
        function mms = cleanMatchedSources(ms, args)
            if size(ms,2) > 1
                ms = mergeByCoo(ms,ms(1));
            end
            mms = ms.setBadPhotToNan('BadFlags', args.BadFlags, 'MagField', 'MAG_PSF', 'CreateNewObj', true);
            r = lcUtil.zp_meddiff(ms, 'MagField', args.MagField, 'MagErrField', args.MagErrField);
            [mms, ~] = applyZP(mms, r.FitZP, 'ApplyToMagField', args.MagField);
            mms = transitSearch.removeSourcesWithFewDetections(mms, args.Ndet);
        end
        
        function mms = removeSourcesWithFewDetections(mms, minNdet)
            NdetGood = sum(~isnan(mms.Data.MAG_PSF), 1);
            Fndet = NdetGood > minNdet;
            mms = mms.selectBySrcIndex(Fndet, 'CreateNewObj', false);
        end
        
        function lcData = extractLightCurve(mms, ra, dec)
            ind = mms.coneSearch(ra, dec, 6).Ind;
            if ~isempty(ind)
                if length(ind) == 1
                lcData.lc = mms.Data.MAG_PSF(:, ind);
                lcData.typicalSD = clusteredSD1(mms, 'Isrc', ind);
                else
                    fprintf()

                end

            end

        end
        
        function lcData = handleNaNValues(lcData, res)
            isNan = isnan()
        end
        
        function results = detectTransits(lcData, args)
            results.detection1 = transitSearch.detectConsecutivePoints(lcData, args);
            results.detection2 = transitSearch.runMeanFilter(lcData, args);
            results.detection3 = transitSearch.detectAreaEvents(lcData, args);
        end
        
        function detection = detectConsecutivePoints(lcData, args)
            % Implement detection method 1 (2 consecutive points)
            % TODO: Implement actual logic
            detection = [];
        end
        
        function detection = runMeanFilter(lcData, args)
            % Implement run mean filter detection
            % TODO: Implement actual logic
            detection = [];
        end
        
        function detection = detectAreaEvents(lcData, args)
            % Implement area detection method
            % TODO: Implement actual logic
            detection = [];
        end
        
        function generateOutput(results)
            % Implement output generation (tables, plots, documentation)
            % TODO: Implement actual logic
        end
        

        %% Get field names. 
        function [fieldNames,DateNames,TelNames] = extractFieldNames(fileNames)
            % Extract the field names from a cell array of file names
            % Input: fileNames - a cell array of file names
            % Output: fieldNames - a cell array of field names

            % Ensure input is a cell array
            if ~iscell(fileNames)
                error('Input must be a cell array of file names.');
            end

            % Initialize a cell array to store the field names
            numFiles = length(fileNames);
            fieldNames = cell(numFiles, 1);
            DateNames = cell(numFiles, 1);
            DateNames = cell(numFiles, 1);
    
            for i = 1:numFiles
                fileName = fileNames{i};
                parts = strsplit(fileName, '_');
                % Ensure there is at least one part in the split filename
                if numel(parts) >= 4
                    fieldNames{i} = parts{4};
                    DateNames{i} = parts{2};
                    TelNames{i} = parts{1}; %
                else
                    fieldNames{i} = '';  % If no parts, assign an empty string
                    DateNames{i} = '';
                    TelNames{i} = '';
                end
            end
    

        end 
        %% Extract Results of find white dwarfs in field
         function Tab = createTable(results,wd)
            % Initialize variables to store data
            subframes = [];
            wdIds = cell(0);
            Ras = [];
            Decs = [];
            visitsFound = [];
            totalVisits = [];
            badFlags = [];
            overlapFlags = [];
            contaminated = [];
            avgDetections = [];
            Gmag = [];
            Bpmag = [];
            Pwd   = [];

            % Loop through all subframes
            for i = 1:24
                subframData = results{i};
                NWds = length(subframData.ra);
                tableData = wd{i}; 

                for j = 1:NWds
                    subframes = [subframes; i];
                    wdIds = [wdIds; {sprintf('WD_%02d_%03d', i, j)}]; 
                    Ras = [Ras; subframData.ra(j)];
                    Decs = [Decs; subframData.Dec(j)];
                    Gmag = [Gmag; tableData{j,11}];
                    Bpmag = [Bpmag; tableData{j,12}];
                    Pwd = [Pwd; tableData{j,7}];

                    % Count visits where WD was found
                    visits_found_count = sum(~cellfun(@isempty, subframData.Ind(j,:)));
                    visitsFound = [visitsFound; visits_found_count];

                    totalVisits = [totalVisits; subframData.Nvis];

                    % Count bad flags
                    bad_flag_count = 0;
                    overlap_flag_count = 0;
                    for k = 1:subframData.Nvis
                        if ~isempty(subframData.Flags{j,k})
                            bad_flag_count = bad_flag_count + sum(subframData.Flags{j,k}.BFcounts) ;
                            overlap_flag_count = overlap_flag_count + subframData.Flags{j,k}.EFcounts;
                        end
                    end
                    badFlags = [badFlags; bad_flag_count];
                    overlapFlags = [overlapFlags; overlap_flag_count];

                    contaminated = [contaminated; any(subframData.Contaminated(j,:))];

                    % Calculate average detections
                    detections = cellfun(@(x) transitSearch.ifelse(isempty(x), 0, x), subframData.Ndet(j,:));
                    avgDetections = [avgDetections; mean(detections)];
                end
            end

            % Create the table
            Tab = table(subframes, wdIds, Ras, Decs,Gmag,Bpmag,Pwd, visitsFound, totalVisits, overlapFlags, badFlags, contaminated, avgDetections, ...
                'VariableNames', {'Subframe', 'WD_ID', 'RA', 'Dec','Gmag','Bp_mag','P_wd', 'Visits_Found', 'Total_Visits','Overlap_Flags',...
                'Bad_Flags', 'Contaminated', 'Avg_Detections'});
        end
% Helper function
        function result = ifelse(condition, true_value, false_value)
            if condition
                result = true_value;
            else
                result = false_value;
            end
        end
        %% Documentation of results table
        function documentTableToPDF(table, Results, txtRow, fieldID)

            filename = ['/Users/yarinms/Documents/Data/',fieldID.Tel,'_',fieldID.Date,'_',fieldID.ID];

    
            % Create the plots %%
            [hist_filename, scatter_filename] = transitSearch.createEfficiencyPlots(Results,table);
    
            % Create a LaTeX table
            numRows = size(table, 1);
            numCols = size(table, 2);
            columnNames = table.Properties.VariableNames;
            data = table2cell(table);  % Convert table to cell array
            latexTable = '\begin{tabular}{';

            % Define column alignment (e.g., 'l' for left, 'c' for center, 'r' for right)
            for col = 1:numCols
                latexTable = [latexTable, 'l '];  % Change 'l' to 'c' or 'r' as needed
            end
            latexTable = [latexTable, '}\n'];

            % Add column names
            latexTable = [latexTable, strjoin(columnNames, ' & '), ' \\\n'];
            latexTable = [latexTable, '\hline\n'];  % Add horizontal line after the header

            % Add data rows
            for row = 1:numRows
                rowData = data(row, :);
                formattedRow = strjoin(cellfun(@num2str, rowData, 'UniformOutput', false), ' & ');
                latexTable = [latexTable, formattedRow, ' \\\n'];
            end

            % End the LaTeX table environment
            latexTable = [latexTable, '\end{tabular}\n'];

            
            
            
            
            %latex_table = latex(table);

            % Write the LaTeX document
            fid = fopen([filename, '.tex'], 'w');
            fprintf(fid, '\\documentclass{article}\n');
            fprintf(fid, '\\usepackage{booktabs}\n');
            fprintf(fid, '\\usepackage{geometry}\n');
            fprintf(fid, '\\usepackage{graphicx}\n');
            fprintf(fid, '\\usepackage{pgfplots}\n');
            fprintf(fid, '\\pgfplotsset{compat=newest}\n');
            fprintf(fid, '\\usepgfplotslibrary{colormaps}\n');
            fprintf(fid, '\\geometry{a4paper,margin=1in}\n');
            fprintf(fid, '\\begin{document}\n');
    
            % Add text rows
            fprintf(fid, '\\begin{center}\n');
            for i = 1:length(txtRow)
                fprintf(fid, '%s\n\n', strrep(txtRow{i}, '\n', ' \\\\ '));
            end
            fprintf(fid, '\\end{center}\n\n');
    
            % Add the table
            fprintf(fid, '\\begin{table}\n');
            fprintf(fid, '\\centering\n');
            fprintf(fid, sprintf('\\caption{\\footnotesize White Dwarf Observation Summary (%s ; %s)}\n',fieldID.Tel,fieldID.Date));
            fprintf(fid, latexTable);
            fprintf(fid, '\\end{table}\n\n');
    
            % Add the plots
            fprintf(fid, '\\begin{figure}[htbp]\n');
            fprintf(fid, '\\centering\n');
            fprintf(fid, '\\input{%s}\n', hist_filename);
            fprintf(fid, '\\caption{\\footnotesize Detection Efficiency vs G magnitude}\n');
            fprintf(fid, '\\end{figure}\n\n');
    
            fprintf(fid, '\\begin{figure}[htbp]\n');
            fprintf(fid, '\\centering\n');
            fprintf(fid, '\\input{%s}\n', scatter_filename);
            fprintf(fid, '\\caption{\\footnotesize Average Detection Efficiency vs G magnitude (Scatter plot)}\n');
            fprintf(fid, '\\end{figure}\n');
    
    fprintf(fid, '\\end{document}\n');
    fclose(fid);

    % Use system command to compile the LaTeX document to PDF
    %system('pdflatex -shell-escape %s.tex', filename);
    command = sprintf('pdflatex -shell-escape "%s.tex"', filename);

    %    Execute the system command
    status = system(command);
    
    disp(['PDF created: ', filename, '.pdf']);
end

function [hist_filename, scatter_filename] = createEfficiencyPlots(Results,Tab)
    % Calculate efficiencies 
    num_visits = Results{1}.Nvis;
    efficiencies = zeros(size(Tab, 1), num_visits);
    
    for i = 1:size(Tab, 1)
        subframe = Tab.Subframe(i);
        wd_index = str2double(regexp(Tab.WD_ID{i}, '\d+$', 'match'));
        
        for visit = 1:num_visits
            Ndet = Results{subframe}.Ndet{wd_index, visit};
            if isempty(Ndet)
                efficiencies(i, visit) = 0;
            else
                Npts = 20;  % Assuming Npts is always 20, adjust if necessary
                efficiencies(i, visit) = Ndet / Npts;
            end
        end
    end
    
    avg_efficiencies = mean(efficiencies, 2);
    
    % Create histogram
    figure('Visible', 'off');
    [a,b,c] = unique(Tab.Gmag);
    h = bar(Tab.Gmag(b), avg_efficiencies(b));
    hold on
    
    % Find indices where the data is zero and plot x markers
    zeroIndices = find(avg_efficiencies(b) == 0);
    Zidx         = Tab.Gmag(b);
    for i = 1:length(zeroIndices)
        % Mark the zero value with an 'x'
        plot(Zidx(i), 0, 'x', 'MarkerSize',5, 'LineWidth', 2, 'Color', 'r');
    end
    hold off
    xlabel('G magnitude');
    ylabel('Detection Efficiency');
    title('Detection Efficiency vs G magnitude');
    
    
   % Save histogram as PDF
    hist_filename = 'efficiency_histogram.pdf';
    print(gcf, hist_filename, '-dpdf', '-bestfit');
    close;
    
    % Create scatter plot
    figure('Visible', 'off');
    scatter(Tab.Gmag, avg_efficiencies, 'filled');
    xlabel('G magnitude');
    ylabel('Average Detection Efficiency');
    title('Average Detection Efficiency vs G magnitude');
    
    scatter_filename = 'efficiency_scatter.pdf';
    print(gcf, scatter_filename, '-dpdf', '-bestfit');
    close;
end

%% Group to batches functions
function res = groupVisits(table, matchedSources, Results, args)

    res = cell(size(table, 1), 1); % Preallocate results

    for Iwd = 1:length(table.Subframe)
        
        if table.Visits_Found(Iwd) > 0
            
            CropID = table.Subframe(Iwd);
            Nvis = table.Total_Visits(Iwd);
            ms = matchedSources(CropID, :);
            
            % Check for consecutive visits
            if any(diff(mean([ms.JD])) * 24 * 60 > 15)
                error('Visit might not be consecutive\n Please Check....');
            end
            
            % Find the corresponding RA and detection values
            [~, j] = find(Results{CropID}.ra == table.RA(Iwd));
            detections = cellfun(@(x) transitSearch.ifelse(isempty(x), 0, x), Results{CropID}.Ndet(j, :));
            
            if any(detections < Nvis)
                fprintf('\nCannot find source in all visits\n %i', detections);
                
                visToTake = detections ~= 0;
                
                if sum(visToTake) > 0
                    mms = matchedSources(CropID, visToTake);
                    batches = transitSearch.groupBatches(mms, args.Nvisits);
                else
                    fprintf('\nCannot find source at all %i \n Gmag = %.2f ', Iwd, table.Gmag(Iwd));
                    continue;
                end
            else
                fprintf('\nFound source in all visits');
                batches =  transitSearch.groupBatches(matchedSources(CropID, :), args.Nvisits);
            end
            
            %[ms, res] = TranS.findSourceInMatchedSources(matchedSources, table.RA(Iwd), table.Dec(Iwd));
            res{Iwd} = batches; % Store result
        else
            res{Iwd} = 'Empty'; % Mark as empty if no visits found
        end
    end
end

function batches = groupBatches(matchedSources, Nvisits)
    % Helper function to create batches
    numBatches = ceil(size(matchedSources, 2) / Nvisits);
    batches = cell(numBatches, 1);

    for i = 1:numBatches
        startIdx = (i - 1) * Nvisits + 1;
        endIdx = min(i * Nvisits, size(matchedSources, 2));
        batches{i} = matchedSources(startIdx:endIdx);
    end
end

        %%
        
        function [filteredList,isMatchingField] = filterListByFieldName(list, fieldName)
            isMatchingField = cellfun(@(x) contains(x, fieldName), {list{:}});
            filteredList = list(isMatchingField);
        end
    end
end