% inFolder = '/home/koosk/data/data/DRP/newNaming/zeroPad/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/Images/';
% imNormFile = './classification/newNaming-imgNorm60X.mat';
% outFolder = '/home/koosk/data/data/DRP/newNaming/zeroPad/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/ImagesNormalized/';
%
% inFolder = '/home/koosk/data/data/DRP/DVP2-class/Telo/ACC-export/cropRaw/';
% imNormFile = '/home/koosk/data/data/DRP/DVP2-class/imgNorm-all.mat';
% outFolder = [inFolder, '../crop/'];
%
% inFolder = '/home/koosk/data/data/DRP/2022_v1_zeroPadded/ACC_211008-HK-live-60X__2021-10-08T14_56_14-Measurement1/Images/';
% imNormFile = '/home/koosk/data/data/DRP/2022_v1_zeroPadded/2022_v1_zeroPadded_imgNorm60X_3.mat';
% outFolder = [inFolder, '../ImagesNormalized/'];
%
inFolder = '/home/koosk/data/data/DRP/210424-HelaKyoto-TubGFP-H2BmCherry-live__2021-04-24T16_32_17-Measurement1_v2/Images/';
imNormFile = '/home/koosk/data/data/DRP/210424-HelaKyoto-TubGFP-H2BmCherry-live__2021-04-24T16_32_17-Measurement1_v2/imgNorm.mat';
outFolder = [inFolder, '../ImagesNormalized/'];

mkdir(outFolder);


% create normalization intensities
load(imNormFile);
lowRmed = median(lowR);
lowGmed = median(lowG);
highRmed = median(highR);
highGmed = median(highG);

lows  = [lowRmed lowGmed 0];
highs = [highRmed highGmed 1];

% iterate through
fileList = dir([inFolder '*.tif']);

for i=1:numel(fileList)
   
    disp(i);
    
    inName = [inFolder fileList(i).name];    
    inImg = imread(inName);
    outImg = uint8(imadjust(inImg, [lows; highs])/256);
    
    imwrite(outImg, [outFolder fileList(i).name(1:end-4) '.jpg']);
end
