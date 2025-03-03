%% params
% regressionModelPath = '/home/koosk/data/data/DRP/models/DRP_train_result_ws-27-Jan-2022_21_06_04_v39.mat';
% regressionModelPath = 'd:\dnn_models\DVP2\models\DRP_train_result_ws-21-Jan-2022_04_13_24_v38.mat';
regressionModelPath = '/storage01/grexai/dev/DVP2/models/DRP_train_result_ws-21-Jan-2022_04_13_24_v38.mat'

regression_model_input_size = [299, 299]; % img size reguired by the model
% classificationModelPath = '/home/koosk/data/data/DRP/models/DRP_train_result_ws-29-Jan-2022_03_49_52_classif_v4_resnet50.mat';
% classificationModelPath = 'd:\dnn_models\DVP2\models\DRP_train_result_ws-21-Jan-2022_18_59_36_classif_v3_resnet50.mat';
classificationModelPath = '/storage01/grexai/dev/DVP2/models/DRP_train_result_ws-21-Jan-2022_18_59_36_classif_v3_resnet50.mat'

classification_model_input_size = [224, 224]; % img size reguired by the model
% acc_folder = '/home/koosk/data/data/DRP/211130-screen-all-wo-junk/';
% acc_folder = '/home/koosk/data/data/DRP/211130-wojunk-newrelabel/';
% acc_folder = '/home/koosk/data/data/DRP/screens/Screen18/';
outFolder = fullfile(acc_folder, 'predictions4BIAS_bulk');
saveAgreedPredictionImages = false;
filterAgreedImagesDir = fullfile(acc_folder, 'filteredAgreement');
allowedClassDiff = 3;
minimumRadius = 3500;
switchRBChannels = true;


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
mkdir(fullfile(outFolder))

mkdir(fullfile(filterAgreedImagesDir ,'interphase'))
for j = 1:40
    mkdir(fullfile(filterAgreedImagesDir, num2str(j)))
end

classHeader = {'id','PREDICTED CLASS ID'};
for i = 1:numel(cats)
    classHeader{end+1} = ['CLASS ', num2str(i),' ', sprintf('#%06s', dec2hex(i*10000)), ' mitotic-', char(cats(i))];
end

for img_idx = 1:numel(image_files)
    disp(['Processing image ', num2str(img_idx), '/', num2str(numel(image_files))])
    file = image_files(img_idx);
    if strcmp(file.name, '.') || strcmp(file.name, '..')
        continue
    end
    
    image = imread(fullfile(an3_folder, file.name));
    if switchRBChannels
        image = cat(3, image(:,:,3), image(:,:,2), image(:,:,1));
    end
    [sy, sx, ~] = size(image);
    [~, fname, ext] = fileparts(file.name);
    features = readmatrix(fullfile(an2_folder, [fname, '.txt']), 'Delimiter', ' ');
    idxMap = readmatrix(fullfile(extra_folder, [fname, '.txt']), 'Delimiter', ' ');
    num_cells = size(features, 1);
    crops = zeros(bigger_input_size(1), bigger_input_size(2),3, size(features,1), 'uint8');
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
    [preds, predsRegCls, predsRegIdx] = predict_ensemble(regressionModel, classificationModel, crops, allowedClassDiff, classification_model_input_size);
    [thetaList, radiusList] = regplaneToPolar(preds(:,1), preds(:,2));
    radiusFilter = radiusList>minimumRadius;
    agreementFilter = ~isnan(preds(:,1));
    
    idxListBool = radiusFilter & agreementFilter;
    outFpath = fullfile(outFolder, [fname, '.csv']);
    objectIds = idxMap(idxListBool);
    classIdArray = arrayfun(@char, predsRegCls(idxListBool), 'UniformOutput', false);
    radiusArray = zeros(nnz(idxListBool), numel(cats));
    radiusListFiltered = radiusList(idxListBool);
    predsRegIdxFiltered = predsRegIdx(idxListBool);
    for i = 1:size(radiusArray, 1)
        classIdx = predsRegIdxFiltered(i);
        radius = radiusListFiltered(i);
        confidence = min(1, radius./5000);
        radiusArray(i, classIdx) = confidence;
    end
    biasData = table(objectIds, predsRegIdxFiltered);
    for i = 1:numel(cats)
        biasData.(['Var', num2str(i)]) = radiusArray(:,i);
    end
    biasData.Properties.VariableNames = classHeader;
    writetable(biasData, outFpath);
    
    if saveAgreedPredictionImages
        for i = 1:size(preds,1)
            if idxListBool(i)
                crop = crops(:,:,:,i);
                classFolder = char(predsRegCls(i));
                objId = idxMap(i);
                pred = preds(i, :);
                imwrite(crop, fullfile(filterAgreedImagesDir, classFolder, ...
                    sprintf('%s-objId-%d-regCoord-%.0f-%.0f_regClass-%s.jpg', fname, objId, pred, classFolder)));
            end
        end
    end
end


function [preds, predsRegCls, predsRegIdx] = predict_ensemble(regressionModel, classificationModel, crops, allowedClassDiff, classification_model_input_size)
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

