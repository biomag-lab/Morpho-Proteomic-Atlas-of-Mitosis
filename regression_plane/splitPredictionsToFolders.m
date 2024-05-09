%% split predictions into folders

imdsVal = imageDatastore('/home/koosk/data/data/DRP/211130-screen-all/BIAS-naming/cropRaw');
augImdsVal = augmentedImageDatastore([299,299,3],imdsVal);
augImdsVal.MiniBatchSize = 1;
allowedClassDiff = 3;
radiusFilter = 3500;

%%
outputFolder = './data/filteredAgreement/';
data = load('./data/211130-screen-all-result-ws/211130-screen-all-result-ws.mat');
classDiffList = data.classDiffList;
coorRegPredList = data.coorRegPredList;
interphaseClassname = 'interphase';
% create classes
mkdir(outputFolder);
for i=1:40
    mkdir([outputFolder num2str(i)]);
end
mkdir([outputFolder interphaseClassname]);

index = 0;
while imdsVal.hasdata()
    index = index + 1;
    if classDiffList(index) > allowedClassDiff
        continue
    end
    im = read(imdsVal);
    coord = coorRegPredList(index, :);
    [theta, radius] = regplaneToPolar(coord(1), coord(2));
    if radius >= radiusFilter
        regClass = regressionToClass(coord);
        classFolder = char(regClass);
        [~, basename, ~] = fileparts(imdsVal.Files{index});
        imwrite(im, [outputFolder, classFolder, filesep, ...
                sprintf('%s-regCoord-%.0f-%.0f_regClass-%s.jpg', ...
                basename, regPred, regClass)]);
    end
end