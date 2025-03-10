% Split image set to training and validation based on distances in angle.

close all

% trSetFolder = '/home/koosk/data/data/DRP/newNaming/zeroPad/210424-HelaKyoto-TubGFP-H2BmCherry-live__2021-04-24T16_32_17-Measurement1_v2';
% trSetFolder = '/home/koosk/data/data/DRP/newNaming/zeroPad/ACC_210617-HelaKyoto-40x-live__2021-06-17T12_08_49-Measurement1';
% trSetFolder = '/home/koosk/data/data/DRP/newNaming/zeroPad/ACC_210617-HelaKyoto-40x-live-frame-2__2021-06-17T15_46_18-Measurement1';
% trSetFolder = '/home/koosk/data/data/DRP/newNaming/zeroPad/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4';
% trSetFolder = '/home/koosk/data/data/DRP/2022_v1_zeroPadded/ACC_210617-HelaKyoto-40x-live__2021-06-17T12_08_49-Measurement1';
% trSetFolder = '/home/koosk/data/data/DRP/2022_v1_zeroPadded/ACC_210617-HelaKyoto-40x-live-frame-2__2021-06-17T15_46_18-Measurement1';
% trSetFolder = '/home/koosk/data/data/DRP/2022_v1_zeroPadded/ACC_210819-HK-live-frame-60X__2021-08-19T16_53_11-Measurement1';
% trSetFolder = '/home/koosk/data/data/DRP/2022_v1_zeroPadded/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4';
% trSetFolder = '/home/koosk/data/data/DRP/2022_v1_zeroPadded/ACC_211008-HK-live-60X__2021-10-08T14_56_14-Measurement1';
% trSetFolder = '/home/koosk/data/data/DRP/210424-HelaKyoto-TubGFP-H2BmCherry-live__2021-04-24T16_32_17-Measurement1_v2/';
trSetFolder = '/home/koosk/data/images/DVP3/trainingSetExport_20220318/ACC_mitotic_150';

disp(['Processing folder: ', trSetFolder])
% outFolder = fullfile(trSetFolder, 'split_traj');
% outFolder = '/home/koosk/images-data/newNaming_split';
% outFolder = '/home/koosk/images-data/2022_v1_zeroPadded_split';
% outFolder = '/home/koosk/images-data/2022_v1_zeroPadded_split_w20X';
outFolder = '/home/koosk/images-data/dvp3_220318';
validationRatio = 0.1;
sectorResolution = 120; % 1 to 360 equal sectores
minSectorDistanceToSplit = 5; % distance in number of sectors to allow splitting
labelExt = '.tif';

% imFolder = fullfile(trSetFolder, 'ImagesNormalized');
imFolder = fullfile(trSetFolder, 'Images');
lbFolder = fullfile(trSetFolder, 'Labels');
trainFolder = fullfile(outFolder, 'train');
valFolder = fullfile(outFolder, 'val');

imList = dir(imFolder);

nIm = length(imList);
[~, ~, ext] = fileparts(imList(3).name);


imList = dir(fullfile(imFolder,['*',ext]));
lbList = dir(fullfile(lbFolder,['*',labelExt]));

imListCell = struct2cell(imList);
imNames = imListCell(1,:)';
splitImNames = cellfun(@(x) strsplit(x, {'_t', '_m', '_id','_objID',ext}), imNames, 'UniformOutput', false);
splitImNames = vertcat(splitImNames{:});

trajIDs = unique(str2double(splitImNames(:,4)));

nTraj = numel(trajIDs);
polarPositionContainer = zeros(nTraj,sectorResolution);
polarFrameContainer = cell(nTraj,sectorResolution);
rotZmaz = [0  1;...
          -1  0];

for i = 1:nTraj
    disp(['Processing trajectory ', num2str(i), '/', num2str(nTraj)]);
    frameIdx = find(str2double(splitImNames(:,4)) == trajIDs(i));
    nFrame = length(frameIdx);
    for j = 1:nFrame
        coor = double(imread(fullfile(lbFolder,lbList(frameIdx(j)).name))) - [5000 5000]; % shift to the origo
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
%         if arcIdx == 75
%             disp(fullfile(lbFolder,lbList(frameIdx(j)).name))
%         end
        polarPositionContainer(i,arcIdx) = polarPositionContainer(i,arcIdx) + 1;
        polarFrameContainer{i,arcIdx} = [polarFrameContainer{i,arcIdx}, str2double(splitImNames{frameIdx(j),2})];
    end
end
figure, imagesc(polarPositionContainer)
xlabel(['Section (~', num2str(round(360/sectorResolution)), ' degrees)'])
ylabel('Trajectory')



%% collect files
rng(810349);
trainSet = [];
valSet = [];

for i = 1:nTraj
    frameIdx = find(str2double(splitImNames(:,4)) == trajIDs(i));
    nFrame = length(frameIdx);

    selectedNames = imNames(frameIdx);
    selectedNames2 = splitImNames(frameIdx,:);
    fileList = [];
    emptyCtr = 0;
    
    allFileList = [];
    
    for j = 1:sectorResolution
        frameList = polarFrameContainer{i, j};
        
        if ~isempty(frameList)
            emptyCtr = 0;
            for k = frameList
                nameIdx = find(str2double(selectedNames2(:,2)) == k);
                allFileList = [allFileList; selectedNames(nameIdx)];
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
    
%     % collect images for visualization
%     images = cell(length(allFileList), 1);
%     for j = 1:length(allFileList)
%         images{j} = imread(fullfile(imFolder, allFileList{j}));
%     end
%     figure, montage(images)
%     %
%     
%     % check similarities
%     ssimList = zeros(length(images)-1,1);
%     corrList = zeros(length(images)-1,1);
%     cosSimList = zeros(length(images)-1,1);
%     for j = 1:length(images)-1
%         img1 = imresize(images{j}, [224, 224]);
%         img2 = imresize(images{j+1}, [224, 224]);
%         [ssimVal, ssimMap] = ssim(img2, img1, 'Radius', 0.2);
%         ssimList(j) = ssimVal;
%         corrList(j) = corr2(img1(:), img2(:));
%         cosSimList(j) = getCosineSimilarity(double(img1(:)), double(img2(:)));
%     end
%     figure, plot(ssimList), title('SSIM')
%     figure, plot(corrList), title('CORR2')
%     figure, plot(cosSimList), title('Cosine Similarity')
%     %
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
numTrain = numel(trainSet);
totalNumFiles = numel(trainSet) + numel(valSet);
wb = waitbar(0, ['Moving files: 0/', num2str(totalNumFiles)]);
for i = 1:numel(trainSet)
    wb = waitbar(i/totalNumFiles, wb, ['Moving files: ', num2str(i), '/', num2str(totalNumFiles)]);
    f = trainSet{i};
    [~, fname, ~] = fileparts(f);
    labelFile = [fname, labelExt];
    copyfile(fullfile(imFolder,f), trainImgFolder);
    copyfile(fullfile(lbFolder,labelFile), trainLabelFolder);
end
for i = 1:numel(valSet)
    wb = waitbar((numTrain+i)/totalNumFiles, wb, ['Moving files: ', num2str(numTrain+i), '/', num2str(totalNumFiles)]);
    f = valSet{i};
    [~, fname, ~] = fileparts(f);
    labelFile = [fname, labelExt];
    copyfile(fullfile(imFolder,f), valImgFolder);
    copyfile(fullfile(lbFolder,labelFile), valLabelFolder);
end
close(wb)

%%
function [trainSet, valSet, fileList] = addAndCopyToSet(trainSet, valSet, fileList, validationRatio)
    if rand < validationRatio
        valSet = [valSet; fileList];
    else
        trainSet = [trainSet; fileList];
    end
    fileList = [];
end

function Cs = getCosineSimilarity(x,y)
    if isvector(x)==0 || isvector(y)==0
        error('x and y have to be vectors!')
    end

    if length(x)~=length(y)
        error('x and y have to be same length!')
    end
    xy   = dot(x,y);
    nx   = norm(x);
    ny   = norm(y);
    nxny = nx*ny;
    Cs   = xy/nxny;
end