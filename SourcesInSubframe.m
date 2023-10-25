classdef SourcesInSubframe
    % An object that extract , compute and plots relvant data collected by
    % the LAST observatory 
    % 
    % Properties
    %
    %
    % Methods
    
    properties
        ObsDate    % Input - syntax - [dd mm yyyy] i.e. [22 08 2023]
        Mount      % Input - [1-10] - int
        CamNumber  % Input - choose a camera [1-4]
        Subframe   % Input - [1-24]
        Path       % get path from input
        Sources    % A WD structure of sources and their data
        Data(1,1) struct % some data to contain
    end
    
    methods
        
        function Result = get.Path(Obj)
            
            cd('/home/ocs');
            
            cd('../../') ; 
            
            
            % get data path
            
            
            if Obj.CamNumber <= 2 
                
                keyword = 'last*e';
                
                if Obj.CamNumber == 1
                    
                    DataDir = 'data1' ;
                   
                    
                else
                    
                    DataDir = 'data2' ;
                    
                end
                    
                    
                
            else
                
                keyword = 'last*w';
                
                if Obj.CamNumber == 3
                    
                    DataDir = 'data1' ;
                    
                else
                    
                    DataDir = 'data2' ;
                    
                end                
                
            end
            
            if Obj.Mount < 10 
            
                
            T = strcat('LAST.01.0',num2str(Obj.Mount),'.','0',num2str(Obj.CamNumber));
            
            else
                
            T = strcat('LAST.01.',num2str(Obj.Mount),'.','0',num2str(Obj.CamNumber));
            
            end
            
            month = num2str(Obj.ObsDate(2));
            day = num2str(Obj.ObsDate(1));
            
            if length(month) == 1 
                
                month = strcat('0',month) ;
            end
            
            if length(day) == 1
                
                day = strcat('0',day);
                
            end
                
            
            Dir = dir(keyword);
            
            Result = strcat(Dir.name,'/',DataDir,'/archive/',T,'/',...
                num2str(Obj.ObsDate(3)),'/',month,'/',day,'/proc');
            
          %  fprintf(['Path : ', Result, '\n'])
            
            Obj.Path = Result;
            
        end            
            
            
        function MS = CreateMS(Obj,Args)
            % Create a matched sources object for the date and subframe of
            % Obj
            
            arguments
                Obj
                Args.DirIdx = 3;
            end
            
            Pathto = Obj.Path;
            
   
            cd(Pathto)
            
            Dir = dir;
            
            fprintf(['\nCreating MatchSource object from Directory : ' ,Dir(Args.DirIdx).name,'\n'])        
           
            cd(Dir(Args.DirIdx).name)
            %cd(Dir.name) ;
            %cd(DataDir)  ;
            %cd('archive');
            %dir(T);
            
            
            
            %if Obj.
            
            %pathway = 
            
            
            
            %MS =  inputArg1 + inputArg2;
        end          
        
        
        function Obj = get_Data(Obj,Args)
            % Get relvant data from catalogs of a specific directory
            % default : first directory in the path given by date
            % Input - 
            %       SourcesInSubframe object
            %       Arguments :
            %
            %       DirIdx - change to any directory
            
            
            arguments
                Obj
                Args.DirIdx = 3;
            end
            
            
            
            Pathto = Obj.Path;
            
   
            cd(Pathto)
            
            Dir = dir;
            
            fprintf(['\nGetting data from Directory : ' ,Dir(Args.DirIdx).name,'\n'])        
           
            cd(Dir(Args.DirIdx).name)
            
            if length(num2str(Obj.Subframe)) > 1 
            
                GeneralName = strcat('*_0',num2str(Obj.Subframe),'_sci_proc_Cat*');
            else
                GeneralName = strcat('*_00',num2str(Obj.Subframe),'_sci_proc_Cat*');
            end
            
            FileNames = AstroImage.readFileNamesObj(GeneralName);
            
            LIMMAG   = zeros(length(FileNames),1);
            FieldID  = [] ;
            
            for i = 1 : length(FileNames)
                
                LIMMAG(i) = FileNames(i).Key.LIMMAG;
                
                FieldID   = [FieldID ; FileNames(i).Key.FIELDID];
                
            end
            
            FieldName = unique(FieldID,'rows');
            
            if length(FieldName(:,1)) > 1
                
                fprintf('\nProblem In Field List \n')
                
            end
            
            
            % get limmag , fieldID
            % from header
            [MaxLimmag,MaxIdx] = max(LIMMAG) ;
            
            ExtractFrom = FileNames(MaxIdx);
            
            RA  = FileNames(MaxIdx).Key.CRVAL1;
            Dec = FileNames(MaxIdx).Key.CRVAL2;
            
            R1 = FileNames(MaxIdx).Key.RA1
            R2 = FileNames(MaxIdx).Key.RA2
            R3 = FileNames(MaxIdx).Key.RA3
            R4 = FileNames(MaxIdx).Key.RA4
            
            D1 = FileNames(MaxIdx).Key.DEC1
            D2 = FileNames(MaxIdx).Key.DEC2
            D3 = FileNames(MaxIdx).Key.DEC3
            D4 = FileNames(MaxIdx).Key.DEC4
            
            
            % compare CRVAL1 & CRVAL2 with the center of RA1234&Dec1234
            
            
            
            Obj.Data(1).FieldID = FieldName ;
            Obj.Data(1).LIMMAG  = MaxLimmag ;
            Obj.Data(1).Coord = [(R4+R2)/2,(D2+D4)/2];
            
            fprintf(['\nFor subframe ',num2str(Obj.Subframe),' Field ', FieldName])
            fprintf(['\nMaximal Limiting Magnitude is ', num2str(MaxLimmag)])
            fprintf(['\n(in directory : ',Dir(Args.DirIdx).name,')\n'])

           
        end        
        
        function obj = GetSources(inputArg1,inputArg2)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

