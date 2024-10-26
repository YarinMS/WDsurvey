% Run over S tiers








cd('~/Projects/Variables/M6T2/')
Dir = dir ;

%%

[ra, dec, cropID, fullPath,Tel, FieldID] = extractInfoFromFileName(Dir(5).name);


PWD = pwd;
cd(fullPath)
Template = sprintf('*_%s_*%03d_sci_*.hdf5',FieldID,cropID);

list = MatchedSources.rdirMatchedSourcesSearch('FileTemplate',Template);
matchedSources = MatchedSources.readList(list);
cd(PWD)
%%
Table.CropID = cropID;
Table.RA = ra;
Table.Dec = dec;
Table.Nvisits = 4;
Table.Name = 'PresentA';
Table.FieldID = FieldID;

        
        % Optionally: Print or save results
        
%%
MS = matchedSources
MSgroups = groupMS(MS,Table.Nvisits)
Res = getLCfromMS(MSgroups, Table, ...
            sprintf('~/Projects/WD_survey/Wide/%s/', Table.Name));
fprintf('Processed Source %s: RA=%.6f, Dec=%.6f, CropID=%d\n', ...
            Table.Name, ra, dec, cropID);
    
   




%%
processPlots('~/Projects/Variables/S tier/')

%%
processPlots('~/Projects/Variables/M10T2/S/')