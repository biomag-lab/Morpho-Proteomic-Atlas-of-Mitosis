inFolder = '/home/koosk/data/images/DVP3/trainingSetExport_20220318/ACC_mitotic_150/Images';

outFolder = fullfile(inFolder, '..', 'ImagesJpg');
mkdir(outFolder);
imList = dir(inFolder);
for i = 3:numel(imList)
    [~, fname, ext] = fileparts(imList(i).name);
    img = imread(fullfile(imList(i).folder, imList(i).name));
    img = double(img) ./ 255;
    imwrite(img, fullfile(outFolder, [fname, '.jpg']));
end
