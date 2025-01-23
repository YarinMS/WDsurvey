function response = gaiaConeSearch(RA,DEC)

baseUrl = 'http://gea.esac.esa.int/tap-server/tap/sync?REQUEST=doQuery&LANG=ADQL&FORMAT=csv&';



query = [sprintf('QUERY=SELECT+*,+DISTANCE(%.10f,%.10f, ra, dec)+AS+ang_sep+FROM+gaiaedr3.gaia_source+',RA,DEC) ...
    sprintf('WHERE+DISTANCE(%.10f,%.10f, ra, dec)+<+1./720+',RA,DEC)...
    'ORDER+BY+ang_sep+ASC']

url = [baseUrl query];

options = weboptions('Timeout', 120);
response = webread(url,options);


end