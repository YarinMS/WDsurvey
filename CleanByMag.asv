function [ms] = CleanByMag(ms,threshold)
%   for a matched sources object filter target with mean magnitude > threshold 
%   the value of a target mean magnitude is given from the
%   MatchedSources.plotRMS function

rms = ms.plotRMS('FieldX','MAG_PSF','PlotColor','r') ;
hold on
lg = cell(1,2) ;
lg{1} = 'Forced Phot product' ;


if sum(rms.XData > threshold) > 0 
     
     Ind  = rms.XData > threshold ;
     
   
         
         ms.Data.MAG_PSF(:,Ind) = nan;
         ms.Data.MAGERR_PSF(:,Ind) = nan;
         ms.plotRMS('FieldX','MAG_PSF');
         hold off
         lg{2} = 'cleaned' ;
         legend(lg(:),'Location','best','Interpreter','latex')
         pause(7);
         close;
         

     
     
else
    fprintf('\nNo data to remove')
     
     
    
     
end

end

