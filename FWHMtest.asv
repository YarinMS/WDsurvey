%% Path to data
cd('/last06e/data1/archive/LAST.01.06.01/2023/10/25/proc')


% Get all hdf5 files of a sub frame in path 
SubFrame = 15;

L = MatchedSources.rdirMatchedSourcesSearch('CropID',15);   


% Sometimes you need to choose a field % TBD 

%% Upload all files to a MatchedSources object
                          
ms = MatchedSources.readList(L);    
% Merge all MatchedSources elkement into a single element object
MSU = mergeByCoo(ms,ms(1));
%   % Add GAIA mag and colors
% MSU.addExtMagColor;
                           