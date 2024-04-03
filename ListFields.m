function [E] = ListFields(E,Args)

arguments
    E WDss
    Args.None = [];

end

DataPath = E.Path;

%DataPath2 = '/last06w/data1/archive/LAST.01.06.03/2023/09/16/proc';
cd(DataPath)

Visits = dir;

FieldNames = [] ;

for Ivis = 3 : numel(Visits)
    
    cd(Visits(Ivis).name)
    
    Cats = dir;
    
    VisitCenter = '010_001_015_sci_proc_Cat_1.fits';
    
    IDX = find(contains({Cats.name},VisitCenter));
    
    if isempty(IDX)
        
        IDX =  find(contains({Cats.name}, '001_001_015_sci_proc_Cat_1.fits'));
        
    end
    
    H   = AstroHeader(Cats(IDX).name,3);
    
    FieldNames = [FieldNames ; {H.Key.FIELDID}]
    
    
    cd ..
        
    
end
    
    
E.Data.DataStamp = [DataPath(24:36),'-',DataPath(38:41),'-',DataPath(43:44),'-',DataPath(46:47)]
E.Data.FieldNames = FieldNames;




end
