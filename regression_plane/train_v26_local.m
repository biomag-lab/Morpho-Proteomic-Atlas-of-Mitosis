% Im2Im regression, cropped images
% starting from Flora_20x_n2009_v9, 
% v1: inceptionv3, d5, blur incl, adam; result val RMSE = 1150, train RMSE = 500
% v2: resnet50; ; result val RMSE = 1300, train RMSE = 300
% v3: mixed 20x and 40x datasets, reverted to v1; result val RMSE = 1107, train RMSE = ~522
% v4: 40x frame1 and frame2; result val RMSE = 1170, train RMSE = 500
% v5: 40x frame1 and frame2 padded; result val RMSE = 2000, train RMSE = 1500
% v6: 40x 16 bit frame1 and 2 correctly padded; result val RMSE = 1470, train RMSE = 800
% v7: googlenet; result val RMSE = 1405, train RMSE = 1300
% v8: resnet18; result val RMSE = 1600, train RMSE = 900
% v9: v7 with different LR params; result val RMSE = 1380, train RMSE = 600
% v10: v8 with different LR params; result val RMSE = 1560, train RMSE = 550
% v11: starting from v6, correctly zero padded; result val RMSE = 1300, train RMSE = 900
% v12: zero pad, 0.75 crop; result val RMSE = 1380, train RMSE = 870
% v13: v11 ds, 1D regression on theta; result val RMSE = 25.02, train RMSE = 14.14
% v14: v12, mirror padded 40x; result val RMSE = 1400, train RMSE = 900
% v15: mod LR, mirror padded mixed; result val RMSE = 1272, train RMSE = 602
% v16: zero padded mixed; result val RMSE = 1228, train RMSE = 544
% v17: zero pad, 60x only; result val RMSE = 1543, train RMSE = 419
% v18; zp balanced mixed; result val RMSE = 1503, train RMSE = 605
% v19; zp mixed, 60x mult 6; result val RMSE = 1193, train RMSE = 449
% v20; fixed 19's dataset; result val RMSE = 1264, train RMSE = 415
% v21; preprocessed dataset (normalize+histeq), changed aug params in this
% script; result val RMSE =, train RMSE = 
% v26: using augmentations script from classification pipeline; result val RMSE = 1416, train RMSE = 

transferLearn = 0;
% modelName = '/home/koosk/data/data/DRP/resnet50_reg_flora.mat';

preTrained = true;
if preTrained
    %load('/storage01/koosk/DRP/mod2_rn50_drp_in.mat');
% 	net = inceptionv3;
% 	lgraph = layerGraph(net);
%     
%     drp = dropoutLayer(0.2,"Name","drop_out");
%     FcOut_1 = fullyConnectedLayer(10,"Name","FcOut_1");
%     FcOut_2 = fullyConnectedLayer(2,"Name","FcOut_2");
%     out = regressionLayer("Name", "Regression_out");
%     
%     lgraph = replaceLayer(lgraph,"avg_pool",drp);
%     lgraph = replaceLayer(lgraph,"predictions",FcOut_1);
%     lgraph = replaceLayer(lgraph,"predictions_softmax",FcOut_2);
%     lgraph = replaceLayer(lgraph,"ClassificationLayer_predictions",out);
    
    net = googlenet;
    lgraph = layerGraph(net);
    
    FcOut_1 = fullyConnectedLayer(10,"Name","FcOut_1");
    FcOut_2 = fullyConnectedLayer(2,"Name","FcOut_2");
    out = regressionLayer("Name", "Regression_out");
    
    lgraph = replaceLayer(lgraph,"loss3-classifier",FcOut_1);
    lgraph = replaceLayer(lgraph,"prob",FcOut_2);
    lgraph = replaceLayer(lgraph,"output",out);
else % Build a brand new back-bone
    resNet18_regressionBackbone_fc2
end

imdsTrain = imageDatastore('/home/koosk/images-data/class41/regression_augmented/train/images/','IncludeSubfolders',true);
labelsTrain = imageDatastore('/home/koosk/images-data/class41/regression_augmented/train/labels/','IncludeSubfolders',true);
imdsVal = imageDatastore('/home/koosk/images-data/class41/regression_augmented/val/images/','IncludeSubfolders',true);
labelVal = imageDatastore('/home/koosk/images-data/class41/regression_augmented/val/labels/','IncludeSubfolders',true);             

% aug = imageDataAugmenter(   "RandXReflection",true,...
%                             "RandYReflection",true,...
%                             "RandRotation",[-90, 90],...
%                             "RandScale", [0.9, 1.1],...
%                             "RandXTranslation", [-3, 3],...
%                             "RandYTranslation", [-3, 3]);
pixelRange = [-10 10];
scaleRange = [0.8 1.2];
rotationRange = [0 360];
aug= imageDataAugmenter( ...
    'RandXReflection',true, ...
    'RandYReflection',true, ...
    'RandRotation', rotationRange, ...
    'RandXTranslation',pixelRange, ...
    'RandYTranslation',pixelRange, ...
    'RandXScale',scaleRange, ...
    'RandYScale',scaleRange);

augImdsTrain = augmentedImageDatastore([224,224,3],imdsTrain , "DataAugmentation", aug);
augImdsVal = augmentedImageDatastore([224,224,3],imdsVal);
% augImdsTrain = augmentedImageDatastore([299,299,3],imdsTrain , "DataAugmentation", aug);
% augImdsVal = augmentedImageDatastore([299,299,3],imdsVal);

augImdsTrain.MiniBatchSize = 1;
augImdsVal.MiniBatchSize = 1;
augImdsTrain = transform(augImdsTrain,@customAugmentationPipeline,'IncludeInfo',false);

% augImdsTrain.MiniBatchSize = 1;
% augImdsVal.MiniBatchSize = 1;
combinedTrainDs = combine(augImdsTrain,labelsTrain);
combinedValDs = combine(augImdsVal,labelVal);

% imdsTest = imageDatastore('/storage01/koosk/DRP/Flora_20x_n2009/split/test/images','IncludeSubfolders',true);
% augImdsTest = augmentedImageDatastore([299,299,3],imdsTest);

trainCoor = labelsTrain.readall;
trainCoor2plot = cell2mat(trainCoor);
figure, scatter(trainCoor2plot(:,1),trainCoor2plot(:,2));
title 'Train coordinates'



if transferLearn == 1
    load(modelName);
    if isa(net,'SeriesNetwork') 
      lgraph = layerGraph(net.Layers); 
    else
    lgraph = layerGraph(net);
    end 
end




miniBatchSize  = 64;
options = trainingOptions('adam', ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs', 9, ... % 2000, ...
    'InitialLearnRate',10^-4, ... % 0.0000001, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.1, ...
    'LearnRateDropPeriod', 3, ...% 300, ...
    'Shuffle','every-epoch', ...
    'ValidationData',combinedValDs, ...
    'ValidationFrequency', 500, ...
    'ExecutionEnvironment','gpu',...
    'Plots','training-progress', ...
    'VerboseFrequency', 300,...
    'Verbose',true);

net = trainNetwork(combinedTrainDs,lgraph,options);

% predResult = predict(net,augImdsTest);
% figure, scatter(predResult(:,1),predResult(:,2))
% title 'Predicted test result'

save(['DRP_train_result_ws-', datestr(now)])


function [dataOut] = customAugmentationPipeline(dataIn)
dataOut = cell([size(dataIn,1),1]);
for idx = 1:size(dataIn,1)
    temp = dataIn{idx,1}{1};
    temp = addNoise(temp, 10^-4);
    
%     % Add randomized Gaussian blur
%     temp = imgaussfilt(temp,1.5*rand);
    
    % Form second column expected by trainNetwork which is the expected response,
    % the categorical label in this case
    dataOut(idx,1) = {temp};
end

end
