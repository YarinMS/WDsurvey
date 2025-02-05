function WDtable = collectWDsFromMS2Vis(RES,ObsID,Mount,Tel,Year,Month,Day,FieldID)

WDtable = table();
h = waitbar(0)
for I = 7:24
    currentCrop  = find(cell2mat(RES.IDs) == I);
    mms          = RES.MSall(currentCrop);
    cropIDcoords = (RES.MScoords(currentCrop));


    groups = {};  % initialize an empty cell array to store the groups
    N = height(mms);
    if mod(N,2) == 0
        % If N is even, just group them into pairs.
        nGroups = N/2;
        groups = cell(nGroups,1);
        for i = 1:nGroups
            idxStart = (i-1)*2 + 1;
            groups{i} = mms(idxStart:idxStart+1);
        end
    else
        % If N is odd, we want all groups of 2 except the last group,
        % which will have 3 elements.
        % (This code assumes N is at least 3.)
        nGroups = (N - 3) / 2;  % number of full groups of 2
        groups = cell(nGroups+1,1);
        for i = 1:nGroups
            idxStart = (i-1)*2 + 1;
            groups{i} = mms(idxStart:idxStart+1);
        end
        % The last group gets the final 3 elements.
        groups{end} = mms(end-2:end);
    end
    
    % Display the grouping result.
    for g = 1:length(groups)
        fprintf('Group %d has %d elements\n', g, numel(groups{g}));
    end

    for g = 1:length(groups)
    currentBatch = groups{g};  % This is a cell array containing 2 (or 3) elements.
    
    % For example, if you want to "unwrap" each element (if each is a {1x1 cell})
    ms = [];  % clear out ms for this batch
    for j = 1:length(currentBatch)
        % currentBatch{j} is a 1x1 cell, so we unwrap it using {1}
        ms = [ms, currentBatch{j}{1}];
    end
    
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

% Find WDs in fields.
Scoords = [mean(mms.Data.RA,'omitnan')' mean(mms.Data.Dec,'omitnan')'];
WDInds = [];
for Is = 1 : height(Scoords)
    ra = Scoords(Is,1);
    dec = Scoords(Is,2);
    WD = isWD(mms,ra,dec);

    if ~isempty(WD.Table)
     if WD.Table.Gmag > 20  
         continue;
     end
        WDInds = [WDInds; Is]
        Row = WD.Table;
        Row.BpRp   = Row.BPmag -Row.RPmag;
        Row.Year =Year;
        Row.Month = Month;
        Row.Day = Day;
        Row.Mount = Mount;
        Row.Tel = Tel;
        Row.Idx = Is;
        Row.CropID = I;
        Row.LRA    = ra;
        Row.LDec   = dec;
        Row.Nvis   = mms.Nepoch/20;
        Row.FieldID = FieldID;
        
       
        Flags = getFlags1(mms,'SrcIdx',Is);


        % plot LC
        t = datetime(mms.JD,'convertfrom','jd');
        sd = std(mms.Data.MAG_PSF(:,Is),'omitnan');
        Row.X1 = mean(mms.Data.X1(:,Is),'omitnan');
        Row.Y1 = mean(mms.Data.Y1(:,Is),'omitnan');
        Row.X2 = mean(mms.Data.X2(:,Is),'omitnan');
        Row.Y2 = mean(mms.Data.Y2(:,Is),'omitnan');
        Row.psdChi2 = mean(mms.Data.PSF_CHI2DOF(:,Is),'omitnan');
        Row.BGANN = mean(mms.Data.BACK_ANNULUS(:,Is),'omitnan');
        Row.sd = sd;
        
        figure()
        plot(t,mms.Data.MAG_PSF(:,Is),'.k','MarkerSize',12)
        ylabel('MAG PSF')
        set(gca,'YDir','reverse')
        
        xlim([min(t) max(t)])
        legend(sprintf('$P_{wd}$ = %.3f; $Gmag$ = %.2f; $Bp-R_p$ = %.3f $\\sigma$ = %.4f',Row.Pwd,Row.Gmag,Row.BpRp,sd))


         title(sprintf('%s $\\#$ %i',ObsID,I))
         try

         xlabel(sprintf('[X1 Y1 X2 Y2] [%.2f %.2f %.2f %.2f] bg ann %.2f \nFlags %i %i %i %i %i %i %i %i',Row.X1,Row.Y1,Row.X2,Row.Y2,Row.BGANN,Flags.BFcounts,Flags.EFcounts))
         catch
             xlabel(sprintf('Flags %i %i %i %i %i %i %i %i',Flags.BFcounts,Flags.EFcounts))
         end
        PN = sprintf('%s_%.3f_%.3f_LC_2vis_CID_%i_%i.png',ObsID,ra,dec,I,g);
        saveas(gcf, PN)

        figure()
        res = mms.plotRMS('FieldY','MAG_PSF','PlotSymbol','.')
        hold on
        Sx = res.XData(Is);
        Sy = res.YData(Is);
        Row.RMS = Sy;
        Row.LMAG = Sx;
        plot(Sx,Sy,'p','MarkerSize',12,'MarkerFaceColor',[204/256 85/256 0])
        legend(sprintf('RMS = %.3f; $Bp-R_p$ = %.3f',Sy,Row.BpRp))
        xlim([10 20])

        ylim([0.005 0.4])
        PN = sprintf('%s_%.3f_%.3f_RMS_2vis_CID_%i_%i.png',ObsID,ra,dec,I,g);
        saveas(gcf, PN)


        SlgLbl = sprintf('$P_{wd}$ = %.3f; $Gmag$ = %.2f; $Bp-R_p$ = %.3f $\\sigma$ = %.4f',Row.Pwd,Row.Gmag,Row.BpRp,sd);
        Util.plotWithControl(mms,Is,SlgLbl)
        PN = sprintf('%s_%.3f_%.3f_LC2_2vis_CID_%i_%i.png',ObsID,ra,dec,I,g);
        saveas(gcf, PN)
    
    
    
        WDtable = vertcat(WDtable,Row);
    
    
    end



end

    end
waitbar(I/24,h,sprintf('Now looking in CID %i\nFound %i WDs overall',I+1,height(WDtable)))
end







end