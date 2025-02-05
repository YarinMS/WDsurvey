
%%
Year = 2025;
Month = 1;
Day = 27;
Mount = 7;
Tel = 1;
FieldID = '1412.WDM7';
ObsID = sprintf('LAST.01.%02d.%02d.%04d%02d%02d-%s',Mount,Tel,Year,Month,Day,FieldID)
RES = Util.getCropIDMarvin(Mount,Tel,Year,Month,Day,FieldID)
 %%
 MainTable = table();
 %%
f = waitbar(0)
counter = 0;
 for D = [22]
     for T = [3]
         counter = counter+1;
            
         ObsID = sprintf('LAST.01.%02d.%02d.%04d%02d%02d-%s',Mount,T,Year,Month,D,FieldID)
         RES = Util.getCropIDMarvin(Mount,T,Year,Month,D,FieldID);

         if ~isempty(RES.MSall)
            tab = Util.collectWDsFromMS(RES,ObsID);

            MainTable = vertcat(MainTable,tab)
         end

         waitbar(counter/(4*8),f,sprintf('Finished Date %i-%i-%i Tel %i',D,Month,Year,T))
    
     end 
 end


 %% Main table 
 MT = MainTable(MainTable.Gmag<19,:)
 figure
 plot(MT.BpRp,MT.RMS,'.','MarkerSize',9)
 xlabel('$B_p-R_p$')
 ylabel('RMS')
 
 figure
 plot(MT.Gmag,MT.RMS,'.','MarkerSize',9)
 xlabel('$B_p-R_p$')
 ylabel('Gmag')



 %% 2 vis
MainTable2vis = table();
 %%
f = waitbar(0)
counter = 0;
 for D = [29]
     for T = [1:4]
         counter = counter+1;
            
         ObsID = sprintf('LAST.01.%02d.%02d.%04d%02d%02d-%s',Mount,T,Year,Month,D,FieldID)
         RES = Util.getCropIDMarvin(Mount,T,Year,Month,D,FieldID);

         if ~isempty(RES.MSall)
            tab = Util.collectRMS2Vis(RES,ObsID,Mount,T,Year,Month,D,FieldID);

            MainTable2vis = vertcat(MainTable2vis,tab)
         end

         waitbar(counter/(4*8),f,sprintf('Finished Date %i-%i-%i Tel %i',D,Month,Year,T))
    
     end 
 end



 %%
 MT = MainTable2vis;
 Mdiff = abs(MT.Gmag-MT.LMAG);
 Mwd = MT(Mdiff < 1.5,:);
 % Mwd all WD from 4 telescopes specific moun, field id and date.

 figure
 plot(Mwd.BpRp,Mwd.RMS,'.','MarkerSize',9)
 xlabel('$B_p-R_p$')
 ylabel('RMS')
 
 figure
 plot(Mwd.Gmag,Mwd.RMS,'.','MarkerSize',9)
 xlabel('Gmag')
 ylabel('RMS') 



 figure
 semilogy(Mwd.BpRp,Mwd.RMS,'.','MarkerSize',9)
 xlabel('$B_p-R_p$')
 ylabel('RMS')
 
 figure
 semilogy(Mwd.Gmag,Mwd.RMS,'.','MarkerSize',9)
 xlabel('Gmag')
 ylabel('RMS')



 %%


 
 figure
 semilogy(Mwd.LMAG,Mwd.RMS,'.','MarkerSize',9)
 xlabel('MAG PSF')
 ylabel('RMS')


 figure
 histogram(Mwd.LMAG,20)
 xlabel('MAG PSF')
 ylabel('# LC')



 figure
 histogram(Mwd.Gmag,20)
 xlabel('Gaia G mag')
 ylabel('# LC')