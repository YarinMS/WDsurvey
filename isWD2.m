function WD =isWD2(Obj, RA, Dec)
    % Calculate color
    PWD = pwd;
    cd('/home/ocs/Downloads/WD/WDEDR3');
    WD = catsHTM.cone_search('WDEDR3', RA*pi/180, Dec*pi/180, 6, 'OutType', 'AstroCatalog');
    cd(PWD);
end