function tab = nightRun(mount,tel,year,month,day,batchSize,Args)


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

  if ~exist(Args.SaveDir, 'dir')
        mkdir(Args.SaveDir);
  end



    tab = WDmainLAST(mount, tel, year,month,day, batchSize,'PlotNSave',false);

    save(strcat(Args.SaveDir,sprintf('Results_table_%s_%s_%i_vis.mat',Args.Tel,Args.Date,batchSize)),'tab');
    
    
    



end % nightRun end