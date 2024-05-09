% Split image set to training and validation based on distances in angle.

close all

% trSetFolder = '/home/koosk/data/data/DRP/DVP2_trSet_Flora1603_210704/';
% trSetFolder = '/home/koosk/data/data/DRP/Flora_20x_n2009/';
trSetFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/';
outFolder = fullfile(trSetFolder, 'split_traj_d5');
validationRatio = 0.1;
sectorResolution = 120; % 1 to 360 equal sectores
minSectorDistanceToSplit = 4; % distance in number of sectors to allow splitting

imFolder = fullfile(trSetFolder, 'Images');
lbFolder = fullfile(trSetFolder, 'Labels');
trainFolder = fullfile(outFolder, 'train');
valFolder = fullfile(outFolder, 'val');

imList = dir(imFolder);

nIm = length(imList);
[~, ~, ext] = fileparts(imList(3).name);

imList = dir(fullfile(imFolder,['*',ext]));
lbList = dir(fullfile(lbFolder,['*',ext]));

imListCell = struct2cell(imList);
imNames = imListCell(1,:)';
splitImNames = cellfun(@(x) strsplit(x, {'_id','_f',ext}), imNames, 'UniformOutput', false);
splitImNames = vertcat(splitImNames{:});

trajIDs = unique(str2double(splitImNames(:,2)));

nTraj = numel(trajIDs);
polarPositionContainer = zeros(nTraj,sectorResolution);
polarFrameContainer = cell(nTraj,sectorResolution);
rotZmaz = [0  1;...
          -1  0];
phaseBorders = ceil([90,180,225,270,360]/ (360 / sectorResolution)); % in sectors

for i = 1:nTraj
    frameIdx = find(str2double(splitImNames(:,2)) == trajIDs(i));
    nFrame = length(frameIdx);
    for j = 1:nFrame
        coor = double(imread(fullfile(lbFolder,lbList(frameIdx(j)).name)));
        [theta2, rad2] = regplaneToPolar(coor(:,1), coor(:,2), 10000, true);
        coor = coor - [5000 5000]; % shift to the origo
        rotCoor = (coor .* [-1 1]) * rotZmaz; % flip by x then rot 90 around z;
        thetaRad = atan2(rotCoor(2),rotCoor(1));
        if thetaRad < 0
            thetaRad = 2*pi + thetaRad;
        end
        theta = round(rad2deg(thetaRad));
        if theta == 0
            arcIdx = 1;
        else
            arcIdx = ceil(theta / (360 / sectorResolution));
        end
        disp([num2str(i), ', ', num2str(j), '; ', num2str(theta), ', ', num2str(theta2), ', ', num2str(coor), '; ', lbList(frameIdx(j)).name])
        polarPositionContainer(i,arcIdx) = polarPositionContainer(i,arcIdx) + 1;
        polarFrameContainer{i,arcIdx} = [polarFrameContainer{i,arcIdx}, str2double(splitImNames{frameIdx(j),3})];
    end
end
figure, imagesc(polarPositionContainer)


%% collect files
trainSet = [];
valSet = [];

for i = 1:nTraj
    frameIdx = find(str2double(splitImNames(:,2)) == trajIDs(i));
    nFrame = length(frameIdx);

    selectedNames = imNames(frameIdx);
    selectedNames2 = splitImNames(frameIdx,:);
    fileList = [];
    emptyCtr = 0;
    lastPhase = 1;
    
    for j = 1:sectorResolution
        frameList = polarFrameContainer{i, j};
        
        phaseIdx = find(j >= [0, phaseBorders]);
        
        if ~isempty(frameList)
            emptyCtr = 0;
            for k = frameList
                nameIdx = find(str2double(selectedNames2(:,3)) == k);
                fileList = [fileList; selectedNames(nameIdx)];
            end
        else
            emptyCtr = emptyCtr + 1;
            if emptyCtr == minSectorDistanceToSplit
                [trainSet, valSet, fileList] = addAndCopyToSet(trainSet, valSet, fileList, validationRatio);
            end
        end
    end
    [trainSet, valSet, fileList] = addAndCopyToSet(trainSet, valSet, fileList, validationRatio);
end

%% move to folders
trainImgFolder = fullfile(trainFolder, 'images');
trainLabelFolder = fullfile(trainFolder, 'labels');
valImgFolder = fullfile(valFolder, 'images');
valLabelFolder = fullfile(valFolder, 'labels');
mkdir(trainImgFolder);
mkdir(trainLabelFolder);
mkdir(valImgFolder);
mkdir(valLabelFolder);
for i = 1:numel(trainSet)
    f = trainSet{i};
    copyfile(fullfile(imFolder,f), trainImgFolder);
    copyfile(fullfile(lbFolder,f), trainLabelFolder);
end
for i = 1:numel(valSet)
    f = valSet{i};
    copyfile(fullfile(imFolder,f), valImgFolder);
    copyfile(fullfile(lbFolder,f), valLabelFolder);
end
disp(['Num train images: ', num2str(numel(trainSet))])
disp(['Num val images: ', num2str(numel(valSet))])

%%
function [trainSet, valSet, fileList] = addAndCopyToSet(trainSet, valSet, fileList, validationRatio)
    if rand < validationRatio
        valSet = [valSet; fileList];
    else
        trainSet = [trainSet; fileList];
    end
    fileList = [];
end

