function [robustSD] = RobustSD(Vec)
% Calc robust Standard Deviation for a 1 dimensional vector
% TBD for a matrix
m = Vec(~isnan(Vec)) ;

Median = median(m);
MAD    = sort(abs(Median-m));
mid    = round(length(MAD)/2);
if mid > 0
           
    robustSD = 1.5*MAD(mid);
           
else
    
    robustSD = nan;
           
end

end

