% A class that finds and characterize targets in LAST data
% Detailed documentation is required. . . . . . .(one day)



classdef WDss
    
    
    properties
        
        % Properties to input:
        
        Path   % A proc folder containing the targets cat and proc fits 
        Nsrc
        Name
        RA
        Dec
        G_g
        G_Bp
        G_Rp
        Color
        
        % Properties to aquire:
        
        FieldID  % Add field name - take from path
        CropID   % Add subframe number after providing a path 
        Data     % Catalog Data and Forced Photometry Data
        fieldId
        
        
    end
    
    
    methods % constructor
        
        function obj = WDss(Path,Name,RA,Dec,G_g,G_Bp,G_Rp,Args)
            
            arguments
                Path
                Name
                RA
                Dec
                G_g
                G_Bp
                G_Rp
                
                
                
                Args.plotTargets = true;
                
                
                Args.getCatData = true ; % get Matched sources object for every target we can find in the Cat files , even if it appears in more than one subframe
                Args.printCat   = true ; % from CatData - get Target Index, plot : subframe RMS with ZP, and SysRem for aper3 and psf. and corresponding LC
                Args.getRMS     = true ;
                Args.applyZP    = true ;
                Args.FieldId    = ''   ;
                Args.Isempty    = false;
                
                
                Args.getForcedData = true ; % gey MatchedSources object for every target exist in the FOV
                
                Args.Batch      = [];
                
                
            end
            
            obj.Path  = Path;
            obj.Nsrc  = length(RA);
            obj.Name  = Name;
            obj.RA    = RA;
            obj.Dec   = Dec;
            obj.G_g   = G_g;
            obj.G_Bp  = G_Bp;
            obj.G_Rp  = G_Rp;
            obj.Color = G_Bp - G_Rp;
            obj.fieldId = Args.FieldId;
        
        
        % obj.FieldID = getFieldID()
        
        % obj.CropID  = getCropID()
          if ~Args.Isempty
            if Args.plotTargets
                
                [obj.CropID,obj.FieldID] = Coo_to_Subframe(obj)
                
                
            end
            
            if Args.getCatData

                [obj.Data.Catalog.CatID,obj.Data.Catalog.InCat] = FindInCat(obj) ;
                obj.Data.Catalog.MS     = createMS(obj) ;
          
                
                if Args.applyZP
 
                        obj.Data.Catalog.APER_2 = msZP(obj,'MAGField','MAG_APER_2','MagErrField','MAGERR_APER_2') ;                        
                        obj.Data.Catalog.PSF    = msZP(obj,'MAGField','MAG_PSF','MagErrField','MAGERR_PSF') ;
                        obj.Data.Catalog.APER_22 = msZP(obj,'MAGField','MAG_APER_2','MagErrField','MAGERR_APER_2') ;                        
                        obj.Data.Catalog.PSF2    = msZP(obj,'MAGField','MAG_PSF','MagErrField','MAGERR_PSF') ;
                end
            end
            
            if ~isempty(Args.Batch)
                
                
                %[obj.Data.Catalog.CatID,obj.Data.Catalog.InCat] = FindInCat(obj) ;
                % obj.Data.Catalog.MS    = createMSbacth(obj) ;
                Args.getForcedData     = false;
                 for Iobj = 1 : obj.Nsrc
                    
                    for Iiter = 1 :  length(obj.CropID(Iobj,:))
                        
                        if ~isempty(obj.CropID{Iobj,Iiter}) 
                            
                            fprintf('\nPreforming Forced Photometry for target  # %i in Sub Frame %i ', Iobj,obj.CropID{Iobj,Iiter});
                            obj.Data.ForcedBatch.MS{Iobj,Iiter} = obj.ForcedMSbatch(obj,'Iobj',Iobj,'CropID',obj.CropID{Iobj,Iiter});
                            fprintf('\nCompleted Forced Photometry for target  # %i in Sub Frame %i ', Iobj,obj.CropID{Iobj,Iiter});
                          %  ms = obj.Data.Forced.MS{Iobj,Iiter}.copy();
                 
                           % R = lcUtil.zp_meddiff(ms,'MagField','MAG_PSF','MagErrField','MAGERR_PSF');
                            %[FP_ZP,ApplyToMagFieldr] = applyZP(ms, R.FitZP,'ApplyToMagField','MAG_PSF');
                            
                            %obj.Data.Forced.PSFzp{Iobj,Iiter} = FP_ZP.copy();
                            
                            
                        end
                    end
                
                end
               
                
                
                
            end
        
            
            
            if Args.getForcedData
                
                
                for Iobj = 1 : obj.Nsrc
                    
                    for Iiter = 1 :  length(obj.CropID(Iobj,:))
                        
                        if ~isempty(obj.CropID{Iobj,Iiter}) 
                            
                            fprintf('\nPreforming Forced Photometry for target  # %i in Sub Frame %i ', Iobj,obj.CropID{Iobj,Iiter});
                            obj.Data.Forced.MS{Iobj,Iiter} = obj.ForcedMS(obj,'Iobj',Iobj,'CropID',obj.CropID{Iobj,Iiter});
                            ms = obj.Data.Forced.MS{Iobj,Iiter}.copy();
                 
                            R = lcUtil.zp_meddiff(ms,'MagField','MAG_PSF','MagErrField','MAGERR_PSF');
                            [FP_ZP,ApplyToMagFieldr] = applyZP(ms, R.FitZP,'ApplyToMagField','MAG_PSF');
                            
                            obj.Data.Forced.PSFzp{Iobj,Iiter} = FP_ZP.copy();
                            
                        end
                    end
                
                end
                
            end
          
        % obj.Data.Catalog.Coadd    = FindInCoadd(obj)
        
        
        end
       end
        
        
        
        
        
        
    end
    
    
    methods (Access = private)
        
        
        
        
        function mszp = msZP(obj,Args)
            
            arguments
                
                obj WDs
                Args.Index       = [];
                Args.MagField    = [];
                Args.MagErrField = [] ;
                
            end
                 
                 for Iobj = 1: obj.Nsrc
           
                 
                     [Itgt,Isubframe] = find(cellfun(@(x) ~isempty(x),obj.Data.Catalog.MS(Iobj,:)))
                
                 
                     if ~isempty(Itgt)
                     
                     
                        for  Iiter = 1: length(Isubframe)
                     

                 
                            ms = obj.Data.Catalog.MS{Iobj,Iiter}.copy()
                 
                            R = lcUtil.zp_meddiff(ms,'MagField',Args.MagField,'MagErrField',Args.MagErrField)
                            [MS_ZP,ApplyToMagFieldr] = applyZP(ms, R.FitZP,'ApplyToMagField',Args.MagField);

                            mszp{Iobj,Iiter} = MS_ZP.copy();
                    
            
                        end
                     
                     else
                         mszp{Iobj,1} = {}
                 
                     end
                 end
                 
                 
          
                 
           
            
            
        end
        
        function MS = createMS(obj)
            
            
            cd(obj.Path)
            

            cd('../')

            
            % From MatchedSources doc :
            % prepare list of files to upload
            %MS = cell(obj.Nsrc,0)
            for Iobj = 1 : obj.Nsrc
                
                if obj.Data.Catalog.InCat(Iobj)
                    
                    
                     if length(obj.Data.Catalog.CatID{Iobj}) == 1
                
                           L = MatchedSources.rdirMatchedSourcesSearch('CropID',obj.Data.Catalog.CatID{Iobj}(1));      
                           % Consider only visits with the same Field ID
                           Visits = find(contains(L.FileName,obj.fieldId));
                           List.FileName = L.FileName(Visits);
                           List.Folder   = L.Folder(Visits);
                           List.CropID   = L.CropID;
                           
                           %   Upload all files to a MatchedSources object
                           ms = MatchedSources.readList(List);    
                           %   % Merge all MatchedSources elkement into a single element object
                           MSU = mergeByCoo(ms,ms(1));
                           %   % Add GAIA mag and colors
                           % MSU.addExtMagColor;
                           MS{Iobj,1} = MSU.copy() ;
                           fprintf('\n\n Finished Creating a MatchedSources object for target # %i',Iobj)
                           
                     else
                         
                        
                         
                          if length(obj.Data.Catalog.CatID{Iobj}) > 1
                              
                              for Iiter = 1 : length(obj.Data.Catalog.CatID{Iobj})
                
                                   L   = MatchedSources.rdirMatchedSourcesSearch('CropID',obj.Data.Catalog.CatID{Iobj}(Iiter));      
                                   ms  = MatchedSources.readList(L);    
                                   MSU = mergeByCoo(ms,ms(1));                                  
                                   % MSU.addExtMagColor;
                                   MS{Iobj,Iiter} = MSU.copy() ;
                                   fprintf('\n\n Finished Creating %i out of %i MatchedSources objects for target # %i \n',Iiter,length(obj.Data.Catalog.CatID{Iobj}),Iobj)
                              end
                               
                          end
                         
                     end
                     
                else
                    
                     MS{Iobj,1} = {} ;
                     
                end
            end

            
            
        end
        
        function [CatID,Flags] = FindInCat(obj)
            
            Nobj = obj.Nsrc;
            
            fprintf('\nLooking for %i sources in the Catalog data',  Nobj)
            
            cd(obj.Path) 
            
            MS1 = MatchedSources.read_rdir('*_sci_merged_MergedMat_*.hdf5');
            
            Flags = false(Nobj,1);
            CatID = cell(Nobj,1) ; 
            
            for Iobj = 1 : Nobj
                
                
                for Isubframe = 1 : 24
                    
                   if  ~isempty( MS1(Isubframe).coneSearch(obj.RA(Iobj),obj.Dec(Iobj)).Ind)
                       
                       fprintf('\nTarget # %i Found in subframe %i\nTarget name : %s',Iobj,Isubframe,obj.Name(Iobj,:))
                       
                       if isempty(CatID{Iobj,1})
                           
                           Flags(Iobj,1) = true;
                           
                           CatID{Iobj,1} = Isubframe ;
                           
                       else
                           
                           CatID{Iobj,1} = [CatID{Iobj,1} Isubframe];
                           
                           fprintf('\nTarget # %i Appear in subframes: %i %i %i %i\n ',Iobj,[CatID{Iobj}])
                           
                       end
                       
                       
                   end
                    
                end
                
                
                
            end
            
            fprintf('\nFound %i out of  %i targets in the Catalog files \n',sum(Flags),Nobj)
         
            
        end
        
   
        
        function MS = createMSbatch(obj)
            
            
            cd(obj.Path)
            

            cd('../')

            
            % From MatchedSources doc :
            % prepare list of files to upload
            %MS = cell(obj.Nsrc,0)
            for Iobj = 1 : obj.Nsrc
                
                if obj.Data.Catalog.InCat(Iobj)
                    
                    
                     if length(obj.Data.Catalog.CatID{Iobj}) == 1
                
                           L = MatchedSources.rdirMatchedSourcesSearch('CropID',obj.Data.Catalog.CatID{Iobj}(1));      
                           %   Upload all files to a MatchedSources object
                           ms = MatchedSources.readList(L);    
                           %   % Merge all MatchedSources elkement into a single element object
                           MSU = mergeByCoo(ms,ms(1));
                           %   % Add GAIA mag and colors
                           % MSU.addExtMagColor;
                           MS{Iobj,1} = MSU.copy() ;
                           fprintf('\n\n Finished Creating a MatchedSources object for target # %i',Iobj)
                           
                     else
                         
                        
                         
                          if length(obj.Data.Catalog.CatID{Iobj}) > 1
                              
                              for Iiter = 1 : length(obj.Data.Catalog.CatID{Iobj})
                
                                   L   = MatchedSources.rdirMatchedSourcesSearch('CropID',obj.Data.Catalog.CatID{Iobj}(Iiter));      
                                   ms  = MatchedSources.readList(L);    
                                   MSU = mergeByCoo(ms,ms(1));                                  
                                   % MSU.addExtMagColor;
                                   MS{Iobj,Iiter} = MSU.copy() ;
                                   fprintf('\n\n Finished Creating %i out of %i MatchedSources objects for target # %i \n',Iiter,length(obj.Data.Catalog.CatID{Iobj}),Iobj)
                              end
                               
                          end
                         
                     end
                     
                else
                    
                     MS{Iobj,1} = {} ;
                     
                end
            end

            
            
        end
        

            
            


        
        
        
        
        
  
    
        
        
        
        
        function [CropID,FieldID] = Coo_to_Subframe(obj)
            
             Pattern = '*_001_001_*_sci*proc_Image_1.fits'; % Take the first exposure fro, a Visit, might not be the most efficent 
             
             cd(obj.Path)
             
             tic
             ai = AstroImage.readFileNamesObj(Pattern);
             t0 = toc;
             fprintf('Loaded the first exposure from the current visit, For all subframes only %f Sec ',t0)
             
         
   
             CropID  = cell(obj.Nsrc,1) ; 
             FieldID = string.empty(obj.Nsrc,0);
             

             
             for Iimage = 1 : length(ai)
                 
                 
                 inImage = ai(Iimage).isSkyCooInImage(obj.RA,obj.Dec);
                 
                 if sum(inImage.InImage) > 0 
                     
                     for Iobj = 1 : obj.Nsrc
                         
                         if inImage.InImage(Iobj)
                             
                             if isempty(CropID{Iobj,1})
                             
                                  CropID{Iobj,1} = ai(Iimage).HeaderData.Key.CROPID ; 
                                  FieldID(Iobj)  = ai(Iimage).HeaderData.Key.FIELDID;
                                  % plot
                                 % [AI] = obj.get_target(ai,obj,Iobj,CropID{Iobj,1});

                                  fprintf('\nCoord of source # %i Found in subframe %i\nTarget name : %s',Iobj,CropID{Iobj,1},obj.Name(Iobj,:))
                                  
                             else
                                  CropID{Iobj,length(CropID{Iobj})+1} = ai(Iimage).HeaderData.Key.CROPID ; 
                                  fprintf('\nTarget # %i Appear in subframes: %i %i %i %i\n ',Iobj,[CropID{Iobj,:}])
                             end
                             
                             
                         end
                         
                         
                     end
                     
                     
                     
                     
                 end
                 
             end
             
          
             
             
             
        end
           
        
   
             
             
      
        
    end
    
    
    methods (Static)
        
              
        function [ai] = get_target(AI,obj,idx,subframe)
          % From one AstroImage, plot it together with an
          % aperture on a target
           %   Detailed explanation goes here
            target_ra  = obj.RA(idx);
            target_dec = obj.Dec(idx);
            flag = true;


            ds9(AI(subframe))

            [x,y] = ds9.coo2xy(target_ra,target_dec);



            if (x > 1726 - 128) || (x < 128)
                
                fprintf(['Target on the edge. RA = ',num2str(target_ra),' Dec = ', num2str(target_dec),' subframe #',num2str(subframe),'( ',num2str(x),',',num2str(y),'\n'])
                if x > 64
                    if x < 1726-64
                         flag = false;
                         ai = AI(subframe).Image(y-64:y+64,x-64:x+64);
                         ds9(ai)
                         ds9.plot(64+2,64+2,'go','Size',8,'text',obj.Name(idx,:));
                         ds9.plot(64,10,'g','Size',1,'text',['B_p = ',num2str(obj.G_Bp(idx))]);   
                         ds9.plot(64,150,'r','Size',1,'text',['sub frame #',num2str(subframe)]);
                         info = obj.Name(idx,:);
                         ds9.read2fits(info);
                         fprintf(['Saved a tiny region around ', obj.Name(idx,:),'\n'])
                    end
                end
                
            else
                
                if (y > 1726 - 128) || (y < 128)
                    fprintf(['Target on the edge. RA = ',num2str(target_ra),' Dec = ', num2str(target_dec),' subframe #',num2str(subframe),'( ',num2str(x),',',num2str(y),'\n'])
                    if y > 64
                        if y < 1726 - 64
                            flag = false;
                             ai = AI(subframe).Image(y-64:y+64,x-64:x+64);
                             ds9(ai)
                             ds9.plot(64+2,64+2,'go','Size',8,'text',obj.Name(idx,:));
                             ds9.plot(64,10,'g','Size',1,'text',['B_p = ',num2str(obj.G_Bp(idx))]);   
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
                    ds9.plot(128,10,'g','Size',1,'text',['B_p = ',num2str(obj.G_Bp(idx))]);
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
        
        
        
        
        
        
        function [times_vec,LimMag_vec] = Header_LimMag(obj)
           
           if ~isempty(obj.FieldID)
               %
               Nobs           = length(obj.Data.Catalog.MS{8,1}.JD) ;
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
           
           cd(obj.Path)
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
                   
                   if ~isempty(strfind(fn(m).name ,char(obj.FieldID(1))))
                       
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
       
        
        
        function FP = ForcedMS(obj,Args)
            
            arguments
                
                obj
                Args.Iobj = [];
                Args.CropID = [];
                
            end
            
            AI = [];
            
            Iobj = Args.Iobj;
            
            cd(obj.Path)
            cd ../
            directories = dir;
            
      
            
            for Idir = 3 : length(directories)
                
                cd(directories(Idir).name)
                
                fn = FileNames.generateFromFileName('*proc_Image_1.fits');
                
                if ~isempty(obj.CropID{Iobj,1})
                    
                    if ~isempty(fn.selectBy('FieldID',char((obj.FieldID(Iobj)))).FieldID)
                        
                        FN = fn.selectBy('CropID',Args.CropID);
                        AI = [AI  AstroImage.readFileNamesObj(FN)];
                        fprintf('\nLoaded Subframe %i from dir : %s ',Args.CropID, directories(Idir).name)
                       
                       
                        
                    end
                    
                else
                    
                    fprintf('\n Couldnt Find Target # %i In the FOV, RA,DEC = %.5f , %.5f \n',Iobj,obj.RA(Iobj), obj.Dec(Iobj) )
                    
                    break;
                end
                
                cd ../
                
                
                
            end
            
            
            %%%%%%%%% ADD FLAGS you have to ask for MASK in the pipeline
            tic ; 
            FP = imProc.sources.forcedPhot(AI,'Coo',[obj.RA(Iobj) obj.Dec(Iobj)],'ColNames',{'RA','Dec','X','Y','Xstart','Ystart','Chi2dof','FLUX_PSF','FLUXERR_PSF','MAG_PSF','MAGERR_PSF','BACK_ANNULUS', 'STD_ANNULUS','FLUX_APER','FLAG_POS'});
            to     = toc;

            fprintf('\nFinished analyazing %s', obj.Name(Iobj,:))
            fprintf('\nFor subframe # %d',obj.CropID{Iobj,1})
            fprintf([' \n only "',num2str(to) ,'" s'])
            
        end
       

        
        function plt = plotLC(obj,Args)
            
            arguments
                
                obj
                Args.Iobj        = [];
                Args.plotCat     = true;
                Args.plotForced  = true;
                Args.Compare     = true;
                
                
            end
            
            Iobj = Args.Iobj;
            
            Isubframe = cell2mat(obj.Data.Catalog.CatID(Iobj,:));
                
            if Args.plotCat   
                     if ~isempty(Isubframe)
                     
                     
                        for  Iiter = 1: length(Isubframe)
                            
                            
                            
                            MSpsf      = obj.Data.Catalog.PSF{Iobj,Iiter}.copy();
                            MSaper     = obj.Data.Catalog.APER_2{Iobj,Iiter}.copy();
                            t0         = ceil(MSpsf.JD(1)) - 0.5 ; 
                            
                            Xlabel = strcat('JD  - ',num2str(t0));
                            
                            Index_psf  = MSpsf.coneSearch(obj.RA(Iobj),obj.Dec(Iobj)).Ind ;
                            Index_aper = MSaper.coneSearch(obj.RA(Iobj),obj.Dec(Iobj)).Ind ;
                            
                            
                            Ypsf   = MSpsf.Data.MAG_PSF(:,Index_psf) ;
                            Yaper  = MSaper.Data.MAG_APER_2(:,Index_aper) ;
                            RobustSDpsf  = RobustSD(Ypsf)  ; 
                            RobustSDaper = RobustSD(Yaper) ;
                            
                            
                            SYSpsf      = obj.Data.Catalog.PSFsys{Iobj,Iiter}.copy();
                            SYSaper     = obj.Data.Catalog.APERsys{Iobj,Iiter}.copy();
                            
                            Index_psfSYS = SYSpsf.coneSearch(obj.RA(Iobj),obj.Dec(Iobj)).Ind ;
                            Index_aperSYS = SYSaper.coneSearch(obj.RA(Iobj),obj.Dec(Iobj)).Ind ;
                            
                            
                            YpsfSYS   = SYSpsf.Data.MAG_PSF(:,Index_psfSYS) ;
                            YaperSYS  = SYSaper.Data.MAG_APER_2(:,Index_aperSYS) ;
                            RobustSDpsfSYS  = RobustSD(YpsfSYS)  ; 
                            RobustSDaperSYS = RobustSD(YaperSYS) ;
                            
                            
                            
                          
                            
                            
                            
                            
                            figure();
                            subplot(2,1,1)
                            plt = plot(MSaper.JD - t0,Yaper,'.','Color','red')
                            LgLbl{1} = sprintf('APER 2 ; Robust SD = %.4f ; ',RobustSDaper);
                            hold on 
                            plot(SYSaper.JD - t0,YaperSYS,'o','Color',[0.1 0.1 0.1])
                            LgLbl{3} = sprintf('APER 2 (SysRem); Robust SD = %.4f ; ',RobustSDaperSYS);
       
                            set(gca,'YDir','reverse')
                            xlabel(Xlabel,'Interpreter','latex')
                            ylabel('Inst Mag','Interpreter','latex')
                            title(sprintf('Catalog APER 2 ; \\# %i ; RA , Dec = (%.5f , %.5f) ;  $B_p$ = %.3f ; $B_p-R_p$ = %.4f',Iobj,obj.RA(Iobj),obj.Dec(Iobj),obj.G_Bp(Iobj),obj.Color(Iobj)),'Interpreter','latex')
                            legend(LgLbl{[1,3]} ,'Interpreter','latex')
                            
                            
                            subplot(2,1,2)
                            plot(MSpsf.JD - t0 , Ypsf, '.' ,'Color', 'red')
                            LgLbl{2} = sprintf('PSF ; Robust SD = %.4f' , RobustSDpsf);
                            hold on 
                            plot(SYSpsf.JD - t0 , YpsfSYS, 'o' ,'Color', [0.1 0.1 0.1])
                            LgLbl{4} = sprintf('PSF (SysRem) ; Robust SD = %.4f' , RobustSDpsfSYS);
                            set(gca,'YDir','reverse')
                            xlabel(Xlabel,'Interpreter','latex')
                            ylabel('Inst Mag','Interpreter','latex')
                            title(sprintf('Catalog PSF  ; Sub Frame \\# %i',Isubframe(Iiter)),'Interpreter','latex')
                            legend(LgLbl{[2,4]},'Interpreter','latex')
                            set(gcf, 'Position', get(0, 'ScreenSize'));


                    
            
                        end
                     
                     else
                         fprintf('\nTarget # %i, could not be detected in the catalogs, B_p = ' ,Iobj,obj.G_Bp(Iobj))
                 
                     end
                     
            end
            
            
         IsubframeFP = cell2mat(obj.CropID(Iobj,:));
            
                
            
            if Args.plotForced
                
                     if ~isempty(IsubframeFP)
                     
                     
                        for  Iiter = 1: length(IsubframeFP)
                            
                            
                            
                            FPpsf      = obj.Data.Forced.MS{Iobj,Iiter}.copy();
                            FPZP       = obj.Data.Forced.PSFzp{Iobj,Iiter}.copy();
                            t0         = ceil(FPpsf.JD(1)) - 0.5 ; 
                            
                            Xlabel = strcat('JD  - ',num2str(t0));
                            
                            FPidx_psf  = FPpsf.coneSearch(obj.RA(Iobj),obj.Dec(Iobj)).Ind ;
                            FPidx_zp = FPZP.coneSearch(obj.RA(Iobj),obj.Dec(Iobj)).Ind ;
                            
                            
                            YpsfFP   = FPpsf.Data.MAG_PSF(:,FPidx_psf) ;
                            YzpFP  = FPZP.Data.MAG_PSF(:,FPidx_zp) ;
                            RobustSDpsfFP  = RobustSD(YpsfFP)  ; 
                            RobustSDzpFP = RobustSD(YzpFP) ;
                            
                            
                            SYSpsfFP      = obj.Data.Forced.PSFsys{Iobj,Iiter}.copy();
                            %SYSaper     = obj.Data.Catalog.APER_2sys{Iobj,Iiter}.copy();
                            
                            FPidx_psfSYS = SYSpsfFP.coneSearch(obj.RA(Iobj),obj.Dec(Iobj)).Ind ;
                            %Index_aperSYS = SYSaper.coneSearch(obj.RA(Iobj),obj.Dec(Iobj)).Ind ;
                            
                            
                            FPYpsfSYS   = SYSpsfFP.Data.MAG_PSF(:,FPidx_psfSYS) ;
                            %YaperSYS  = SYSaper.Data.MAG_APER_2(:,FPidx_zp) ;
                            RobustSDpsfSYSFP  = RobustSD(FPYpsfSYS)  ; 
                            %RobustSDaperSYS = RobustSD(aperSYS) ;
                            
                            
                            
                          
                            
                            
                            
                            
                            figure();
                            subplot(2,1,1)
                            plot(FPZP.JD - t0,YzpFP,'.','Color','red')
                            LgLbl{5} = sprintf('PSF + ZP ; Robust SD = %.4f ',RobustSDzpFP);
                            hold on 
                            plot(FPpsf.JD - t0 , YpsfFP, 'o' ,'Color', [0.1 0.1 0.1])
                            LgLbl{6} = sprintf('PSF ; Robust SD = %.4f' , RobustSDpsfFP);
                            set(gca,'YDir','reverse')
                            xlabel(Xlabel,'Interpreter','latex')
                            ylabel('Inst Mag','Interpreter','latex')
                            title(sprintf('Forced  ; \\# %i ; RA , Dec =  (%.5f  , %.5f) ;  $$B_p$$ = %.3f ; $$ B_p-R_p $$ = %.4f',Iobj,obj.RA(Iobj),obj.Dec(Iobj),obj.G_Bp(Iobj),obj.Color(Iobj)),'Interpreter','latex')
                            legend(LgLbl{5:6} ,'Interpreter','latex')
                            
                            
                            subplot(2,1,2)
                            %plot(SYSaper.JD - t0,yaperSYS,'.','Color',[0.1 0.9 0])
                            %LgLbl{7} = sprintf('APER 2 (SysRem); Robust SD = %.4f ; ',RobustSDaperSYS);
                            %hold on 
                            plot(SYSpsfFP.JD - t0 , FPYpsfSYS, '.' ,'Color', [0.1 0.1 0.1])
                            LgLbl{7} = sprintf('PSF + SysRem ; Robust SD = %.4f' , RobustSDpsfSYSFP);
                            set(gca,'YDir','reverse')
                            xlabel(Xlabel,'Interpreter','latex')
                            ylabel('Inst Mag','Interpreter','latex')
                            T = title(sprintf('Forced PSF + SysRem ; Sub frame \\# %i ; ',IsubframeFP(Iiter)),'Interpreter','latex')
                            T.Interpreter = 'latex'
                            legend(LgLbl(7),'Interpreter','latex')
                            set(gcf, 'Position', get(0, 'ScreenSize'));


                    
            
                        end
                     
                     else
                         fprintf('\nTarget # %i, could not be detected in the catalogs, B_p = ' ,Iobj,obj.G_bp(Iobj))
                 
                     end                
                
                
                
                
                
                
                
            end
            
            
            
            
            
            % plot forced
            
            % compare
            
            
            
            
        end
        
        
        function SysRemPerVisit(obj,Args)
            
            arguments
                
                obj
                Args.Pathway = []
                
            end
            
            
            
            if ~isempty(Args.Pathway)
                
            end
            
            
            
        end
        
        
        
        
        function FP = ForcedMSbatch(obj,Args)
            
            arguments
                
                obj
                Args.Iobj = [];
                Args.CropID = [];
                
            end
            
            
            
            Iobj = Args.Iobj;
            
            cd(obj.Path)
            cd ../
            directories = dir;
            
            DirIndex = zeros(length(directories),1);
            DirName  = [];
            
            for Idir = 1 :length(directories)
                
                if Idir < 3 
                    DirIndex(Idir,1) = nan ;
                     DirName = [DirName ; '99999999'] ;
                    
                else
                
                     DirIndex(Idir,1) = directories(Idir).datenum ;
                     DirName = [DirName ; directories(Idir).name] ;
                end

            end
            [~,Ind] = sort(DirIndex);
            SortedDir = DirName(Ind,:);
            
            if mod((length(Ind)-2)/2,2) == 0 
                
                Nbatch = (length(Ind)-2)/2 ;
                
            else
                 Nbatch = (length(Ind)-3)/2 ;
                
            end
            
            
               
                
            
        counter = 0;      
        for Ibatch = 1 : Nbatch
            
            AI = [];
            
            
            for Idir = 1 : 2
                
                counter = counter + 1;
                cd(SortedDir(counter,:))
                fprintf('\nCollecting relvant files from %s , subframe # %i',SortedDir(counter,:),Args.CropID)
                
                fn = FileNames.generateFromFileName('*proc_Image_1.fits');
                
                if ~isempty(obj.CropID{Iobj,1})
                    
                    if ~isempty(fn.selectBy('FieldID',char((obj.FieldID(Iobj)))).FieldID)
                        
                        FN = fn.selectBy('CropID',Args.CropID);
                        AI = [AI  AstroImage.readFileNamesObj(FN)];
                        fprintf('\nLoaded Subframe %i from dir : %s ',Args.CropID, SortedDir(counter,:))
                       
                       
                        
                    end
                    
                else
                    
                    fprintf('\n Couldnt Find Target # %i In the FOV, RA,DEC = %.5f , %.5f \n',Iobj,obj.RA(Iobj), obj.Dec(Iobj) )
                    
                    break;
                end
                
                cd ../
                
                
                
            end
            
   
            
            
            %%%%%%%%% ADD FLAGS you have to ask for MASK in the pipeline
            tic ; 
            FP{1,Ibatch} = imProc.sources.forcedPhot(AI,'Coo',[obj.RA(Iobj) obj.Dec(Iobj)],'ColNames',{'RA','Dec','X','Y','Xstart','Ystart','Chi2dof','FLUX_PSF','FLUXERR_PSF','MAG_PSF','MAGERR_PSF','BACK_ANNULUS', 'STD_ANNULUS','FLUX_APER','FLAG_POS','FLAGS'});
            to     = toc;

            fprintf('\nFinished analyazing %s Batch # %i / %i', obj.Name(Iobj,:),Ibatch,Nbatch)
            fprintf('\nFor subframe # %d',obj.CropID{Iobj,1})
            fprintf([' \n only "',num2str(to) ,'" s'])
            
        end
        
        end
            
        
        
        function [obj,LC,jd] = plotRMSComparison(obj, Args)
            
            arguments
                
                
                obj
                Args.WDidx    = [];
                Args.Iimage   = 1;
                Args.SaveTo   = [];
                
               
            end
    
              Iiter = Args.Iimage;
              WDidx =Args.WDidx;
              
              Object = obj.Data.ForcedBatch.MS{WDidx, Iiter};
    
              
              Dim = size(Object);
              LC = [];
              jd = [];
              for Ibatch = 1 : Dim(2)
                  flag = true;
                  
                  C{1,Ibatch}    = Object{Ibatch}.copy()
                  
                  [MSmodel2{1,Ibatch},D{1,Ibatch}]  = FitZP2(  C{1,Ibatch} ,'MagField','MAG_PSF','MagErrField','MAGERR_PSF','title',' only good sources MAG PSF (1 visit)','Title2','ZP - SysRem RMS results  - PSF (1 Visit)');
                  %MSmodel2
                  % Csys{1,Ibatch} = C{1,Ibatch}.sysrem('sysremArgs',{'Niter',2},'MagFields' ,{'MAG_PSF'} , 'MagErrFields',{'MAGERR_PSF'});
                  if ~isnan(D{1,Ibatch}.JD)  
                        figure('color','white','Position',[10 10 1120 840 ]);
                        subplot(1,2,1)
                        hold on;
                  
                        a = D{1,Ibatch}.plotRMS('FieldX', 'MAG_PSF', 'PlotSymbol', '+', 'PlotColor', 'red');
                        b = MSmodel2{1,Ibatch} .plotRMS('FieldX', 'MAG_PSF', 'PlotSymbol', 'o', 'PlotColor', 'black');
                        semilogy(a.XData(1),a.YData(1),'.','color','cyan','MarkerSize',20)
                        hline(1/5);
                        xline(19);
                        legend('Original RMS', 'Sysrem RMS',sprintf('WD RMS =  %.3f',a.YData(1)),'SNR = 5','Mag = 19','Interpreter','latex','Location','best');
                        xlabel('Mag','Interpreter','latex');
                        ylabel('RMS','Interpreter','latex'); 
                        title(sprintf( 'RMS Comparison - Forced PSF + SysRem  . Double Visit %i / %i',Ibatch,Dim(2)),'Interpreter','latex');
                        xlim([10,20])
                        ylim([1e-3,5])
                        hold off;
                        subplot(1,2,2)
                  %a = C{1,Ibatch} .plotRMS('FieldX', 'MAG_PSF', 'PlotSymbol', '+', 'PlotColor', 'red');
                  %b = Csys{1,Ibatch} .plotRMS('FieldX', 'MAG_PSF', 'PlotSymbol', 'o', 'PlotColor', 'black');
                        semilogy(a.XData,a.YData-b.YData,'o')
                        hline(0.01)
                        hold on 
                        if a.YData(1) < b.YData(1)
                              semilogy(a.XData(1),b.YData(1)-a.YData(1),'.','Color','red','MarkerSize',20)
                              legend('RMS difference', '0.01',sprintf('WD RMS difference = %.3f',a.YData(1)-b.YData(1)),'Interpreter','latex','Location','best');
                      
                        else
                              semilogy(a.XData(1),a.YData(1)-b.YData(1),'.','Color','magenta','MarkerSize',20)
                              legend('RMS difference', '0.01',sprintf('WD RMS difference = %.3f',a.YData(1)-b.YData(1)),'Interpreter','latex','Location','best');
                      
                        end

                  
                        xlabel('Mag','Interpreter','latex');
                        ylabel('RMS','Interpreter','latex'); 
                        title('Difference in RMS $$ RMS_{psf} - RMS_{psf+sysrem} $$','Interpreter','latex');
                        xlim([10,20])
                  
                        set(gcf, 'Position', get(0, 'ScreenSize'));
                        pause(1);
                  
                        filename = sprintf('%s/RMS_Forced_sysrem_WD_%i_Visit_%i_of_%i.png',Args.SaveTo,WDidx,Ibatch,Dim(2))
                        saveas(gcf, filename)
                        close;
                  
                  
                        figure('color','white','Position',[10 10 1120 840 ]);
                  %subplot(2,1,1)
                        hold on;
                  %a = Object{1,Ibatch} .plotRMS('FieldX', 'MAG_PSF', 'PlotSymbol', '+', 'PlotColor', 'red');
                  %b = Csys{1,Ibatch} .plotRMS('FieldX', 'MAG_PSF', 'PlotSymbol', 'o', 'PlotColor', 'black');
                  %semilogy(a.XData(1),a.YData(1),'.','color','cyan','MarkerSize',20)
                       [t,Sorted] = sort(Object{1,Ibatch}.JD);
                  
                       t0 = round(t(1)) + 0.5 ; 
                       y = D{1,Ibatch}.Data.MAG_PSF(Sorted,1);
                       plot(t-t0,y,'-o')
                       hold on;
                       [tsys,Sortedsys] = sort(MSmodel2{1,Ibatch}.JD);
                       ysys = MSmodel2{1,Ibatch}.Data.MAG_PSF(Sortedsys,1);
                       plot(tsys-t0,ysys,'-o')
                  
                       set(gca,'YDir','reverse')
                       legend(sprintf('WD Forced PSF RobustSD =   %.3f',RobustSD(y)),sprintf('WD Forced PSF + sysrem RobustSD =   %.3f',RobustSD(ysys)),'Interpreter','latex','Location','best');
                       xlabel(['JD - ',num2str(t0)],'Interpreter','latex');
                       ylabel('Inst Mag','Interpreter','latex'); 
                       title(sprintf( 'WD %i - Forced PSF   . $B_p$ = %.3f',WDidx,obj.G_Bp(WDidx)),'Interpreter','latex');
                  %xlim([10,20])
                  %ylim([1e-3,5])
                       hold off;
                 % subplot(2,1,2)
                  
     
                  %set(gca,'YDir','reverse')
                  %legend(sprintf('WD Forced PSF + sysrem RobustSD =   %.3f',RobustSD(ysys)),'Interpreter','latex','Location','best');
                 % xlabel('JD','Interpreter','latex');
                  %ylabel('Inst Mag','Interpreter','latex'); 
                 % title(sprintf( 'WD %i - Forced PSF + SysRem -   . $B_p$ = %.3f',WDidx,obj.G_Bp(WDidx)),'Interpreter','latex');
    
   
                  
                       set(gcf, 'Position', get(0, 'ScreenSize'));
                       pause(1);
                  
                       filename = sprintf('%s/LC_Forced_sysrem_WD_%i_Visit_%i_of_%i.png',Args.SaveTo,WDidx,Ibatch,Dim(2));
                       saveas(gcf, filename)
                       close;
                       
                       
                  else
                      
                      fprintf('Nan Vector on visit %i',Ibatch)
                      flag = false;
                      
                  end
                  
                  if ~isnan(MSmodel2{1,Ibatch}.JD)
                       LC = [LC ; MSmodel2{1,Ibatch}.Data.MAG_PSF(:,1)];
                       jd = [jd ; MSmodel2{1,Ibatch}.JD' ] ;
                       
                  end
                  
           
                  

  
                  
              end
    

              

              if ~isempty(obj.CropID{WDidx}) 
              
                  obj.Data.ForcedBatch.MSsys{WDidx, Iiter} = MSmodel2;
                  
              else
                  obj.Data.ForcedBatch.MSsys{WDidx, Iiter} = {NaN};
              end
end

        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
    end
    
        
        
    
    
    
    
    
    
    
end