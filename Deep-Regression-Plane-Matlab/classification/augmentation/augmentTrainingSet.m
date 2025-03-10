function augmentTrainingSet(inFolder, outFolder, styleData, multiplyAugment)
%%%
% This script generates a training set such that the median cell size is
% fix and crops into images of a fix size and applies random augmentation

expectedCellSize = 40; % this is the diameter 40->256
expectedCropSize = 299;

if styleData == 0
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
elseif styleData == 1
    % augmentaiton for style transfer
    numAugment = 1;
    histEqPorob = 0.05;
    histStretchProb = 0.1;
    histStretchLevel = 0.02;
    invert = 0.0;
    blurProb = 0.2;
    blurLevel = 4;
    noiseProb = 0.2;       
    colorFlip = 0.0;
    maskFormat = '.tiff'; % TODO change back to .png
    stepSize = 6;%10;
elseif styleData == 2
    % augmentaiton for validation RCNN
    numAugment = 1;
    histEqPorob = 0.0;
    histStretchProb = 0.0;
    histStretchLevel = 0.0;
    invert = 0.0;
    blurProb = 0.0;
    blurLevel = 0;
    noiseProb = 0.0;       
    colorFlip = 0.0;
    maskFormat = '.tiff'; % TODO change back to .png
    stepSize = 1;
end

if nargin == 4
    numAugment = multiplyAugment;
end

mkdir(outFolder);

fileList = dir([inFolder filesep '*.jpg']);

numAugment = round(multiplyAugment / numel(fileList));

for i=1:stepSize:numel(fileList)
    disp(fileList(i).name);
    % read in the image and the mask
    inImg = imread([inFolder filesep fileList(i).name ]);        
    
    resImage = imresize(inImg, [299 299], 'bicubic');
                    
    outImg =  resImage;
    outMask =  resImage;

        for j=1:numAugment
            outName = [fileList(i).name(1:end-4) '_aug' randHexString(6)];
            [outImg, ~] = augment_image(outImg, outMask, rand(1) < histStretchProb, rand(1) * histStretchLevel, rand(1) < histEqPorob, rand(1) < invert, rand(1) < colorFlip, rand(1) < noiseProb, randi(3), rand(1) < blurProb, rand(1) * blurLevel);            
            imwrite(outImg, [outFolder  filesep outName '.jpg']);

        end
        % case 2

end
