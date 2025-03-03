% get normalization params for img transform
clear all

% inFolder = 'c:\receive\projects\projects\BRC\projects\DVP2\annotations\40x_2\Images\';
% inFolder = '/home/koosk/data/data/DRP/newNaming/zeroPad/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/Images/';
% inFolder = '/home/koosk/data/data/DRP/DVP2-class/Telo/ACC-export/cropRaw/';
% inFolder = '/home/koosk/data/data/DRP/2022_v1_zeroPadded/ACC_211008-HK-live-60X__2021-10-08T14_56_14-Measurement1/Images/';
inFolder = '/home/koosk/data/data/DRP/210424-HelaKyoto-TubGFP-H2BmCherry-live__2021-04-24T16_32_17-Measurement1_v2/Images/';


fileList = dir([inFolder '*.tif']);

tol = [0.005 0.995];

for i=1:numel(fileList)
   
    inName = [inFolder fileList(i).name];
%     inRegName = fullfile(inCoordFolder, fileList(i).name);

    inImg = imread(inName);
%     regplaneCoord = double(imread(inRegName));
%     [theta, radius] = regplaneToPolar(regplaneCoord(1), regplaneCoord(2)); % not polar but Euclidean
%     if theta < 15 && theta > 345
%     	disp(['Skipping file (interphase): ', fileList(i).name])
%     	continue
%     end
    
    lowhigh = stretchlim(inImg, tol);
    lowR(i) = lowhigh(1, 1);
    highR(i) = lowhigh(2, 1);
    lowG(i) = lowhigh(1, 2);
    highG(i) = lowhigh(2, 2);
        
    disp(i);
end

% save('imgNorm40X_2.mat', 'lowR', 'highR', 'lowG', 'highG');
% save('./classification/newNaming-imgNorm60X.mat', 'lowR', 'highR', 'lowG', 'highG');
save('./imgNorm.mat', 'lowR', 'highR', 'lowG', 'highG');
