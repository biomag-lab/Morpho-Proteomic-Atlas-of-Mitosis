regressionData = load('/home/koosk/work/projects/DRP/data/DRP_train_result_ws-19-Mar-2022_01_25_47_dvp3_train1.mat');

imdsTest = imageDatastore('/home/koosk/images-data/dvp3_220318/test/images/');
labelTest = imageDatastore('/home/koosk/images-data/dvp3_220318/test/labels/');

augImdsTest = augmentedImageDatastore([299,299,3], imdsTest);
augImdsTest.MiniBatchSize = 32;

regressionNet = regressionData.net;
y = regressionNet.predict(augImdsTest);

yhat_ = labelTest.readall;
yhat = zeros(numel(yhat_), 2);
for i = 1:numel(yhat_)
    yhat(i,:) = yhat_{i};
end
%%
regError = sqrt(sum((yhat - double(y)).^2,2));
regRMSE = sqrt(mean(regError.^2)); % RMSE
disp('------------------------------------------------')
disp(['Regression model RMSE = ', num2str(regRMSE)]);
disp('')

f = figure;
DVPerrorVisualization(yhat, y)
title('regression based')
