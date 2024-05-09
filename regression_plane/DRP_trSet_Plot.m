% Script for plotting the training set

% imPath = 'D:\BRC\Deep Regression Plane\HeLa trSet\Images';
% labelPath = 'D:\BRC\Deep Regression Plane\HeLa trSet\Labels';
% imPath = '/home/koosk/data/data/DRP/Zero_Padded/20x-210424-HelaKyoto-TubGFP-H2BmCherry-live__2021-04-24T16_32_17-Measurement1_v2/Images/';
% labelPath = '/home/koosk/data/data/DRP/Zero_Padded/20x-210424-HelaKyoto-TubGFP-H2BmCherry-live__2021-04-24T16_32_17-Measurement1_v2/Labels/';
imPath = '/home/koosk/images-data/newNaming_split/val/images/';
labelPath = '/home/koosk/images-data/newNaming_split/val/labels/';

% imList = dir(fullfile(imPath,'*.png'));
% LabelList = dir(fullfile(labelPath,'*.png'));
imList = dir(fullfile(imPath,'*.jpg'));
LabelList = dir(fullfile(labelPath,'*.tif'));

% rp = uint16(zeros(10000,10000,3));
rp = uint8(zeros(10000,10000,3));

im = imread(fullfile(imPath,imList(1).name));



for i = 1:length(imList)
    im = imread(fullfile(imPath,imList(i).name));
    [x, y, ch] = size(im);
    [~,fname,~] = fileparts(imList(i).name);
    coor = imread(fullfile(labelPath,[fname, '.tif']));
    
    BB = getBB(coor,[y x]);
    im(:,:,1) = imadjust(im(:,:,1));
    im(:,:,2) = imadjust(im(:,:,2));
    
    rp(BB(3):BB(4),BB(1):BB(2), :) = im;
end

f = figure;
ax = axes(f);
imshow(rp,'Parent',ax)
ax.YDir = 'normal';
