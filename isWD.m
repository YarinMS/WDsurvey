function WD =isWD(Obj, RA, Dec)
    % Calculate color
    PWD = pwd;
    cd('~/marvin/catsHTM/WD/WDEDR3');
    WD = catsHTM.cone_search('WDEDR3', RA*pi/180, Dec*pi/180, 3, 'OutType', 'AstroCatalog');
    cd(PWD);
end