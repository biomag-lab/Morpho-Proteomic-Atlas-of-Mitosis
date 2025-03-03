% Script for plotting the training set

baseFolder = 'C:\Users\BIOMAG\Desktop\210528-HelaKyoto-PFAfixed-frame_ ACC_PROJECT_nuc';
imPath = fullfile(baseFolder,'anal3');
metaPath = fullfile(baseFolder,'anal2');
regResultPath = 'C:\Users\BIOMAG\Desktop\210528-HelaKyoto-PFAfixed-frame_ ACC_PROJECT_nuc\drp_predictions_210528-HelaKyoto-PFAfixed-frame_ ACC_PROJECT_nuc.csv';
imExt = 'tif';
answer = questdlg('Would you like to filter the prediction?','Filtering','Yes','No','No');

if strcmp(answer,'Yes')
    theta_min = 0;
    theta_max = 360;
    radius_min = 0;
    preds_filtered = filter_preds(regResultPath,theta_min,theta_max,radius_min);
else
    theta_min = 205;
    theta_max = 208;
    radius_min = 4300;
    preds_filtered = filter_preds(regResultPath,theta_min,theta_max,radius_min);
end

% imList = dir(fullfile(imPath,'*.png'));
% LabelList = dir(fullfile(labelPath,'*.png'));

rp = uint16(zeros(10000,10000,3));

imName = preds_filtered.ImageName{1};
im = imread(fullfile(imPath,imName));
[x, y, ch] = size(im);
slitImName = strsplit(imName,imExt);
metaName = [slitImName{1},'txt'];
data = read_anal2(fullfile(metaPath,metaName));
cutSize = [50 50];

for i = 1:size(preds_filtered,1)
    if ~strcmp(imName,preds_filtered.ImageName{i})
        imName = preds_filtered.ImageName{i};
        im = imread(fullfile(imPath,imName));
        slitImName = strsplit(imName,imExt);
        metaName = [slitImName{1},'txt'];
        data = read_anal2(fullfile(metaPath,metaName));
    end
%     cropCoor = [max(1, preds_filtered.xPixelPos(i) - cutSize(1)),...
%                 min(x ,preds_filtered.xPixelPos(i) + cutSize(1)),...
%                 max(1 ,preds_filtered.yPixelPos(i) - cutSize(1)),...
%                 min(y ,preds_filtered.yPixelPos(i) + cutSize(1))];
    cellID = preds_filtered.ObjectNumber(i);
    cropCoor = [max(1, data{1}(cellID) - cutSize(1)),...
                min(y ,data{1}(cellID) + cutSize(1)),...
                max(1 ,data{2}(cellID) - cutSize(1)),...
                min(x ,data{2}(cellID) + cutSize(1))];
    crop = im(cropCoor(3):cropCoor(4),cropCoor(1):cropCoor(2),:);
    [cropX, cropY, ~] = size(crop);
    coor = [preds_filtered.regPosX(i), preds_filtered.regPosY(i)];
    BB = getBB(coor*10000,[cropY,cropX]);
    if ~any(BB<1) && ~any(BB>10000)
        rp(BB(3):BB(4),BB(1):BB(2), :) = crop;
    end
    i
end

f = figure;
ax = axes(f);
imshow(im2uint8(rp*200),'Parent',ax)
ax.YDir = 'normal';
% imwrite(im2uint8(rp*200),'RegP_thumbPrediction.png')
% path = fullfile(baseFolder,'BIAS_import_pro');
% writeCSV4BIASimport(path,preds_filtered)