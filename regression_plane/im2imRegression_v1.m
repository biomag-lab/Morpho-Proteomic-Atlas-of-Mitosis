% Im2Im regression v1: attempt to use center crops

transferLearn = 0;
% modelName = 'c:\receive\projects\projects\BRC\projects\RegressionPaper\training\DeepRP_test\resnet50_reg.mat';
modelName = '/home/koosk/work/projects/DRP/mod_rn50_drp_in.mat';

preTrained = true;
if preTrained
    net = resnet50;
    lgraph = layerGraph(net);
    
    drp = dropoutLayer(0.2,"Name","drop_out");
    FcOut_1 = fullyConnectedLayer(10,"Name","FcOut_1");
    FcOut_2 = fullyConnectedLayer(2,"Name","FcOut_2");
    out = regressionLayer("Name", "Regression_out");
    
    lgraph = replaceLayer(lgraph,"avg_pool",drp);
    lgraph = replaceLayer(lgraph,"fc1000",FcOut_1);
    lgraph = replaceLayer(lgraph,"fc1000_softmax",FcOut_2);
    lgraph = replaceLayer(lgraph,"ClassificationLayer_fc1000",out);
    
else % Build a brand new back-bone
    resNet18_regressionBackbone_fc2
end

imdsTrain = imageDatastore('/storage01/koosk/DRP/DRP_HeLa_trSet_1201db/split/images/trainAug/','IncludeSubfolders',true);
labelsTrain = imageDatastore('/storage01/koosk/DRP/DRP_HeLa_trSet_1201db/split/labels/trainAug/','IncludeSubfolders',true);
imdsVal = imageDatastore('/storage01/koosk/DRP/DRP_HeLa_trSet_1201db/split/images/val/','IncludeSubfolders',true);
labelVal = imageDatastore('/storage01/koosk/DRP/DRP_HeLa_trSet_1201db/split/labels/val/','IncludeSubfolders',true);
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

cropRect = [17, 17, 66, 66];
augImdsTrain = transform(augImdsTrain,@(x) imcrop(x, cropRect ));
augImdsVal = transform(augImdsVal,@(x) imresize(x, cropRect));

augImdsTrain.MiniBatchSize = 1;
augImdsVal.MiniBatchSize = 1;
combinedTrainDs = combine(augImdsTrain,labelsTrain);
combinedValDs = combine(augImdsVal,labelVal);

imdsTest = imageDatastore('/storage01/koosk/DRP/DRP_HeLa_trSet_1201db/split/images/test','IncludeSubfolders',true);
augImdsTest = augmentedImageDatastore([224,224,3],imdsTest);

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

predResult = predict(net,augImdsTest);
figure, scatter(predResult(:,1),predResult(:,2))
title 'Predicted test result'

save(['DRP_train_result_ws-', datestr(now)])
