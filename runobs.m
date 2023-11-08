% obs 22/8/23
Unit = obs.unitCS('10')

Unit.connect
Unit.Camera{1}.classCommand('SaveOnDisk=1') % save images on all cameras
Unit.Camera{2}.classCommand('SaveOnDisk=1')
Unit.Camera{3}.classCommand('SaveOnDisk=1')
Unit.Camera{4}.classCommand('SaveOnDisk=1')


for i=1:4; Unit.Camera{i}.classCommand('Temperature = 0'), end



pause(5)
fprintf('Starting with Flats')

Unit.operateUnit

pause(5)

Unit.Mount.home

Unit.Mount.track

pause(5)

Unit.focusTel

fprintf('Ready for Observation')
obs.util.observation.obsByPriority(Unit,'Simulate',false,'CoordFileName','/home/ocs/targetlists/04092023obs.txt', 'CadenceMethod', 'cycle')
