%%
WDcoords =  [151.496162,22.825555;
             224.058543,37.790009;
             126.157447,47.814221;
             237.273780,76.498722;
             335.211509,27.500142;
             205.365297,7.874315;
             224.003602,57.697353;
             14.578353,30.018686;
             %132.617989,27.322151;
             333.329728,29.426885;
             287.017601,-6.961325;
             313.1827,46.6596;
             349.308368,26.472297;
             350.6544,29.1893;
             354.7539,44.4560;
             327.9921,33.3334;
             269.8235,31.2372;
             93.3582,37.6778;
             330.9053,41.3110;
             65.072070,36.272278;
             13.418762,36.020888;
             350.017121,27.106564;
             278.371430,24.350063;
             358.862179,30.933093;
             331.163397,41.992909;
             335.333409,44.100147]

%%
gTable = table();
for I=1:height(WDcoords)

    gRow   = Util.gaiaConeSearch(WDcoords(I,1),WDcoords(I,2));
    if ~isempty(gRow)
    gRow = gRow(1,:)
    else
        gRow = table()
        continue;
    end
    gRow.AbsG = gRow.phot_g_mean_mag +5 -5* log10(1000./gRow.parallax);
    gTable = vertcat(gTable,gRow);


end
%%
lgLabel{1} = '100pc Gaia'
lgLabel{2}  =  sprintf('($M_G$=%.2f, $B_p-R_p$=%.2f, $P_{wd}$ = %.2f)', ...
        gRow.AbsG,gRow.bp_rp,gRow.Pwd)

figure()

plts.plotHRDiagramWithSource(gaiaData,gRow.AbsG,gRow.bp_rp)

hold on

for I = 1: height(gTable)-1

    % scatter(gTable.bp_rp(I),gTable.AbsG(I))
    scatter(gTable.bp_rp(I),gTable.AbsG(I), 30, 'MarkerEdgeColor', [0.85, 0.33, 0.1], ...
        'MarkerFaceColor', [0.85, 0.33, 0.1], 'LineWidth', 1.5)

    lgLabel{I+2} = sprintf('($M_G$=%.2f, $B_p-R_p$=%.2f, $P_{wd}$ = %.2f)', ...
        gTable.bp_rp(I),gTable.AbsG(I),gTable.Pwd(I));

end

legend(lgLabel(:))


%% Find in gtab
for I = 1:height(WDcoords)
    wdra = WDcoords(I,1);
    wddec = WDcoords(I,2);

    idx = abs(gtab.RA - wdra) < 3/3600 & abs(gtab.Dec-wddec) < 3/3600;
    matchedIdx{I} = idx;
end

%% For each source get all available lc
FieldNames = cell(0,height(WDcoords));
MT         = zeros(height(WDcoords),7);
for I =1:height(WDcoords)

    Tab = gtab(matchedIdx{I},:)
    if isempty(Tab)
        continue;
    end
        FieldNames(I) = {Tab.FieldID{1}};
        
        ID  = Tab{1,{'TelescopeID'}};
        MT(I,1)  = str2num(ID(9:10));
        MT(I,2)  = str2num(ID(end-1:end));
        MT(I,3)  = Tab{1,{'Year'}}
        MT(I,4)  = Tab{1,{'Month'}}
        MT(I,5)  = Tab{1,{'Day'}}
        MT(I,6)  = Tab{1,{'RA'}}
        MT(I,7)  =Tab{1,{'Dec'}}
        

        figure()
        t = Tab.JD;
        t = datetime(t{1},'convertfrom','jd');
        y = Tab.MAG_PSF;
        plot(t,y{1},'k-o')
        i =I;
%title(sprintf('(%.4f,%.4f)  $P_{wd}$ -  %.2f; ID \\# %i  $B_p$ = %.3f GG = %.3f G =%.3f',Tab.RA(i),Tab.Dec(i), Tab.Pwd(i),i,gTable.phot_g_mean_mag(I),gTable.phot_g_mean_mag(i),gTable.phot_g_mean_mag(i)))
%xlabel(sprintf('Abs  $G$ = %.2f; $B_p-R_p$ = %.3f\n %s %04d-%02d-%02d %s',Tab.AbsMag(i),Tab.BpRp(i),Tab.TelescopeID(i,:),Tab.Year(i),Tab.Month(i),Tab.Day(i),Tab.FieldID{i}))
        set(gca,'YDir','reverse')

end


%%
% Suppose:
%   cands: Nx2 matrix with cands(:,1)=RA (degrees), cands(:,2)=DEC (degrees)
%   gaiaIDs: an N-by-1 cell array of strings, containing Gaia DR3 IDs,
%            e.g. gaiaIDs{i} = 'Gaia DR3 1234567890'
%   T: the big table with ~4000 rows, containing columns:
%         T.RA, T.DEC, T.Time, T.Flux (example)
%   matchedIdx{i}: for the i-th candidate, the row indices in T that match.

N = size(gTable, 1);   % number of candidates
outRows = [];         % We'll build a new table for the matched light curves

% Create some empty arrays to hold the new columns
allGaiaIDs = {};      % cell array of strings, parallel to each row in outRows
allTimes   = [];      % numeric array for times
allFluxes  = [];      % numeric array for flux, etc.
outRows = table( ...
    'Size', [0 5], ...
    'VariableTypes', {'cell','double','double','double','double'}, ...
    'VariableNames', {'GaiaID','RA','DEC','Time','Flux'} );
for i = 1:N
    idx = matchedIdx{i};
    if isempty(idx)
        fprintf('Candidate %d (GaiaID=%s) not found in T!\n', i, gaiaIDs{i});
        continue
    end

    % We might have multiple matching rows. Let's assume we want them all.
    % Extract from T:
    candRows = gtab(idx, :);  % a sub-table of T
    % Now each row in candRows presumably has T.Time, T.Flux, etc.

    % We want to store them in a combined table. But we also want to label
    % them with the candidate's Gaia ID.
    nMatches = height(candRows);
    theseIDs = repmat(gTable.designation{i}, nMatches, 1);  % replicate the same GaiaID
    % We'll store them in a new variable "GaiaID" that goes alongside Time, Flux

    % Option 1: build a new table
    newTab = table;
    newTab.GaiaID = theseIDs;        % column of the same ID repeated
    newTab.RA = candRows.RA;         % or you can skip if you don't need it
    newTab.DEC = candRows.Dec;
    newTab.Time = candRows.JD;     % or whatever your light-curve column is
    newTab.Flux = candRows.MAG_PSF;

    % Append to outRows:
    if isempty(outRows)
        outRows = newTab;
    else
        outRows = [outRows; newTab]; %#ok<AGROW>
    end
end

% Now outRows is a table of all matched light-curve rows, with a "GaiaID" column
% that identifies which candidate star they belong to.

% 2) Write to CSV or MAT
writetable(outRows, 'lightcurves_matched.csv');   % for Python, CSV is convenient
% or
% save('lightcurves_matched.mat', 'outRows');


%%

%RES ={};


for Iwd = [1:17  19: height(WDcoords)]

    if MT(Iwd,1) ==0
        continue;
    end

[Res] = Jan.getTargetDataMarvin(MT(Iwd,1),MT(Iwd,2),MT(Iwd,3),MT(Iwd,4),MT(Iwd,5),MT(Iwd,6),MT(Iwd,7),FieldNames{Iwd})

RES = [RES; {Res}]

end