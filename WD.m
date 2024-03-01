% WD class - A tool to help find and characterize targets in LAST data
% Properties:
%           RA   - Right Ascention
%           Dec  - Declination
%           Mag  - Gaia G Mag
%           Name - Target Name
%           Pathway - 1 proc folder containing the targets
%           ...



% Methods:
%
%
%
%
%
% Functions:
%
%
%
%
%
%
%
%
%



classdef WD
    
    properties 
        
        RA       % Right Ascention
        Dec      % Declination
        Mag      % Gaia g mag
        Name     % name of target
        Pathway  % A proc folder containing the targets cat and proc fits
        
        % Properties to aquire:
        
        FieldID    % Add field name - take from path
        CropID     % Add subframe number after providing a path 
        CatID      % Add subframe number found in catalog after providing a path 
        CoaddID    % Add subframe number found in Coadd catalog
        NobsCoadd  % Add the number of coadd images the target appears
        LC_psf     % Add light curve from catalog (MAG_PSF)
        LC_aper    % Add light curve and error bars from catalog (MAG_APER)
        LC_coadd   % Add light curve from coadd catalog.
        LC_FP      % Add light curve and error bars from forcedPhotAll
        LC_FP_Info % [RA DEC  X Y] of source in each frame.
        RMS        % Add Catalog JD
        RMStimeseries % Add Coadd JD
        Flux     % Add flux from catalog
        FluxRMS
        InfoPsf
        InfoAper
        AirMass
        Ndir
        PathToDir
        
    end
    
    properties (Dependent)
        
       
    end

    
    
    methods % constructor
        
        function obj = WD(RA,Dec,Mag,Name,Pathway)
            
            obj.RA      = RA  ;
            obj.Dec     = Dec ;
            obj.Mag     = Mag ;
            obj.Name    = Name;
            obj.Pathway = Pathway;
            
            
            
        end

  
       function obj = get_id(obj, Info)
        
            obj.CropID = Info;
       end
        
       function obj = get_cat_id(obj, Info)
        
            obj.CatID = Info;
       end
        
       function obj = get_fieldID(obj, Info)
        
            obj.FieldID = Info;
       end 
       
       function obj = get_CoaddID(obj, Info)
        
            obj.CoaddID = Info;
       end 
       
       function obj = get_NobsCoadd(obj, Info)
        
            obj.NobsCoadd = Info;
       end 

       function obj = get_FP(obj, Info)
        
            obj.LC_FP = Info;
       end

       function obj = get_FP_Info(obj, Info)
        
            obj.LC_FP_Info = Info;
       end
       
       function obj = get_AirMass(obj, Info)
        
            obj.AirMass = Info;
       end
       
       function H = plotHISTOGRAM(obj, Args)
           
           arguments
               obj
               Args.Threshold = 10;
           end
           
           Total   = [];
           catalog = [];
           coadd   = [];
           
           for i = 1 : length(obj.RA)
               
               if obj.CropID(i) > 0 
                    
                   Total = [Total ; obj.Mag(i)];
               end
               
               if obj.CatID(i) > 0 
                   
                   catalog = [ catalog ; obj.Mag(i)];
               end
               
               if obj.CoaddID(i) > 0
                   
                   if obj.NobsCoadd(i) > Args.Threshold
                       
                       coadd = [ coadd ; obj.Mag(i)];
                   end
               end
           end
               
           
           figure();
           h1 = histogram(Total,10);
           hold on
           h3 = histogram(coadd,'BinEdges',h1.BinEdges);
           hold on
           h2 = histogram(catalog,'BinEdges',h1.BinEdges);
           
           legend('Total WD in field','Detected in Coadd Image','Detected in single Image')
               
       end
          
       
       function P = plotLC(obj,Args)
           
           arguments
               
               obj
               Args.Index       = {};
               Args.id          = [];
               Args.Xlabel      = ['Time'];
               Args.Ylabel      = [];
               Args.Interpreter = 'latex';
               Args.FontSize    = 18;
               Args.YDir        = 'reverse';
               Args.Ylim        = true;
               Args.Deltay      = 0.3;

           end
           
           if Args.Ylim 
               % calc y lim 
               fprintf('\nTrying to find optimal y-axis limits')
               ymax_psf  = max(obj.LC_psf{2}(Args.id,:));
               ymin_psf  = min(obj.LC_psf{2}(Args.id,:));
               ymean_psf  = mean(obj.LC_psf{2}(Args.id,:),'omitnan');
               
               ymax_aper = max(obj.LC_aper{2}(Args.id,:));
               ymin_aper = min(obj.LC_aper{2}(Args.id,:));
               ymean_aper  = mean(obj.LC_aper{2}(Args.id,:),'omitnan');
               
               
               
               
               del_psf   = ymax_psf - ymin_psf;
               
               del_aper  = ymax_aper - ymin_aper;
               
               if abs(del_psf-del_aper) < 0.6
                   
                   delta_y =    Args.Deltay + del_psf./2;
                   
               else
                   
                  fprintf('\nThe diffrences in the light curve scatter is too big, ploting with LARGE y limits ')
                  delta_y = 2 + del_psf./2;
               end
             
               
           end
           
           
           
           % e.LC_psf = {1}{Nobj x Nobs} - time
           %            {2}{Nobj x Novs} - mag_psf 
           t_psf = datetime(obj.LC_psf{1}(Args.id,:),'convertfrom','jd');
           t_aper = datetime(obj.LC_aper{1}(Args.id,:),'convertfrom','jd');
           figure();
           subplot(2,1,1)
           P               = plot(t_psf,obj.LC_psf{2}(Args.id,:),'k.');
           px              = xlabel(Args.Xlabel);
           px.Interpreter  = Args.Interpreter;
           px.FontSize     = Args.FontSize  ;
           py              = ylabel(Args.Ylabel);
           py.Interpreter  = Args.Interpreter;
           py.FontSize     = Args.FontSize  ;
           tit             = title([obj.Name(Args.id,:),' Gaia g mag = ',num2str(obj.Mag(Args.id))]);
           tit.Interpreter = Args.Interpreter;
           lg              = legend(['RMS psf = ',num2str(obj.InfoPsf(Args.id,7))]);
           lg.Interpreter  = Args.Interpreter;
           
           
           if Args.Ylim
               
               ylim([ymean_psf - delta_y/2,ymean_psf+delta_y])
           end
           
           
           
           set(lg,'FontSize',11);
           set(gca,'YDir',Args.YDir);
           %axis tight
           
           subplot(2,1,2)
           P               = plot(t_aper,obj.LC_aper{2}(Args.id,:),'k.');
           px              = xlabel(Args.Xlabel);
           px.Interpreter  = Args.Interpreter;
           px.FontSize     = Args.FontSize  ;
           py              = ylabel(Args.Ylabel);
           py.Interpreter  = Args.Interpreter;
           py.FontSize     = Args.FontSize  ;
          
           lg              = legend(['RMS Aper 3 = ',num2str(obj.InfoAper(Args.id,7))]);
           lg.Interpreter  = Args.Interpreter;
           
           if Args.Ylim
               
               ylim([ymean_aper - delta_y/2,ymean_aper+delta_y])
           end
           
           set(lg,'FontSize',11);
           set(gca,'YDir',Args.YDir)
           %axis tight
           
           
           
       end
       
       
       function P = plotLCERR(obj,Args)
           
           arguments
               
               obj
               Args.Index       = {};
               Args.id          = [];
               Args.Xlabel      = ['Time'];
               Args.Ylabel      = [];
               Args.Interpreter = 'latex';
               Args.FontSize    = 12;
               Args.YDir        = 'reverse';
               Args.Name        = {}
               

           end
           
           if isempty(Args.Name)
               
           
                 Args.Name = obj.Name(Args.id,:);
                 
           end
     
           
           
           % e.LC_psf = {1}{Nobj x Nobs} - time
           %            {2}{Nobj x Novs} - mag_psf 
           %t_psf = datetime(obj.LC_psf{1}(Args.id,:),'convertfrom','jd');
           %t_aper = datetime(obj.LC_aper{1}(Args.id,:),'convertfrom','jd');
           %figure();
            m = obj.LC_psf{2}(Args.id,~isnan(obj.LC_psf{2}(Args.id,:)));
            Median   = median(m);
            MAD = sort(abs(Median-m));
            mid = round(length(MAD)/2);
            if mid > 0
           
                 SDrobust1= 1.5*MAD(mid);
           
            else
                 SDrobust1 = nan;
           
            end
           
           
           
           
           P               =errorbar(obj.LC_psf{1}(Args.id,:),obj.LC_psf{2}(Args.id,:),obj.LC_psf{3}(Args.id,:),"o","MarkerSize",2,...
               "MarkerEdgeColor","black")
           P.Color = 'black';
           px              = xlabel(Args.Xlabel)
           px.Interpreter  = Args.Interpreter;
           px.FontSize     = Args.FontSize  ;
           py              = ylabel(Args.Ylabel)
           py.Interpreter  = Args.Interpreter;
           py.FontSize     = Args.FontSize  ;
           tit             = title('Catalog LC ');
           tit.Interpreter = Args.Interpreter'
           lg              = legend(['RobustSD = ',num2str(SDrobust1)]);
           lg.Interpreter  = Args.Interpreter
           lg.Location = 'best'
           set(lg,'FontSize',11,'Interpreter','latex');
           set(gca,'YDir',Args.YDir)
           axis tight
           
           
       end
       

       
       
       
              function P = plotLCERR_FP(obj,Args)
           
           arguments
               
               obj
               Args.Index       = {};
               Args.id          = [];
               Args.Xlabel      = ['Time'];
               Args.Ylabel      = [];
               Args.Interpreter = 'latex';
               Args.FontSize    = 18;
               Args.YDir        = 'reverse';
               Args.Name        = {}
               

           end
           
           if isempty(Args.Name)
               
           
                 Args.Name = obj.Name(Args.id,:);
                 
           end
           
           %time  = obj.LC_FP{1}(Args.id,:)-2460183.5;
           mag = obj.LC_FP{2}(Args.id,:) ;
           magerr  = obj.LC_FP{3}(Args.id,:)
           
           [~,idx] = sort(time);
           Median   = median(mag);
           MAD = sort(abs(Median-mag));
           mid = round(length(MAD)/2);
           SDrobust = 1.5*MAD(mid);
           rms = SDrobust;
           
           
           
     
          
           
           
           
           figure();
           P               = errorbar(time(idx),mag(idx),magerr(idx),"-o","MarkerSize",2,...
               "MarkerEdgeColor","black")
           P.Color = 'black';
           px              = xlabel(Args.Xlabel)
           px.Interpreter  = Args.Interpreter;
           px.FontSize     = Args.FontSize  ;
           py              = ylabel(Args.Ylabel)
           py.Interpreter  = Args.Interpreter;
           py.FontSize     = Args.FontSize  ;
           tit             = title([Args.Name ,' Gaia g mag = ',num2str(obj.Mag(Args.id))])
           tit.Interpreter = Args.Interpreter
           lg              = legend(['RobustSD = ',num2str(rms)])
           lg.Interpreter  = Args.Interpreter
           set(lg,'FontSize',11);
           set(gca,'YDir',Args.YDir)
           axis tight
           
           
       end
       
   
       function P = plotRMSseries(obj,Args)
           
           arguments
               
               obj
               Args.Index       = {};
               Args.id          = [];
               Args.Xlabel      = ['Time'];
               Args.Ylabel      = ['RMS'];
               Args.Interpreter = 'latex';
               Args.FontSize    = 10;
               Args.YDir        = 'reverse';

           end
           
           
           
           % e.LC_psf = {1}{Nobj x Nobs} - time
           %            {2}{Nobj x Novs} - mag_psf 
           t_psf = datetime(obj.RMS{2,1}(Args.id,:),'convertfrom','jd');
           t_aper = datetime(obj.RMS{1,1}(Args.id,:),'convertfrom','jd');
           figure();
           subplot(2,1,1)
           P = semilogy(t_psf,obj.RMS{2,2}(Args.id,:),'-o')
           px = xlabel(Args.Xlabel)
           px.Interpreter = Args.Interpreter;
           px.FontSize   = Args.FontSize  ;
           py = ylabel(Args.Ylabel)
           py.Interpreter = Args.Interpreter;
           py.FontSize   = Args.FontSize  ;
           tit = title([obj.Name(Args.id,:),' RMS time series in log scale  G mag = ',num2str(obj.Mag(Args.id))])
           tit.Interpreter = Args.Interpreter
           lg = legend(['general RMS psf = ',num2str(obj.InfoPsf(Args.id,7))])
           lg.Interpreter = Args.Interpreter
           set(gca,'FontSize',10);
           %set(gca,'YDir',Args.YDir)
           %axis tight
           
           subplot(2,1,2)
           P = semilogy(t_aper,(obj.RMS{1,2}(Args.id,:)),'-o')
           px = xlabel(Args.Xlabel)
           px.Interpreter = Args.Interpreter;
           px.FontSize   = Args.FontSize  ;
           py = ylabel(Args.Ylabel)
           py.Interpreter = Args.Interpreter;
           py.FontSize   = Args.FontSize  ;
           %title([obj.Name(Args.id,:),' Gaia g mag = ',num2str(obj.Mag(Args.id))])
           lg = legend(['general RMS Aper 3 = ',num2str(obj.InfoAper(Args.id,7))])
           lg.Interpreter = Args.Interpreter
           set(gca,'FontSize',10);
           %set(gca,'YDir',Args.YDir)
           %axis tight
           
           
           
       end
   
       
       
       
       
    end % methods 1
        
        
        
     methods  (Static)
         
         
         
         function [ai] = get_target(AI,obj,idx,subframe)
          % From one AstroImage, plot it together with an
          % aperture on a target
           %   Detailed explanation goes here
           target_ra  = obj.RA(idx);
           target_dec = obj.Dec(idx);
           flag = true;


           ds9(AI(subframe))

           [x,y] = ds9.coo2xy(target_ra,target_dec);


%ds9.plot(x+1,y+1,'go','Size',8,'text',info);

            if (x > 1726 - 128) || (x < 128)
                
                fprintf(['Target on the edge. RA = ',num2str(target_ra),' Dec = ', num2str(target_dec),' subframe #',num2str(subframe),'( ',num2str(x),',',num2str(y),'\n'])
                if x > 64
                    if x < 1726-64
                         flag = false;
                         ai = AI(subframe).Image(y-64:y+64,x-64:x+64);
                         ds9(ai)
                         ds9.plot(64+2,64+2,'go','Size',8,'text',obj.Name(idx,:));
                         ds9.plot(64,10,'g','Size',1,'text',['G mag = ',num2str(obj.Mag(idx))]);   
                         ds9.plot(64,150,'r','Size',1,'text',['sub frame #',num2str(subframe)]);
                         info = obj.Name(idx,:);
                         ds9.read2fits(info);
                         fprintf(['\nSaved a tiny region around ', obj.Name(idx,:),'\n'])
                    end
                end
                
            else
                
                if (y > 1726 - 128) || (y < 128)
                    fprintf(['\nTarget on the edge. RA = ',num2str(target_ra),' Dec = ', num2str(target_dec),' subframe #',num2str(subframe),'( ',num2str(x),',',num2str(y),'\n'])
                    if y > 64
                        if y < 1726 - 64
                            flag = false;
                             ai = AI(subframe).Image(y-64:y+64,x-64:x+64);
                             ds9(ai)
                             ds9.plot(64+2,64+2,'go','Size',8,'text',obj.Name(idx,:));
                             ds9.plot(64,10,'g','Size',1,'text',['G mag = ',num2str(obj.Mag(idx))]);   
                             ds9.plot(64,150,'r','Size',1,'text',['sub frame #',num2str(subframe)]);
                             info = obj.Name(idx,:);
                             ds9.read2fits(info);
                             fprintf(['Saved a tiny region around ', obj.Name(idx,:),'\n'])
                        end 
                    end
                    
                else
                    flag = false;
                    ai = AI(subframe).Image(y-128:y+128,x-128:x+128);
                    ds9(ai);
                    ds9.plot(128+2,128+2,'go','Size',8,'text',obj.Name(idx,:));
                    ds9.plot(128,10,'g','Size',1,'text',['G mag = ',num2str(obj.Mag(idx))]);
                    ds9.plot(128,250,'g','Size',1,'text',['sub frame #',num2str(subframe)]);
                    info = obj.Name(idx,:);
                    ds9.read2fits(info);
                    fprintf(['Saved a tiny region around ', obj.Name(idx,:),'\n'])
            
                end
            end
            
            if flag
                ai = 0;
                
            end
           

            end
         
         function [ai,MinDist] = get_target_full(AI,obj,idx,subframe)
          % From one AstroImage, plot it together with an
          % aperture on a target
           %   Detailed explanation goes here
           target_ra  = obj.RA(idx);
           target_dec = obj.Dec(idx);
           flag = true;


           ds9(AI(subframe))

           [x,y] = ds9.coo2xy(target_ra,target_dec);


%ds9.plot(x+1,y+1,'go','Size',8,'text',info);
                    flag = false;
                    ai = AI(subframe).Image;
                    ds9(ai);
                    ds9.plot(x,y,'go','Size',8,'text',obj.Name(idx,:));
                    ds9.plot(x-2,y-250,'g','Size',1,'text',['G mag = ',num2str(obj.Mag(idx))]);
                    ds9.plot(x-2,y+250,'g','Size',1,'text',['sub frame #',num2str(subframe)]);
                    
                    xmin     = abs(x);
                    xmax     = abs(x-1726);
                    minxdist = round(min(xmin,xmax));
                    
                    ymin     = abs(y);
                    ymax     = abs(y-1726);
                    minydist = round(min(ymin,ymax));
                    MinDist = [minxdist ; minydist ]
                    
                    ds9.plot(x-2,y+300,'g','Size',0.1,'text',['distance from vertical edge #',num2str(minxdist),' pix']);
                    ds9.plot(x-2,y+350,'g','Size',0.1,'text',['distance from horizontal edge #',num2str(minydist),' pix']);

                    info = obj.Name(idx,:);
                    ds9.read2fits(info);
                    fprintf(['Saved a tiny region around ', obj.Name(idx,:),'\n'])
            
                
            end
            
 
           
             
         
        
        function [id,FieldId] = Coo_to_Subframe(Path,obj) 
        % For a specific directory, look for targets in *all* sub images
        % Input :
        %         path - the main path including directory 
        %                 example :
        %                 '/last02e/data1/archive/LAST.01.02.01/2023/07/20/proc/36'

        %         Coordinate list - col1 : ra
        %                           col2 : dec
        %                           col3 : mag

        % Output: 
        %        Id - vector of sub frame and source index for each target

        %
        %%
        

        pat = '*proc_Image_1.fits';
        
        cd(Path)
        
        % tic;
        ai = AstroImage.readFileNamesObj(pat);
        % t = toc;
        fprintf('Loaded all images in path \n')
        
        
        id = zeros(length(obj.RA),2);
        FieldId = string.empty(length(obj.RA),0);
        for i = 1 : length(ai)
    
        flags = ai(i).isSkyCooInImage(obj.RA,obj.Dec);
    
        if  (sum(flags.InImage) > 0 )
              
            check = id(logical(flags.InImage));
            idx   = logical(flags.InImage);
            for j = 1 : length(idx)
                
               if check == 0
                   
                if idx(j) > 0 
                    
                    id(logical(flags.InImage)) = ai(i).HeaderData.Key.CROPID ;
                    [AI] = obj.get_target(ai,obj,j,ai(i).HeaderData.Key.CROPID);
                    FieldId(logical(flags.InImage)) = ai(i).Header{25,2}
                    
                end
               end
                
            end
              
        else
        
        if (sum(flags.InImage) > 0) 
            
            id(logical(flags.InImage), 2 ) =  ai(i).HeaderData.Key.CROPID;
        end
        
        end   
  
        end
        
        
        for i = 1 : length(id(:,1))
            
            if id(i,1) == 0
                
                fprintf(['Could not find target #',num2str(i),' RA = ',num2str(obj.RA(i)),' Dec = ', num2str(obj.Dec(i)),'\n'])
            end
        end
        
        
    
        
        %obj.get_id(id(:,1));
        
        %obj.get_CropID(obj,id(:,1))
       



        end

        %% find overlapping targets :
        function [id,FieldId,XY] = SubframeOverlap(Path,obj,Args) 
            
        % For a specific directory, look for targets in *all* sub images
        
        % Input :
        %         path - the main path including directory 
        %                 example :
        %                 '/last02e/data1/archive/LAST.01.02.01/2023/07/20/proc/36'

        %         Coordinate list - col1 : ra
        %                           col2 : dec
        %                           col3 : mag

        % Output: 
        %        Id - vector of sub frame and source index for each target

        %
        %%
        arguments
            
            Path
            obj
            Args.Index = 1; % choose a star you suspect is on the edge
          
            
            
        end
        
        
        XY = [];
        pat = '*proc_Image_1.fits';
        
        cd(Path)
        
        % tic;
        ai = AstroImage.readFileNamesObj(pat);
        % t = toc;
        fprintf('Loaded all images in path \n')
        
        
        id = zeros(1,4);
        FieldId = string.empty(4,0);
        count = 1;
        for i = 1 : length(ai)
    
        flags = ai(i).isSkyCooInImage(obj.RA(Args.Index),obj.Dec(Args.Index));
        
    
        if  (sum(flags.InImage) > 0 ) 
            
            if count == 1
                subframe = ai(i).HeaderData.Key.CROPID ;
                id(1,count) = ai(i).HeaderData.Key.CROPID ;
                [AI,xy] = obj.get_target_full(ai,obj,Args.Index,ai(i).HeaderData.Key.CROPID);
                XY = [XY ; xy'];
                FieldId(count) = ai(i).Header{25,2};
                count = count + 1;
            else
                
                if ~ismember( ai(i).HeaderData.Key.CROPID, id(1,1:count-1)) 
                    id(1,count) = ai(i).HeaderData.Key.CROPID ;
                    [AI,xy] = obj.get_target_full(ai,obj,Args.Index,ai(i).HeaderData.Key.CROPID);
                    XY = [XY ; xy'];
                    FieldId(count) = ai(i).Header{25,2};
                    count = count + 1;
                end
                
            end
                

        end
        
       end   
        
    
        for i = 1 : length(id(1,:))
            
            if id(1,i) ~= 0
                
                fprintf(['found target #',num2str(Args.Index),' RA = ',num2str(obj.RA(Args.Index)),' Dec = ', num2str(obj.Dec(Args.Index)),' In subframe ',num2str(id(1,i)),'\n'])
            end
        end
        
        end
        
        
    
        %% test forced photmetry as a matched sources object
        
            
        
        
       %% find in catalog fits files.
       
       function [INDEX,id] = find_in_cat(obj)

           % Load obs         
                    
           cd(obj.Pathway)
             
           % creating matched sources object from visit 1 (24 sub-images)


           MS1 = MatchedSources.read_rdir('*_sci_merged_MergedMat_*.hdf5');

           id = zeros(length(obj.RA),1);
           INDEX = cell(length(obj.RA),1);
           for j = 1 : length(obj.RA)
    
    
                 for i = 1 : 24
    

                  
                  if ~isempty( MS1(i).coneSearch(obj.RA(j),obj.Dec(j)).Ind)
            
                         fprintf(['WD number ' , num2str(j),' found in subframe ',num2str(i),'\n'])
            
                         if isempty(INDEX{j,1})
                
                             INDEX{j,1} = i;
                             id(j) = i;
                
                         else
                
                         INDEX{j,1} = [INDEX{j,1} i];
                
                
                         end
                  end
        
                 end
                  
           end
       end
    
       
       
        
 %% find in coadd images.
 
 
       function [m,m2,ID,id,Nobs] = find_in_coadd(obj,threshold) 
       % For a specific directory, look for targets in *all* sub images
       % Input :
       %         path - the main path including directory 
       %                 example :
       %                 '/last02e/data1/archive/LAST.01.02.01/2023/07/20/proc/'

       %%
       cd(obj.Pathway)
       cd ../
       f        = dir;
       Nfolders = length(f)-2 ;
       
       Nobj     = length(obj.RA); 

       id       = zeros(Nobj,3);
       
       



       m = nan(Nfolders,Nobj,3) ;
       m2 = nan(Nfolders,Nobj,3) ;
       Nobs = zeros(Nobj,1);
       ID = zeros(Nobj,1);
       id = zeros(Nobj,1);

       for w = 1 : Nfolders
    
           flags = false(Nobj,1);
           cd(num2str(w))
    
           FileNames = dir('*coadd_Cat_1.fits');
    
           if ~isempty(strfind(FileNames(1).name, obj.FieldID(1)))
        
                  for l = 1 : length(FileNames)
            
                        for tgt = 1 : Nobj
                
                
    
                         AC = AstroCatalog({FileNames(l).name},'HDU',2);
                         FN = FITS.readHeader1(FileNames(l).name,3);
                         tgt_found = AC.coneSearch(obj.RA(tgt),obj.Dec(tgt)).Ind;
        
                         if ~isempty(tgt_found)
                    
                             if ~flags(tgt)
            
                                  %fprintf(['found WD number ',num2str(tgt),' in folder ',num2str(w),' in subframe ',num2str(l),'\n'])
            
                                  m(w,tgt,1) = AC.Catalog(tgt_found,48);
                                  m(w,tgt,2) = AC.Catalog(tgt_found,49);
                                  m(w,tgt,3) = FN{30,2};
                                  sub = FileNames(l).name(56:58);
                                  sub = str2num(sub);
                        
                                  flags(tgt)  = 1 ;
                        
                                  id(tgt) = sub;
                     
                              else
                        
                        % fprintf(['found WD number ',num2str(tgt),' ALSO in folder ',num2str(w),' in subframe ',num2str(l),'\n'])
                                  m2(w,tgt,1) = AC.Catalog(tgt_found,48);
                                  m2(w,tgt,2) = AC.Catalog(tgt_found,49);
                                  m(w,tgt,3)  = FN{30,2};
                     
                                  sub = FileNames(l).name(56:58);
                                  sub = str2num(sub);
                                  ID(tgt) = sub;
                             end
                         end
                       end
                  end
           end
           cd ../ 
       end
            
       Npoints = sum(~isnan(m(:,:,1))) 
       Nobs    = Npoints;

   %    for k = 1 : length(obj.RA)
    
    %        if Npoints(k) > threshold
        
     %           Nobs(k) = Npoints(k);
        
      %      end
      % end
                    
            
            
            
       end
       
       function Coord = get_Coord (MSobj,index)



            nindex = 1;
        
    
            while isnan(MSobj.Data.RA(nindex,index))
        
                nindex = nindex + 1;
           
        
                if nindex > MSobj.Nepoch
            
                    nindex = MSobj.Nepoch ;
                    break;
                end
        
            end
        
    
            Coord = [MSobj.Data.RA(nindex,index) MSobj.Data.Dec(nindex,index)  ];

       end
            
       
       function [RMS,notnanval]  = calcRMS(y)
           
           notnanval = sum(~isnan(y)) / 20 ;
           
           if sum(~isnan(y)) > 1
               
               % do RMS
          
               Mean = mean(y,'omitnan');
               sd   = (y - Mean).^2 ;
               meansquare   = mean(sd,'omitnan');
               RMS = sqrt(meansquare);
           else
               if sum(~isnan(y)) > 1
                   
                   RMS = mean(y,'omitnan') ;
                   
               else
                   
                   RMS = nan;
                   
               end
               
           end
               
               
                   
                   
               
       end
       
       function [rms,interval_center,notnan] = RMS_timeseries(obj,t,y,window)
        
           
           Nwindows = floor(numel(y)/window);
           rms      = zeros(Nwindows,1) ;
           notnan      = zeros(Nwindows,1) ;
           interval_center = zeros(Nwindows,1);
           
           for i = 1 : Nwindows 
               
               start = (i-1)*window +1;
               End   = i*window;
               
              % if (start > length(t))  || (End > length(t))
              %     
               %    break
                   
              % end
               
               Window = y(start:End);
               [rms(i),notnan(i)] = obj.calcRMS(Window)  ;
               interval_center(i) = mean(t(start:End),'omitnan');
               
           end
       end

       
       
       
       

       function [t_psf,y_psf,t_aper,y_aper,Info_psf,Info_aper, ... 
               flags,t_rms_aper,t_rms_psf,t_rms_flux,Rms_aper,Rms_psf, ... 
               Rms_flux,t_flux,f_flux,total_rms,magerr,magerrPSF] = get_LC_cat(obj,rms_window,detection_threshold)
           
           % create a general Matched source object and merge it with the
           % relevant ones.

                cd(obj.Pathway)


                Nobj       = length(obj.RA);
                t_psf      = [] ;
                y_psf      = [] ;
                t_aper     = [] ;
                y_aper     = [] ;
                t_rms_aper = [] ;
                t_rms_psf  = [] ;
                t_rms_flux = [] ;
                Rms_aper   = [] ;
                Rms_psf    = [] ;
                Rms_flux   = [] ;
                Info_psf   = [] ;
                Info_aper  = [] ;
                t_flux     = [] ;
                f_flux     = [] ;
                total_rms  = [] ;
                flags  = false(Nobj,1);
                magerr = [];
                magerrPSF = [];


                 % Load obs
                 % creating matched sources object from visit 1 (24 sub-images)







                    MS1 = MatchedSources.read_rdir('*_sci_merged_MergedMat_*.hdf5');

                    cd('../')

                    MS2 = MatchedSources.read_rdir('*_sci_merged_MergedMat_*.hdf5','OrderPart' , 'CropID');

                    fprintf('finished creating the matched sources objects  \n')

                    for j = 1 : Nobj
    
                        if obj.CatID(j) > 0
    
                            % merging coordinates of sources from the 16 sub images in folder 1 to all
                            % folders :
                            ms =  mergeByCoo(MS2(:,obj.CatID(j)),MS1(obj.CatID(j)));
                            Nobs = numel(ms.JD);


                            % finding ZP for MAG_APER_3
                            R = lcUtil.zp_meddiff(ms,'MagField','MAG_APER_3','MagErrField','MAGERR_APER_3');

                            % finding ZP for MAG_PSF   ### please note that MAG_PSF dont have
                            %'MAgFieldERR' so I use MAGERR_APER_2.
                            Rpsf= lcUtil.zp_meddiff(ms,'MagField','MAG_PSF','MagErrField','MAGERR_PSF');



                            [MSaper,ApplyToMagFieldr] = applyZP(ms, R.FitZP,'ApplyToMagField','MAG_APER_3');

                            [MSpsf,ApplyToMagFieldr] = applyZP(ms, Rpsf.FitZP,'ApplyToMagField','MAG_PSF');
          
          
                             % get LC by index :
          
                             index_psf = MSpsf.coneSearch(obj.RA(j),obj.Dec(j)).Ind;
     
                             coord_psf =  obj.get_Coord(MSpsf,index_psf);
          
                             index_aper3 = MSaper.coneSearch(obj.RA(j),obj.Dec(j)).Ind;
          
                             coord_aper3 =  obj.get_Coord(MSaper,index_aper3);
          
          
          
          
          
                              [t1,y1] = MSaper.getLC_ind(index_aper3,{'MAG_APER_3'});
                              [t2,y2] = MSpsf.getLC_ind(index_psf,{'MAG_PSF'});
                              [t3,f2] = MSaper.getLC_ind(index_psf,{'FLUX_APER_3'});
                              magERR  = MSaper.Data.MAGERR_APER_3(:,index_aper3) ;
                              magErr  = MSpsf.Data.MAGERR_PSF(:,index_psf);
                                % RMS APER3
                                total_rms_aper3 = obj.calcRMS(y1);
                                
                                [rms_aper_3,trms_aper_3] = obj.RMS_timeseries(obj,t1,y1,rms_window);
                               
                                %RMS PSF
                                total_rms_psf   = obj.calcRMS(y2);
                                
                                [rms_psf,trms_psf] = obj.RMS_timeseries(obj,t2,y2,rms_window);
                                
                                %RMS FLUX APER 3
                                total_rms_flux = obj.calcRMS(f2);
                                [rms_flux,trms_flux] = obj.RMS_timeseries(obj,t3,f2,rms_window);
                                
          
                                Info_psf  = [Info_psf ; obj.CropID(j) coord_psf(1:2) obj.RA(j) obj.Dec(j) obj.Mag(j) total_rms_psf(1)];
          
                                Info_aper = [Info_aper ; obj.CropID(j) coord_aper3(1:2) obj.RA(j) obj.Dec(j) obj.Mag(j) total_rms_aper3(1)];
                                
                                total_rms = [total_rms ; total_rms_flux] ;
          
           
                                t_psf      = [t_psf ; t2']  ;
                                y_psf      = [y_psf ; y2']  ;
                                t_aper     = [t_aper ; t1'] ;
                                y_aper     = [y_aper ; y1'] ; 
                                t_flux     = [t_flux ; t3'] ;
                                f_flux     = [f_flux ; f2'] ;
                                t_rms_aper = [t_rms_aper ; trms_aper_3'] ;
                                t_rms_psf  = [t_rms_psf ; trms_psf']     ;
                                t_rms_flux = [t_rms_flux ; trms_flux']   ;
                                Rms_aper   = [Rms_aper ; rms_aper_3' ]   ;
                                Rms_psf    = [Rms_psf ; rms_psf'  ]      ;
                                Rms_flux   = [Rms_flux ; rms_flux' ]     ;
                                magerr     = [magerr   ; magERR']        ;
                                magerrPSF  = [magerrPSF ; magErr']       ;
                                    
          
          
                                if sum(~isnan(y2)) > detection_threshold
              
                                    flags(j) = 1;
                                end
                                
                                if flags(j)
                                    
                                    fprintf(['finished analayzing WD #', num2str(j),' ',obj.Name(j,:),' \n'])
                                    
                                else
                                     fprintf(['not enough observation for WD #', num2str(j),' ',obj.Name(j,:),'\n'])
                                    
                                end
                                
                                
                        else

                                Info_psf  = [Info_psf ; obj.CropID(j) nan nan obj.RA(j) obj.Dec(j) obj.Mag(j) nan];
          
                                Info_aper = [Info_aper ; obj.CropID(j) nan nan obj.RA(j) obj.Dec(j) obj.Mag(j) nan];
                                
                                total_rms = [total_rms ; nan] ;
                                
                                ms =  mergeByCoo(MS2(:,1),MS1(1));
                                Nobs = numel(ms.JD);
          
                                T = ones(Nobs,1)*nan;
                                t_psf    = [t_psf ; T'] ;
                                y_psf    = [y_psf ; T'] ;
                                t_aper   = [t_aper ; T'] ;
                                y_aper   = [y_aper ; T' ]; 
                                t_flux   = [t_flux ; T' ] ;
                                f_flux   = [f_flux ; T'] ;
                                magerr   = [magerr ; T'] ;
                                magerrPSF= [magerrPSF ; T'];
                                Tt = ones(floor(Nobs/20),1)*nan;
                                t_rms_aper = [t_rms_aper ; Tt' ] ;
                                t_rms_psf  = [t_rms_psf ; Tt' ] ;
                                t_rms_flux = [t_rms_flux ; Tt' ] ;
                                Rms_aper   = [Rms_aper ; Tt' ] ;
                                Rms_psf    = [Rms_psf ; Tt'  ] ;
                                Rms_flux   = [Rms_flux ; Tt' ] ;
                                      
                            
          
                        end
                    end



          
  

   

       end
        
        
        
        
        
       function [times_vec,LimMag_vec] = Header_LimMag(obj)
           
           if ~isempty(obj.LC_psf)
               %
               Nobs           = length(obj.LC_psf{1}(:,1)) ;
               times_vec      = zeros(Nobs,24)*nan;
               LimMag_vec     = zeros(Nobs,24)*nan;
               Subframe_index = ones(24,1);
               flag = false;
               
           else
               Nobs           = 1440;
               times_vec      = zeros(Nobs,24)*nan;
               LimMag_vec     = zeros(Nobs,24)*nan;
               Subframe_index = ones(24,1);  
               fprintf('Analayzinf field : %s ',obj.FieldID)
               flag = true;
           end
           
           cd(obj.Pathway)
           cd ../
           
           directory = dir;
           
           for i = 3 : length(directory)
               
               cd(directory(i).name)
               
               if flag
                   
                   keyword = strcat('*',obj.FieldID,'*proc_Image*.fits');
                   %keyword = strcat('*proc_Image*.fits');
                   
               else
               
                   keyword = '*'+obj.FieldID(1)+'*proc_Image*.fits';
                   %keyword = strcat('*proc_Image*.fits');
                   
               end
               
               
               field_in = false;
               
               fn = dir; 
               
               for m = 1 : length(fn)
                   
                   if ~isempty(strfind(fn(m).name ,char(obj.FieldID(1,:))))
                       
                       field_in = true; 
                       break;
                       
                   end
               end
               
              
               if field_in
                   
                   H = AstroHeader(char(keyword));
                   
                   for l = 1 : length(H)
                       
                       crop_id = getVal(H(l),'CROPID');
                       
                       if getVal(H(l),'LIMMAG') > 19
                       
                           fprintf('Lim mag higher than 19 \n')
                           
                           
                       end
                       times_vec(Subframe_index(crop_id),crop_id)  = getVal(H(l),'JD');
                       LimMag_vec(Subframe_index(crop_id),crop_id) = getVal(H(l),'LIMMAG');
                       Subframe_index(crop_id) = Subframe_index(crop_id) + 1 ;
                       
                   
                   end
                   
               end
               fprintf(['Finished with folder #',num2str(i),' Out of ',num2str(length(directory)),'\n'])
               cd ../
           end
           
           
           
           
           
           
           
       end
        
        
        
        
       function F = plotFLUX(obj,Args)
           
           
           arguments
               
               obj
               Args.Index       = {};
               Args.id          = [];
               Args.Xlabel      = ['Time'];
               Args.Ylabel      = ['Flux [Counts]'];
               Args.Interpreter = 'latex';
               Args.FontSize    = 18;
               Args.YDir        = 'normal';
               Args.TextShift   = 0;
               Args.placeIn     = 15;
               Args.JDShift     = 2.460173e6;

           end
           
           
           t   = obj.Flux{1}(Args.id,:) ;
           
           T   = datetime(t,'convertfrom','jd');
           f   = obj.Flux{2}(Args.id,:) ;
           RMS = obj.FluxRMS(Args.id)   ;
           
           
           med = median(f,'omitnan')  ; 
           poisson_scatter = sqrt(med);
           SD = std(f,'omitnan');
           
           % Variability calculation
           
           fluxerr = abs(0.4*log(10)*f.*obj.LC_aper{3}(Args.id,:));
           w  = 1./fluxerr;
           V1 = sum(w,'omitnan')   ;
           V2 = sum(w.^2,'omitnan'); 
           weighted_mean = sum(f.*w ,'omitnan')/ sum(w,'omitnan');
           weighted_sd   = sqrt(sum(w.*(f-weighted_mean).^2,'omitnan')/(V1-(V2/V1)));
           Variability  = weighted_sd/weighted_mean ;
           
           figure();
           %subplot(2,1,1)
           P               = errorbar(obj.Flux{1}(Args.id,:)-Args.JDShift,f,fluxerr,'o')
           px              = xlabel(Args.Xlabel)
           px.Interpreter  = Args.Interpreter;
           px.FontSize     = Args.FontSize  ;
           py              = ylabel(Args.Ylabel)
           py.Interpreter  = Args.Interpreter;
           py.FontSize     = Args.FontSize  ;
           tit             = title([obj.Name(Args.id,:),' Gaia g mag = ',num2str(obj.Mag(Args.id))]);
           tit.Interpreter = Args.Interpreter;
           lg              = legend(['Flux Aper3 SD = ',num2str(SD)]);
           lg.Interpreter  = Args.Interpreter
           text(t(floor(length(t)/4))-Args.JDShift,floor(median(f,'omitnan'))+Args.TextShift ,['$\bar{f} = $',num2str(med),' $\sigma =$ ',num2str(SD), ' $\sqrt{\bar{f}} = $ ', ... 
               num2str(poisson_scatter)],'Interpreter',Args.Interpreter,'FontWeight','bold')
           
           text(t(floor(length(t)/4))-Args.JDShift,floor(median(f,'omitnan'))+Args.TextShift-100 ,['$\bar{f}_{Weighted} = $',num2str(weighted_mean),' $\bar{\sigma} =$ ',num2str(weighted_sd), ' $\frac{\bar{\sigma}}{\bar{f}_{W}} = $ ', ... 
               num2str(Variability)],'Interpreter',Args.Interpreter,'FontWeight','bold')
           set(gca,'FontSize',10);
           set(gca,'YDir',Args.YDir)
           %axis tight
        
        
        
       end
       
       function F = plotFLUX2(obj,Args)
           
           
           arguments
               
               obj
               Args.Index       = {};
               Args.id          = [];
               Args.Xlabel      = ['Time'];
               Args.Ylabel      = ['Flux [Counts]'];
               Args.Interpreter = 'latex';
               Args.FontSize    = 18;
               Args.YDir        = 'normal';
               Args.TextShift   = 0;
               Args.placeIn     = 15;
               %Args.JDShift     = 2.460173e6;

           end
           
           
           t   = obj.Flux{1}(Args.id,:) ;
           
           T   = datetime(t,'convertfrom','jd');
           f   = obj.Flux{2}(Args.id,:) ;
           RMS = obj.FluxRMS(Args.id)   ;
           
           
           med = median(f,'omitnan')  ; 
           poisson_scatter = sqrt(med);
           SD = std(f,'omitnan');
           
           % Variability calculation
           
           fluxerr = abs(-0.4*log(10)*f.*obj.LC_aper{3}(Args.id,:));
           w  = 1./fluxerr;
           V1 = sum(w,'omitnan')   ;
           V2 = sum(w.^2,'omitnan'); 
           weighted_mean = sum(f.*w ,'omitnan')/ sum(w,'omitnan');
           weighted_sd   = sqrt(sum(w.*(f-weighted_mean).^2,'omitnan')/(V1-(V2/V1)));
           Variability  = weighted_sd/weighted_mean ;
           
           figure();
           %subplot(2,1,1)
           P               = errorbar(obj.Flux{1}(Args.id,:),f,fluxerr,'o')
           px              = xlabel(Args.Xlabel)
           px.Interpreter  = Args.Interpreter;
           px.FontSize     = Args.FontSize  ;
           py              = ylabel(Args.Ylabel)
           py.Interpreter  = Args.Interpreter;
           py.FontSize     = Args.FontSize  ;
           tit             = title([obj.Name(Args.id,:),' Gaia g mag = ',num2str(obj.Mag(Args.id))]);
           tit.Interpreter = Args.Interpreter;
           lg              = legend(['Flux Aper3 SD = ',num2str(SD)]);
           lg.Interpreter  = Args.Interpreter
           text(t(floor(length(t)/4))-Args.JDShift,floor(median(f,'omitnan'))+Args.TextShift ,['$\bar{f} = $',num2str(med),' $\sigma =$ ',num2str(SD), ' $\sqrt{\bar{f}} = $ ', ... 
               num2str(poisson_scatter)],'Interpreter',Args.Interpreter,'FontWeight','bold')
           
           text(t(floor(length(t)/4))-Args.JDShift,floor(median(f,'omitnan'))+Args.TextShift-100 ,['$\bar{f}_{Weighted} = $',num2str(weighted_mean),' $\bar{\sigma} =$ ',num2str(weighted_sd), ' $\frac{\bar{\sigma}}{\bar{f}_{W}} = $ ', ... 
               num2str(Variability)],'Interpreter',Args.Interpreter,'FontWeight','bold')
           set(gca,'FontSize',18);
           set(gca,'YDir',Args.YDir)
           %axis tight
        
        
        
       end
       
       
       
       
       function [R,LC,X,Y,RA,Dec,AirMass,FP] = forceddraft(obj,Args)
              %UNTITLED Summary of this function goes here
              %   Detailed explanation goes here - Yes
              
              arguments
                  
                 obj
                 Args.Index = 1;
              end

              AI = [];
              
              cd(obj.Pathway)
              
              cd ../
             

              directories = dir;
              counter = 0 ;

              for i = 3 : length(directories)
    
                   cd(directories(i).name)
    
    
                   fn  = FileNames.generateFromFileName('*proc_Image_1.fits');
                       
               if ~ ismissing(obj.FieldID(Args.Index)) 
              
               
    
                    if ~isempty(fn.selectBy('FieldID',char(obj.FieldID(Args.Index))).FieldID)
        
        
                        if obj.CropID(Args.Index) > 0 
                   
                            FN  = fn.selectBy('CropID',obj.CropID(Args.Index));
    
                            AI  = [AI AstroImage.readFileNamesObj(FN)];
                       
                            flag = true;
                       
                        else
                            fprintf('Object dont have a CropID \n')
                       
                            flag = flase;
                            break;
                       
                        end
                    end
                    
               else
                   
                   fprintf('Object might not be in field \n directory # %s \n',directories(i).name)
                   %fprintf('RA  %d', obj.RA(Args.Index))
                   %fprintf('\n Dec %d ', obj.Dec(Args.Index))
                   flag = false;
                   counter = counter + 1 ;
                   %break;
                   
               end
               cd ../
    
              end
              
              % obs coo :
              ObsLon = 35.04085833;
              ObsLat = 30.0530725 ;

              if flag
                  tic;
                  FP     = imProc.sources.forcedPhot(AI,'Coo',[obj.RA(Args.Index) obj.Dec(Args.Index)]);
                  to     = toc;
                    
                  fprintf('\nfinished analyazing WD #%d , %s',Args.Index,obj.Name(Args.Index,:))
                  fprintf([' \n only ',num2str(to) ,' s'])
                  [R,LC] = lcUtil.zp_external(FP);
                  
                  X      = FP.Data.X(:,1);
                  Y      = FP.Data.Y(:,1);
                  RA     = FP.Data.RA(:,1);
                  Dec    = FP.Data.Dec(:,1);
                  
                 
                  
                  
                      
                   
                   ObsCoo  = [ObsLon, ObsLat];
                   [AirMass,~,~] = celestial.coo.airmass(LC(:,1),RA*(pi/180),Dec*(pi/180),ObsCoo*(pi/180));
                      
                      
                      
                      
                      
                 
              else
                  
                 
                  R   = [nan* ones(counter*20,7)];
                  LC  = [nan* ones(counter*20,7)];
                  X   = [nan* ones(counter*20,1)];
                  Y   = [nan* ones(counter*20,1)];
                  RA  = [nan* ones(counter*20,1)];
                  Dec = [nan* ones(counter*20,1)];
                  
                  
                  AirMass  =  [nan* ones(counter*20,1)];
                  
                  
              end


       end
       
       
       
       function [R,LC,X,Y,RA,Dec,AirMass,FP] = DetrendTarget(obj,Args)
              %   Soon
              %   Detailed explanation goes here - Yes
              
              arguments
                  
                 obj
                 Args.Index = 1;
              end
              
              
              % First, get the MS object of forced photometry

              AI = [];
              
              cd(obj.Pathway)
              
              cd ../
             

              directories = dir;
              counter = 0 ;

              for i = 3 : length(directories)
    
                   cd(directories(i).name)
    
    
                   fn  = FileNames.generateFromFileName('*proc_Image_1.fits');
                       
               if ~ ismissing(obj.FieldID(Args.Index)) 
              
               
    
                    if ~isempty(fn.selectBy('FieldID',char(obj.FieldID(Args.Index))).FieldID)
        
        
                        if obj.CropID(Args.Index) > 0 
                   
                            FN  = fn.selectBy('CropID',obj.CropID(Args.Index));
    
                            AI  = [AI AstroImage.readFileNamesObj(FN)];
                       
                            flag = true;
                       
                        else
                            fprintf('Object dont have a CropID \n')
                       
                            flag = flase;
                            break;
                       
                        end
                    end
                    
               else
                   
                   fprintf('Object might not be in field \n directory # %s \n',directories(i).name)
                   %fprintf('RA  %d', obj.RA(Args.Index))
                   %fprintf('\n Dec %d ', obj.Dec(Args.Index))
                   flag = false;
                   counter = counter + 1 ;
                   %break;
                   
               end
               cd ../
    
              end
              
              % obs coo :
              ObsLon = 35.04085833;
              ObsLat = 30.0530725 ;

              if flag
                  tic;
                  FP     = imProc.sources.forcedPhot(AI,'Coo',[obj.RA(Args.Index) obj.Dec(Args.Index)]);
                  to     = toc;
                  
                  
                   
                  
                  fprintf('\nFinished analyazing WD #%d , %s',Args.Index,obj.Name(Args.Index,:))
                  fprintf([' \n Only ',num2str(to) ,' s'])
                  [R,LC] = lcUtil.zp_external(FP);
                  
                  [RefSources,RefIdx] = find(FP.SrcData.phot_g_mean_mag < 15.8)
                  fprintf('\nTaking %d sources for detrending',length(RefIdx)) 
                  
                  % Reference matrix of [frames x sources]
                  RefMat    = FP.Data.FLUX_PSF(:,RefIdx);
                  RefMagMat = FP.Data.MAG_PSF(:,RefIdx);
                  
                  % Sort by time :
                
                  
                  % Filter by rms 
                  rms       = obj.calcRMS(RefMagMat)
                  Idx2      = logical(rms > 0 ) & (rms < 0.1) 
                  RefIdx    = RefIdx(Idx2) ;
                  RefMat    = [FP.Data.FLUX_PSF(:,RefIdx) FP.Data.FLUX_PSF(:,1)];
                  RefMagMat = [FP.Data.MAG_PSF(:,RefIdx) FP.Data.MAG_PSF(:,1)];
                  rms       = obj.calcRMS(RefMagMat);
                  
                  
                  
                  
                  % Sort by time
                  
                    
                  [~,SortInd] = sort(FP.JD);
                  

                  RefMat = RefMat(SortInd,:);
                  RefMagMat = RefMagMat(SortInd,:);
                  
                  
                  
                  

                  
                  
                  
                  
                  
                  % From Gaia catalog, take g and b_p-r_p
                  
                  gmag = FP.SrcData.phot_g_mean_mag(RefIdx) ;
                  BpRp = FP.SrcData.phot_bp_mean_mag(RefIdx) - FP.SrcData.phot_rp_mean_mag(RefIdx);
                  target_color = FP.SrcData.phot_bp_mean_mag(1) - FP.SrcData.phot_rp_mean_mag(1);
                  
                  % filter Nans
                  NewIdx = (~isnan(BpRp) & ~isnan(gmag))
                  
                  RefMat    = [RefMat(:,NewIdx) RefMat(:,length(RefMat(1,:)))];
                  RefMagMat = [RefMagMat(:,NewIdx) RefMagMat(:,length(RefMagMat(1,:)))];
                 
                  gmag = FP.SrcData.phot_g_mean_mag(RefIdx(NewIdx)) ;
                  BpRp = FP.SrcData.phot_bp_mean_mag(RefIdx(NewIdx)) - FP.SrcData.phot_rp_mean_mag(RefIdx(NewIdx));
                  BpRp  = [BpRp 0.5] ;
                  gmag  = [gmag obj.Mag(Args.Index)];
                  
                  
                  
                  % model = M_s +ZP + BpRp*beta
                  % Hx = P
                  %  x = H \ p
                  
                  % H_frame * x  =  |1 ? c1 | | Z_p    |  = | M_i1s1 |
                  %                 |1 ? c2 | | beta   |  = | M_i1s2 |
                  %                 |1 ? c3 | | M_s    |  + | M_i1s3 |
                  %                
                  %
                  
                  % Trend data.
                  %   solve m_{ij} = M_j + z_i +a*(B_p-R_p)_j

                   

                  p = length(RefMat(:,1)) ; % # of epoches
                  q = length(RefMat(1,:)) ; % # of sources

% m = zeros(p*q,1) ; % designated m vector
                  m = [] ; % designated m vector


                  for k = 1 : p
   
                           m = [ m ; RefMagMat(k,:)'] ;

                  end
                  
                  



                  I = sparse(eye(q)) ; 

                  H = [];



                  for j = 1 : p
                      
                         M = zeros(q,p);
                         M(:,j) = 1 ;
                      
                        


                         line_j  = [ sparse(M)  , I , BpRp' ] ;
  

                         H = [ H ; line_j] ; 

                  end


                  b = H \ m ; %-mean(m(logical(~isnan(m)))));

                  MM  = H*b;

                  MMM = [];
                  MMM = [MM(1:q)'];
                  for t = 2 : p

                       MMM = [MMM ; MM((t-1)*q+1:t*q)'];

                  end

MMMM = MMM';


end


                 
             if true     
                  
                
                  
                  
                  
                  
                  X      = FP.Data.X(:,1);
                  Y      = FP.Data.Y(:,1);
                  RA     = FP.Data.RA(:,1);
                  Dec    = FP.Data.Dec(:,1);
                  
                 
                  
                  
                      
                   
                   ObsCoo  = [ObsLon, ObsLat];
                   [AirMass,~,~] = celestial.coo.airmass(LC(:,1),RA*(pi/180),Dec*(pi/180),ObsCoo*(pi/180));
                      
                      
                      
                      
                      
                 
              else
                  
                 
                  R   = [nan* ones(counter*20,7)];
                  LC  = [nan* ones(counter*20,7)];
                  X   = [nan* ones(counter*20,1)];
                  Y   = [nan* ones(counter*20,1)];
                  RA  = [nan* ones(counter*20,1)];
                  Dec = [nan* ones(counter*20,1)];
                  
                  
                  AirMass  =  [nan* ones(counter*20,1)];
                  
                  
              end
        end

% 

       function [R,LC,X,Y,RA,Dec,AirMass,FP] = DetrendFlux(obj,Args)
              %   Soon
              %   Detrend forced photometry by flux field and not mag field
              
              arguments
                  
                 obj
                 Args.Index  = 1;
                 Args.Find   = false;
                 Args.XY     = [];
                 Args.Moving = false; 
                 
                 
              end
              
              if Args.Find
                  
                  % index argument ISNT handled, need to change
                   [id,FieldId]  = obj.Coo_to_Subframe(obj.Pathway,obj);
                   obj           = obj.get_id(id(:,1));
                   obj           = obj.get_fieldID(FieldId);
                   fprintf('Found the source in subframe # %d',obj.CropID(Args.Index))
                  
              end
              
              % First, get the MS object of forced photometry

              AI = [];
              
              cd(obj.Pathway)
              
              cd ../
             

              directories = dir;
              counter = 0 ;

              for i = 3 : length(directories)
    
                   cd(directories(i).name)
    
    
                   fn  = FileNames.generateFromFileName('*proc_Image_1.fits');
                       
               if ~ ismissing(obj.FieldID(Args.Index)) 
              
               
    
                    if ~isempty(fn.selectBy('FieldID',char(obj.FieldID(Args.Index))).FieldID)
        
        
                        if obj.CropID(Args.Index) > 0 
                   
                            FN  = fn.selectBy('CropID',obj.CropID(Args.Index));
    
                            AI  = [AI AstroImage.readFileNamesObj(FN)];
                       
                            flag = true;
                       
                        else
                            fprintf('Object dont have a CropID \n')
                       
                            flag = flase;
                            break;
                       
                        end
                    end
                    
               else
                   
                   fprintf('Object might not be in field \n directory # %s \n',directories(i).name)
                   %fprintf('RA  %d', obj.RA(Args.Index))
                   %fprintf('\n Dec %d ', obj.Dec(Args.Index))
                   flag = false;
                   counter = counter + 1 ;
                   %break;
                   
               end
               cd ../
    
              end
              
              % obs coo :
              ObsLon = 35.04085833;
              ObsLat = 30.0530725 ;

              if flag
                  
                  
                  % for forced in XY position and moving
                  if ~isempty(Args.XY) && Args.Moving
                      fprintf('\nApplying forced photometry on the target \nWith arguments of X,Y coordinates and moving as true')
                      tic;
                      FP     = imProc.sources.forcedPhot(AI,'Coo',Args.XY,'CooUnits','pix','Moving',Args.Moving);
                      to     = toc;
                  end
                  
                  % for forced in XY and not moving 
                  if ~isempty(Args.XY) && (Args.Moving == false)
                      fprintf('\nApplying forced photometry on the target \nWith arguments of X,Y coordinates and moving as false')
                   
                      tic;
                      FP     = imProc.sources.forcedPhot(AI,'Coo',Args.XY,'CooUnits','pix','Moving',false);
                      to     = toc;
                  end
                  
                  % for forced photometry with ra, dec and moving
                  if isempty(Args.XY) && Args.Moving
                      fprintf('\nApplying forced photometry on the target \nWith arguments of RA, Dec coordinates and moving as true')
                      tic;
                      FP     = imProc.sources.forcedPhot(AI,'Coo',[obj.RA(Args.Index) obj.Dec(Args.Index)].*ones(numel(AI),1),'Moving',Args.Moving);
                      to     = toc;
                  end
                  
                  % for forced photometry with ra, dec and not moving
                  if isempty(Args.XY) && (Args.Moving == false)
                      
                      
                      fprintf('\nApplying forced photometry on the target \nWith arguments of RA, Dec coordinates and moving as false')
                   
                      tic;
                      FP     = imProc.sources.forcedPhot(AI,'Coo',[obj.RA(Args.Index) obj.Dec(Args.Index)]);
                      to     = toc;
                      
                      
                  end
                  
                  
                  
                   
                  
                  fprintf('\nFinished analyazing WD #%d , %s',Args.Index,obj.Name(Args.Index,:))
                  fprintf([' \n Only ',num2str(to) ,' s'])
                  [R,LC] = lcUtil.zp_external(FP);
                  
                  [RefSources,RefIdx] = find(FP.SrcData.phot_g_mean_mag < 15.8)
                  fprintf('\nTaking %d sources for detrending',length(RefIdx)) 
                  
                  % Reference matrix of [frames x sources]
                  RefMat    = FP.Data.FLUX_PSF(:,RefIdx);
                  RefMagMat = FP.Data.MAG_PSF(:,RefIdx);
                  
                  % Sort by time :
                
                  
                  % Filter by rms 
                  rms       = obj.calcRMS(RefMagMat)
                  Idx2      = logical(rms > 0 ) & (rms < 0.1) 
                  RefIdx    = RefIdx(Idx2) ;
                  RefMat    = [FP.Data.FLUX_PSF(:,RefIdx) FP.Data.FLUX_PSF(:,1)];
                  RefMagMat = [FP.Data.MAG_PSF(:,RefIdx) FP.Data.MAG_PSF(:,1)];
                  rms       = obj.calcRMS(RefMagMat);
                  
                  
                  
                  
                  % Sort by time
                  
                    
                  [~,SortInd] = sort(FP.JD);
                  

                  RefMat = RefMat(SortInd,:);
                  RefMagMat = RefMagMat(SortInd,:);
                  
                  
                  
                  

                  
                  
                  
                  
                  
                  % From Gaia catalog, take g and b_p-r_p
                  
                  gmag = FP.SrcData.phot_g_mean_mag(RefIdx) ;
                  BpRp = FP.SrcData.phot_bp_mean_mag(RefIdx) - FP.SrcData.phot_rp_mean_mag(RefIdx);
                  target_color = FP.SrcData.phot_bp_mean_mag(1) - FP.SrcData.phot_rp_mean_mag(1);
                  
                  % filter Nans
                  NewIdx = (~isnan(BpRp) & ~isnan(gmag))
                  
                  RefMat    = [RefMat(:,NewIdx) RefMat(:,length(RefMat(1,:)))];
                  RefMagMat = [RefMagMat(:,NewIdx) RefMagMat(:,length(RefMagMat(1,:)))];
                 
                  gmag  = FP.SrcData.phot_g_mean_mag(RefIdx(NewIdx)) ;
                  BpRp  = FP.SrcData.phot_bp_mean_mag(RefIdx(NewIdx)) - FP.SrcData.phot_rp_mean_mag(RefIdx(NewIdx));
                  BpRp  = [BpRp 0.5] ;
                  gmag  = [gmag obj.Mag(Args.Index)];
                  
                  
                  
                  % model = M_s +ZP + BpRp*beta
                  % Hx = P
                  %  x = H \ p
                  
                  % H_frame * x  =  |1 ? c1 | | Z_p    |  = | M_i1s1 |
                  %                 |1 ? c2 | | beta   |  = | M_i1s2 |
                  %                 |1 ? c3 | | M_s    |  + | M_i1s3 |
                  %                
                  %
                  
                  % Trend data.
                  %   solve m_{ij} = M_j + z_i +a*(B_p-R_p)_j

                   

                  p = length(RefMat(:,1)) ; % # of epoches
                  q = length(RefMat(1,:)) ; % # of sources

% m = zeros(p*q,1) ; % designated m vector
                  m = [] ; % designated m vector


                  for k = 1 : p
   
                           m = [ m ; RefMagMat(k,:)'] ;

                  end
                  
                  



                  I = sparse(eye(q)) ; 

                  H = [];



                  for j = 1 : p
                      
                         M = zeros(q,p);
                         M(:,j) = 1 ;
                      
                        


                         line_j  = [ sparse(M)  , I , BpRp' ] ;
  

                         H = [ H ; line_j] ; 

                  end


                  b = H \ m ; %-mean(m(logical(~isnan(m)))));

                  MM  = H*b;

                  MMM = [];
                  MMM = [MM(1:q)'];
                  for t = 2 : p

                       MMM = [MMM ; MM((t-1)*q+1:t*q)'];

                  end

                  MMMM = MMM';


              end


                 
             if true     
                  
                
                  
                  
                  
                  
                  X      = FP.Data.X(:,1);
                  Y      = FP.Data.Y(:,1);
                  RA     = FP.Data.RA(:,1);
                  Dec    = FP.Data.Dec(:,1);
                  
                 
                  
                  
                      
                   
                   ObsCoo  = [ObsLon, ObsLat];
                   [AirMass,~,~] = celestial.coo.airmass(LC(:,1),RA*(pi/180),Dec*(pi/180),ObsCoo*(pi/180));
                      
                      
                      
                      
                      
                 
              else
                  
                 
                  R   = [nan* ones(counter*20,7)];
                  LC  = [nan* ones(counter*20,7)];
                  X   = [nan* ones(counter*20,1)];
                  Y   = [nan* ones(counter*20,1)];
                  RA  = [nan* ones(counter*20,1)];
                  Dec = [nan* ones(counter*20,1)];
                  
                  
                  AirMass  =  [nan* ones(counter*20,1)];
                  
                  
              end
        end
       
       function [R,LC,X,Y,RA,Dec,AirMass,FP,Robust_parameters] = ForcedFlux(obj,Args)
              %   Soon
              %   Detrend forced photometry by flux field and not mag field
              
              arguments
                  
                 obj
                 Args.Index  = 1;
                 Args.Find   = false;
                 Args.XY     = [];
                 Args.Moving = false; 
                 
                 
              end
              
              if Args.Find
                  
                  % index argument ISNT handled, need to change
                   [id,FieldId]  = obj.Coo_to_Subframe(obj.Pathway,obj);
                   obj           = obj.get_id(id(:,1));
                   obj           = obj.get_fieldID(FieldId);
                   fprintf('Found the source in subframe # %d',obj.CropID(Args.Index))
                  
              end
              
              % First, get the MS object of forced photometry

              AI = [];
              
              cd(obj.Pathway)
              
              cd ../
             

              directories = dir;
              counter = 0 ;

              for i = 3 : length(directories)
    
                   cd(directories(i).name)
    
    
                   fn  = FileNames.generateFromFileName('*proc_Image_1.fits');
                       
               if ~ ismissing(obj.FieldID(Args.Index)) 
              
               
    
                    if ~isempty(fn.selectBy('FieldID',char(obj.FieldID(Args.Index))).FieldID)
        
        
                        if obj.CropID(Args.Index) > 0 
                   
                            FN  = fn.selectBy('CropID',obj.CropID(Args.Index));
    
                            AI  = [AI AstroImage.readFileNamesObj(FN)];
                       
                            flag = true;
                       
                        else
                            fprintf('Object dont have a CropID \n')
                       
                            flag = flase;
                            break;
                       
                        end
                    end
                    
               else
                   
                   fprintf('Object might not be in field \n directory # %s \n',directories(i).name)
                   %fprintf('RA  %d', obj.RA(Args.Index))
                   %fprintf('\n Dec %d ', obj.Dec(Args.Index))
                   flag = false;
                   counter = counter + 1 ;
                   %break;
                   
               end
               cd ../
    
              end
              
              % obs coo :
              ObsLon = 35.04085833;
              ObsLat = 30.0530725 ;

              if flag
                  
                  
                  % for forced in XY position and moving
                  if ~isempty(Args.XY) && Args.Moving
                      fprintf('\nApplying forced photometry on the target \nWith arguments of X,Y coordinates and moving as true')
                      tic;
                      FP     = imProc.sources.forcedPhot(AI,'Coo',Args.XY,'CooUnits','pix','Moving',Args.Moving);
                      to     = toc;
                  end
                  
                  % for forced in XY and not moving 
                  if ~isempty(Args.XY) && (Args.Moving == false)
                      fprintf('\nApplying forced photometry on the target \nWith arguments of X,Y coordinates and moving as false')
                   
                      tic;
                      FP     = imProc.sources.forcedPhot(AI,'Coo',Args.XY,'CooUnits','pix','Moving',false,'AddRefStarsDist',0);
                      to     = toc;
                  end
                  
                  % for forced photometry with ra, dec and moving
                  if isempty(Args.XY) && Args.Moving
                      fprintf('\nApplying forced photometry on the target \nWith arguments of RA, Dec coordinates and moving as true')
                      tic;
                      FP     = imProc.sources.forcedPhot(AI,'Coo',[obj.RA(Args.Index) obj.Dec(Args.Index)].*ones(numel(AI),1),'Moving',Args.Moving);
                      to     = toc;
                  end
                  
                  % for forced photometry with ra, dec and not moving
                  if isempty(Args.XY) && (Args.Moving == false)
                      
                      
                      fprintf('\nApplying forced photometry on the target \nWith arguments of RA, Dec coordinates and moving as false')
                   
                      tic;
                      FP     = imProc.sources.forcedPhot(AI,'Coo',[obj.RA(Args.Index) obj.Dec(Args.Index)]);
                      to     = toc;
                      
                      
                  end
                  
                  
                  
                   
                  
                  fprintf('\nFinished analyazing WD #%d , %s',Args.Index,obj.Name(Args.Index,:))
                  fprintf([' \n Only ',num2str(to) ,' s'])
                  [R,LC] = lcUtil.zp_external(FP);
                  
              end
              
              if true     

                  
                  X      = FP.Data.X(:,1);
                  Y      = FP.Data.Y(:,1);
                  RA     = FP.Data.RA(:,1);
                  Dec    = FP.Data.Dec(:,1);
                        
                  ObsCoo  = [ObsLon, ObsLat];
                  [AirMass,~,~] = celestial.coo.airmass(FP.JD',RA*(pi/180),Dec*(pi/180),ObsCoo*(pi/180)); 
                  
                  Median   = median(LC(:,2));
                  MAD = sort(abs(Median-LC(:,2)));
                  mid = round(length(MAD)/2);
                  SDrobust = 1.5*MAD(mid);
                  
                  Robust_parameters = [Median ; SDrobust];
                   
                  
              else
                  
                 
                  R   = [nan* ones(counter*20,7)];
                  LC  = [nan* ones(counter*20,7)];
                  X   = [nan* ones(counter*20,1)];
                  Y   = [nan* ones(counter*20,1)];
                  RA  = [nan* ones(counter*20,1)];
                  Dec = [nan* ones(counter*20,1)];
                  
                  
                  AirMass  =  [nan* ones(counter*20,1)];
                  Robust_parameters = [nan ; nan];
                  
              end

              
              
              
        end
       
       function [AirMass,FP,MS,Robust_parameters] = Forced1(obj,Args)
              %   [R,LC,X,Y,RA,Dec,AirMass,FP,MS,Robust_parameters]
              %   original output
              %   Detailed explanation goes here - Yes
              
              arguments
                  
                 obj
                 Args.Index = 1;
                 Args.ID    = 1;
                 Args.FieldID = [];
                 Args.SaveTo  = '~/Documents/WD_survey/270823/358+34/Detrend/'
    
              end

              AI = [];
              
              cd(obj.Pathway)
              
              cd ../
             

              directories = dir;
              counter = 0 ;

              for i = 3 : length(directories)
    
                   cd(directories(i).name)
    
    
                   fn  = FileNames.generateFromFileName('*proc_Image_1.fits');
                       
               if ~ismissing(Args.FieldID) 
              
               
    
                    if ~isempty(fn.selectBy('FieldID',char(Args.FieldID)).FieldID)
        
        
                        if Args.ID > 0 
                   
                            FN  = fn.selectBy('CropID',Args.ID);
    
                            AI  = [AI AstroImage.readFileNamesObj(FN)];
                       
                            flag = true;
                       
                        else
                            fprintf('Object dont have a proper ID \n')
                       
                            flag = flase;
                            break;
                       
                        end
                    end
                    
               else
                   
                   fprintf('Object might not be in field \n directory # %s \n',directories(i).name)
                   %fprintf('RA  %d', obj.RA(Args.Index))
                   %fprintf('\n Dec %d ', obj.Dec(Args.Index))
                   flag = false;
                   counter = counter + 1 ;
                   %break;
                   
               end
               cd ../
    
              end
              
              % obs coo :
              ObsLon = 35.04085833;
              ObsLat = 30.0530725 ;

              if flag
                  tic;
                  FP     = imProc.sources.forcedPhot(AI,'Coo',[obj.RA(Args.Index) obj.Dec(Args.Index)],'ColNames',{'RA','Dec','X','Y','Xstart','Ystart','Chi2dof','FLUX_PSF','FLUXERR_PSF','MAG_PSF','MAGERR_PSF','BACK_ANNULUS', 'STD_ANNULUS','FLUX_APER','FLAG_POS','FLAGS','MAG_APER'});
                  to     = toc;

                  fprintf('\nFinished analyazing %s', obj.Name(Args.Index,:))
                  fprintf('\nFor subframe # %d',Args.ID)
                  fprintf([' \n only "',num2str(to) ,'" s'])
                  %PF = FP;
                  FileName = [Args.SaveTo,obj.Name(Args.Index,:),'_FP0.mat'];
                  save(FileName,'FP', '-nocompression', '-v7.3')
                 % R = lcUtil.zp_meddiff(PF,'MagField','MAG_PSF','MagErrField','MAGERR_PSF')
                  
           
                  %[MS,ApplyToMagFieldr] = applyZP(PF, R.FitZP,'ApplyToMagField','MAG_PSF');
                  MS = [];
                  
       
                  
                  
       %           [R,LC] = lcUtil.zp_external(FP,'UpdateMagFields',{'MAG_PSF','FLUX_PSF'})
                  
                  
                  % [R,LC] = lcUtil.zp_external(FP,'UpdateMagFields,{'MAG_PSF','FLUX_PSF'});
                  %R = [];
                  %LC = [];
                  % Without ZP external
                  
                  
         %         X      = FP.Data.X(:,1);
         %         Y      = FP.Data.Y(:,1);
                  RA     = FP.Data.RA(:,1);
                  Dec    = FP.Data.Dec(:,1);
                  
                 
                  
                  
                      
                   
                   ObsCoo  = [ObsLon, ObsLat];
                   [AirMass,~,~] = celestial.coo.airmass(FP.JD',RA*(pi/180),Dec*(pi/180),ObsCoo*(pi/180));
                      
                   Median   = median(FP.Data.MAG_PSF(:,1));
                   MAD = sort(abs(Median-FP.Data.MAG_PSF(:,1)));
                   mid = round(length(MAD)/2);
                   SDrobust = 1.5*MAD(mid);
                  
                   Robust_parameters = [Median ; SDrobust];
                      
                      
                      
                 
              else
                  
                 
          %        R   = [nan* ones(counter*20,7)];
          %        LC  = [nan* ones(counter*20,7)];
          %        X   = [nan* ones(counter*20,1)];
          %        Y   = [nan* ones(counter*20,1)];
           %       RA  = [nan* ones(counter*20,1)];
            %      Dec = [nan* ones(counter*20,1)];
                  
                  
                  AirMass  =  [nan* ones(counter*20,1)];
                  Robust_parameters = [nan ; nan];
                  
                  
              end


       end
   
       function [R,LC,FP] = Forced2(obj,Args)
              %
              %   Detailed explanation goes here - Yes
              
              arguments
                  
                 obj
                 Args.Index = 1;
                 Args.ID    = 1;
                 Args.FieldID = [];
    
              end

              AI = [];
              
              cd(obj.Pathway)
              
              cd ../
             

              directories = dir;
              counter = 0 ;

              for i = 3 : length(directories)
    
                   cd(directories(i).name)
    
    
                   fn  = FileNames.generateFromFileName('*proc_Image_1.fits');
                       
               if ~ ismissing(Args.FieldID) 
              
               
    
                    if ~isempty(fn.selectBy('FieldID',char(Args.FieldID)))
        
        
                        if Args.ID > 0 
                   
                            FN  = fn.selectBy('CropID',Args.ID);
    
                            AI  = [AI AstroImage.readFileNamesObj(FN)];
                       
                            flag = true;
                       
                        else
                            fprintf('Object dont have a proper ID \n')
                       
                            flag = flase;
                            break;
                       
                        end
                    end
                    
               else
                   
                   fprintf('Object might not be in field \n directory # %s \n',directories(i).name)
                   %fprintf('RA  %d', obj.RA(Args.Index))
                   %fprintf('\n Dec %d ', obj.Dec(Args.Index))
                   flag = false;
                   counter = counter + 1 ;
                   %break;
                   
               end
               cd ../
    
              end
              
              % obs coo :
              ObsLon = 35.04085833;
              ObsLat = 30.0530725 ;

              if flag
                  tic;
                  FP     = imProc.sources.forcedPhot(AI,'Coo',[obj.RA(Args.Index) obj.Dec(Args.Index)]);
                  to     = toc;
                    
                  fprintf('\nFinished analyazing %s', obj.Name(Args.Index,:))
                  fprintf('\nFor subframe # %d',Args.ID)
                  fprintf([' \n only "',num2str(to) ,'" s'])
                  [R,LC] = lcUtil.zp_external(FP);
                  
                  X      = FP.Data.X(:,1);
                  Y      = FP.Data.Y(:,1);
                  RA     = FP.Data.RA(:,1);
                  Dec    = FP.Data.Dec(:,1);
                  
                 
                  
                  
                      
                   
                   ObsCoo  = [ObsLon, ObsLat];
                   [AirMass,~,~] = celestial.coo.airmass(LC(:,1),RA*(pi/180),Dec*(pi/180),ObsCoo*(pi/180));
                      
                   Median   = median(LC(:,7));
                   MAD = sort(abs(Median-LC(:,7)));
                   mid = round(length(MAD)/2);
                   SDrobust = 1.5*MAD(mid);
                  
                   Robust_parameters = [Median ; SDrobust];
                      
                      
                      
                 
              else
                  
                 
                  R   = [nan* ones(counter*20,7)];
                  LC  = [nan* ones(counter*20,7)];
                  X   = [nan* ones(counter*20,1)];
                  Y   = [nan* ones(counter*20,1)];
                  RA  = [nan* ones(counter*20,1)];
                  Dec = [nan* ones(counter*20,1)];
                  
                  
                  AirMass  =  [nan* ones(counter*20,1)];
                  Robust_parameters = [nan ; nan];
                  
                  
              end


       end
    
       function [lc,ForcedMag,ForcedMagErr,ForcedTime,X,Y,ra,dec,AM,FP,Robust,MinDist,ID] = ForcedCheck(obj,Args)
              
              % Get the forced photometry of a source in a WD object. in
              % all frames ( in ForcedMag ForcedMagerr
              
              % Find how many siginificant detection exist over the entire
              % obs
              
              % Find distance from the edge of the subframe, if the target
              % is overlapping in another subframe get data from both.
              
              arguments
                  
                 obj
                 Args.Index  = 1; % index in WD object
                 Args.Find   = true; % find in images
                 Args.XY     = [];
                 Args.Moving = false; 
                 
                 
              end
              MinDist = [];
              ID = [];
              
              if Args.Find
                  
                  % index argument ISNT handled, need to change
                   [id,FieldId,xy] = obj.SubframeOverlap(obj.Pathway,obj,'Index',Args.Index);
                   MinDist = [MinDist ; xy]
                   ID      = [ID ; id ]
                   if sum(id > 0) > 0
                    
                       fprintf('Found the source in subframes # : %s ',num2str(id(id > 0)) )

                   end
                   
                   %obj          = obj.get_id(id(:,1));
                   %obj          = obj.get_fieldID(FieldId);
                   %fprintf('Found the source in subframe # %d',obj.CropID(Args.Index))
                  
              end
              
              id = id(id > 0);
              ForcedMag    = [];
              ForcedMagErr = [];
              ForcedTime   = [];
              X            = [];
              Y            = [];
              ra           = [];
              dec          = [];
              AM           = [];
              Subframe     = [];
              Robust       = [];
              lc = {};

              
              for i = 1:length(id)
    
    
                 [R,LC,Xpos,Ypos,RA,Dec,AirMass,FP,Robust_parameters] = obj.Forced1(obj,'Index',Args.Index,'ID',id(i),'FieldID',FieldId(i))
    
                 ForcedTime   = [ForcedTime ; FP.JD'];
                 ForcedMag    = [ForcedMag ; FP.Data.MAG_PSF(:,1)'];
                 ForcedMagErr = [ForcedMagErr ; FP.Data.MAGERR_PSF(:,1)'];
                 X    = [X ; Xpos'] ;
                 Y    = [Y ; Ypos'] ;
                 ra   = [ra ; RA'] ;
                 dec  = [dec ; Dec'];
                 AM   = [AM ; AirMass'];
                 Subframe = [Subframe id(i)]
                 lc = {lc ; LC}
                 Robust = [Robust ; Robust_parameters]
                 
                 fprintf('Finished with subframe # ',num2str(id(i)))
   
              end
        
        end
              

       function [FP,MS,Robust,MinDist,ID] = ForcedMS(obj,Args)
              
              % Get the forced photometry of a source in a WD object.
              
              % Find how many siginificant detection exist over the entire
              % obs
              
              % Find distance from the edge of the subframe, if the target
              % is overlapping in another subframe get data from both.
              
              arguments
                  
                 obj
                 Args.Index  = 1; % index in WD object
                 Args.Find   = true; % find in images
                 Args.XY     = [];
                 Args.Moving = false; 
                 
                 
              end
              MinDist = [];
              ID = [];
              
              if Args.Find
                  
                  % index argument ISNT handled, need to change
                   [id,FieldId,xy] = obj.SubframeOverlap(obj.Pathway,obj,'Index',Args.Index);
                   MinDist = [MinDist ; xy]
                   ID      = [ID ; id ]
                   if sum(id > 0) > 0
                    
                       fprintf('Found the source in subframes # : %s ',num2str(id(id > 0)) )

                   end
                   
                   %obj          = obj.get_id(id(:,1));
                   %obj          = obj.get_fieldID(FieldId);
                   %fprintf('Found the source in subframe # %d',obj.CropID(Args.Index))
                  
              end
              
              FirldId = FieldId(id > 0);
              id = id(id > 0);
              
              %ForcedMag    = [];
              %ForcedMagErr = [];
              %ForcedTime   = [];
              %X            = [];
              %Y            = [];
              %ra           = [];
              %dec          = [];
              %AM           = [];
              %Subframe     = [];
              %Robust       = [];
              %lc = {};

              
               if  ~isempty(id )
    
    
              [AirMass,FP,MS,Robust] = obj.Forced1(obj,'Index',Args.Index,'ID',id(1),'FieldID',FieldId(1));
              % original output [R,LC,Xpos,Ypos,RA,Dec,AirMass,FP,Robust] 
                 
               else
                   
                   fprintf('Could not find target i any subframe ??')
   
              end
        
        end
              
              
         
      end
       

        
            
    end
        
        
        
        
    
