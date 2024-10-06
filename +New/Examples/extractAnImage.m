% Run over S tiers








cd('~/Projects/Variables/S tier/')
Dir = dir ;

%%

[ra, dec, cropID, fullPath,Tel, FieldID] = extractInfoFromFileName(Dir(3).name)


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
Table.Nvisits = 3;
Table.Name = 'SDSS14+37'

        
        % Optionally: Print or save results
        
%%
MS = a(Table.CropID,:)
MSgroups = groupMS(MS,Table.Nvisits)
Res = getLCfromMS(MSgroups, Table, ...
            sprintf('~/Projects/WD_survey/LCs/%s/', Table.Name));
fprintf('Processed Source %s: RA=%.6f, Dec=%.6f, CropID=%d\n', ...
            Table.Name, ra, dec, cropID);
    
   




%%
processPlots('~/Projects/Variables/S tier/')

%%
processPlots('~/Projects/Variables/M10T2/S/')