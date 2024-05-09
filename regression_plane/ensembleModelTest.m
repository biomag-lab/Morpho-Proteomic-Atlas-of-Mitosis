%% Ensemble model test

allowedClassDiff = 3;
saveFailedPredictionImages = true;

% classifData = load('./data/DRP_train_result_ws-02-Dec-2021_06_49_24-classif_class41.mat'); % googlenet
% classifData = load('./data/resnet50_41class.mat'); % resnet, somewhat better
classifData = load('/home/koosk/data/data/DRP/models/DRP_train_result_ws-21-Jan-2022_18_59_36_classif_v3_resnet50.mat');
% classifData = load('/home/koosk/data/data/DRP/models/DRP_train_result_ws-29-Jan-2022_03_49_52_classif_v4_resnet50.mat');
% regressionData = load('DRP_train_result_ws-03-Dec-2021_19_10_36-regression-googlenet-heavyaugmentation_v26_local.mat');
% regressionData = load('/home/koosk/data/data/DRP/models/DRP_train_result_ws-21-Nov-2021_03_21_18_v20.mat');
% regressionData = load('/home/koosk/data/data/DRP/models/DRP_train_result_ws-02-Sep-2021_17_14_12_train_40x_2000_v4.mat');
% regressionData = load('/home/koosk/data/data/DRP/models/DRP_train_result_ws-08-Nov-2021_11_23_07_train_40x_2000_v16');
regressionData = load('/home/koosk/data/data/DRP/models/DRP_train_result_ws-21-Jan-2022_04_13_24_v38.mat');
% regressionData = load('/home/koosk/data/data/DRP/models/DRP_train_result_ws-27-Jan-2022_21_06_04_v39.mat');

%%
% imdsVal = imageDatastore('/home/koosk/images-data/class41/regression_augmented/val/images/','IncludeSubfolders',true);
% labelVal = imageDatastore('/home/koosk/images-data/class41/regression_augmented/val/labels/','IncludeSubfolders',true);
imdsVal = imageDatastore('/home/koosk/images-data/2022_v1_zeroPadded_split/test/images/','IncludeSubfolders',true);
labelVal = imageDatastore('/home/koosk/images-data/2022_v1_zeroPadded_split/test/labels/','IncludeSubfolders',true);
% imdsVal = imageDatastore('/home/koosk/images-data/2022_v1_zeroPadded_split_w20X/test/images/','IncludeSubfolders',true);
% labelVal = imageDatastore('/home/koosk/images-data/2022_v1_zeroPadded_split_w20X/test/labels/','IncludeSubfolders',true);
% augImdsVal = augmentedImageDatastore([224,224,3],imdsVal);
augImdsVal = augmentedImageDatastore([299,299,3],imdsVal);
augImdsVal.MiniBatchSize = 1;
combinedValDs = combine(augImdsVal,labelVal);

rp = uint8(zeros(10000,10000,3));
rpNotSelected = uint8(zeros(10000,10000,3));
rpGt = uint8(zeros(10000,10000,3));
cats = categorical(['interphase'; string((1:40)')]);


classifNet = classifData.net;
regressionNet = regressionData.net;
sectorLength = (360-30)/40;
coorGtList = [];
coorClsPredList = [];
coorRegPredList = [];
gtClassList = {}; 
gtClassIdxList = zeros(augImdsVal.NumObservations,1)-1;
classPredList = {};
classPredIdxList = zeros(augImdsVal.NumObservations,1)-1;
agreementCoorRegPredList = []; % coord list for samples where the ensemble model agrees, coords from reg model are used
agreementCoorGtList = [];
classDiffList = [];
index = 0;
agreementIndex = false(augImdsVal.NumObservations, 1);
filteredImagesDir = './data/filtered/';
mkdir([filteredImagesDir,'interphase'])
for i=1:40
    mkdir([filteredImagesDir,num2str(i)])
end
while combinedValDs.hasdata()
    index = index + 1;
    data = read(combinedValDs);
    im = data{1,1}{1};
    im4cls = imresize(im, [224, 224]);
    coorGt = data{1,2};
    classPred = classifNet.classify(im4cls);
    classIdx = find(classPred == cats);
    if classIdx == 1
%         randDegree = rand*30-15;
        randDegree = 0;
        degree = 0 + randDegree;
    else
%         randDegree = rand*sectorLength;
        randDegree = 0;
        degree = 15 + (classIdx-1)*sectorLength - randDegree;
    end
    dFix = 270-degree;
%     radius = 3700 + randi(1000);
    radius = 4200;
    coorPred = [cosd(dFix)*radius, sind(dFix)*radius] + [5000,5000];
    
    coorGtList = [coorGtList; coorGt];
    coorClsPredList = [coorClsPredList ; coorPred];
    
    dist = norm(double(coorGt)-coorPred);
    
    disp(['idx = ', num2str(index), ', dFix = ', num2str(dFix), ', classIdx = ', num2str(classIdx), ', classPred = ', char(classPred), ...
        ', coorGt = ', num2str(coorGt(1)), ', ', num2str(coorGt(2)), ', coorPred = ', num2str(round(coorPred(1))), ', ', num2str(round(coorPred(2))), ...
        ', norm = ', num2str(dist)])
    
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
    
    gtClass = regressionToClass(coorGt);
    gtClassList{end+1} = char(gtClass);
    gtClassIdxList(index) = find(gtClass == cats);

    classPredList{end+1} = char(classPred);
    classPredIdxList(index) = classIdx;
    
    %%


    [x, y, ch] = size(im);
    BB = getBB(regPred,[y x]);
    im(:,:,1) = imadjust(im(:,:,1));
    im(:,:,2) = imadjust(im(:,:,2));
    if classdiff <= allowedClassDiff
        rp(BB(3):BB(4),BB(1):BB(2), :) = im;
        agreementCoorRegPredList = [agreementCoorRegPredList; regPred];
        agreementCoorGtList = [agreementCoorGtList; coorGt];
        agreementIndex(index) = true;
    else
        rpNotSelected(BB(3):BB(4),BB(1):BB(2), :) = im;
        if saveFailedPredictionImages
            ensembleError = sqrt(sum((double(coorGt) - double(regPred)).^2,2)); 
            diff = sqrt(mean(ensembleError .^2)); % RMSE
            classFolder = char(gtClass);
%             if regClassIdx == 1
%                 classFolder = 'interphase';
%             end
            imwrite(im, [filteredImagesDir, classFolder, '/', ...
                sprintf('img-gtCoord-%d-%d_gtClass-%s_regCoord-%.0f-%.0f_regClass-%s_classifClass-%s.jpg', ...
                coorGt, gtClass, regPred, regClass, classPred)]);
%                 sprintf('prediction-%d-%d_ground-truth-%d-%d_diff-%d', int16(regPred),  coorGt(1), coorGt(2), int16(diff)), '.jpg']); % TODO
        end
    end
    BB = getBB(coorGt,[y x]);
    rpGt(BB(3):BB(4),BB(1):BB(2), :) = im;
end

%%
regError = sqrt(sum((double(coorGtList) - double(coorRegPredList)).^2,2));
regRMSE = sqrt(mean(regError.^2)); % RMSE
disp('------------------------------------------------')
disp(['Regression model RMSE = ', num2str(regRMSE)]);
disp('')

classError = abs(gtClassIdxList - classPredIdxList);
classError(classError>20) = abs(classError(classError>20)-41);
classAccuracy = mean(classError==0);
disp(['Classification model accuracy = ', num2str(classAccuracy)]);
disp(['Classification mean class distance = ', num2str(mean(classError))]);
disp(['Classification 1-miss accuracy = ', num2str(mean(classError<2))]);
disp(['Classification 2-miss accuracy = ', num2str(mean(classError<3))]);
disp(['Classification 3-miss accuracy = ', num2str(mean(classError<4))]);
disp('Classification performance:')
classperf(gtClassList, classPredList)
disp('')

classDiffList = classDiffList';
ensembleErrors = sqrt(sum((double(agreementCoorGtList) - double(agreementCoorRegPredList)).^2,2));
gtdiffEnsemble = sqrt(mean(ensembleErrors .^2)); % RMSE
numAgreement = nnz(agreementIndex);
numSamples = augImdsVal.NumObservations;
disp(['Ensemble agreed on ', num2str(numAgreement), '/', num2str(numSamples), ' elements: ', sprintf('%1.2f', numAgreement/numSamples)])
disp(['Ensemble RMSE = ', num2str(gtdiffEnsemble)]);

%%
f = figure;
ax = axes(f);
imshow(rp,'Parent',ax)
ax.YDir = 'normal';
title(ax, 'Agreement between models')
saveas(f, 'test_aggreement.png')

f = figure;
ax = axes(f);
imshow(rpNotSelected,'Parent',ax)
ax.YDir = 'normal';
title(ax, 'Disagreement between models')
saveas(f, 'test_disaggreement.png')

f = figure;
ax = axes(f);
imshow(rpGt,'Parent',ax)
ax.YDir = 'normal';
title(ax, 'Ground truth')
saveas(f, 'test_gt.png')

f = figure;
DVPerrorVisualization(coorGtList, coorClsPredList)
title('classification based')
saveas(f, 'test_classif_error.png')

f = figure;
DVPerrorVisualization(coorGtList, coorRegPredList)
title('regression based')
saveas(f, 'test_regression_error.png')

f = figure;
DVPerrorVisualization(agreementCoorGtList, agreementCoorRegPredList)
title('Ensemble model compared to GT')
saveas(f, 'test_ensemble_vs_gt.png')
