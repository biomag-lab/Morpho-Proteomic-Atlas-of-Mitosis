% % baseFolder = '/home/koosk/data/data/DRP/Zero_Padded/20x-210424-HelaKyoto-TubGFP-H2BmCherry-live__2021-04-24T16_32_17-Measurement1_v2';
% % baseFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210617-HelaKyoto-40x-live__2021-06-17T12_08_49-Measurement1';
% baseFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210617-HelaKyoto-40x-live-frame-2__2021-06-17T15_46_18-Measurement1';
% % baseFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4';
% inFolder = fullfile(baseFolder,'Images/');

% baseFolder = '/home/koosk/data/data/DRP/Zero_Padded/20x-210424-HelaKyoto-TubGFP-H2BmCherry-live__2021-04-24T16_32_17-Measurement1_v2';
% baseFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210617-HelaKyoto-40x-live-frame-2__2021-06-17T15_46_18-Measurement1';
baseFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4';
inFolder = fullfile(baseFolder,'ImagesFixIntensity/');


% inFolder = fullfile(baseFolder,'Images/');
% regFolder = fullfile(baseFolder,'Labels/');
fileList = dir(inFolder);
minValues = zeros(numel(fileList)-2,3);
maxValues = zeros(numel(fileList)-2,3);
avgValues = zeros(numel(fileList)-2,3);
sumValues = zeros(numel(fileList)-2,3);

tic
for j=3:numel(fileList)
    fname = fileList(j).name;
    fileName = [inFolder fname];
%     fileRegName = [regFolder fname];

    inImg = imread(fileName);
%     regImg = imread(fileRegName);
    
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
    sumValues(statIdx,1) = sum(inCh1(:));
    sumValues(statIdx,2) = sum(inCh2(:));
end
toc
% save('s20xFixed-statistics.mat', 'baseFolder', 'minValues', 'maxValues', 'avgValues', 'sumValues')
