inFolder = '/home/koosk/data/data/DRP/DRP_HeLa_trSet_1201db/split/images/val/';
outFolder = '/home/koosk/data/data/DRP/DRP_HeLa_trSet_1201db/split/images/valFisheye_100_75/';

%%
fileList = dir(inFolder);
addpath('fisheye_trafo')

for j=3:numel(fileList)
    fileName = [inFolder fileList(j).name];
    img = imread(fileName);
    img = convertFishEyeOptics(51, 51, img, 101, 100, 75);
    imwrite(img, [outFolder, fileList(j).name]);
end
