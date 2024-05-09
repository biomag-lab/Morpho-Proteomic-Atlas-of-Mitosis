baseFolder = '/home/koosk/images-data/dvp3_220318';
requiredNumFiles = 30000;

inFolder = fullfile(baseFolder,'train/images/');
regFolder = fullfile(baseFolder,'train/labels/');

outFolder = fullfile(baseFolder,'trainAug_v2/images/');
outRegFolder = fullfile(baseFolder,'trainAug_v2/labels/');





%% aug params
numAugment = 1;
histEqPorob = 0.05; %0.05;
histStretchProb = 0.1; %0.2;
histStretchLevel = 0.03; %0.04;
invert = 0.0;
blurProb = 0.2;
blurLevel = 2;
noiseProb = 0.1;   
colorFlip = 0;%0.1;
maskFormat = '.tiff';
stepSize = 1;  

mkdir(outFolder);
mkdir(outRegFolder);
imList = dir(inFolder);
[~, ~, ext] = fileparts(imList(3).name);
imList = dir(fullfile(inFolder,['*',ext]));
% lbList = dir(fullfile(lbFolder, '*.tif'));

numAugment = round(requiredNumFiles / numel(imList));

for i = 1:numel(imList)
    inImg = imread(fullfile(imList(i).folder, imList(i).name));
    fname = imList(i).name;
    [~, basename, ext] = fileparts(fname);
    regFname = [basename '.tif'];
    fileRegName = [regFolder regFname];
    regImg = imread(fileRegName);
    
    resImage = imresize(inImg, [299 299], 'bicubic');
    
    imwrite(resImage, fullfile(outFolder, fname));
    imwrite(regImg, fullfile(outRegFolder, regFname));
    
    %% TODO write for loop here for augmentation
    for j = 1:numAugment
        outMask =  resImage;
        [outImg, ~] = augment_image(resImage, outMask, rand(1) < histStretchProb, rand(1) * histStretchLevel, rand(1) < histEqPorob, rand(1) < invert, rand(1) < colorFlip, rand(1) < noiseProb, randi(3), rand(1) < blurProb, rand(1) * blurLevel);
        
        outFileName = [basename '_' randHexString(10)];
        imwrite(outImg, fullfile(outFolder, [outFileName '.jpg']));
        imwrite(regImg, fullfile(outRegFolder, [outFileName '.tif']));
    end
    
% outMask =  inImg;
% [outImg, ~] = augment_image(inImg, outMask, rand(1) < histStretchProb, rand(1) * histStretchLevel, rand(1) < histEqPorob, rand(1) < invert, rand(1) < colorFlip, rand(1) < noiseProb, randi(3), rand(1) < blurProb, rand(1) * blurLevel);

end