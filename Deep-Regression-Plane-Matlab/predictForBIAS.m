%% params
% regressionModelPath = '/home/koosk/data/data/DRP/models/DRP_train_result_ws-27-Jan-2022_21_06_04_v39.mat';
regressionModelPath = '/home/koosk/data/data/DRP/models/DRP_train_result_ws-21-Jan-2022_04_13_24_v38.mat';
regression_model_input_size = [299, 299]; % img size reguired by the model
% classificationModelPath = '/home/koosk/data/data/DRP/models/DRP_train_result_ws-29-Jan-2022_03_49_52_classif_v4_resnet50.mat';
classificationModelPath = '/home/koosk/data/data/DRP/models/DRP_train_result_ws-21-Jan-2022_18_59_36_classif_v3_resnet50.mat';
classification_model_input_size = [224, 224]; % img size reguired by the model
% acc_folder = '/home/koosk/data/data/DRP/211130-screen-all-wo-junk/';
acc_folder = '/home/koosk/data/data/DRP/211130-wojunk-newrelabel/';
outFolder = fullfile(acc_folder, 'predictions4BIAS');
allowedClassDiff = 3;
minimumRadius = 3500;
saveAgreedPredictionImages = true;


%% real stuff
an2_folder = fullfile(acc_folder, 'anal2');
an3_folder = fullfile(acc_folder, 'anal3');
extra_folder = fullfile(acc_folder, 'extra');
cats = categorical(['interphase'; string((1:40)')]);

regressionModel = load(regressionModelPath, 'net');
regressionModel = regressionModel.net;
classificationModel = load(classificationModelPath, 'net');
classificationModel = classificationModel.net;
if an3_folder(end) ~= filesep
    an3_folder = [an3_folder, filesep];
end
image_files = dir(an3_folder);

PlateName = {};
Row = {};
Col = {};
ImageName = {};
ImageNumber = [];
ObjectNumber = [];
regPosX = [];
regPosY = [];
bigger_input_size = regression_model_input_size;
if classification_model_input_size(1) > bigger_input_size(1)
    bigger_input_size = classification_model_input_size;
end
mkdir(fullfile(outFolder, 'interphase'))
for j = 1:40
    mkdir(fullfile(outFolder ,num2str(j)))
end
% filterAgreedImagesDir = './data/filteredAgreement/';
% filterFailedImagesDir = './data/filtered/';
% outDirs = {filterAgreedImagesDir; filterFailedImagesDir};
% for i = 1:2
%     outDir = outDirs{i};
%     mkdir([outDir ,'interphase'])
%     for j = 1:40
%         mkdir([outDir ,num2str(j)])
%     end
% end

for img_idx = 1:numel(image_files)
    file = image_files(img_idx);
    if strcmp(file.name, '.') || strcmp(file.name, '..')
        continue
    end
    
    image = imread(fullfile(an3_folder, file.name));
    [sy, sx, ~] = size(image);
    [~, fname, ext] = fileparts(file.name);
    features = readmatrix(fullfile(an2_folder, [fname, '.txt']), 'Delimiter', ' ');
    idxMap = readmatrix(fullfile(extra_folder, [fname, '.txt']), 'Delimiter', ' ');
    num_cells = size(features, 1);
    crops = zeros(bigger_input_size(1), bigger_input_size(2),3, size(features,1));
    for cell_idx = 1:num_cells
        cx = features(cell_idx, 1);
        cy = features(cell_idx, 2);
        ul = [cy, cx] - floor(bigger_input_size/2);
        br = [cy, cx] + floor(bigger_input_size/2);
        ul_ = max(ul, 1);
        br_ = min(br, [sy, sx]);
        crop = imcrop(image, [ul_(2), ul_(1), br_(2)-ul_(2), br_(1)-ul_(1)]);
        if ul(1) < 1
            crop = padarray(crop, [1-ul(1), 0], 'pre');
        end
        if ul(2) < 1
            crop = padarray(crop, [0, 1-ul(2)], 'pre');
        end
        if br(1) > sy
            crop = padarray(crop, [br(1)-sy, 0], 'post');
        end
        if br(2) > sx
            crop = padarray(crop, [0, br(2)-sx], 'post');
        end
        
        crops(:,:,:,cell_idx) = crop;
    end
    [preds, predsRegCls] = predict_ensemble(regressionModel, classificationModel, crops, allowedClassDiff, classification_model_input_size);
    [thetaList, radiusList] = regplaneToPolar(preds(:,1), preds(:,2));
    radiusFilter = radiusList>minimumRadius;
    agreementFilter = ~isnan(preds(:,1));
    
    for catIdx = 1:numel(cats)
        cat = cats(catIdx);
        idxListBool = predsRegCls == cat & radiusFilter & agreementFilter;
        if ~any(idxListBool)
            continue
        end
%         objectIds = find(idxListBool);
        objectIds = idxMap(idxListBool);
%         classIdArray = repmat({char(cat)}, nnz(idxListBool), 1);
        classIdArray = ones(nnz(idxListBool), 1);
        radiusArray = round(radiusList(idxListBool));
        outFpath = fullfile(outFolder, char(cat), [fname, '.csv']);
        biasData = table(objectIds, classIdArray, radiusArray);
        biasData.Properties.VariableNames = {'id','PREDICTED CLASS ID','CLASS 1 #d5ff00 Cluster_1'};
        writetable(biasData, outFpath);
        
%         if saveAgreedPredictionImages
%             [theta, radius] = regplaneToPolar(regPred(1), regPred(2));
%             if radius >= radiusFilter
%                 classFolder = char(regClass);
%                 [~, basename, ~] = fileparts(info.Filename);
%                 imwrite(im, [filterAgreedImagesDir, classFolder, filesep, ...
%                         sprintf('%s-regCoord-%.0f-%.0f_regClass-%s.jpg', ...
%                         basename, regPred, regClass)]);
%             end
%         end
    end
end


function [preds, predsRegCls] = predict_ensemble(regressionModel, classificationModel, crops, allowedClassDiff, classification_model_input_size)
cats = categorical(['interphase'; string((1:40)')]);

predsReg = predict(regressionModel, crops);
predsRegCls = arrayfun(@(rowidx) regressionToClass(predsReg(rowidx, :)), 1:size(predsReg,1))';
crops4cls = imresize(crops, classification_model_input_size);
predsCls = classificationModel.classify(crops4cls);
predsRegIdx = arrayfun(@(idx) find(predsRegCls(idx) == cats), 1:size(predsReg,1))';
predsClsIdx = arrayfun(@(idx) find(predsCls(idx) == cats), 1:size(predsCls,1))';

diff = abs(predsClsIdx - predsRegIdx);
diff(diff > 20) = abs(diff(diff > 20) - 41);
agreementIdx = diff <= allowedClassDiff;
preds = predsReg;
preds(~agreementIdx, :) = NaN;

end

