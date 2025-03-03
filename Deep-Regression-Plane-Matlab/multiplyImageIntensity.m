% inFolder = '/home/koosk/data/data/DRP/Zero_Padded/20x-210424-HelaKyoto-TubGFP-H2BmCherry-live__2021-04-24T16_32_17-Measurement1_v2/Images';
% outFolder = '/home/koosk/data/data/DRP/Zero_Padded/20x-210424-HelaKyoto-TubGFP-H2BmCherry-live__2021-04-24T16_32_17-Measurement1_v2/ImagesFixIntensity';
% multiplier = [4.7674; 3.8729];

% % inFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210617-HelaKyoto-40x-live__2021-06-17T12_08_49-Measurement1/Images';
% % outFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210617-HelaKyoto-40x-live__2021-06-17T12_08_49-Measurement1/ImagesFixIntensity';
% % multiplier = [1; 1];
% 
% inFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210617-HelaKyoto-40x-live-frame-2__2021-06-17T15_46_18-Measurement1/Images';
% outFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210617-HelaKyoto-40x-live-frame-2__2021-06-17T15_46_18-Measurement1/ImagesFixIntensity';
% multiplier = [1.1573; 1.1108];
% 
inFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/Images';
outFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/ImagesFixIntensity';
multiplier = [7.3614; 6.8068];


% multiplier = 6;

mkdir(outFolder);
fileList = dir(inFolder);

numFiles = numel(fileList)-2;
wb = waitbar(0, ['Fixing image intensity: 0/', num2str(numFiles)]);
for j=3:numel(fileList)
    wb = waitbar((j-2)/numFiles, wb, ['Fixing image intensity: ', num2str(j-2), '/', num2str(numFiles)]);
    
    fname = fileList(j).name;
    fileName = fullfile(inFolder, fname);

    inImg = imread(fileName);
    multImg = inImg;
    multImg(:,:,1) = multImg(:,:,1) .* multiplier(1);
    multImg(:,:,2) = multImg(:,:,2) .* multiplier(2);
%     multImg = inImg .* multiplier;
    
    [~, basename, ext] = fileparts(fname);
%     outFilepath = fullfile(outFolder, [basename, '-mult', num2str(multiplier), ext]);
    outFilepath = fullfile(outFolder, fname);
    imwrite(multImg, outFilepath);
end
close(wb)
