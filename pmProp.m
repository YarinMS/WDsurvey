function WDsources = pmProp(wdSources,Args)

    arguments
    wdSources
    Args.Date = {}; % JD only, otherwise will take todays JD.

    end

    % Define the epoch year (e.g., from wdSources.Epoch)
    epoch_year = wdSources.Epoch;

    % Create a datetime object for January 1 of the specified epoch year
    epoch_date = datetime(epoch_year, 1, 1, 12, 0, 0);

    % Convert this date to Julian Date
    jd_epoch = juliandate(epoch_date);

    % Set initial J2000.0 epoch (in Julian days)
    EpochInRA = jd_epoch ; 
    EpochInDec =jd_epoch;
    
    if isempty(Args.Date)
        % Calculate today's Julian day
        date_today = datetime('today');
        EpochOut = juliandate(date_today);

    else
        EpochOut = Args.Date;
    end

    RA = deg2rad(wdSources.RA) ;          % Example RA in degrees at J2000.0
    Dec = deg2rad(wdSources.Dec) ; % Example Dec in degrees at J2000.0
    Plx = wdSources.Plx;
    PM_RA = wdSources.pmRA   ;            % Proper motion in RA (mas/yr)
    PM_Dec =  wdSources.pmDE;                % Proper motion in Dec (mas/yr)
    
    % Propagate the position to today's date
    [RA_final, Dec_final] = celestial.coo.proper_motion(EpochOut, EpochInRA, EpochInDec, RA, Dec, PM_RA, PM_Dec,Plx);




    
    RA1 = rad2deg(RA_final);
    Dec1 = rad2deg(Dec_final);
    wdSources.RA = RA1;
    wdSources.Dec = Dec1;
    WDsources = wdSources;



end