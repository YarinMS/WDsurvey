function performForcedPhotometry(obj, fileList, eventInfo)
    % eventInfo contains target coordinates for forced photometry
    
        ai =[];
        for i = 1:numel(AI)
            ai = [ai ; AstroImage.readFileNamesObj(AI{i})];
        end
    
    
        if ~isempty(AI)
            tic ; 
            FP = imProc.sources.forcedPhot(AI,'Coo',[obj.RA(Iobj) obj.Dec(Iobj)],'ColNames',{'RA','Dec','X','Y','Xstart','Ystart','Chi2dof','FLUX_PSF','FLUXERR_PSF','MAG_PSF','MAGERR_PSF','BACK_ANNULUS', 'STD_ANNULUS','FLUX_APER','MAG_APER','FLAG_POS','FLAGS'});
            to     = toc

            fprintf('\nFinished analyazing %s Batch # %i / %i', obj.Name(Iobj,:),Ibatch,Nbatch)
            fprintf('\nFor subframe # %d',obj.CropID{Iobj,1})
            fprintf([' \n only "',num2str(to) ,'" s'])
        else
                  FP = NaN;
        end
            
        
        
    end
end