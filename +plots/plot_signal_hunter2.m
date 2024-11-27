%

profile on

MT = table();

% MT = SignalHunter2(MT,4, 1, 2023, 9, 16, 20,'PlotNSave',false)

MT = SignalHunter2(MT,4, 1, 2024, 10, 26, 20,'PlotNSave',false)


profile off 
profile viewer

MetaTable = MT;
%%
MT = MetaTable
% Sort MT by maxRMF, with NaNs at the end
nanIdx = isnan(MT.maxRMF); % Identify NaN rows
sortedByMaxRMF = sortrows(MT(~nanIdx, :), 'maxRMF', 'descend'); % Sort rows without NaN
% sortedByMaxRMF = [sortedByMaxRMF; MT(nanIdx, :)]; % Append rows with NaN to the end

for Icand = 1 : 7

    t = datetime(sortedByMaxRMF.JD{Icand},'convertfrom','JD');
    figure();

    plot(t,sortedByMaxRMF.MAG_PSF{Icand},'k-o')
    title(sprintf('(%.4f,%.4f)Pwd = %.3f',sortedByMaxRMF.RA(Icand),sortedByMaxRMF.Dec(Icand),sortedByMaxRMF.Pwd(Icand)))
    set(gca,'YDir','reverse')
end


% Sort MT by MaxPS, with NaNs at the end
[nanIdx] = isnan(MT.MaxPS); % Identify NaN rows
sortedByMaxPS = sortrows(MT(~nanIdx, :), 'MaxPS', 'descend'); % Sort rows without NaN
for Icand = 1 : 100

    t = datetime(sortedByMaxPS.JD{Icand},'convertfrom','JD');
    figure();

    plot(t,sortedByMaxPS.MAG_PSF{Icand},'k-o')
    title(sprintf('(%.4f,%.4f)Pwd = %.3f',sortedByMaxPS.RA(Icand),sortedByMaxPS.Dec(Icand),sortedByMaxPS.Pwd(Icand)))
    set(gca,'YDir','reverse')
end



% Sort MT by RMSNsigma, with NaNs at the end
[nanIdx] = isnan(MT.RMSNsigma); % Identify NaN rows
sortedByRMSNsigma = sortrows(MT(~nanIdx, :), 'RMSNsigma', 'descend'); % Sort rows without NaN
%sortedByRMSNsigma = [sortedByRMSNsigma; MT(nanIdx, :)]; % Append rows with NaN to the end
for Icand = 1 : 100

    t = datetime(sortedByRMSNsigma.JD{Icand},'convertfrom','JD');
    figure();

    plot(t,sortedByRMSNsigma.MAG_PSF{Icand},'k-o')
    title(sprintf('(%.4f,%.4f)Pwd = %.3f',sortedByRMSNsigma.RA(Icand),sortedByRMSNsigma.Dec(Icand),sortedByRMSNsigma.Pwd(Icand)))
    set(gca,'YDir','reverse')
end

% Display summaries (optional)
fprintf('Sorted by maxRMF with NaNs at the end: Top 5 rows:\n');
disp(sortedByMaxRMF(1:5, :));

fprintf('Sorted by MaxPS with NaNs at the end: Top 5 rows:\n');
disp(sortedByMaxPS(1:5, :));

fprintf('Sorted by RMSNsigma with NaNs at the end: Top 5 rows:\n');
disp(sortedByRMSNsigma(1:5, :));
