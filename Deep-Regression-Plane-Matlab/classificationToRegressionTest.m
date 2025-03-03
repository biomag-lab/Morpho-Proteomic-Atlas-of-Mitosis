load('DRP_train_result_ws-02-Dec-2021_06_49_24-classif_class41.mat') % googlenet

%%
imdsVal = imageDatastore('/home/koosk/images-data/class41/regression_augmented/val/images/','IncludeSubfolders',true);
labelVal = imageDatastore('/home/koosk/images-data/class41/regression_augmented/val/labels/','IncludeSubfolders',true);
augImdsVal = augmentedImageDatastore([224,224,3],imdsVal);
augImdsVal.MiniBatchSize = 1;
combinedValDs = combine(augImdsVal,labelVal);

rp = uint8(zeros(10000,10000,3));
cats = categorical(['interphase'; string((1:40)')]);


sectorLength = (360-30)/40;
coorGtList = [];
coorPredList = [];
bigErrorCtr = 0;
index = 0;
while combinedValDs.hasdata()
    index = index + 1;
    data = read(combinedValDs);
    im = data{1,1}{1};
    coorGt = data{1,2};
    classPred = net.classify(im);
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
    coorPredList = [coorPredList; coorPred];
    
    dist = norm(double(coorGt)-coorPred);
    
    disp(['idx = ', num2str(index), ', dFix = ', num2str(dFix), ', classIdx = ', num2str(classIdx), ', classPred = ', char(classPred), ...
        ', coorGt = ', num2str(coorGt(1)), ', ', num2str(coorGt(2)), ', coorPred = ', num2str(round(coorPred(1))), ', ', num2str(round(coorPred(2))), ...
        ', norm = ', num2str(dist)])
    
    if dist > 5000
        bigErrorCtr = bigErrorCtr + 1;
    end
    
    [x, y, ch] = size(im);
    BB = getBB(coorPred,[y x]);
    im(:,:,1) = imadjust(im(:,:,1));
    im(:,:,2) = imadjust(im(:,:,2));
    rp(BB(3):BB(4),BB(1):BB(2), :) = im;
end

f = figure;
ax = axes(f);
imshow(rp,'Parent',ax)
ax.YDir = 'normal';

figure,
DVPerrorVisualization(coorGtList, coorPredList)
