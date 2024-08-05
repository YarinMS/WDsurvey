function analyazeVisits(Path,Args)
%
%
%
% Input
%       - Path : An str path to a certain visit.
% Arguments 
%       - Nvisit : Choose how many visit to consider. Default is 1.

arguments
Path str 
Args.Nvisit         = 1;
Args.detectionMethod
Args.logPath str    = {};
Args.tablePath  str = {};
Args.Plot           = false;
Args.Coord  (1,2)double = [0 0];
Args.CropID


end

%% Create the requested MS Object
% Nvisits

% CropID

% MergeVisits

% Cleaning

% ZP

% Detrending


%% Apply detection methods


%% Log results
end

function MS = loadMatchedSources(Path, Args)

arguments
    Path str 
    Args.ApplyZP = true;
    Args.Detrend = false;
    Args.Nvisit  = 1;
    Args.CropID  = {};
    Args.FieldID = {};
end

% If CropID is known
if ~isempty(Args.CropID)





    % Create a matched sources object for N Visits
    if Args.Nvisit > 1

        cd(Path)
        cd('..')
        List = MatchedSources.rdirMatchedSourcesSearch('CropID',Args.CropID);
        % How to check for adjacent visits. ?
        % This is a work to be done
        % If you have a field ID it could help but not for adjecnt ones.

    else

        cd(Path)
        List = MatchedSources.rdirMatchedSourcesSearch('CropID',Args.CropID);
        MS   = MatchedSources.readList(List);
    end


else
    %% Look for the target in the Data
    % This is a longer process since it might migrate between subframes

    % Find Target in Data function


end

%% Clean the MS object. Which Flags to remove


if Args.ApplyZP

end


if Args.Detrend

end



end




%% Find in Last DATA

function [ot] = findInLAST(RA,Dec,OT)

Flag = celestial.coo.findInBox(RA, Dec, [OT.RAU1, OT.RAU2, OT.RAU3, OT.RAU4], [OT.DECU1, OT.DECU2, OT.DECU3, OT.DECU4]);

ot = OT(Flag,:);


end

%% get WD from catalog
load('/Users/yarinms/Catalogs/LAST_Visits.mat')
RA = 290;
Dec = 30;
[WD] = getWDlist(RA,Dec,500);


wd.RA  =[ WD.Table.RA.*RAD];
wd.Dec =[ WD.Table.RA.*RAD];


%%
Flag = {};


%%
f = waitbar(0,'Looking For WDs in LAST data....');
for Iwd = 25433:numel(SmallSrc.RA(:,1))
    Flag{Iwd} = celestial.coo.findInBox(SmallSrc.RA(Iwd)*RAD, SmallSrc.Dec(Iwd)*RAD, [OT.RAU1, OT.RAU2, OT.RAU3, OT.RAU4], [OT.DECU1, OT.DECU2, OT.DECU3, OT.DECU4]);
    waitbar(Iwd/numel(SmallSrc.RA(:,1)), f, sprintf("%i/%i",Iwd,numel(SmallSrc.RA(:,1))))

end
close(f)
%%
tic
Total = 0;
SmallSrc.ObsList = cell(numel(SmallSrc.RA(:,1)), 1);
f = waitbar(0);
for Iwd = 1:numel(SmallSrc.RA(:,1))
    [U,xxx,iu] = unique(OT(Flag{Iwd},{'Year','Month','Day','Mount','Camera','CropID','FieldID'}));
    uc = accumarray(iu,1); cond = (uc>8);     %  *15*20 > 4*VSX.Period(i)*24*60*60);
    U = U(cond,:); uc = uc(cond);
    ObsList = {};

    if  ~isempty(U)
        Path = compose("~/marvin/LAST.01.%02i.%02i/%i/%02i/%02i/proc/", U.Mount,U.Camera,U.Year,U.Month,U.Day);
        %Path = compose("~/Data/LAST.01.%02i.%02i/%i/%02i/%02i/proc/%s/", U.Mount,U.Camera,U.Year,U.Month,U.Day,U.Visit);
    
    
        template = compose("*%s_000_001_%03i_sci_merged_MergedMat_1.hdf5", U.FieldID,U.CropID);
for j = 1:length(uc)
cd(Path(j));
files = MatchedSources.rdirMatchedSourcesSearch('FileTemplate', template(j));
dtmax = max(diff(FileNames.generateFromFileName(files.FileName).julday))*24*60;
if dtmax<(2+6.67) % max time gap set at visit dur + 2 min
obslist{end+1} = files;
end
end

SmallSrc.ObsList{i} = obslist;
if ~isempty(obslist);
Total = Total + 1;
disp([Iwd, uc(j), SmallSrc.Gmag(i)])
end
waitbar(Iwd/numel(SmallSrc.RA(:,1)), f, sprintf("%i/%i",Iwd,numel(SmallSrc.RA(:,1))))
end
end
toc
%cd /marvin
disp(ctr)


%% Look for WDs from catlog

function [WD] = getWDlist(RA,Dec,coneRad)
 RAD = 180/pi;
 coneRad = 4*pi*(RAD)^2 *3600;
 PWD = pwd;
 cd('~/Catalogs/WD/WDEDR3')
 WD  = catsHTM.cone_search('WDEDR3',RA./RAD, Dec./RAD, coneRad, 'OutType','AstroCatalog');
 cd(PWD)             

end



%%
% WD  = catsHTM.cone_search('WDEDR3',RA./RAD, Dec./RAD, coneRad*RAD*3600, 'OutType','AstroCatalog')
RAD = 180*pi;
AvbWD = WD.Table.Dec.*RAD > -12.5;
VisWD = WD.Table.Gmag < 19.2;

flagWD = AvbWD & VisWD;

SRCs =  WD.Table(flagWD,:);
SmallSrc = SRCs;
WD_indices = find(flagWD);

%% After you have Flag
load('/Users/yarinms/Catalogs/LAST_Visits.mat')
load('/Users/yarinms/Catalogs/WDflgs2.mat')
load('/Users/yarinms/Catalogs/WDcatalog.mat')

%%
tic
Total = 0;
SmallSrc.ObsList = cell(numel(SmallSrc.RA(:,1)), 1);
f = waitbar(0,'Looking for WD in LAST data...');
% Prepare Excel headers
headers = {'Name', 'RA [deg]', 'Dec [deg]', 'Pwd', 'Gmag', 'BPmag', 'RPmag', 'TeffH', 'MassH', '', '', '', 'Nvisits', ...
           'Year', 'Month', 'Day', 'Mount', 'Camera', 'CropID', 'FieldID', '', '', '','CatIdx', 'Analyzed', 'Path'};
filename = '~/Documents/WDlistLAST01.xlsx';
writecell(headers, filename, 'Sheet', 1, 'Range', 'A1');


 row = 2;
for Iwd = 1:numel(SmallSrc.RA(:,1))
    [U,xxx,iu] = unique(OT(Flag{Iwd},{'Year','Month','Day','Mount','Camera','CropID','FieldID'}));
    uc = accumarray(iu,1); cond = (uc>8);     %  *15*20 > 4*VSX.Period(i)*24*60*60);
    U = U(cond,:); uc = uc(cond);
    obslist = {};

    if  ~isempty(U)
 
        Path = compose("~/marvin/LAST.01.%02i.%02i/%i/%02i/%02i/proc/", U.Mount,U.Camera,U.Year,U.Month,U.Day);
        Path = char(Path);       
        SmallSrc.ObsList{Iwd} = Path;

        RA = SmallSrc.RA(Iwd) * (180/pi);
        Dec = SmallSrc.Dec(Iwd) * (180/pi);
        Pwd = sprintf('%.3f', SmallSrc.Pwd(Iwd));
        Gmag = sprintf('%.2f', SmallSrc.Gmag(Iwd));
        BPmag = sprintf('%.2f', SmallSrc.BPmag(Iwd));
        RPmag = sprintf('%.2f', SmallSrc.RPmag(Iwd));
        TeffH = sprintf('%.2f', SmallSrc.TeffH(Iwd));
        MassH = sprintf('%.3f', SmallSrc.MassH(Iwd));
        Nvisits = sprintf('%i', uc);

     % Apply light grey shading if there are multiple rows
        if height(U) > 1


            for Iline = 1 : height(U)
                    
                    data_row = {[], RA, Dec, Pwd, Gmag, BPmag, RPmag, TeffH, MassH, '', '', '', uc(Iline), ...
                    U.Year(Iline), U.Month(Iline), U.Day,(Iline) U.Mount(Iline), U.Camera(Iline), U.CropID(Iline), U.FieldID(Iline),...
                     '', '', '',WD_indices(Iwd), '', Path(Iline,:)};

                    writecell(data_row, filename, 'Sheet', 1, 'Range', ['A' num2str(row)]);
                    

                % Read the current row to get the range
                %current_row = ['A' num2str(row) ':Z' num2str(row)];
                % Apply shading using Excel COM server
                %e = actxserver('Excel.Application');
                %ewb = e.Workbooks.Open(filename);
                %esheet = ewb.Sheets.Item(1);
                %erange = esheet.Range(current_row);
                %erange.Interior.Color = 0.9 * 2^24 + 0.9 * 2^16 + 0.9 * 2^8; % Light grey color
                %ewb.Save();
                %ewb.Close();
                %e.Quit();

                 row = row + 1;
                 if Iline == 1
                     Total = Total +1
                 end
            end
        else
        % Prepare the row data
        data_row = {[], RA, Dec, Pwd, Gmag, BPmag, RPmag, TeffH, MassH, '', '', '', Nvisits, ...
                    U.Year, U.Month, U.Day, U.Mount, U.Camera, U.CropID, U.FieldID, '', '', '',WD_indices(Iwd), '', Path};

        % Write to Excel
       
        writecell(data_row, filename, 'Sheet', 1, 'Range', ['A' num2str(row)]);
        row = row + 1;
        Total = Total +1
        end
    end

    waitbar(Iwd / numel(SmallSrc.RA(:,1)), f);
end

%% Better code:
tic
Total = 0;
SmallSrc.ObsList = cell(numel(SmallSrc.RA(:,1)), 1);
f = waitbar(0,'Looking for WD in LAST data...');

% Prepare the headers
headers = {'Name', 'RA [deg]', 'Dec [deg]', 'Pwd', 'Gmag', 'BPmag', 'RPmag', 'TeffH', 'MassH', ' ', '  ', '   ', 'Nvisits', ...
           'Year', 'Month', 'Day', 'Mount', 'Camera', 'CropID', 'FieldID', '     ', '.', '... ', 'CatIdx', 'Analyzed', 'Path'};
filename = '~/Documents/WDlistLAST030824.xlsx';

% Create a table with headers
headers_table = cell2table(cell(0, numel(headers)), 'VariableNames', headers);
writetable(headers_table, filename, 'Sheet', 1, 'WriteVariableNames', true);

% Initialize a table for collecting rows
data_table = table();
DAT = table();
row = 2;
for Iwd = 1:numel(SmallSrc.RA(:,1))
    [U, xxx, iu] = unique(OT(Flag{Iwd}, {'Year','Month','Day','Mount','Camera','CropID','FieldID'}));
    uc = accumarray(iu, 1);
    cond = (uc > 17); %  18+ visits -> 2+ hrs. ;
    U = U(cond, :);
    uc = uc(cond);
    obslist = {};

    if ~isempty(U)
        Path = compose("~/marvin/LAST.01.%02i.%02i/%i/%02i/%02i/proc/", U.Mount, U.Camera, U.Year, U.Month, U.Day);
        Path = char(Path);       
        SmallSrc.ObsList{Iwd} = Path;

        RA = SmallSrc.RA(Iwd) * (180/pi);
        Dec = SmallSrc.Dec(Iwd) * (180/pi);
        Pwd = SmallSrc.Pwd(Iwd);
        Gmag = SmallSrc.Gmag(Iwd);
        BPmag = SmallSrc.BPmag(Iwd);
        RPmag = SmallSrc.RPmag(Iwd);
        TeffH = SmallSrc.TeffH(Iwd);
        MassH = SmallSrc.MassH(Iwd);
        Nvisits = uc;

        if height(U) > 1
            for Iline = 1:height(U)
                data_row = {[], RA, Dec, Pwd, Gmag, BPmag, RPmag, TeffH, MassH, '', '', '', uc(Iline), ...
                            U.Year(Iline), U.Month(Iline), U.Day(Iline), U.Mount(Iline), U.Camera(Iline), U.CropID(Iline), U.FieldID(Iline),...
                            '', '', '', WD_indices(Iwd), '', Path(Iline,:)};

                % Append data_row to the data table
                data_table = [data_table; cell2table(data_row, 'VariableNames', headers)];
                DAT = [DAT; cell2table(data_row, 'VariableNames', headers)];

                if Iline == 1
                    Total = Total + 1
                end
            end
        else
            data_row = {[], RA, Dec, Pwd, Gmag, BPmag, RPmag, TeffH, MassH, '', '', '', Nvisits, ...
                        U.Year, U.Month, U.Day, U.Mount, U.Camera, U.CropID, U.FieldID, '', '', '', WD_indices(Iwd), '', Path};

            % Append data_row to the data table
            data_table = [data_table; cell2table(data_row, 'VariableNames', headers)];
            DAT = [DAT; cell2table(data_row, 'VariableNames', headers)];

            Total = Total + 1
        end
  

    % Write accumulated data to Excel
    writetable(data_table, filename, 'Sheet', 1, 'Range', ['A' num2str(row)], 'WriteVariableNames', false);

    % Update row index
    row = row + height(data_table);
    data_table = table(); % Clear data_table for next iteration

 
    end
       waitbar(Iwd / numel(SmallSrc.RA(:,1)), f,sprintf("Looking For WDs .... %d%%",floor(100*Iwd/numel(SmallSrc.RA(:,1)))));
end

close(f);
