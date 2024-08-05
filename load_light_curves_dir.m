
function [light_curves, errors, times,Coords,GeneralRMS,Events,Bp] = load_light_curves_dir(directory_path)
    % Get list of all directories in the specified path

    % Initialize cell arrays to store data
    light_curves = cell(0);
    errors = cell(0);
    times = cell(0);
    Coords =cell(0);
    GeneralRMS = cell(0);
    Events = cell(0);
    Bp = cell(0);

  
        % Get list of all .mat files in the current directory
        files = dir(fullfile(directory_path, 'sys*LC.mat'));

        % Loop through each .mat file in the current directory
        for j = 1:length(files)
            % Load data from the current file
            file_path = fullfile(directory_path, files(j).name);
            data = load(file_path);
            Coords{end+1} = data.MD.Coords;
            Events{end+1} = data.MD.Events{1};
            GeneralRMS{end+1} = data.MD.GeneralRMS;
            Bp{end+1} = data.MD.Bp;

            data = data.MD.LC;
            j


           

            % Store data in matrices
            light_curves{end+1} = data(:, 1);
            errors{end+1} = data(:, 2);
            times{end+1} = data(:, 3);
        end
 
end
