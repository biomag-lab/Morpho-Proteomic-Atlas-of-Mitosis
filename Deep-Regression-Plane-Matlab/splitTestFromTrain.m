% Split test set from train set using regression format
% inFolder = '/home/koosk/images-data/2022_v1_zeroPadded_split/train/images/';
% inCoordFolder = '/home/koosk/images-data/2022_v1_zeroPadded_split/train/labels/';
% outFolder = '/home/koosk/images-data/2022_v1_zeroPadded_split/test/';
%
inFolder = '/home/koosk/images-data/2022_v1_zeroPadded_split_w20X/train/images/';
inCoordFolder = '/home/koosk/images-data/2022_v1_zeroPadded_split_w20X/train/labels/';
outFolder = '/home/koosk/images-data/2022_v1_zeroPadded_split_w20X/test/';


numOutClasses = 40;

interphaseClassname = 'interphase';
rng(810349);
% create folders
mkdir(outFolder);
testImgFolder = fullfile(outFolder, 'images');
testLabelFolder = fullfile(outFolder, 'labels');
mkdir(testImgFolder)
mkdir(testLabelFolder)


% setup
fileList = dir([inFolder '*.jpg']);
splitDeg = (360 - 30) / numOutClasses; % bottom 15-15 degrees are interphase cells

% count elements in each class
coordList = zeros(numel(fileList), 2);
classList = zeros(numel(fileList),1);
for i = 1:numel(fileList)
    file = fileList(i);
    [~, basename, ~] = fileparts(file.name);
    regplaneCoord = double(imread(fullfile(inCoordFolder, [basename, '.tif'])));
    coordList(i,:) = regplaneCoord;
    cls = regressionToClass(regplaneCoord);
    clsIdx = 0;
    if cls ~= categorical({'interphase'}) % interphase will be 0
        clsIdx = str2double(char(cls));
    end
    classList(i) = clsIdx;
end

% move files to test from each class
for i = 0:numOutClasses
    fileIdxOfClass = find(classList==i);
    idxOrder = randperm(numel(fileIdxOfClass));
    fileIdxOrder = fileIdxOfClass(idxOrder);
    numOfClass = nnz(classList==i);
    numToCopy = 30;
    if numOfClass < 50
        numToCopy = 3;
    elseif numOfClass < 300
        numToCopy = 15;
    end
    for j = 1:numToCopy
        idxToCopy = fileIdxOrder(j);
        file = fileList(idxToCopy);
        [~, basename, ~] = fileparts(file.name);
        imgPath = fullfile(inFolder, file.name);
        coordPath = fullfile(inCoordFolder, [basename, '.tif']);
        
        movefile(imgPath, testImgFolder)
        movefile(coordPath, testLabelFolder)
    end
end
