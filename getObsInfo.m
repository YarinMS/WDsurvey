function [WD] = getObsInfo(WD,Args)

arguments
    
    WD WDss 
    Args.FN = '';
    Args.save_to = WD.Data.save_to;
    
end


Subframe = '016';

FieldNames = WD.Data.FieldNames;
field_name = Args.FN;
FieldIdx   = find(contains(FieldNames,field_name));
WD.Data.FieldID = field_name;

Results  = ReadFromCat(WD.Path,'Field',FieldNames{FieldIdx(1)},'SubFrame',Subframe,'getAirmass',true,'WD',WD);


% Store Results for :

% Subframe Airmass Vs time


% Sub frame Lim Mag Vs time

WD.Data.date = datetime(Results.JD(1),'convertfrom','jd');

% save_to   = '/home/ocs/Documents/WD_survey/Thesis/'
file_name = ['Field_Results_',FieldNames{FieldIdx(1)},'_',char(WD.Data.DataStamp),'.mat'];

save([Args.save_to,file_name],'Results','-v7.3') ;


fprintf('\nField (rea,dec) from the first frame : %.10f,%.10f',Results.Coord(1,1),Results.Coord(1,2))

WD.Data.Results = Results;

end