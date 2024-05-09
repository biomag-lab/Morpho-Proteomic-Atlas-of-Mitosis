% convert files to classification format
% input folder should contain 'images' and 'labels' folders

% inFolder = '/home/koosk/images-data/2022_v1_zeroPadded_split/test';
% inFolder = '/home/koosk/images-data/2022_v1_zeroPadded_split/val';
% inFolder = '/home/koosk/images-data/2022_v1_zeroPadded_split/trainBalAug_v2_2';
% inFolder = '/home/koosk/images-data/2022_v1_zeroPadded_split_w20X/test';
% inFolder = '/home/koosk/images-data/2022_v1_zeroPadded_split_w20X/val';
inFolder = '/home/koosk/images-data/2022_v1_zeroPadded_split_w20X/trainBalAug_v2_2';

inImgFolder = fullfile(inFolder, 'images');
inLabelFolder = fullfile(inFolder, 'labels');
outFolder = fullfile(inFolder, 'classification');

numOutClasses = 40;
interphaseClassname = 'interphase';
% create classes/folders
mkdir(outFolder);
for i=1:numOutClasses
    mkdir(fullfile(outFolder, num2str(i)));
end
mkdir(fullfile(outFolder, interphaseClassname));

fileList = dir([inImgFolder filesep '*.jpg']);
for i=1:numel(fileList)
    disp(i);
    
    file = fileList(i);
    inImgPath = fullfile(inImgFolder, file.name);
    [~, basename, ~] = fileparts(file.name);
    regplaneCoord = double(imread(fullfile(inLabelFolder, [basename, '.tif'])));
    cls = regressionToClass(regplaneCoord);
    copyfile(inImgPath, fullfile(outFolder, char(cls), file.name));
end


