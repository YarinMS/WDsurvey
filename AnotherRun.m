%%
cd('/Users/yarinms/Documents/Master/WhiteDwarfs/Codes/LASTmounts')
%%
Dir = dir;
Dir.name
%%
Ifield = [3:1:70];
for i = 2:numel(Ifield)

    cd('/Users/yarinms/Documents/Master/WhiteDwarfs/Codes/LASTmounts')
    Dir = dir;
    Ifield = [3:1:70];
    run(Dir(Ifield(i)).name)
close all;


end
 %%