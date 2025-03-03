% Im2Im regression
% testing theta-only training

transferLearn = 0;
% modelName = 'c:\receive\projects\projects\BRC\projects\RegressionPaper\training\DeepRP_test\resnet50_reg.mat';
% modelName = '/home/koosk/data/data/DRP/resnet50_reg_flora.mat';

preTrained = true;
if preTrained
    net = resnet50;
%     model = load(modelName);
%     net = model.net;
    lgraph = layerGraph(net);
    
    drp = dropoutLayer(0.2,"Name","drop_out");
    FcOut_1 = fullyConnectedLayer(10,"Name","FcOut_1");
    FcOut_2 = fullyConnectedLayer(1,"Name","FcOut_2");
    out = regressionLayer("Name", "Regression_out");
    
    lgraph = replaceLayer(lgraph,"avg_pool",drp);
    lgraph = replaceLayer(lgraph,"fc1000",FcOut_1);
    lgraph = replaceLayer(lgraph,"fc1000_softmax",FcOut_2);
    lgraph = replaceLayer(lgraph,"ClassificationLayer_fc1000",out);
    
else % Build a brand new back-bone
    resNet18_regressionBackbone_fc2
end

% imdsTrain = imageDatastore('/home/koosk/data/data/DRP/DRP_HeLa_trSet_1201db/split/images/train/','IncludeSubfolders',true);
% labelsTrain = imageDatastore('/home/koosk/data/data/DRP/DRP_HeLa_trSet_1201db/split/labels/train/','IncludeSubfolders',true);
% imdsVal = imageDatastore('/home/koosk/data/data/DRP/DRP_HeLa_trSet_1201db/split/images/val/','IncludeSubfolders',true);
% labelVal = imageDatastore('/home/koosk/data/data/DRP/DRP_HeLa_trSet_1201db/split/labels/val/','IncludeSubfolders',true);

% mixed zero padded
% imdsTrain = imageDatastore('/home/koosk/data/data/DRP/Zero_Padded/mixed_zero_padded_20x_40x_60x/trainAug/images/','IncludeSubfolders',true);
% labelsTrain = imageDatastore('/home/koosk/data/data/DRP/Zero_Padded/mixed_zero_padded_20x_40x_60x/trainAug/labels/','IncludeSubfolders',true);
% imdsVal = imageDatastore('/home/koosk/data/data/DRP/Zero_Padded/mixed_zero_padded_20x_40x_60x/val/images/','IncludeSubfolders',true);
% labelVal = imageDatastore('/home/koosk/data/data/DRP/Zero_Padded/mixed_zero_padded_20x_40x_60x/val/labels/','IncludeSubfolders',true);

% 60x zero padded
% imdsTrain = imageDatastore('/home/koosk/data/data/DRP/Zero_Padded/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/split_traj/trainAug/images/','IncludeSubfolders',true);
% labelsTrain = imageDatastore('/home/koosk/data/data/DRP/Zero_Padded/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/split_traj/trainAug/labels/','IncludeSubfolders',true);
% imdsVal = imageDatastore('/home/koosk/data/data/DRP/Zero_Padded/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/split_traj/val/images/','IncludeSubfolders',true);
% labelVal = imageDatastore('/home/koosk/data/data/DRP/Zero_Padded/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/split_traj/val/labels/','IncludeSubfolders',true);

% % mixed mirror padded
% imdsTrain = imageDatastore('/home/koosk/data/data/DRP/mirrorPadded/mixed_mirrorPadded_20x_40x_60x/trainAug/images/','IncludeSubfolders',true);
% labelsTrain = imageDatastore('/home/koosk/data/data/DRP/mirrorPadded/mixed_mirrorPadded_20x_40x_60x/trainAug/labels/','IncludeSubfolders',true);
% imdsVal = imageDatastore('/home/koosk/data/data/DRP/mirrorPadded/mixed_mirrorPadded_20x_40x_60x/val/images/','IncludeSubfolders',true);
% labelVal = imageDatastore('/home/koosk/data/data/DRP/mirrorPadded/mixed_mirrorPadded_20x_40x_60x/val/labels/','IncludeSubfolders',true);

% sandbox
imdsTrain = imageDatastore('/home/koosk/data/data/DRP/Zero_Padded/mix_zp_balanced_20x_40x_60x/trainBalAug/images/','IncludeSubfolders',true);
labelsTrain = imageDatastore('/home/koosk/data/data/DRP/Zero_Padded/mix_zp_balanced_20x_40x_60x/trainBalAug/labels/','IncludeSubfolders',true);
imdsVal = imageDatastore('/home/koosk/data/data/DRP/Zero_Padded/mix_zp_balanced_20x_40x_60x/val/images/','IncludeSubfolders',true);
labelVal = imageDatastore('/home/koosk/data/data/DRP/Zero_Padded/mix_zp_balanced_20x_40x_60x/val/labels/','IncludeSubfolders',true);


% sandbox 2
% imdsTrain = imageDatastore('/home/koosk/data/data/DRP/Zero_Padded/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/split_traj/train/images/','IncludeSubfolders',true);
% labelsTrain = imageDatastore('/home/koosk/data/data/DRP/Zero_Padded/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/split_traj/train/labels/','IncludeSubfolders',true);
% imdsVal = imageDatastore('/home/koosk/data/data/DRP/Zero_Padded/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/split_traj/val/images/','IncludeSubfolders',true);
% labelVal = imageDatastore('/home/koosk/data/data/DRP/Zero_Padded/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/split_traj/val/labels/','IncludeSubfolders',true);

labelsTrain = transform(labelsTrain, @transformLabelsToTheta);
labelVal = transform(labelVal, @transformLabelsToTheta);

% % numFiles = numel(imds.Files);
% % shuffledIdx = randperm(numFiles);
% % 
% % trainIdx = shuffledIdx(1:round(0.8*numFiles));
% % valIdx = shuffledIdx(numel(trainIdx)+1:end);
% % 
% % imdsTrain = imageDatastore(imds.Files(trainIdx));
% % imdsVal = imageDatastore(imds.Files(valIdx));
% % 
% % labelsTrain = imageDatastore(labelDsTrain.Files(trainIdx));
% % labelVal = imageDatastore(labelDsTrain.Files(valIdx));

% customAugTrain = transform(imdsTrain, @addNoise);                        

aug = imageDataAugmenter(   "RandXReflection",true,...
                            "RandYReflection",true,...
                            "RandRotation",[-180, 180],...
                            "RandScale", [0.7, 1.5],...
                            "RandXShear", [0, 25],...
                            "RandYShear", [0, 25],...
                            "RandXTranslation", [-5, 5],...
                            "RandYTranslation", [-5, 5]);
                            


                        
augImdsTrain = augmentedImageDatastore([224,224,3],imdsTrain , "DataAugmentation", aug);
augImdsVal = augmentedImageDatastore([224,224,3],imdsVal);


augImdsTrain.MiniBatchSize = 1;
augImdsVal.MiniBatchSize = 1;
augImdsTrain = transform(augImdsTrain,@customAugmentationPipeline,'IncludeInfo',false);

% augImdsTrain.MiniBatchSize = 1;
% augImdsVal.MiniBatchSize = 1;
combinedTrainDs = combine(augImdsTrain,labelsTrain);
combinedValDs = combine(augImdsVal,labelVal);

% imdsTest = imageDatastore('/home/koosk/data/data/DRP/DRP_HeLa_trSet_1201db/split/images/test','IncludeSubfolders',true);
% augImdsTest = augmentedImageDatastore([224,224,3],imdsTest);
@
trainCoor = labelsTrain.readall;
% trainCoor2plot = cell2mat(trainCoor);
% figure, scatter(trainCoor2plot(:,1),trainCoor2plot(:,2));
figure, plot([trainCoor{:}], '.');
title 'Train coordinates'



if transferLearn == 1
    load(modelName);
    if isa(net,'SeriesNetwork') 
      lgraph = layerGraph(net.Layers); 
    else
    lgraph = layerGraph(net);
    end 
end




miniBatchSize  = 16;
options = trainingOptions('sgdm', ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs', 1000, ... % 2000, ...
    'InitialLearnRate',10^-7, ... % 0.0000001, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.33, ...
    'LearnRateDropPeriod', 250, ...% 300, ...
    'Shuffle','every-epoch', ...
    'ValidationData',combinedValDs, ...
    'ValidationFrequency', 50, ...
    'ExecutionEnvironment','gpu',...
    'Plots','training-progress', ...
    'VerboseFrequency', 10,...
    'Verbose',true);

net = trainNetwork(combinedTrainDs,lgraph,options);

% predResult = predict(net,augImdsTest);
% figure, scatter(predResult(:,1),predResult(:,2))
% title 'Predicted test result'

save(['DRP_train_result_ws-', datestr(now)])


function [dataOut] = customAugmentationPipeline(dataIn)

% dataOut = cell([size(dataIn,1),2]);
dataOut = cell([size(dataIn,1),1]);

for idx = 1:size(dataIn,1)
    temp = dataIn{idx,1}{1};
%     temp = dataIn(idx,1);
    
    % Add randomized Gaussian blur
    temp = imgaussfilt(temp,1.5*rand);
    
%     % Add salt and pepper noise
%     temp = imnoise(temp,'salt & pepper');
%     
%     % Add randomized rotation and scale
%     tform = randomAffine2d('Scale',[0.95,1.05],'Rotation',[-30 30]);
%     outputView = affineOutputView(size(temp),tform);
%     temp = imwarp(temp,tform,'OutputView',outputView);
    
    % Form second column expected by trainNetwork which is the expected response,
    % the categorical label in this case
    dataOut(idx,1) = {temp};
end

end

function theta = transformLabelsToTheta(x)
[theta, ~] = regplaneToPolar(x(1), x(2), 10000, true);
theta = {theta};
end