%% DB work 9.2.25

% connect to DB
D = db.Db;
D.User = 'last_user';
D.Password = 'physics';
D.connect
D.useDB('last')
%%
D.showTables
%%
T=D.query('SELECT * FROM visit_images WHERE ra < 277.3 AND ra > 277.1 AND dec<23.2 AND dec >23.0')
%D.showTables
%%
T1 = D.query('SELECT * FROM proc_src WHERE ra < 277.3 AND ra > 277.1 AND dec<23.2 AND dec >23.0')

%% MUST disconnect when done. 
D.disconnect