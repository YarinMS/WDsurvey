function [ms,m,dm,detections] = CleanLargeErr(ms,threshold,MagThreshold)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

      

       all_measurments = 0;
       c1 = 0 ;


       for i = 1 : length(ms.Data.MAG_PSF(:,1))
           all_measurments = all_measurments +1; 
    
           s1 = ms.Data.MAGERR_PSF(i,1);
           m1 = ms.Data.MAG_PSF(i,1);
    

           if ~isnan(s1)
                if (abs(s1) > threshold)  || (m1 > MagThreshold)
        
                     ms.Data.MAGERR_PSF(i,:) = nan;
                     ms.Data.MAG_PSF(i,:) = nan;
                     fprintf('error too large t1 :%d \n',m1/s1)
        
                else
        
                     c1 = c1 +1;
                     
        
                end
         
           else
        
                ms.Data.MAGERR_PSF(i,:) = nan;
                ms.Data.MAG_PSF(i,:) = nan;
                fprintf('errorbar has nan value \n')
        
           end
    
       end
       
       dm = ms.Data.MAGERR_PSF(~isnan(ms.Data.MAG_PSF(:,1)),1);
       t  = ms.JD(~isnan(ms.Data.MAG_PSF(:,1)));
       m  = ms.Data.MAG_PSF(~isnan(ms.Data.MAG_PSF(:,1)),1);
       detections = (100*c1)/all_measurments;
       
       

       
end

