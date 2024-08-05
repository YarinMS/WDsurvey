function [TypicalSD] = clusteredSD1(MS,Args)

arguments
    MS MatchedSources
    Args.None= {};
    Args.ExtData = false;
    Args.ZP      = true;
    Args.MedInt  = 0;
    Args.Sys     = false;
    Args.Isrc = 0;

    
    
end

    % set Bin interval
    Args.MedInt = median(MS.Data.MAG_PSF(:,Args.Isrc),'omitnan')
    MinMag = Args.MedInt - 0.125;
    MaxMag = Args.MedInt + 0.125;
    
    
    % Find all sources within this Interval
    PSFmat = MS.Data.MAG_PSF;
    PSFmag = median(PSFmat,'omitnan');
    
    MagFlag = (MinMag <= PSFmag ) & (PSFmag <= MaxMag);

    if sum(MagFlag) > 0

        % calc the median sd of all sources    
        PSFmat = PSFmat(:,MagFlag);
        % Sigma clip all sources signals And get SD:
        PSFsd  = NaN(size(PSFmat(1,:)));

        for Isource = 1 : length(PSFmat(1,:))

            [newM,newS]    = SigmaClips(PSFmat(:,Isource),'SigmaThreshold',3,...
            'MeanClip',false);
            PSFsd(Isource) = newS ;

         end


    TypicalSD = median(PSFsd,'omitnan');

    else
           TypicalSD = median(PSFsd,'omitnan')
    end
end