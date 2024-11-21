function nightsRun(mount,computer,Year,Month, Day,Nnights,batchSize)


if computer == 'e'

    tel = [1:2];

else

    tel = [3:4];

end

 % Create a datetime object for the starting date
startDate = datetime(Year, Month, Day);

% Generate Nnights consecutive dates
nextDates = startDate + caldays(0:Nnights-1);

% Extract year, month, and day for each date
for Idate = 1  : numel(nextDates)

    for Itel = tel
  
    fprintf('\n############ Processing %s (Tel # %i )############\n',nextDates(Idate),Itel)
    nightRun(mount,Itel,year(nextDates(Idate)),month(nextDates(Idate)),day(nextDates(Idate)),batchSize)

    end
end









end