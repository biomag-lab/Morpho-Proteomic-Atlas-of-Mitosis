trSetFolder = '/home/koosk/data/images/DVP3/trainingSetExport_20220318/ACC_mitotic_150';
filterRadiusLessThan = 3000;

labelExt = '.tif';
imFolder = fullfile(trSetFolder, 'ImagesJpg');
lbFolder = fullfile(trSetFolder, 'Labels');
outImfolder = fullfile(trSetFolder, 'ImagesFiltered');
outLbFolder = fullfile(trSetFolder, 'LabelsFiltered');

mkdir(outImfolder);
mkdir(outLbFolder);
imList = dir(imFolder);
[~, ~, ext] = fileparts(imList(3).name);
imList = dir(fullfile(imFolder,['*',ext]));
lbList = dir(fullfile(lbFolder,['*',labelExt]));
numImg = numel(imList);

labels = zeros(numImg, 2);
for i = 1:numImg
    coord = imread(fullfile(lbList(i).folder, lbList(i).name));
    r = double(coord) - [5000,5000];
    r = sqrt(sum(r.^2));
    if r >= filterRadiusLessThan
        copyfile(fullfile(lbList(i).folder, lbList(i).name), outLbFolder)
        copyfile(fullfile(imList(i).folder, imList(i).name), outImfolder)
    end
end