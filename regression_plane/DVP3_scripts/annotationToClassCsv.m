trSetFolder = '/home/koosk/data/images/DVP3/trainingSetExport_20220318/ACC_mitotic_150';
outFile = '/home/koosk/data/images/DVP3/trainingSetExport_20220318/ACC_mitotic_150/regression_to_class.csv';
filterRadiusLessThan = 3000;

labelExt = '.tif';
imFolder = fullfile(trSetFolder, 'Images');
lbFolder = fullfile(trSetFolder, 'Labels');
imList = dir(imFolder);
[~, ~, ext] = fileparts(imList(3).name);
imList = dir(fullfile(imFolder,['*',ext]));
lbList = dir(fullfile(lbFolder,['*',labelExt]));
numImg = numel(imList);

phases = zeros(numImg,1);
for i = 1:numImg
    coord = imread(fullfile(lbList(i).folder, lbList(i).name));
    [theta, radius] = regplaneToPolar(coord(1), coord(2));
    phase = [];
    if radius < filterRadiusLessThan
        phase = 0;
    elseif theta < 15 || theta >= 345
        phase = 1;
    elseif theta < 90
        phase = 2;
    elseif theta < 180
        phase = 3;
    elseif theta < 225
        phase = 4;
    elseif theta < 270
        phase = 5;
    elseif theta < 345
        phase = 6;
    end
    phases(i) = phase;
end

t = table({imList.name}', phases, 'VariableNames', {'filename', 'mitotic_class_idx'});
writetable(t, outFile);
