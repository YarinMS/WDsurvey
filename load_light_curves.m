
function [light_curves, errors, times] = load_light_curves(directory_path)
    % Get list of all directories in the specified path
    directories = dir(directory_path);
    directories = directories([directories.isdir]); % Filter out non-directories

    % Initialize cell arrays to store data
    light_curves = cell(0);
    errors = cell(0);
    times = cell(0);

    % Loop through each directory
    for i = 1:length(directories)
        % Skip '.' and '..' directories
        if strcmp(directories(i).name, '.') || strcmp(directories(i).name, '..')
            continue;
        end

        % Get path to the current directory
        current_dir_path = fullfile(directory_path, directories(i).name);

        % Get list of all .mat files in the current directory
        files = dir(fullfile(current_dir_path, '*LC.mat'));

        % Loop through each .mat file in the current directory
        for j = 1:length(files)
            % Load data from the current file
            file_path = fullfile(current_dir_path, files(j).name);
            data = load(file_path);
            data = data.Ysys;

            % Store data in matrices
            light_curves{end+1} = data(:, 1);
            errors{end+1} = data(:, 2);
            times{end+1} = data(:, 3);
        end
    end
end
