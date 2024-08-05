
function [WDmag,WDtimes,Time] = load_Tables_dir(directory_path)
    % Get list of all directories in the specified path

    % Initialize cell arrays to store data
    WDmag= cell(0);
    WDtimes = cell(0);
    Time    = cell(0)


  
        % Get list of all .mat files in the current directory
        files = dir(fullfile(directory_path, '*Table_Results*'));

        % Loop through each .mat file in the current directory
        for j = 1:length(files)

            file_path = fullfile(directory_path, files(j).name);

            data = load(file_path);
            WDmag{end+1} = data.Tab(:, 3);
            WDtimes{end+1} = data.Tab(:, 4);

             Res = dir(fullfile(directory_path, ['Field_Results*',files(j).name(1:20),'*']));
             Min = zeros(length(Res),1)
             for k = 1 : length(Res)

                file_path = fullfile(directory_path, Res(k).name);

                ResData = load(file_path);

                Min(k) = sqrt((ResData.Results.Coord(1,1) - mean(data.Tab(:,1)))^2 + (ResData.Results.Coord(1,2) - mean(data.Tab(:,2)))^2)

              

             end

              [~,sorted] = sort(Min);

              ObsTime = cell(0);

              for l = 1 :2 

                file_path = fullfile(directory_path, Res(sorted(l)).name);

                ResData = load(file_path);

                times   = datetime(ResData.Results.JD,'convertfrom','jd');

                %ObsTime{end+1} = max(times) - min(times);


                 ObsTime{end+1} = length(ResData.Results.JD)*20/(60*60)
           


              end

              Time{end+1} = ObsTime{1}+ObsTime{2}



            % Load data from the current file
            

    

           

        end
 
end
