function Result = rdirMSfast(Args)
            % Recursive search for MergedMat files and return file names.
            %   The output is a structure array in which each element
            %   contains the file name, sorted by date & time.
            % Input  : * ...,key,val,...
            %            'FileTemplate' - File name template to search
            %                   Should have CropID in the template to avoid
            %                   getting all of them.
            %            'Path' - Path in which to start the recursive
            %                   search. Default is pwd.
            % Output : - A structure array with field
            %            .FullName containing
            %               a cell array of full file names (including path).
            %               The structure is an array in which each element
            %               corresponds to a different CropID.
            %            .Folder - A cell array of folders.

            arguments
                Args.FileTemplate       = '*.hdf5';
                Args.Path               = pwd;
            end

            PWD = pwd;
            cd(Args.Path);
            List = struct2table(dir(fullfile("**",Args.FileTemplate)));
            List = sortrows(List, 'name');

            Result.FileName = List.name;
            Result.Folder   = List.folder;            
            cd(PWD);
        end