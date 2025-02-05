%% GitHub Issue

% find which dates are relavents

% Create smaller MSs
Names = [];
Mjd = [];
for Ivis = 1 : length(MS)
    Names = [Names; MS(Ivis).FileName];
    Mjd   = [Mjd; mean(MS(Ivis).JD)];
end

[~,s] = sort(Mjd);
Names = Names(s,:);
MS = MS(s);

%%
% Define the pattern you want to match (example: all files from 20240729)
pattern = 'LAST\.01\.05\.02\/2024\/11\/05';

% Get the number of files
nFiles = size(Names, 1);

% Initialize index array
Indexes = [];

% Loop through each filename and check for a match
for i = 1:nFiles
    filename = strtrim(Names(i, :));  % Remove trailing spaces
    if ~isempty(regexp(filename, pattern, 'once'))
        Indexes = [Indexes; i];  % Store index if the pattern matches
    end
end

% Display matching indexes
disp('Indexes of matching files:');
disp(Indexes);



%%
% with smaller MSs:

ms1 = mergeByCoo(MS(Indexes),MS(Indexes(2)));

ms1.bestMag;

 % Consider all sources with NdetPts > args.Ndet measurements then NaNs. 
 NdetGood = sum(~isnan(ms1.Data.MAG_BEST), 1);
 Fndet = NdetGood >= (0.10*ms1.Nepoch);

 ms1 = ms1.selectBySrcIndex(Fndet, 'CreateNewObj', false);
 ms1.sortData;
 


% Now set bad flag points to NaN in all apertures
ms1 = ms1.setBadPhotToNan('BadFlags', {'Saturated','Negative'}, 'MagField', 'MAG_PSF', 'CreateNewObj', true);

 nans = isnan(ms1.Data.MAG_PSF);
    ms1.Data.MAG_APER_3(nans) = nan;
    ms1.Data.MAG_APER_2(nans) = nan;
    ms1.Data.MAG_BEST(nans) = nan;
 
    NdetGood = sum(~isnan(ms1.Data.MAG_PSF), 1);
    Fndet = NdetGood >= (ms1.Nepoch-0.95*ms1.Nepoch);
  
    ms1 = ms1.selectBySrcIndex(Fndet, 'CreateNewObj', false);
    % Apply zero point correction

    r = lcUtil.zp_meddiff(ms1, 'MagField', {'MAG_PSF'}, 'MagErrField', {'MAGERR_PSF'});
    [ms1, ~] = applyZP(ms1, r.FitZP, 'ApplyToMagField', 'MAG_PSF');
% now that you have matched sources combined for every subframe. look for
% WDs in the subframe of sources 

% new sources??
    ms1.bestMag;
    Coords = [mean(ms1.Data.RA,'omitnan')', mean(ms1.Data.Dec,'omitnan')']


    for Is = 1 : height(Coords)

        WD = isWD(MS,Coords(Is,1),Coords(Is,2));
        if ~isempty(WD.Table)
            WDID = sprintf('WD_%i_%s_%i',Is,pattern,S)
            WData.(WDID) = {};
            WData.(WDID).Gaia = WD.Table;
            Idx = ms1.coneSearch(Coords(Is,1),Coords(Is,2))
            WData.(WDID).LC = ms1.Data.MAG_BEST(:,Idx.Ind);
  
            figure();
            plot(ms1.JD,ms1.Data.MAG_BEST(:,Idx.Ind),'k.')
            title([WDID,' ', sprintf('G = %.3f B_p-R_p = %.3f',WD.Table.Gmag,WD.Table.BPmag - WD.Table.RPmag)])
        end
    end

%% Good plot 
figure; plot(tt,ms1.Data.MAG_PSF(:,932),'k.'); hold on; plot(tt,ms1.Data.MAG_PSF(:,932-50),'.')
set(gca,'YDir','reverse')
xlabel('Time')
ylabel('MAG PSF')
xlim([min(tt) max(tt)])
hold on
plot(tt,ms1.Data.MAG_PSF(:,931),'.')



%% fIND ALL PROBLEMATIC LIGHT CURVES
meanMag = mean(ms1.Data.MAG_PSF,'omitnan')
BadInd = [];
for I = 1 : length(meanMag)

    diff = abs(ms1.Data.MAG_PSF(:,I)-meanMag(I));

    if any(diff > 0.75)
        BadInd = [BadInd ; I];
        plot(tt,ms1.Data.MAG_PSF(:,I),'.')
        set(gca,'YDir','reverse')
        xlabel('Time')
        ylabel('MAG PSF')
        xlim([min(tt) max(tt)])
        hold on
    end
end


%%
AllBadGood = [20,41,53,56,57,58,59,60,61,63]
Centroid = [mean(mean(ms1.Data.RA,'omitnan')),mean(mean(ms1.Data.Dec,'omitnan'))]
Coords = [mean(ms1.Data.RA(:,AllBadGood),'omitnan')' mean(ms1.Data.Dec(:,AllBadGood),'omitnan')']

figure()
scatter(Coords(:,1),Coords(:,2))
legend(??)
hold on 
scatter(scatter(Centroid(:,1),Centroid(:,2)))
legend(% CropID centroid)
hold on 
scatter(alpha,delta)
legend(%CropID borders (4))

%%
%% Define Variables
AllBadGood = [20,41,53,56,57,58,59,60,61,63]; % Indices of sources
Centroid = [mean(mean(ms1.Data.RA,'omitnan')), mean(mean(ms1.Data.Dec,'omitnan'))]; % Compute centroid
Coords = [mean(ms1.Data.RA(:,BadInd(AllBadGood)),'omitnan')', mean(ms1.Data.Dec(:,BadInd(AllBadGood)),'omitnan')']; % Compute source coordinates

%% Plot the Data

alpha = [351.110478273201           351.79239622827          351.797094404579           351.11111691105]

figure(); 
hold on; grid on;

% Plot sources
scatter(Coords(:,1), Coords(:,2), 50, 'b', 'filled', 'DisplayName', 'Sources');

% Plot centroid
scatter(Centroid(1), Centroid(2), 80, 'r', 'filled', 'DisplayName', 'Centroid');

% Plot CropID borders
scatter(alpha, delta, 60, 'g', 'DisplayName', 'CropID borders (4)');

% Configure legend and axes
legend();
xlabel('RA'); ylabel('Dec');
title('Source Positions, Centroid, and CropID Borders');

hold off;


%%

for I = 1 : length(AllBadGood)

    getFlags1(ms1,'SrcIdx',BadInd(AllBadGood(I)))

end