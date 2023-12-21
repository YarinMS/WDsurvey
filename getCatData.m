function [LC,RAcat,Deccat,Xcat,Ycat] = getCatData(RA2,Dec2,Target)
%% AstroCatlaog
                         
                          cd(Target.Pathway)
                          cd ../
             
                          directory = dir;
                          LC = [];
                          RAcat = [];
                          Deccat = [];
                          Xcat  = [];
                          Ycat = [];
                          
                          if Target.CropID > 9 
                              
                              Str = strcat('*0',num2str(Target.CropID),'_sci_proc_Cat*')
                              
                          else
                              
                             Str = strcat('*00',num2str(Target.CropID),'_sci_proc_Cat*')
                               
            
                          end
                          
                          for i = 3 : length(directory)
                          

               
                                 cd(directory(i).name)
                          
                                AC=AstroCatalog(Str,'HDU',2)
                                AC.convertCooUnits('deg')
                                
% find index psf  :

                                 for Iimg =  1 :20
    
                                         [RA, Dec] = AC(Iimg).getLonLat('deg');

                                         [Dist,inx_cat1] = min(sqrt((Dec - Dec2).^2 + (RA - RA2).^2));
                                         %inx_cat1
                                         if Dist < 1e-4
                                              %
                                              
                                              LC = [LC ; AC(Iimg).Catalog(inx_cat1,47)];
                                              RAcat = [RAcat; AC(Iimg).Catalog(inx_cat1,52)];
                                              Deccat = [Deccat ; AC(Iimg).Catalog(inx_cat1,53)];
                                              Xcat  = [Xcat ;AC(Iimg).Catalog(inx_cat1,45)];
                                              Ycat = [Ycat;AC(Iimg).Catalog(inx_cat1,46)];
                                          %AC(Iimg).Catalog(inx_cat1,45)
                                          %AC(Iimg).Catalog(inx_cat1,46)
                                         else
                                              
                                              LC = [LC ; nan];
                                              RAcat = [RAcat; nan];
                                              Deccat = [Deccat ; nan];
                                              Xcat  = [Xcat ;nan ];
                                              Ycat = [Ycat;nan];
 
                                              
                                              
                                         end

                                              
                                          
  

                                 end
                                    cd ../
                          end
                          

                             
                
end

