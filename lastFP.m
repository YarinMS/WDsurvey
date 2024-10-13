classdef lastFP
    properties
        computerId
        mountNumber
        telescopesList
        dataDirs = {'data1', 'data2'};
        baseDirPattern = '/%s/archive/LAST.%02d.%02d.%02d/%04d/%02d/%02d';
        operatingMounts = [1, 2, 3, 4, 5, 6, 8, 10];
    end
    
    methods
        % Constructor
        function obj = lastFP(computerId)
            obj.computerId = computerId;
            
            % Determine the mount and telescope numbers based on the computer identifier
            if contains(computerId, 'e')
                obj.telescopesList = [1, 2]; % Eastern computer handles telescopesList 1 and 2
            elseif contains(computerId, 'w')
                obj.telescopesList = [3, 4]; % Western computer handles telescopesList 3 and 4
            else
                error('Invalid computer identifier. Must contain "e" or "w" to specify east or west.');
            end
            
            % Extract the mount number from the computer identifier
            obj.mountNumber = str2double(regexp(computerId, '\d+', 'match'));
            
            % Check if the mount is currently operating
            if ~ismember(obj.mountNumber, obj.operatingMounts)
                error('Mount %02d is not currently operating.', obj.mountNumber);
            end
        end
        
        % Method to process observations
        function processObservations(obj, year, month, day)
            for telescope = obj.telescopesList
                for data_idx = 1:length(obj.dataDirs)
                    % Construct the base directory for each combination
                    baseDir = sprintf(obj.baseDirPattern, obj.dataDirs{data_idx}, 1, obj.mountNumber, telescope, year, month, day);
                    baseDir = strcat('/',obj.computerId,baseDir);
                    
                    if exist(baseDir, 'dir') == 7
                        % Check if data is available for processing
                        fprintf('Processing telescope %02d on mount %02d: %s\n', telescope, obj.mountNumber, baseDir);
                        
                        % Access proc directory and iterate through visits
                        procDir = fullfile(baseDir, 'proc');
                        if exist(procDir, 'dir') == 7 
                            visitDirs = dir(fullfile(procDir, '*v0'));
                            
                            if ~isempty(visitDirs)
                                % Sort visits based on time information
                                visits = obj.prepListOfConVisits('path',procDir)
                                visits = obj.sortVisits(visitDirs);
                                
                                % Group consecutive visits into batches
                                visitBatches = obj.groupConsecutiveVisits(visits, 15 * 60); % 15-minute threshold in seconds
                                
                                % Process each batch
                                for batch = 1:length(visitBatches)
                                    fprintf('Processing batch %d of visits for telescope %02d on mount %02d\n', batch, telescope, obj.mountNumber);
                                    % TODO: Implement forced photometry for each batch (to be continued)
                                end
                            end
                        end
                    end
                end
            end
        end
        
        % Helper method to sort visits
        function sortedVisits = sortVisits(obj, visitDirs)
            % Extract time from visit directory names in the format HHMMSS
            visitTimes = arrayfun(@(x) obj.extractTime(x.name), visitDirs);

            % Adjust times after midnight to come after evening times
            adjustedTimes = arrayfun(@(t) t + (t < 120000) * 240000, visitTimes);

            % Sort visits based on adjusted times
            [~, idx] = sort(adjustedTimes);
            sortedVisits = visitDirs(idx);
        end
        
        function time = extractTime(~, visitName)
            % Extract time information in the format HHMMSS from the visit name
            hour = str2double(visitName(1:2));
            minute = str2double(visitName(3:4));
            second = str2double(visitName(5:6));
            time = hour * 10000 + minute * 100 + second;
        end
        
        % consecutive visits :
        
         function List = prepListOfConVisits(obj,args)

            arguments
                obj
                %Table
                args.fileTemplate
                args.CropID
                args.path
            end
            Ind = 0;
            PWD = pwd;
            cd(args.path) % This must be a path to proc directory

            DirVisit = io.files.dirDir();
            Nv = numel(DirVisit);
            for Iv=1:1:Nv
                %[Iy, Im, Id, Iv, Ind]
                cd(DirVisit(Iv).name);
                
                Files = dir('*MergedMat_1.hdf');
                FN = FileNames.generateFromFileName({Files.name});
                if FN.nfiles>0
                    Ind = Ind + 1;
                    CropID = FN.CropID;
                    JD     = FN.julday;
                    List(Ind).FieldID = FN.FieldID{1};
                 
                    List(Ind).VistDir = DirVisit(Iv).name;
                   % List(Ind).Year    = Table.Year;
                   % List(Ind).Month   = Table.Month;
                   % List(Ind).Day     = Table.Day;
        
                    List(Ind).Path    = fullfile(path, DirVisit(Iv).name,'','');
                    
                    List(Ind).AllFiles = {Files.name};
                    List(Ind).CropID   = CropID;
                    List(Ind).JD       = JD;
                    List(Ind).MinJD    = min(JD);
                end
                cd ..
            end
            cd(PWD)

           end
        
        
        
        

        
        % Helper method to group consecutive visits
        function visitBatches = groupConsecutiveVisits(obj, visits, max_time_diff)
            % Group visits that are within max_time_diff seconds of each other
            visitBatches = {};
            currentBatch = [];
            
            for i = 1:length(visits)
                if isempty(currentBatch)
                    currentBatch = visits(i);
                else
                    timeDiff = obj.calcTimeDiff(visits(i - 1).name, visits(i).name);
                    if timeDiff <= max_time_diff
                        currentBatch(end + 1) = visits(i); %#ok<AGROW>
                    else
                        visitBatches{end + 1} = currentBatch; %#ok<AGROW>
                        currentBatch = visits(i);
                    end
                end
            end
            if ~isempty(currentBatch)
                visitBatches{end + 1} = currentBatch;
            end
        end
        
        % Helper method to calculate time difference between visits
        function timeDiff = calcTimeDiff(obj, visit1, visit2)
            % Calculate the time difference between two visits based on their names
            time1 = sscanf(visit1, '%*[^_]_%08d.%06d');
            time2 = sscanf(visit2, '%*[^_]_%08d.%06d');
            timeDiff = abs(time2 - time1);
        end
    end
end