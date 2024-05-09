projectName = 'ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4';
regResultFileName = 'DRP_train_result_ws-10-Nov-2021_07_54_39_train_40x_2000_v17.csv';
trackingFile = fullfile('Trackings','ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4','20211113_0613_simpleTrack.csv');
baseDir = '/mnt/HDD2_10TB/Attila/DVP';

addpath(genpath('/home/HDD2_10TB/Attila/ACC_trajAnnotation_0616_v7_RPgridBG'))
cropSize = 299;

%Create a data structure easier to mine
plateArray = cell(1,1);
predData = readtable(fullfile(baseDir,projectName,regResultFileName));
toCheckFields = {'ObjectNumber','regPosX','regPosY','ImageName','PlateName','xPixelPos','yPixelPos'};
checkTable(toCheckFields,predData);
for i=1:size(predData,1)
    plateIdx = 1;
    plateArray = addCellToPlateArray(...
        plateArray,...
        plateIdx,...
        predData.ImageName{i},...
        predData.ObjectNumber(i),...
        predData.xPixelPos(i),...
        predData.yPixelPos(i),...
        predData.regPosX(i),...
        predData.regPosY(i));
end


trackTable = readtable(fullfile(baseDir,trackingFile));
toCheckFields = {'ImageName','Plate','TrackID','tracking__center_x','tracking__center_y','Frame'};
checkTable(toCheckFields,trackTable)

trackIDs = unique(trackTable.TrackID);

nofTrajs = length(trackIDs);
trajGUIInfoArray = cell(nofTrajs,15);
k = 1;
h2 = waitbar(0,sprintf('Matching trajectories with regression output (%d/%d)',0,nofTrajs));
for i=1:nofTrajs
    currentIndices = find(trackTable.TrackID == trackIDs(i));
    relevantTable = trackTable(currentIndices,:);
    trajLength = length(currentIndices);
    regPos = zeros(trajLength,2);
    for j = 1:trajLength
        idx = (strcmp(predData.ImageName,relevantTable.ImageName(j))) & (predData.ObjectNumber == relevantTable.ObjectID(j));
        if sum(idx) == 1
            regPos(j,:) = [predData.regPosX(idx), predData.regPosY(idx)];
        else
            disp('error')
            disp(j)
        end
    end
    
    currentTrajInfo = convertPositionsToTrajGUI(regPos, relevantTable);
    if ~isempty(currentTrajInfo)
        trajGUIInfoArray(k,:) = currentTrajInfo;
        k = k+1;
    end
    
    if ishandle(h2), waitbar(i/nofTrajs,h2,sprintf('Matching trajectories with regression output (%d/%d)',i,nofTrajs)); end
end
% trajGUIInfoArray(k:end,:) = [];
plotTrajGUIhandle = plotTrajGui(trajGUIInfoArray,fullfile(baseDir,projectName),cropSize);
% trajTable = trajQuality(trajGUIInfoArray(:,1));
% filteredTrajTable = trajTable(trajTable.LengthOfTraj > 1.2,:);
save(fullfile(baseDir,projectName,['trajGUIInfoArray_',regResultFileName(1:end-4),'.mat']),'trajGUIInfoArray')
% save(fullfile(baseDir,projectName,['filteredTrajTable_',regResultFileName(1:end-4),'.mat']),'filteredTrajTable')
% score = summary(filteredTrajTable);
% writestruct(score,fullfile(baseDir,projectName,['score',regResultFileName(1:end-4),'.xml']))
disp('Ready for gui');