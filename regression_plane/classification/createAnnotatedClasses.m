% create annotated dataset with classes
% inFolder = 'c:\receive\projects\projects\BRC\projects\DVP2\annotations\20x\Images\';
% inCoordFolder = 'c:\receive\projects\projects\BRC\projects\DVP2\annotations\20x\Labels\';
% imNormFile = 'c:\receive\projects\projects\BRC\projects\DVP2\annotations\prog\imgNorm20X.mat';
% outFolder = 'c:\receive\projects\projects\BRC\projects\DVP2\annotations\60x\fourty\';

%v3
% inFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210617-HelaKyoto-40x-live-frame-2__2021-06-17T15_46_18-Measurement1/Images/';
% inCoordFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210617-HelaKyoto-40x-live-frame-2__2021-06-17T15_46_18-Measurement1/Labels/';
% imNormFile = '/home/koosk/work/projects/DRP/classification/imgNorm40X_2.mat';
% outFolder = '/home/koosk/images-data/class40_v3/train/';

% %v4
% inFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/split_traj1/val/images/';
% inCoordFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/split_traj1/val/labels/';
% imNormFile = '/home/koosk/work/projects/DRP/classification/imgNorm.mat';
% % outFolder = '/home/koosk/images-data/class40_v4/train/';
% outFolder = '/home/koosk/images-data/class40_v4/val/';

% v5 with 41 classes (40 mitotic + interphase)
inFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/Images/';
inCoordFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/Labels/';
imNormFile = '/home/koosk/work/projects/DRP/classification/imgNorm.mat';
outFolder = '/home/koosk/images-data/class41/train/';


numOutClasses = 40;

interphaseClassname = 'interphase';
% create classes
mkdir(outFolder);
for i=1:numOutClasses
    mkdir([outFolder num2str(i)]);
end
mkdir([outFolder interphaseClassname]);

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

splitDeg = (360 - 30) / numOutClasses; % bottom 15-15 degrees are interphase cells

for i=1:numel(fileList)
   
    disp(i);
    
    inName = [inFolder fileList(i).name];    
    inImg = imread(inName);
    outImg = uint8(imadjust(inImg, [lows; highs])/256);
    inRegName = [inCoordFolder fileList(i).name];    
    regplaneCoord = double(imread(inRegName));
    inIRegmg = regplaneCoord - 5000;   
    
    [theta, radius] = regplaneToPolar(regplaneCoord(1), regplaneCoord(2)); % not polar but Euclidean
    if theta >= 15 && theta <= 345 % mitotic
    	classNum = floor((theta-15) / splitDeg)+1;
        imwrite(outImg, [outFolder num2str(classNum) '/' fileList(i).name(1:end-4) '.jpg']);
    else % interphase
        imwrite(outImg, [outFolder interphaseClassname '/' fileList(i).name(1:end-4) '.jpg']);
    end
    
end
   
