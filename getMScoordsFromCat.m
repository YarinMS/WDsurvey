function [RA,Dec,fieldCoords,AI] = getMScoordsFromCat(subframeCatFile)

    AI = AstroHeader(subframeCatFile,3);
    raMin  = min([ AI.Key.RA1;AI.Key.RA2;AI.Key.RA3;AI.Key.RA4]);
    raMax  = max([ AI.Key.RA1;AI.Key.RA2;AI.Key.RA3;AI.Key.RA4]);
    decMin = min([ AI.Key.DEC1;AI.Key.DEC2;AI.Key.DEC3;AI.Key.DEC4]);
    decMax = max([ AI.Key.DEC1;AI.Key.DEC2;AI.Key.DEC3;AI.Key.DEC4]);
    RA     = raMin + abs(raMin-raMax)/2;    
    Dec    = decMin + abs(decMax - decMin)/2;

    fieldCoords.raMin = raMin;
    fieldCoords.raMax =  raMax;
    fieldCoords.decMin = decMin;
    fieldCoords.decMax = decMax;

end