function timeWindow = calculateTimeWindow(dateStr)
    eventTime = datetime(dateStr, 'InputFormat', 'yyyyMMdd.HHmmss.SSS');
    timeWindow.startTime = datestr(eventTime - minutes(10), 'yyyymmdd.HHMMSS.FFF');
    timeWindow.endTime = datestr(eventTime + minutes(10), 'yyyymmdd.HHMMSS.FFF');
end
