% noiseVariance = 0.001; % 20x and 40x
noiseVariance = 10^-6; % 60x

% inFolder = '/home/koosk/data/data/DRP/Flora_20x_n2009/split/train/images/';
% regFolder = '/home/koosk/data/data/DRP/Flora_20x_n2009/split/train/labels/';
% 
% outFolder = '/home/koosk/data/data/DRP/Flora_20x_n2009/split/trainAug/images/';
% outRegFolder = '/home/koosk/data/data/DRP/Flora_20x_n2009/split/trainAug/labels/';
% %%
% inFolder = '/home/koosk/data/data/DRP/Flora_20x_n2009/split_traj_d5/train/images/';
% regFolder = '/home/koosk/data/data/DRP/Flora_20x_n2009/split_traj_d5/train/labels/';
% 
% outFolder = '/home/koosk/data/data/DRP/Flora_20x_n2009/split_traj_d5/trainAug/images/';
% % outRegFolder = '/home/koosk/data/data/DRP/Flora_20x_n2009/split_traj_d5/trainAug/labels/';
% %%
% inFolder = '/home/koosk/data/data/DRP/DVP2_trSet_40x_plate1/split_traj_d4/train/images/';
% regFolder = '/home/koosk/data/data/DRP/DVP2_trSet_40x_plate1/split_traj_d4/train/labels/';
% 
% outFolder = '/home/koosk/data/data/DRP/DVP2_trSet_40x_plate1/split_traj_d4/trainAug/images/';
% outRegFolder = '/home/koosk/data/data/DRP/DVP2_trSet_40x_plate1/split_traj_d4/trainAug/labels/';
% %%
% inFolder = '/home/koosk/data/data/DRP/trSet_Export_ACC_210617-HelaKyoto-40x-live-frame-2__2021-06-17T15_46_18-Measurement1_2000/split_traj_d5/train/images/';
% regFolder = '/home/koosk/data/data/DRP/trSet_Export_ACC_210617-HelaKyoto-40x-live-frame-2__2021-06-17T15_46_18-Measurement1_2000/split_traj_d5/train/labels/';
% 
% outFolder = '/home/koosk/data/data/DRP/trSet_Export_ACC_210617-HelaKyoto-40x-live-frame-2__2021-06-17T15_46_18-Measurement1_2000/split_traj_d5/trainAug/images/';
% outRegFolder = '/home/koosk/data/data/DRP/trSet_Export_ACC_210617-HelaKyoto-40x-live-frame-2__2021-06-17T15_46_18-Measurement1_2000/split_traj_d5/trainAug/labels/';
%%
% baseFolder = '/home/koosk/data/data/DRP/trSet_Export_ACC_210617-HelaKyoto-40x-live__2021-06-17T12_08_49-Measurement1_1543/trSet_Export_1543_40x_frame1';
% baseFolder = '/home/koosk/data/data/DRP/trSet_Export_ACC_210617-HelaKyoto-40x-live__2021-06-17T12_08_49-Measurement1_1543_padded';
% baseFolder = '/home/koosk/data/data/DRP/trSet_Export_ACC_210617-HelaKyoto-40x-live-frame-2__2021-06-17T15_46_18-Measurement1_2500';
% baseFolder = '/home/koosk/data/data/DRP/trSet_Export_ACC_210617-HelaKyoto-40x-live-frame-2__2021-06-17T15_46_18-Measurement1_2500_padded';

% baseFolder = '/home/koosk/data/data/DRP/trSet16Bit_20x_210424-HelaKyoto-TubGFP-H2BmCherry-live__2021-04-24T16_32_17-Measurement1_v2_2009_padded';
% baseFolder = '/home/koosk/data/data/DRP/trSet16bit_ACC_210617-HelaKyoto-40x-live__2021-06-17T12_08_49-Measurement1_1569_padded';
% baseFolder = '/home/koosk/data/data/DRP/trSet16bit_ACC_210617-HelaKyoto-40x-live-frame-2__2021-06-17T15_46_18-Measurement1_5044_padded';

baseFolder = '/home/koosk/data/data/DRP/Zero_Padded/20x-210424-HelaKyoto-TubGFP-H2BmCherry-live__2021-04-24T16_32_17-Measurement1_v2';
% baseFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210617-HelaKyoto-40x-live__2021-06-17T12_08_49-Measurement1';
% baseFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210617-HelaKyoto-40x-live-frame-2__2021-06-17T15_46_18-Measurement1';

% baseFolder = '/home/koosk/data/data/DRP/ZeroPad_075_crop/210424-HelaKyoto-TubGFP-H2BmCherry-live__2021-04-24T16_32_17-Measurement1_v2';
% baseFolder = '/home/koosk/data/data/DRP/ZeroPad_075_crop/ACC_210617-HelaKyoto-40x-live__2021-06-17T12_08_49-Measurement1';
% baseFolder = '/home/koosk/data/data/DRP/ZeroPad_075_crop/ACC_210617-HelaKyoto-40x-live-frame-2__2021-06-17T15_46_18-Measurement1';

% baseFolder = '/home/koosk/data/data/DRP/mirrorPadded/210424-HelaKyoto-TubGFP-H2BmCherry-live__2021-04-24T16_32_17-Measurement1_v2';
% baseFolder = '/home/koosk/data/data/DRP/mirrorPadded/ACC_210617-HelaKyoto-40x-live__2021-06-17T12_08_49-Measurement1';
% baseFolder = '/home/koosk/data/data/DRP/mirrorPadded/ACC_210617-HelaKyoto-40x-live-frame-2__2021-06-17T15_46_18-Measurement1';
% baseFolder = '/home/koosk/data/data/DRP/mirrorPadded/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4'; 
% baseFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4';

inFolder = fullfile(baseFolder,'split_traj/train/images/');
regFolder = fullfile(baseFolder,'split_traj/train/labels/');

outFolder = fullfile(baseFolder,'split_traj/trainBalAug/images/');
outRegFolder = fullfile(baseFolder,'split_traj/trainBalAug/labels/');
% outFolder = '/home/koosk/data/data/DRP/Zero_Padded/mix_zp_balanced_20x_40x_60x/trainBalAug/images/';
% outRegFolder = '/home/koosk/data/data/DRP/Zero_Padded/mix_zp_balanced_20x_40x_60x/trainBalAug/labels/';
% densityMax = 200;
% maxNumAugmentations = 20;
sectorResolution = 120;
%%
density = load('zero_padded_section_density.mat');
density = density.ps_zp;
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
wb = waitbar(0, ['Creating augmentations for files: 0/', num2str(numTotalAug)]);

for j=3:numel(fileList)

    fname = fileList(j).name;
    fileName = [inFolder fname];
    fileRegName = [regFolder fname];

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
    imwrite(regImg, [outRegFolder, fname]);
    [theta, radius] = regplaneToPolar(regImg(1), regImg(2), 10000, true);
    arcIdx = ceil(theta / (360 / sectorResolution));
    
%     numAugmentations = round((1-(density(max(1,arcIdx))/densityMax))*maxNumAugmentations);
%     numAugmentations = round(max(density)/density(max(1,arcIdx))*2-1);
    numAugmentations = round(max(density)/density(max(1,arcIdx))-1);
    wb = waitbar((j-2)/numTotalAug, wb, ['Creating augmentations: ', num2str((j-2)), '/', num2str(numTotalAug)]);
    for k=1:numAugmentations
        outFileName = randHexString(10);
        outImg = inImg;
        outImg = addNoise(outImg, noiseVariance);
        intensityRange = max(inImg(:)) - min(inImg(:));
        outImg = transformIntensity(outImg, intensityRange);
        
        outCh1 = outImg(:,:,1);
        outCh2 = outImg(:,:,2);
        outCh3 = outImg(:,:,3);
        augMaxValues(augIdx, 1) = max(outCh1(:));
        augMaxValues(augIdx, 2) = max(outCh2(:));
        augAvgValues(statIdx,1) = mean(outCh1(:));
        augAvgValues(statIdx,2) = mean(outCh2(:));
        augIdx = augIdx + 1;
        
        regimg = regImg - randi(21,1,2, 'uint16')-21;
        
        imwrite(outImg, [outFolder outFileName '.png']);
        imwrite(regImg, [outRegFolder outFileName '.png']);            
    end

end
close(wb)