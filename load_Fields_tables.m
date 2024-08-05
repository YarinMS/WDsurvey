function [FieldJD,FieldAM,FieldCoord] =load_Fields_tables(directory_path)
    % Get list of all directories in the specified path
    %directories = dir(directory_path);
    %directories = directories([directories.isdir]); % Filter out non-directories

    % Initialize cell arrays to store data
    FieldJD    = cell(0);
    FieldAM    = cell(0);
    FieldCoord = cell(0);

        files = dir(fullfile(directory_path, 'Field_Results*'));


        % Get path to the current directory
        %current_dir_path = fullfile(directory_path, directories(i).name);

        % Get list of all .mat files in the current directory
     

        % Loop through each .mat file in the current directory
        for j = 1:length(files)
            % Load data from the current file
            file_path = fullfile(directory_path, files(j).name);
            data = load(file_path);
            data = data.Results;

            % Store data in matrices
            FieldCoord{end+1} = data.Coord(1,:);
            FieldJD{end+1}    = data.JD;
            FieldAM{end+1}    = data.AM;
            
        end
   
end




