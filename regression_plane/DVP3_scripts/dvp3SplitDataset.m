trSetFolder = '/home/koosk/data/images/DVP3/trainingSetExport_20220318/ACC_mitotic_150';
outFolder = '/home/koosk/images-data/dvp3_220318';
valRatio = 0.1;
testRatio = 0.05;


labelExt = '.tif';
imFolder = fullfile(trSetFolder, 'ImagesFiltered');
lbFolder = fullfile(trSetFolder, 'LabelsFiltered');
trainFolder = fullfile(outFolder, 'train');
valFolder = fullfile(outFolder, 'val');
testFolder = fullfile(outFolder, 'test');

imList = dir(imFolder);
[~, ~, ext] = fileparts(imList(3).name);
imList = dir(fullfile(imFolder,['*',ext]));
lbList = dir(fullfile(lbFolder,['*',labelExt]));
numImg = numel(imList);

labels = zeros(numImg, 2);
for i = 1:numel(lbList)
    coord = imread(fullfile(lbList(i).folder, lbList(i).name));
    labels(i,:) = coord;
end
figure, plot(labels(:,1), labels(:,2), '.')

idx = randperm(numImg)';
probs = rand(numImg, 1);
testIdx = idx(probs<testRatio);
valIdx = idx(probs>=testRatio & probs<(testRatio+valRatio));
trainIdx = idx(probs >= (testRatio+valRatio));

mkdir(fullfile(trainFolder, 'images'));
mkdir(fullfile(trainFolder, 'labels'));
mkdir(fullfile(valFolder, 'images'));
mkdir(fullfile(valFolder, 'labels'));
mkdir(fullfile(testFolder, 'images'));
mkdir(fullfile(testFolder, 'labels'));

copyFilesToSet(imList(testIdx), lbList(testIdx), fullfile(testFolder, 'images'), fullfile(testFolder, 'labels'));
copyFilesToSet(imList(valIdx), lbList(valIdx), fullfile(valFolder, 'images'), fullfile(valFolder, 'labels'));
copyFilesToSet(imList(trainIdx), lbList(trainIdx), fullfile(trainFolder, 'images'), fullfile(trainFolder, 'labels'));

function copyFilesToSet(imList, lbList, targetImDir, targetLbDir)
for i = 1:numel(imList)
    copyfile(fullfile(imList(i).folder, imList(i).name), targetImDir)
    copyfile(fullfile(lbList(i).folder, lbList(i).name), targetLbDir)
end
end







