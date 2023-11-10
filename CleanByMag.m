function [ms] = CleanByMag(ms,threshold)
%   for a matched sources object filter target with mean magnitude > threshold 
%   the value of a target mean magnitude is given from the
%   MatchedSources.plotRMS function

rms = ms.plotRMS('FieldX','MAG_PSF') ;
hold on
lg = cell(1,2) ;
lg{1} = 'Forced Phot product' ;


if sum(rms > threshold) > 0 
     
     Ind  = rms.XData > threshold ;
     
     if length(Ind) >= 1
         
         ms.Data.MAG_PSF(:,Ind) = nan;
         ms.Data.MAGERR_PSF(:,Ind) = nan;
         ms.plotRMS('FieldX','MAG_PSF');
         hold off
         lg{2} = 'cleaned' ;
         legend(lg(:))
         pause(7);
         close;
         
     end
     
     
    
     
end

end

