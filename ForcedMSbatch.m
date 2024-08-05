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
            if ~isempty(AI)
            tic ; 
            FP{1,Ibatch} = imProc.sources.forcedPhot(AI,'Coo',[obj.RA(Iobj) obj.Dec(Iobj)],'ColNames',{'RA','Dec','X','Y','Xstart','Ystart','Chi2dof','FLUX_PSF','FLUXERR_PSF','MAG_PSF','MAGERR_PSF','BACK_ANNULUS', 'STD_ANNULUS','FLUX_APER','FLAG_POS','FLAGS'});
            to     = toc;

            fprintf('\nFinished analyazing %s Batch # %i / %i', obj.Name(Iobj,:),Ibatch,Nbatch)
            fprintf('\nFor subframe # %d',obj.CropID{Iobj,1})
            fprintf([' \n only "',num2str(to) ,'" s'])
            else
                  FP{1,Ibatch} = NaN;
            end
            
        end
        
        end