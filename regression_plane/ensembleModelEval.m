%% Ensemble model evaluation on new screens

allowedClassDiff = 3;
saveAgreedPredictionImages = true;
saveFailedPredictionImages = true;
radiusFilter = 3500;

% classifData = load('./data/DRP_train_result_ws-02-Dec-2021_06_49_24-classif_class41.mat'); % googlenet
% classifData = load('./data/resnet50_41class.mat'); % resnet, somewhat better
% classifData = load('/home/koosk/data/data/DRP/models/DRP_train_result_ws-21-Jan-2022_18_59_36_classif_v3_resnet50.mat');
classifData = load('/home/koosk/data/data/DRP/models/DRP_train_result_ws-29-Jan-2022_03_49_52_classif_v4_resnet50.mat');
% regressionData = load('DRP_train_result_ws-03-Dec-2021_19_10_36-regression-googlenet-heavyaugmentation_v26_local.mat');
% regressionData = load('/home/koosk/data/data/DRP/models/DRP_train_result_ws-21-Nov-2021_03_21_18_v20.mat');
% regressionData = load('/home/koosk/data/data/DRP/models/DRP_train_result_ws-16-Nov-2021_18_12_39_v19.mat');
% regressionData = load('/home/koosk/data/data/DRP/models/DRP_train_result_ws-02-Sep-2021_17_14_12_train_40x_2000_v4.mat');
% regressionData = load('/home/koosk/data/data/DRP/models/DRP_train_result_ws-08-Nov-2021_11_23_07_train_40x_2000_v16');
% regressionData = load('/home/koosk/data/data/DRP/models/DRP_train_result_ws-08-Sep-2021_v27.mat');
% regressionData = load('/home/koosk/data/data/DRP/models/DRP_train_result_ws-09-Jan-2022_01_31_31_possibly_v31_pt4.mat');
% regressionData = load('/home/koosk/data/data/DRP/models/DRP_train_result_ws-21-Jan-2022_04_13_24_v38.mat');
regressionData = load('/home/koosk/data/data/DRP/models/DRP_train_result_ws-27-Jan-2022_21_06_04_v39.mat');

%%
% imdsVal = imageDatastore('/home/koosk/data/data/DRP/DVP2-class/Ana/crop');
% imdsVal = imageDatastore('/home/koosk/data/data/DRP/DVP2-class/Telo/ACC-export/cropRaw');
% imdsVal = imageDatastore('/home/koosk/data/data/DRP/211130-screen-all/BIAS-naming/cropRaw');
% imdsVal = imageDatastore('/home/koosk/images-data/newNaming_split/val/images');
% augImdsVal = augmentedImageDatastore([224,224,3],imdsVal);
imdsVal = imageDatastore('/home/koosk/data/data/DRP/211130-screen-all-wo-junk/cropRaw');

rp = uint8(zeros(10000,10000,3));
rpNotSelected = uint8(zeros(10000,10000,3));
rpRegressionModel = uint8(zeros(10000,10000,3));
rpClassificationModel = uint8(zeros(10000,10000,3));
cats = categorical(['interphase'; string((1:40)')]);


classifNet = classifData.net;
regressionNet = regressionData.net;
sectorLength = (360-30)/40;
coorClsPredList = [];
coorRegPredList = [];
agreementCoorRegPredList = []; % coord list for samples where the ensemble model agrees, coords from reg model are used
classDiffList = [];
index = 0;
filterAgreedImagesDir = './data/filteredAgreement/';
filterFailedImagesDir = './data/filtered/';
outDirs = {filterAgreedImagesDir; filterFailedImagesDir};
for i = 1:2
    outDir = outDirs{i};
    mkdir([outDir ,'interphase'])
    for j = 1:40
        mkdir([outDir ,num2str(j)])
    end
end
while imdsVal.hasdata()
    index = index + 1;
    [im, info] = read(imdsVal);
    im4cls = imresize(im, [224, 224]);
    classPred = classifNet.classify(im4cls);
    classIdx = find(classPred == cats);
    if classIdx == 1
        randDegree = rand*30-15;
%         randDegree = 0;
        degree = 0 + randDegree;
    else
        randDegree = rand*sectorLength;
%         randDegree = 0;
        degree = 15 + (classIdx-1)*sectorLength - randDegree;
    end
    dFix = 270-degree;
    radius = 3700 + randi(1000);
%     radius = 4200;
    coorPred = [cosd(dFix)*radius, sind(dFix)*radius] + [5000,5000];
    
    coorClsPredList = [coorClsPredList ; coorPred];
    
    
    disp(['idx = ', num2str(index), ', dFix = ', num2str(dFix), ', classIdx = ', num2str(classIdx), ', classPred = ', char(classPred), ...
        ', coorPred = ', num2str(round(coorPred(1))), ', ', num2str(round(coorPred(2)))])
    
    %%
    im4reg = imresize(im, [299, 299]);
%     im4reg = imresize(im, [224, 224]);
    regPred = regressionNet.predict(im4reg);
    regClass = regressionToClass(regPred);
    regClassIdx = find(regClass == cats);
    disp(['classif idx = ', num2str(classIdx), ', reg class idx = ', num2str(regClassIdx)]);
    diff = abs(classIdx - regClassIdx);
    if diff > 20
        diff = abs(diff - 41);
    end
    classdiff = abs(diff);
    classDiffList(end+1) = classdiff;
    
    coorRegPredList = [coorRegPredList; regPred];

    im(:,:,1) = imadjust(im(:,:,1));
    im(:,:,2) = imadjust(im(:,:,2));
    [x, y, ch] = size(im);
    
    BB = getBB(coorPred,[y x]);
    rpClassificationModel(BB(3):BB(4),BB(1):BB(2), :) = im;
    
    BB = getBB(regPred,[y x]);
    rpRegressionModel(BB(3):BB(4),BB(1):BB(2), :) = im;
    if classdiff <= allowedClassDiff
        rp(BB(3):BB(4),BB(1):BB(2), :) = im;
        agreementCoorRegPredList = [agreementCoorRegPredList; regPred];
        if saveAgreedPredictionImages
            [theta, radius] = regplaneToPolar(regPred(1), regPred(2));
            if radius >= radiusFilter
                classFolder = char(regClass);
                [~, basename, ~] = fileparts(info.Filename);
                imwrite(im, [filterAgreedImagesDir, classFolder, filesep, ...
                        sprintf('%s-regCoord-%.0f-%.0f_regClass-%s.jpg', ...
                        basename, regPred, regClass)]);
            end
        end
    else
        rpNotSelected(BB(3):BB(4),BB(1):BB(2), :) = im;
        if saveFailedPredictionImages
            classFolder = char(regClass);
            imwrite(im, [filterFailedImagesDir, classFolder, '/', ...
                sprintf('img-regCoord-%.0f-%.0f_regClass-%s_classifClass-%s.jpg', ...
                regPred, regClass, classPred)]);
        end
    end
end


%%
f = figure;
ax = axes(f);
imshow(rp,'Parent',ax)
ax.YDir = 'normal';
title(ax, 'Agreement between models')
fname = 'ensemble-agreement';
saveas(f, [fname, '.png'])
imwrite(flipud(rp), [fname, '-full.png'])

f = figure;
ax = axes(f);
imshow(rpNotSelected,'Parent',ax)
ax.YDir = 'normal';
title(ax, 'Disagreement between models')
fname = 'ensemble-disagreement';
saveas(f, [fname, '.png'])
imwrite(flipud(rpNotSelected), [fname, '-full.png'])

f = figure;
ax = axes(f);
imshow(rpClassificationModel,'Parent',ax)
ax.YDir = 'normal';
title(ax, 'Classification model with slightly randomized positions')
fname = 'classification';
saveas(f, [fname, '.png'])
imwrite(flipud(rpClassificationModel), [fname, '-full.png'])

f = figure;
ax = axes(f);
imshow(rpRegressionModel,'Parent',ax)
ax.YDir = 'normal';
title(ax, 'Prediction of regression model')
fname = 'regression';
saveas(f, [fname, '.png'])
imwrite(flipud(rpRegressionModel), [fname, '-full.png'])
