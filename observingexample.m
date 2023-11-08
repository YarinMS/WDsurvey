%% Observing example
addpath('/home/ocs/Documents/WD survey') % add functions path

% step 1 : define the Unit
Unit = obs.unitCS('10')  

% step 2 : connect,take flats,take focus and start observing 
%operateUnit2(Unit,'Temp',0,'TargetList','/home/ocs/targetlists/target_coordinates150923.txt','Itel',[1,2,3,4])

% To stop the script and shutdown at the end of the observation :
%
% 1st option:

% In the terminal type
% 
% touch ~/abort_and_shutdown  - The mount will shutdown (see notes)
%
% 2nd option:
% 
% In the end of the night use crtl+c to stop the script and use
% Unit.shutdown


%% Notes:
% To change the number of working telescopes :
%
% Change the 'Itel' argument in OperateUnit2
% - i.e. [1,4] to choose to take images only with telescope 1 and 4
%
% To stop the observing Script :
%
% In the terminal - 
%
% touch ~/abort_obs
%
% Will stop the observing script ONLY after finishing the visit (after
% completing 20 frames)
%
% Or you can use , In the terminal :
% 
% touch ~/abort_and_shutdown 
%
% Will stop the observation like ~/abort_obs and shutdown the mount right after.
