
% v38: inceptionv3 on updated '2022_v1_zeroPadded_split' dataset (with test set); result val RMSE = 1265, train RMSE = 355

transferLearn = 0;


preTrained = true;
if preTrained
    net = inceptionv3;
	lgraph = layerGraph(net);
    
    drp = dropoutLayer(0.2,"Name","drop_out");
    FcOut_1 = fullyConnectedLayer(10,"Name","FcOut_1");
    FcOut_2 = fullyConnectedLayer(2,"Name","FcOut_2");
    out = regressionLayer("Name", "Regression_out");
    
    lgraph = replaceLayer(lgraph,"avg_pool",drp);
    lgraph = replaceLayer(lgraph,"predictions",FcOut_1);
    lgraph = replaceLayer(lgraph,"predictions_softmax",FcOut_2);
    lgraph = replaceLayer(lgraph,"ClassificationLayer_predictions",out);
    
else % Build a brand new back-bone
    resNet18_regressionBackbone_fc2
end

imdsTrain = imageDatastore('/storage01/koosk/DRP/2022_v1_zeroPadded_split_with_test/trainBalAug_v2_2/images/','IncludeSubfolders',true);
labelsTrain = imageDatastore('/storage01/koosk/DRP/2022_v1_zeroPadded_split_with_test/trainBalAug_v2_2/labels/','IncludeSubfolders',true);
imdsVal = imageDatastore('/storage01/koosk/DRP/2022_v1_zeroPadded_split_with_test/val/images/','IncludeSubfolders',true);
labelVal = imageDatastore('/storage01/koosk/DRP/2022_v1_zeroPadded_split_with_test/val/labels/','IncludeSubfolders',true);             

aug = imageDataAugmenter(   "RandXReflection",true,...
                            "RandYReflection",true,...
                            "RandRotation",[-90, 90],...
                            "RandScale", [0.9, 1.1],...
                            "RandXTranslation", [-3, 3],...
                            "RandYTranslation", [-3, 3]);

augImdsTrain = augmentedImageDatastore([299,299,3],imdsTrain , "DataAugmentation", aug);
augImdsVal = augmentedImageDatastore([299,299,3],imdsVal);

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
    'MaxEpochs', 5, ... % 2000, ...
    'InitialLearnRate',10^-4, ... % 0.0000001, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.1, ...
    'LearnRateDropPeriod', 5, ...% 300, ...
    'Shuffle','every-epoch', ...
    'ValidationData',combinedValDs, ...
    'ValidationFrequency', 100, ...
    'ExecutionEnvironment','multi-gpu',...
    'Plots','training-progress', ...
    'VerboseFrequency', 20,...
    'Verbose',true, ...
    'CheckpointPath', './checkpoint/' ...
    );

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
