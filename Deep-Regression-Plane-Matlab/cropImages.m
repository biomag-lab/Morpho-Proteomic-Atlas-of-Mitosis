folder = '/home/koosk/data/data/DRP/DRP_HeLa_trSet_1201db/split_05/images/trainAug/';
% cropRect = [17, 17, 66, 66];
cropRect = [26, 26, 50, 50];

fileList = dir(folder);
for j=3:numel(fileList)
    fileName = [folder fileList(j).name];
    inImg = imread(fileName);
    inImg = imcrop(inImg, cropRect);
    imwrite(inImg, fileName);
end
