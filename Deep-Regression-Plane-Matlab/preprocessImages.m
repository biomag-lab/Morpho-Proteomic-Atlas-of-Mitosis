% PREPROCESS IMAGES

% inFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/Images';
% inFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210617-HelaKyoto-40x-live-frame-2__2021-06-17T15_46_18-Measurement1/Images';
% inFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210617-HelaKyoto-40x-live__2021-06-17T12_08_49-Measurement1/Images';
inFolder = '/home/koosk/data/data/DRP/Zero_Padded/20x-210424-HelaKyoto-TubGFP-H2BmCherry-live__2021-04-24T16_32_17-Measurement1_v2/Images';


outputExt = '.png'; % can be empty to keep original extension

%%
outFolder = fullfile(inFolder, '..', 'ImagesPreprocessed');

mkdir(outFolder);
fileList = dir(inFolder);

numFiles = numel(fileList)-2;
wb = waitbar(0, ['Working on images: 0/', num2str(numFiles)]);
for j=3:numel(fileList)
    wb = waitbar(j/numFiles, wb, ['Working on images: ', num2str(j), '/', num2str(numFiles)]);
    
    fname = fileList(j).name;
    fileName = fullfile(inFolder, fname);

    inImg = imread(fileName);
    resultImg = zeros(size(inImg));
%     ch1 = mat2gray(inImg(:,:,1));
%     ch1 = histeq(imadjust(ch1, stretchlim(ch1, [0.2, 1])));
    ch1 = histeq(mat2gray(inImg(:,:,1)));
    ch2 = histeq(mat2gray(inImg(:,:,2)));
    resultImg(:,:,1) = ch1;
    resultImg(:,:,2) = ch2;
    
    [~, basename, ext] = fileparts(fname);
    if ~isempty(outputExt)
        ext = outputExt;
    end
    outFilepath = fullfile(outFolder, [basename, ext]);
    imwrite(resultImg, outFilepath);
end
close(wb)
