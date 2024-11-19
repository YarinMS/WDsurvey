function Res = nightRun(mount,tel,year,month,day,Args)


arguments
    
    mount double
    tel double
    year double
    month double
    day  double
    batchSize double
    
    
    Args.Date    =  sprintf('%04d-%02d-%02d',year,month,day);
    Args.SaveDir = sprintf('~/Documents/WD_survey/NightRun/%04d-%02d-%02d/',year,month,day);
    Args.Tel     = sprintf('LAST.01.%02d.%02d',mount,tel)
    
    
    
end % Arguments



    tab = WDmain(m, tel, year,month,day, batchSize);

    stackedWDtable = vertcat(tab{:});
    
    
    



end % nightRun end