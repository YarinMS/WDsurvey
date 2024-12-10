function plotNTabStat(Tab, Args)

arguments
    Tab
    Args.Xfield = 'C_Back';
    Args.Yfield = 'maxRMF';
    Args.gaiaData = [];
end

% Separate WD table for specific plotting
WDtable = Tab(Tab.Pwd > 0, :);
xT = Tab.(Args.Xfield);
yT = Tab.(Args.Yfield);
xW = WDtable.(Args.Xfield);
yW = WDtable.(Args.Yfield);

% Plot the scatter plot
figure();
scatter(xT, yT, 25, 'MarkerEdgeColor',[0.85, 0.33, 0.1], ...
        'MarkerFaceColor', 'none','MarkerFaceAlpha', 0.7);
hold on;
plot(xW, yW, 'ok');
xlabel('Corr RA');
ylabel('SD from mean (RMF)');

% Enable data cursor mode
dcm = datacursormode(gcf);
datacursormode on;

% Loop to allow multiple point selection
selected_indices = [];
disp('Click on points to select them. Press Enter when finished.');

while true
    pause; % Wait for user interaction
    c_info = getCursorInfo(dcm); % Retrieve clicked data point
    if isempty(c_info)
        % User pressed Enter without selecting a point
        break;
    end

    % Find the row index of the clicked point
    row_idx = find(xT == c_info.Position(1) & yT == c_info.Position(2));
    if ~isempty(row_idx)
        selected_indices = [selected_indices; row_idx(1)]; % Store selected index
        disp(['Selected point index: ', num2str(row_idx(1))]);
    end
end

% Plot light curves and HR diagram for all selected points
for k = 1:length(selected_indices)
    i = selected_indices(k);

    % Extract time and magnitude data
    figure();
    subplot(2, 1, 1);
    t = Tab.JD(i);
    t = datetime(t{1}, 'convertfrom', 'jd');
    y = Tab.MAG_PSF(i);
    plot(t, y{1}, 'k-o');

    % Title and labels
    title(sprintf('(%.4f, %.4f)  $P_{wd}$ - %.2f; ID \\# %i', Tab.RA(i), Tab.Dec(i), Tab.Pwd(i), i));
    xlabel(sprintf('Abs  $G$ = %.2f; $B_p-R_p$ = %.3f\n %s %04d-%02d-%02d %s', ...
        Tab.AbsMag(i), Tab.BpRp(i), Tab.TelescopeID(i,:), Tab.Year(i), Tab.Month(i), Tab.Day(i), Tab.FieldID{i}));
    set(gca, 'YDir', 'reverse');

    % Plot HR diagram if Gaia data exists
    if ~isempty(Tab.AbsMag(i)) && ~isempty(Args.gaiaData)
        subplot(2, 1, 2);
        plts.plotHRDiagramWithSource(Args.gaiaData, Tab.AbsMag(i), Tab.BpRp(i));
    end
end
disp('Selection and plotting complete.');
end
