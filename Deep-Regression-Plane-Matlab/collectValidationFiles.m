imgFolder = '/home/koosk/images-data/class41/regression_augmented/val/images/';
% searchFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/ACC_210912-HK-60x-live__2021-09-12T23_48_01-Measurement4/Labels/';
% searchFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210617-HelaKyoto-40x-live-frame-2__2021-06-17T15_46_18-Measurement1/Labels/';
% searchFolder = '/home/koosk/data/data/DRP/Zero_Padded/ACC_210617-HelaKyoto-40x-live__2021-06-17T12_08_49-Measurement1/Labels/';
searchFolder = '/home/koosk/data/data/DRP/Zero_Padded/20x-210424-HelaKyoto-TubGFP-H2BmCherry-live__2021-04-24T16_32_17-Measurement1_v2/Labels/';
targetFolder = '/home/koosk/images-data/class41/regression_augmented/val/labels/';

imgList = dir([imgFolder '*.jpg']);
searchList = dir([searchFolder '*.tif']);
searchFnames = {};
for i = 1:numel(searchList)
    [~, fname, ~] = fileparts(searchList(i).name);
    searchFnames{end+1} = fname;
end

for i = 1:numel(imgList)
    [~, fname, ~] = fileparts(imgList(i).name);
    if any(contains(searchFnames, fname))
        copyfile(fullfile(searchFolder, [fname, '.tif']), targetFolder)
    end
end