function nightlySignalHunt(MetaTable,year,month,day,Args)

arguments
    MetaTable 
    year 
    month 
    day 
    Args.Nvisits =  2;
    Args.ID = '20Vis'; 
end


%% loop over obs night

Mounts = [2:6,8,10,1];
h = waitbar(0)
Counter = 0 ;
for Imount = Mounts
    for Itel = [1:4]
        if Imount ==2
            if Itel <= 2
                continue
            end
        end
        Counter = Counter+1;
        checkDir = sprintf('~/marvin/LAST.01.%02d.%02d/%04d/%02d/%02d/proc',Imount,Itel,year,month,day);

        if isdir(checkDir)
            waitbar(Counter/(Imount*Itel),h,sprintf('Mount %i; Tel %i ',Imount,Itel))
            MetaTable = SignalHunter2(MetaTable,Imount, Itel, year, month, day, Args.Nvisits,'PlotNSave',false,'ID',Args.ID)
            
        end



    end
end

save(sprintf('/media/yarinms/Data2/Projects/MarvinRuns/%s/Results_Table_LAST.01.%02d.%02d_%04d.%02d.%02d_%s.mat',Args.ID,Imount,Itel,year,month,day),'MetaTable','-v7.3');
end
