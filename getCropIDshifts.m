%%%
funpackFitsFiles('2024-08-11 17:37:30', '2024-08-11 17:40:00','/last04e/data1/archive/LAST.01.04.01/', '~/Documents/to/unpack/')






%%


% pwd =  '/home/ocs/Documents/to/unpack'


AI = AstroImage('LAST.01.04.01_20240811.173902.358_clear_Test20s_016_001_001_sci_raw_Image_1.fits', 'HDU',1)
Args.BlockSize                        = [1600 1600];  % empty - full image
Args.OverlapXY                        = [64 64];


 [SI, InfoCCDSEC] = imProc.image.image2subimages(AI, Args.BlockSize)%, 'UpdateCat',false,...
                                                                        {},...
                                                                        'OverlapXY',Args.OverlapXY,...
                                                                        'UpdateWCS',false,...
                                                                        'UpdatePSF',false);
                                                                    
% Calculate shifts
XYshift = zeros(24,2);

for i= 1 : 24
    
    a = str2num(SI(i).Header{88,2});
    x_min = a(1);
    x_max = a(2);
    y_min = a(3);
    y_max = a(4);
    
     XYshift(i,1) = x_min % (0)
     XYshift(i,2) = y_min
    
    if i <=6
        % frame starts from x = 0 to x = DOESNTMATTER (1590 till overlap)
       
        
        
        
    elseif i <=12
        
    elseif i <= 18
        
    else
        
        
    end
    

end                                                    
                                                                    
%% Now you have all crop IDs.






loadFitsInDS9('~/Documents/to/unpack/','x',3350,'y',4800,'radius',5)
