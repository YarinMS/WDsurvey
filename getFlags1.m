function [Res, EdgeVec ] = getFlags1(MS,Args)

    arguments

        MS MatchedSources
        Args.BadFlags = {'Saturated','Negative','NaN' ,'Spike','Hole','CR_DeltaHT','NearEdge'};
        Args.EdgeFlags = {'Overlap'};
        Args.SrcIdx    


    end

    BitMask =  BitDictionary ; 
% Index of important bits
% 1 - Saturated; 7 - NaN
% 11 - Negative; 12 - Interpolated
% 13 - hole;     14 - diffraction spike
% 15 - CR_HT;    18 Ghost
% 20 - Presistent charge
% 24 - near image edge
% 27 - In overlap
% 28 - SN is source dominated
% 31- source detected




    Bits    =  BitMask.Class(MS.Data.FLAGS(:,Args.SrcIdx));
    bitCount = zeros(1,length(Args.BadFlags));


    BadBits =  Args.BadFlags;


for Ibit = 1 : length(BadBits)
    
    BitIdx = find(contains(BitMask.Dic.BitName,BadBits{Ibit}));
    
    bitCount(Ibit) = sum(bitget(Bits,BitIdx));

end

    EdgeCount = zeros(1,length(Args.EdgeFlags));


    EdgeBits =  Args.EdgeFlags;


for Ibit = 1 : length(EdgeBits)
    
    BitIdx = find(contains(BitMask.Dic.BitName,EdgeBits{Ibit}));
    
    EdgeCount(Ibit) = sum(bitget(Bits,BitIdx));
    EdgeVec = bitget(Bits,BitIdx);

end

Res.BadFlags = Args.BadFlags;
Res.BFcounts = bitCount;
Res.EdgeFlags = Args.EdgeFlags;
Res.EFcounts  = EdgeCount;

end