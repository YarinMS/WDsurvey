function Res = getXYpix(Path,RA,Dec,Args)


arguments
Path char
RA
Dec
Args.CropID = []


end

PWD = pwd;

cd(Path)

List = MatchedSources.rdirMatchedSourcesSearch('CROPID',Args.CropID);%sprintf('%02d',x));
matchedSources = MatchedSources.readList(List);

for Ivis = 1 : length(matchedSources)

Ind = matchedSources(Ivis).coneSearch(RA,Dec).Ind;
if isempty(Ind)
    fprintf('\nCould not find source in vis % #s',pwd)
    MS= [];
else
    MS = matchedSources.mergeByCoo(matchedsources(Ivis));
    break
end

end
% Build
if ~isempty(MS)
    Ind = MS.coneSearch(RA,Dec).Ind;
    Res = MS.Data

else
    Res = []



end