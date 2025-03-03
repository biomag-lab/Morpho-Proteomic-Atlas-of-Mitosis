
% baseFolder = '/home/koosk/images-data/newNaming_split'; 
% density = load('./data/zero_padded_new_naming_section_density.mat');
baseFolder = '/home/koosk/images-data/2022_v1_zeroPadded_split_w20X';
density = load('./data/density_2022_v1_zeroPadded_w20X.mat');

inFolder = fullfile(baseFolder,'train/images/');
regFolder = fullfile(baseFolder,'train/labels/');

outFolder = fullfile(baseFolder,'trainBalAug_v2_2/images/');
outRegFolder = fullfile(baseFolder,'trainBalAug_v2_2/labels/');

sectorResolution = 120;

%% aug params

 % augmentaiton for real images
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

%%
density = density.ps;
mkdir(outFolder);
mkdir(outRegFolder);
fileList = dir(inFolder);

minValues = zeros(numel(fileList)-2,3);
maxValues = zeros(numel(fileList)-2,3);
avgValues = zeros(numel(fileList)-2,3);
augMaxValues = zeros((numel(fileList)-2)*5,3);
augAvgValues = zeros((numel(fileList)-2)*5,3);
augIdx = 1;

numTotalAug = (numel(fileList)-2);
wb = waitbar(0, ['Creating augmentations: 0/', num2str(numTotalAug)]);

for j=3:numel(fileList)

    fname = fileList(j).name;
    fileName = [inFolder fname];
%     fileRegName = [regFolder fname];
    [~, basename, ext] = fileparts(fname);
    regFname = [basename '.tif'];
    fileRegName = [regFolder regFname];

    inImg = imread(fileName);
    regImg = imread(fileRegName);
    
    inCh1 = inImg(:,:,1);
    inCh2 = inImg(:,:,2);
    inCh3 = inImg(:,:,3);
    statIdx = j-2;
    minValues(statIdx,1) = min(inCh1(:));
    minValues(statIdx,2) = min(inCh2(:));
    maxValues(statIdx,1) = max(inCh1(:));
    maxValues(statIdx,2) = max(inCh2(:));
    avgValues(statIdx,1) = mean(inCh1(:));
    avgValues(statIdx,2) = mean(inCh2(:));
    
    
    imwrite(inImg, [outFolder, fname]);
    imwrite(regImg, [outRegFolder, regFname]);
    [theta, radius] = regplaneToPolar(regImg(1), regImg(2), 10000, true);
    arcIdx = ceil(theta / (360 / sectorResolution));

    arcDensity = density(max(1,arcIdx));
    numAugmentations = round(2000/density(max(1,arcIdx))-1);
    wb = waitbar((j-2)/numTotalAug, wb, ['Creating augmentations: ', num2str((j-2)), '/', num2str(numTotalAug)]);
    for k=1:numAugmentations
        outFileName = [basename '_' randHexString(10)];
%         outImg = inImg;
%         outImg = addNoise(outImg, noiseVariance);
%         intensityRange = max(inImg(:)) - min(inImg(:));
%         outImg = transformIntensity_v2(outImg, intensityRange);
        outMask =  inImg;
        [outImg, ~] = augment_image(inImg, outMask, rand(1) < histStretchProb, rand(1) * histStretchLevel, rand(1) < histEqPorob, rand(1) < invert, rand(1) < colorFlip, rand(1) < noiseProb, randi(3), rand(1) < blurProb, rand(1) * blurLevel);
        outImg(:,:,3) = 0;
        
        outCh1 = outImg(:,:,1);
        outCh2 = outImg(:,:,2);
        outCh3 = outImg(:,:,3);
        augMaxValues(augIdx, 1) = max(outCh1(:));
        augMaxValues(augIdx, 2) = max(outCh2(:));
        augAvgValues(statIdx,1) = mean(outCh1(:));
        augAvgValues(statIdx,2) = mean(outCh2(:));
        augIdx = augIdx + 1;
        
        regImg = regImg + randi(41,1,2, 'uint16')-21;
        
        imwrite(outImg, [outFolder outFileName '.jpg']);
        imwrite(regImg, [outRegFolder outFileName '.tif']);            
    end

end
close(wb)