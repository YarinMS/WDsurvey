%% get Visit Directories.

% Load DAT
% Prepare the headers
headers = {'List Ind', 'Ivisit', 'N detctions', 'Contaminated', 'RA [deg]', 'Dec [deg]', 'Pwd', 'Gmag', 'BPmag', ' ', '  ', '   ', 'Nvisits', ...
           'Year', 'Month', 'Day', 'Mount', 'Camera', 'CropID', 'FieldID', '     ', '.', '... ', 'CatIdx', 'Analyzed', 'Path'};
filename = '~/Documents/WDdetailedlistLAST040824b.xlsx';
data_table1 = table();
% Create a table with headers
headers_table = cell2table(cell(0, numel(headers)), 'VariableNames', headers);
writetable(headers_table, filename, 'Sheet', 1, 'WriteVariableNames', true);

% N detection per DAT row;
Ndetections = [];
Contaminted = zeros(height(DAT),1);
PH = {};
MMS = {}
%%
  
   % Con = {};
   % Nodet = {};
   % RES = {};
%T = [];
h = waitbar(0, 'Starting Iterations on all LAST data')
    tic; 
for Ivis = 79 : 1500 %00%height(DAT)
tic;
    %% got to proc dir
    wdRA = DAT{Ivis,2};
    wdDec = DAT{Ivis,3};
    Path = DAT{Ivis,26};
    FieldID = DAT{Ivis,20};
    CropID  = DAT{Ivis,19};
    Pwd     = DAT{Ivis,4};
    Gmag = DAT{Ivis,5};
    BPmag = DAT{Ivis,6};
    NumberVisit = DAT{Ivis,13};
    CatIdx      =DAT{Ivis,24};
    Year  = DAT{Ivis,14};
    Day  = DAT{Ivis,16};
    Month  = DAT{Ivis,15};
    Mount  = DAT{Ivis,17};
    Camera  = DAT{Ivis,18};

    % cd path

    %  Choose Merged Catlog by file name.
     Temp = compose("*%s_000_001_%03i_sci_merged_MergedMat_1.hdf5", FieldID,CropID);

     cd(Path{:})


    %% Create an MS object;

     List = MatchedSources.rdirMatchedSourcesSearch('FileTemplate', Temp);
     
     Nvis = height(List.FileName);


    %% Nvis MatchedSources to scan & store
    Args.MagField = 'MAG_PSF';
    Args.MagErrField = 'MAGERR_PSF';
    save_to = '~/Documents/Work/2024/August/Plots/'
    [Result] = ReadFromCat(Path{:},'Field',FieldID,'FileNames',List,'CropID',CropID,'save_to',save_to);

    MS =  MatchedSources.readList(List);
    
    mms = {};
    
%f = waitbar(1, sprintf('Visit # %i ',Ivis))
    for Ivisit = 1 : Nvis
 
   

       
       % R = lcUtil.zp_meddiff(MatchedSource,'MagField',Args.MagField,'MagErrField',Args.MagErrField);
       % [MS_ZP,ApplyToMagFieldr] = applyZP(MatchedSource, R.FitZP,'ApplyToMagField',Args.MagField);


        % Target 
        search = MS(Ivisit).coneSearch(wdRA,wdDec,6);

        if search.Nsrc == 1
            % Detected in visit I

            lc = MS(Ivisit).Data.MAG_PSF(:,search.Ind);
            NaNs = sum(isnan(lc));
            Ndetections = 20 - NaNs;

           % mms = {mms ,  {MS(Ivis)}};



            if Ivisit == 1 

                       data_row = {Ivis,Ivisit, Ndetections,0, wdRA, wdDec, Pwd, Gmag, BPmag, '', '', '', NumberVisit, ...
                            Year, Month, Day, Mount, Camera, CropID, FieldID,...
                            '', '', {Result}, CatIdx, {MS(Ivisit)}, List.Folder(Ivisit)};

                % Append data_row to the data table
                data_table1 = [data_table1; cell2table(data_row, 'VariableNames', headers)];

            else
                       data_row = {Ivis,Ivisit, Ndetections,0, wdRA, wdDec, Pwd, Gmag, BPmag, '', '', '', NumberVisit, ...
                            Year, Month, Day, Mount, Camera, CropID, FieldID,...
                            '', '', {Result}, CatIdx, {MS(Ivisit)}, List.Folder(Ivisit)};

                % Append data_row to the data table
                data_table1 = [data_table1; cell2table(data_row, 'VariableNames', headers)];

            end
                

        elseif search.Nsrc > 1

                              data_row = {Ivis,Ivisit, 0,1, wdRA, wdDec, Pwd, Gmag, BPmag, '', '', '', NumberVisit, ...
                            Year, Month, Day, Mount, Camera, CropID, FieldID,...
                            '', '', '', CatIdx, '',  List.Folder(Ivisit)};

                % Append data_row to the data table
                data_table1 = [data_table1; cell2table(data_row, 'VariableNames', headers)];



        else
            % No detections mark
                                 data_row = {Ivis,Ivisit, 1,0, wdRA, wdDec, Pwd, Gmag, BPmag, '', '', '', NumberVisit, ...
                            Year, Month, Day, Mount, Camera, CropID, FieldID,...
                            '', '', '', CatIdx, '',  List.Folder(Ivisit)};

                % Append data_row to the data table
                data_table1 = [data_table1; cell2table(data_row, 'VariableNames', headers)];



        end


        % Control group



 % waitbar(Ivisit /Nvis, f,sprintf("Looking For WDs .... %d%%",floor(100* Ivisit /Nvis)));
    end
%close(f)
    %MMS = {MMS ; mms};

t = toc;
T = [T;t];
    waitbar(Ivis / height(DAT), h,sprintf("Looking For WDs .... %i / %i (%.2f %%)\nLast Iter: %.1f s \n AVG : %.1f s ",Ivis,height(DAT),(100*Ivis/height(DAT)),t,mean(T)));

    % look for the target

    % Contaminated in 6 arcsec radius. 4 pixels



    % clean

    % shift flags to lim mag








sprintf('\n %.3f Seconds for the last visit',t)
end
toc;

tic

writetable(data_table1, filename, 'Sheet', 1, 'Range', ['A' num2str(2)], 'WriteVariableNames', false);
save('/Users/yarinms/Catalogs/BigDataTable1.mat','data_table1','-v7.3')
toc











