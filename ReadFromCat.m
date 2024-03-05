function [Result] = ReadFromCat(Path,Args)
% Functions to read specific fields from catalog fits files
% 
%

arguments
    
    Path 
    Args.Header = true;
    Args.Prop   = 'FWHM';
    Args.Field  = ''; 
    Args.SubFrame = ''; % '015' or '009'
    Args.plot     = true;
    Args.getAirmass = false;
    
    
end


% Initilize
FIELDID = [];
JD      = [];
FWHM    = [];
LimMag  = [];
RA   = [];
DEC   = [];



cd(Path)

if Args.Header
    % Read from Header
    Dirs = dir;
    
    
    
    for Ivisit = 3 : length(Dirs)
        
        cd(Dirs(Ivisit).name)
        fprintf('\n %i / %i',Ivisit,length(Dirs))
        
        Cats  = dir;
        % Field and sub frame cut:
        
        FieldIndex = find(contains({Cats.name},Args.Field));
        Cats  = Cats(FieldIndex);
        SubIndex = find(contains({Cats.name},[Args.SubFrame,'_sci_proc_Cat_1.fits']));
        Cats  = Cats(SubIndex);
        
        if numel(Cats) ~= 20
            
           fprintf('\nMissing images for sub-image %s in Visit %s \n',Args.SubFrame,Dirs(Ivisit).name)
        end
        
        % Extract what you are looking for
        for Iimage = 1 : numel(Cats)
            
            AH = AstroHeader(Cats(Iimage).name,3); 
            
            
            FIELDID = [FIELDID ; AH.Key.FIELDID];
            JD      = [JD ; AH.Key.JD];
            FWHM    = [FWHM ;AH.Key.FWHM];
            LimMag  = [LimMag ; AH.Key.LIMMAG];
            
            alpha = [AH.Key.RAU1,AH.Key.RAU2,AH.Key.RAU3,AH.Key.RAU4];
            delta = [AH.Key.DEC1,AH.Key.DEC2,AH.Key.DEC3,AH.Key.DECU4];
            
            RA    = [RA; mean(alpha)];
            DEC   = [DEC ; mean(delta) ] ;
            

                  
            
            
            
        end
        
        cd ../
        
    end
    
    [~,sorted] = sort(JD);
    Result.FIELDID = FIELDID(sorted);
    Result.JD      = JD(sorted);
    Result.FWHM    = FWHM(sorted);
    Result.LimMag = LimMag(sorted);
    Result.Coord   = [RA(sorted) DEC(sorted)];
    
    
    if Args.plot
        
        
        
        t = datetime(Result.JD,'convertfrom','jd');
        figure('Color','white');
        
        subplot(3,1,1)
        plot(t,Result.FWHM)
        xlabel('Time','Interpreter','latex')
        
        ylabel('FWHM [arcsec]','Interpreter','latex')
        subplot(3,1,2)
        plot(t,Result.LimMag)
        xlabel('Time','Interpreter','latex')
        set(gca,'YDir','reverse')
        
        ylabel('Lim Mag [mag]','Interpreter','latex')
        subplot(3,1,3)
        plot(RA(sorted), DEC(sorted))
        xlabel('RA [deg]','Interpreter','latex')
        
        ylabel('DEC [deg]','Interpreter','latex')
    end
        
        
        
    if Args.getAirmass 
        
        [Airmass,Time] = getAirmass(Result);
        
        [~,timeInd] = sort(Time);
        Result.AMtime = Time(timeInd);
        Result.AM     = Airmass(timeInd);
        
    end
    

        
      
    

end


end