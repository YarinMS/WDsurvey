function [Detections, SNR, deviations] = detectEvents(lc, Median, SD, Args)
% Detect events in a light curve.
% The function identifies significant deviations from the median within a given window size.
%
% Input:
%       - lc : light curve with N points (time sorted) Npts x 1.
%       - Median : Sigma clipped median.
%       - SD : Standard deviation of the light curve or the control group.
% Additional arguments:
%       - Args.Window: Window size, default = 3.
%       - Args.Threshold: Threshold given in terms of SD, default = 2.5*SD.
%
% Output:
%       - detections: Array of the same length as lc with detected points marked.
%       - detected_points: Indices of detected points.

arguments

lc (:,1) double
Median (1,1) double
SD (1,1) double
Args.Window  (1,1) double  = 3;
Args.Threshold (1,1) double  = 2.5;
Args.GetDev = false;


end

% Initiate varaiables
Npts = length(lc);
Detections = zeros(Npts,1); % Array to store detection results.
SNR = zeros(Npts,1); % Array to store detection results.
NTsig = sqrt(Args.Window)*SD*Args.Threshold;

if Args.GetDev
   deviations = [];
   deviation = zeros(Npts,1);
end

% Detection process

for Ipt = 1 : Npts
    % Get points in window

    startIdx = max(1,Ipt - floor(Args.Window/2));
    endIdx   = min(Npts, Ipt + floor(Args.Window/2));

    % Handle Edge cases by padding

    % if startIdx == 1 
        
        % windowPts = [repmat(median(lc(startIdx:endIdx),'omitnan'),floor(Args.Window/2)-(Ipt-1),1);lc(startIdx:endIdx)];
    %    windowPts = lc(1:ceil(Args.Window/2));
    %    windowSum = sum(windowPts,'omitnan');
     %   Deviation = abs(windowSum - Median * length(windowPts));

    %elseif endIdx == Npts
     
    
    %windowPts = [lc(startIdx:endIdx);repmat(median(lc(startIdx:endIdx),'omitnan'),floor(Args.Window/2)-(Npts-Ipt),1)];
      %  windowPts = lc(end - ceil(Args.Window/2):end);
      %  windowSum = sum(windowPts,'omitnan');
       % Deviation = abs(windowSum - Median * length(windowPts));
    if (Ipt < floor(Args.Window/2)+1) || (Ipt > Npts-floor(Args.Window/2))    
        Deviation = 0;

    else
        windowPts = lc(startIdx:endIdx);
        windowSum = sum(windowPts,'omitnan');
        Deviation = abs(windowSum - Median * Args.Window);
        
    end

    

    if Deviation > NTsig
        % Mark middle point as detected
        Detections(Ipt)  = 1;
        SNR(Ipt) = Deviation / NTsig;
        if Args.GetDev  
            deviation(Ipt,1) = Deviation;
        end
    end



end

    if Args.GetDev 

        deviations = [deviations; deviation'];

    end


end