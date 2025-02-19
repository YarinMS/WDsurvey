function WDtable = collectRMS2Vis(RES,ObsID,Mount,Tel,Year,Month,Day,FieldID)

WDtable = table();
h = waitbar(0)
for I = 1:24
    currentCrop  = find(cell2mat(RES.IDs) == I);
    mms          = RES.MSall(currentCrop);
    cropIDcoords = (RES.MScoords(currentCrop));


    % groups = {};  % initialize an empty cell array to store the groups
    % N = height(mms);
    % if mod(N,2) == 0
    %     % If N is even, just group them into pairs.
    %     nGroups = N/2;
    %     groups = cell(nGroups,1);
    %     for i = 1:nGroups
    %         idxStart = (i-1)*2 + 1;
    %         groups{i} = mms(idxStart:idxStart+1);
    %     end
    % else
    %     % If N is odd, we want all groups of 2 except the last group,
    %     % which will have 3 elements.
    %     % (This code assumes N is at least 3.)
    %     nGroups = (N - 3) / 2;  % number of full groups of 2
    %     groups = cell(nGroups+1,1);
    %     for i = 1:nGroups
    %         idxStart = (i-1)*2 + 1;
    %         groups{i} = mms(idxStart:idxStart+1);
    %     end
    %     % The last group gets the final 3 elements.
    %     groups{end} = mms(end-2:end);
    % end
    % 
    % % Display the grouping result.
    % for g = 1:length(groups)
    %     fprintf('Group %d has %d elements\n', g, numel(groups{g}));
    % end

    for g = 5 %:length(groups)
    % currentBatch = groups{g};  % This is a cell array containing 2 (or 3) elements.
    % 
    % % For example, if you want to "unwrap" each element (if each is a {1x1 cell})
    % ms = [];  % clear out ms for this batch
    % for j = 1:length(currentBatch)

     ms = [];
    for c = 1: length(mms)
        ms = [ms mms{c}{1}];
    end
     

    %     % currentBatch{j} is a 1x1 cell, so we unwrap it using {1}
    %     ms = [ms, currentBatch{j}{1}];
    % end
    % 
    % Now process ms as before:
    MSU = mergeByCoo(ms, ms(1));
    MSU.bestMag;

% Calibrate mms
% Setting bad Photometry to NaN.
args.BadFlags = {'Saturated', 'Negative', 'NaN', 'Spike', 'Hole', 'NearEdge','Overlap'}; % Change to NaN all data points associated with these flags.
mms = MSU.setBadPhotToNan('BadFlags', args.BadFlags, 'MagField', 'MAG_PSF', 'CreateNewObj', true);

% Consider all sources with all nans sources with NdetPts > args.Ndet. 
NdetGood = sum(~isnan(mms.Data.MAG_PSF), 1);
Fndet = NdetGood > (0.80*mms.Nepoch); % Allow for 15% no detections per source.
mms = mms.selectBySrcIndex(Fndet, 'CreateNewObj', false);
% use bestMag to get the best photometry for a source ( aper 3 / psf)
mms.bestMag


r = lcUtil.zp_meddiff(mms, 'MagField', {'MAG_PSF'}, 'MagErrField', {'MAGERR_PSF'});
[mms, ~] = applyZP(mms, r.FitZP, 'ApplyToMagField', 'MAG_PSF');

Scoords = [mean(mms.Data.RA,'omitnan')' mean(mms.Data.Dec,'omitnan')'];
Colors= zeros(height(Scoords),1);
f= waitbar(0)
PWD = pwd;

for Is = 1 : height(Scoords)
    ra = Scoords(Is,1);
    dec = Scoords(Is,2);
%    waitbar(Is/height(Scoords),f,sprintf('%i / %i g = %i / %i\n %i',Is,height(Scoords),g,length(groups),I))
    try
    AC = catsHTM.cone_search('GAIADR3', ra*pi./180, dec*pi./180, 3, 'OutType', 'AstroCatalog');
    
    
    Colors(Is) =  AC.Table.phot_bp_mean_mag(1) - AC.Table.phot_rp_mean_mag(1);


    catch
        Colors(Is) = NaN;
    end
end


figure();
a = mms.plotRMS('FieldX','MAG_BEST')

figure();
scatter(a.XData, a.YData, 8, Colors, 'filled','MarkerFaceAlpha',0.7); % Use scatter to color-code points
set(gca, 'YScale', 'log'); % Set the y-axis to logarithmic scale
colorbar; % Add a colorbar to show the meaning of color
colormap(jet);
ylim([0.001 0.25])
xlim([11.0 19.2])
grid on; % Enable grid

% Label colorbar
cb = colorbar;
cb.Label.Interpreter = 'latex'; % Use LaTeX interpreter for proper formatting
cb.Label.String = '$$B_p - R_p$$'; 

PN = sprintf('%s_CID_%i_BN_%i_ALL.png',ObsID,I,g);
title(sprintf('%s CID %i BN %i 2vis',ObsID,I,g))
        saveas(gcf, PN)




color_bin_edges = min(Colors):0.3:max(Colors); % Color binning with 0.2 bin width
mag_bin_edges = linspace(min(a.XData), max(a.XData), 20); % 10 bins for magnitude

% Initialize arrays to store binned data
binned_X = []; 
binned_Y = []; 
binned_C = []; % Color to be used in scatter plot

% Loop over magnitude bins
for m = 1:length(mag_bin_edges)-1
    mag_mask = a.XData >= mag_bin_edges(m) & a.XData < mag_bin_edges(m+1);
    
    % Loop over color bins
    for c = 1:length(color_bin_edges)-1
        color_mask = Colors >= color_bin_edges(c) & Colors < color_bin_edges(c+1);
        
        % Get indices of points that fall in both bins
        bin_indices = find(mag_mask' & color_mask);
        
        if ~isempty(bin_indices)
            % Compute median X (magnitude) and median Y (log scale)
            binned_X = [binned_X; median(a.XData(bin_indices))];
            binned_Y = [binned_Y; median(a.YData(bin_indices))];
            binned_C = [binned_C; mean(Colors(bin_indices))]; % Assign color based on bin
        end
    end
end
% Create Binned Scatter Plot
figure();
scatter(binned_X, binned_Y, 30, binned_C, 'filled','MarkerFaceAlpha',0.7); % Use same colors for binned data
set(gca, 'YScale', 'log');
colormap(jet);
colorbar;
grid on;
cb.Direction = 'reverse'; 
ylim([0.001 0.25])
xlim([11.0 19.2])


% Initialize array to store counts
color_bin_counts = zeros(length(color_bin_edges)-1, 1);

% Count number of points in each color bin
for c = 1:length(color_bin_edges)-1
    color_bin_counts(c) = sum(Colors >= color_bin_edges(c) & Colors < color_bin_edges(c+1));
end


% Label colorbar
cb = colorbar;
cb.Label.Interpreter = 'latex';
cb.Label.String = '$$B_p - R_p$$';

% Create legend handles based on binned_C colors
hold on;
legend_handles = gobjects(length(color_bin_edges)-1, 1); % Store handles for legend

for c = 1:length(color_bin_edges)-1
    % Find closest matching color from the colormap
    color_value = mean([color_bin_edges(c), color_bin_edges(c+1)]); % Midpoint of bin
    legend_handles(c) = scatter(NaN, NaN, 30, color_value, 'filled', ...
        'DisplayName', sprintf('%.2f - $$B_p-R_p$$ (%i)- %.2f', color_bin_edges(c),color_bin_counts(c), color_bin_edges(c+1)),'MarkerEdgeAlpha',0.7);
end

hold off;
legend(legend_handles, 'Location', 'westoutside');


% Label colorbar
cb = colorbar;
cb.Label.Interpreter = 'latex';
cb.Label.String = '$$B_p - R_p$$';
cb.Direction = 'reverse'; 
title(sprintf('%s CID %i BN %i ALL Night Binned Nsrc = %i',ObsID,I,g,mms.Nsrc))
% Save binned plot


[g_counts, g_edges] = histcounts(a.XData, mag_bin_edges);
% Add histogram of Gmag bins overlaid on the X-axis
hold on;
hist_y_pos = 0.001%min(a.YData) / 2; % Position the histogram just below the lowest Y value
for i = 1:length(g_counts)
    % Draw a rectangle or stair for each bin
    x_start = g_edges(i);
    x_end = g_edges(i+1);
    y_height = g_counts(i) / max(g_counts) * hist_y_pos; % Scale height for clarity
    patch([x_start x_end x_end x_start], [hist_y_pos hist_y_pos hist_y_pos+y_height hist_y_pos+y_height], ...
          'k', 'FaceAlpha', 0.001, 'EdgeColor', 'k','HandleVisibility', 'off'); % Use transparency
end
hold off;

% Initialize array to store counts for color bins
color_bin_counts = zeros(length(color_bin_edges)-1, 1);

% Count number of points in each color bin
for c = 1:length(color_bin_edges)-1
    color_bin_counts(c) = sum(Colors >= color_bin_edges(c) & Colors < color_bin_edges(c+1));
end

% Map the color_bin_edges to the X-axis limits
x_min = 11.0; % Minimum X-axis limit
x_max = 19.2; % Maximum X-axis limit
color_bin_edges_scaled = x_min + (x_max - x_min) * ((color_bin_edges - min(color_bin_edges)) / (max(color_bin_edges) - min(color_bin_edges)));

% Add the top histogram for color bins
hist_y_top =0.25; % Top of the Y-axis
max_height = 0.18; % Maximum height of the histogram (scaling factor)
% Get the colormap and map the bin values to colors
cmap = colormap(jet); % Get the colormap
cmap_range = linspace(min(color_bin_edges), max(color_bin_edges), size(cmap, 1)); % Range of the colormap

for c = 1:length(color_bin_counts)
    % Find the color corresponding to the current bin
    bin_color_value = mean([color_bin_edges(c), color_bin_edges(c+1)]); % Midpoint of bin
    [~, color_idx] = min(abs(cmap_range - bin_color_value)); % Find the closest color index
    patch_color = cmap(color_idx, :); % Get the corresponding color from the colormap

    % Draw a rectangle for each bin with the corresponding color
    x_start = color_bin_edges_scaled(c);
    x_end = color_bin_edges_scaled(c+1);
    y_bottom = hist_y_top; % Start from the top of the Y-axis
    y_top = hist_y_top - (color_bin_counts(c) / max(color_bin_counts)) * max_height; % Scale height downwards
    patch('XData', [x_start x_end x_end x_start], ...
          'YData', [y_bottom y_bottom y_top y_top], ...
          'FaceColor', patch_color, ...
          'FaceAlpha', 0.7, ...
          'EdgeColor', 'none', ...
          'HandleVisibility', 'off'); % Colored bars with transparency
end

hold off 
PN_binned = sprintf('%s_CID_%i_BN_%i_Binned_ALL.png', ObsID, I, g);
saveas(gcf, PN_binned);
end

    end
waitbar(I/24,h,sprintf('Now looking in CID %i\nFound %i WDs overall',I+1,height(WDtable)))
WDtable = table();
end


