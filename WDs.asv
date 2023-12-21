% A class that finds and characterize targets in LAST data
% Detailed documentation is required. . . . . . .(one day)



classdef WDs
    
    
    properties
        
        % Properties to input:
        
        Path   % A proc folder containing the targets cat and proc fits 
        Name
        RA
        Dec
        G_g
        G_Bp
        G_Rp
        
        % Properties to aquire:
        
        FieldID  % Add field name - take from path
        CropID   % Add subframe number after providing a path 
        Data     % Catalog Data and Forced Photometry Data
        
        
    end
    
    
    methods % constructor
        
        function obj = WDs(Path,Name,RA,Dec,G_g,G_Bp,G_Rp)
            
            obj.Path = Path;
            obj.Name = Name;
            obj.RA   = RA;
            obj.Dec  = Dec;
            obj.G_g  = G_g;
            obj.G_Bp = G_Bp;
            obj.G_Rp = G_Rp;
        
        
        % obj.FieldID = getFieldID()
        
        % obj.CropID  = getCropID()

        % obj.Data    = extractData()
        
        
        end
        
        
        
        
        
        
        
    end
    
    
    methods (Access = private)
        
        function [ai] = DS9plot(obj)
            
        end
        
        function FieldID = getFieldID(obj)
            
            
            
            
        end
        
        function [FlagMap] = Coo_to_Subframe(obj)
            
             Pattern = '*001_001_*proc_Image_1.fits';
             
             cd(obj.Path)
             
             tic
             ai = AstroImage.readFileNamesObj(Pattern);
             t0 = toc;
             sprintf('Loaded the first exposure from the current visit, For all subframes only %f Sec ',t0)
             
             % creat a flag map [Ntgts x N subframes]
             FlagMap = false(length(obj.RA),24);
             % FieldID
             
             
             Ntgts = 
             for Itgt = 1 : n
             
             
             
        end
             
             
             
             
           
             
            
            
        
        
        
        
        
    end
        
        
    
    
    
    
    
    
    
end