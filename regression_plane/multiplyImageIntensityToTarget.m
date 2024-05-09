% convert intensity by determining a multiplier for every image based on
% avg intensity of 40x pt 1

% inFolder = '/home/koosk/data/data/DRP/Zero_Padded/20x-210424-HelaKyoto-TubGFP-H2BmCherry-live__2021-04-24T16_32_17-Measurement1_v2/Images';
% outFolder = '/home/koosk/data/data/DRP/Zero_Padded/20x-210424-HelaKyoto-TubGFP-H2BmCherry-live__2021-04-24T16_32_17-Measurement1_v2/ImagesFixIntensity2';

% inFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210617-HelaKyoto-40x-live__2021-06-17T12_08_49-Measurement1/Images';
% outFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210617-HelaKyoto-40x-live__2021-06-17T12_08_49-Measurement1/ImagesFixIntensity2';
% 
% inFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210617-HelaKyoto-40x-live-frame-2__2021-06-17T15_46_18-Measurement1/Images';
% outFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210617-HelaKyoto-40x-live-frame-2__2021-06-17T15_46_18-Measurement1/ImagesFixIntensity2';
% 
inFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/Images';
outFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/ImagesFixIntensity2';

targetIntensity = [1121.8, 2432.4]; % determined from s40x1Mean from showStats.m

mkdir(outFolder);
fileList = dir(inFolder);

numFiles = numel(fileList)-2;
wb = waitbar(0, ['Fixing image intensity: 0/', num2str(numFiles)]);
for j=3:numel(fileList)
    wb = waitbar((j-2)/numFiles, wb, ['Fixing image intensity: ', num2str(j-2), '/', num2str(numFiles)]);
    
    fname = fileList(j).name;
    fileName = fullfile(inFolder, fname);

    inImg = imread(fileName);
    inCh1 = inImg(:,:,1);
    inCh2 = inImg(:,:,2);
    avgRed = mean(inCh1(:));
    avgGreen = mean(inCh2(:));
    multiplier = [targetIntensity(1)/avgRed, targetIntensity(2)/avgGreen];
    multImg = inImg;
    multImg(:,:,1) = multImg(:,:,1) .* multiplier(1);
    multImg(:,:,2) = multImg(:,:,2) .* multiplier(2);
    
    [~, basename, ext] = fileparts(fname);
    outFilepath = fullfile(outFolder, fname);
    imwrite(multImg, outFilepath);
end
close(wb)
