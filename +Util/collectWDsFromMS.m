function WDtable = collectWDsFromMS(RES,ObsID)

WDtable = table();
h = waitbar(0)
for I = 1:24
    currentCrop  = find(cell2mat(RES.IDs) == I);
    mms          = RES.MSall(currentCrop);
    cropIDcoords = (RES.MScoords(currentCrop));

    ms = [];
    for c = 1: length(mms)
        ms = [ms mms{c}{1}];
    end
     


    MSU = mergeByCoo(ms,ms(1));
    MSU.bestMag;

% Calibrate mms
% Setting bad Photometry to NaN.
args.BadFlags = {'Saturated', 'Negative', 'NaN', 'Spike', 'Hole', 'NearEdge','Overlap'}; % Change to NaN all data points associated with these flags.
mms = MSU.setBadPhotToNan('BadFlags', args.BadFlags, 'MagField', 'MAG_PSF', 'CreateNewObj', true);

% Consider all sources with all nans sources with NdetPts > args.Ndet. 
NdetGood = sum(~isnan(mms.Data.MAG_PSF), 1);
Fndet = NdetGood > (0.85*mms.Nepoch); % Allow for 15% no detections per source.
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
        Row.Idx = Is;
        Row.CropID = I;
        Row.LRA    = ra;
        Row.LDec   = dec;
        Row.Nvis   = mms.Nepoch/20;
        
       
        Flags = getFlags1(mms,'SrcIdx',Is);


        % plot LC
        t = datetime(mms.JD,'convertfrom','jd');
        sd = std(mms.Data.MAG_PSF(:,Is),'omitnan');
        Row.sd = sd;
        figure()
        plot(t,mms.Data.MAG_PSF(:,Is),'.k')
        ylabel('MAG PSF')
        set(gca,'YDir','reverse')
        
        xlim([min(t) max(t)])
        legend(sprintf('$P_{wd}$ = %.3f; $Gmag$ = %.2f; $Bp-R_p$ = %.3f $\\sigma$ = %.4f',Row.Pwd,Row.Gmag,Row.BpRp,sd))

        if sum(Flags.BFcounts) > 0 || sum(Flags.EFcounts)> 0
            title(sprintf('%s $\\#$ %i',ObsID,I))
            xlabel(sprintf('%.3f %.3f Flags %iS %iNeg %iNan %iSp %iH %iCR %iNE %iOL',ra,dec,Flags.BFcounts,Flags.EFcounts))
   
        else
            title(sprintf('%s $\\#$ %i',ObsID,I))
        end
        PN = sprintf('%s_%.3f_%.3f_LC.png',ObsID,ra,dec);
        saveas(gcf, PN)

        figure()
        res = mms.plotRMS('FieldY','MAG_PSF','PlotSymbol','.')
        hold on
        Sx = res.XData(Is);
        Sy = res.YData(Is);
        Row.RMS = Sy
        plot(Sx,Sy,'p','MarkerSize',12,'MarkerFaceColor',[204/256 85/256 0])
        legend(sprintf('RMS = %.3f; $Bp-R_p$ = %.3f',Sy,Row.BpRp))
        xlim([10 20])

        ylim([0.005 0.4])
        PN = sprintf('%s_%.3f_%.3f_RMS.png',ObsID,ra,dec);
        saveas(gcf, PN)


        SlgLbl = sprintf('$P_{wd}$ = %.3f; $Gmag$ = %.2f; $Bp-R_p$ = %.3f $\\sigma$ = %.4f',Row.Pwd,Row.Gmag,Row.BpRp,sd);
        Util.plotWithControl(mms,Is,SlgLbl)
        PN = sprintf('%s_%.3f_%.3f_LC2.png',ObsID,ra,dec);
        saveas(gcf, PN)
    
    
    
        WDtable = vertcat(WDtable,Row);
    
    
    end

    if ~isempty(WDInds)
    
    end


end


waitbar(I/24,h,sprintf('Now looking in CID %i\nFound %i WDs overall',I+1,height(WDtable)))
end







end