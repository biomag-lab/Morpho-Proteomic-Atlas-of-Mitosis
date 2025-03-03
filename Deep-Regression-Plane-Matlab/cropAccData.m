% Crop small images for DVP evaluation from full size images in ACC format
% 
% anal2/featureNames.acc - Contains exported feature names. First 2 is
% assumed to be centroid x and y
%
% anal2/<fname>.txt - features of image with matchin name
% anal3/<fname> - raw image files
%
% output: crop/ crops of images
% Crops at edge should be filled with 0s.

cropSize = [299, 299];
% accFolder = '/home/koosk/data/data/DRP/DVP2-class/Ana/ACC-export';
% accFolder = '/home/koosk/data/data/DRP/DVP2-class/Inter/ACC-export';
% accFolder = '/home/koosk/data/data/DRP/DVP2-class/Meta/ACC-export';
% accFolder = '/home/koosk/data/data/DRP/DVP2-class/PM/ACC-export';
% accFolder = '/home/koosk/data/data/DRP/DVP2-class/Pro/ACC-export';
% accFolder = '/home/koosk/data/data/DRP/DVP2-class/Telo/ACC-export';
% accFolder = '/home/koosk/data/data/DRP/211130-screen-all/BIAS-naming';
accFolder = '/home/koosk/data/data/DRP/211130-screen-all-wo-junk';

%%
outputFolder = fullfile(accFolder, 'cropRaw');
mkdir(outputFolder);
fileList = dir([accFolder, filesep, 'anal3', filesep, '*.tif']);

for i = 1:numel(fileList)
    file = fileList(i);
    [~, basename, ext] = fileparts(file.name);
    img = imread(fullfile(file.folder, file.name));
    [sy, sx, ~] = size(img);
    features = readmatrix(fullfile(accFolder, 'anal2', [basename, '.txt']), 'Delimiter', ' ');
    for featIdx = 1:size(features,1)
        cx = features(featIdx, 1);
        cy = features(featIdx, 2);
        ul = [cy, cx] - floor(cropSize/2);
        br = [cy, cx] + floor(cropSize/2);
        ul_ = max(ul, 1);
        br_ = min(br, [sy, sx]);
        crop = imcrop(img, [ul_(2), ul_(1), br_(2)-ul_(2), br_(1)-ul_(1)]);
        if ul(1) < 1
            crop = padarray(crop, [1-ul(1), 0], 'pre');
        end
        if ul(2) < 1
            crop = padarray(crop, [0, 1-ul(2)], 'pre');
        end
        if br(1) > sy
            crop = padarray(crop, [br(1)-sy, 0], 'post');
        end
        if br(2) > sx
            crop = padarray(crop, [0, br(2)-sx], 'post');
        end
        assert(all(cropSize == size(crop, [1,2])), 'crop size error')
        imwrite(crop, fullfile(outputFolder, [basename, '-crop', num2str(featIdx), '.tif']));
    end
end
