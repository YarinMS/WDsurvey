function jd = dateToJD(year, month, day, hour, minute, second)
    % Converts date and time to Julian Date (JD) in UTC.
    % Inputs:
    %   year   - Year (e.g., 2024)
    %   month  - Month (1-12)
    %   day    - Day (1-31)
    %   hour   - Hour (0-23)
    %   minute - Minute (0-59)
    %   second - Second (0-59)
    %
    % Output:
    %   jd - Julian Date in UTC
    % Create a datetime object in UTC
    dt = datetime(year, month, day, hour, minute, second, 'TimeZone', 'UTC');

    % Convert to Julian Date
    jd = juliandate(dt);

    % Display the result
    disp(['Julian Date: ', num2str(jd)]);

end
