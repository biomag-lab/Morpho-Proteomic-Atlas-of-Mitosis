folder = '/home/koosk/data/data/DRP/pad-test/images';


imList = dir(folder);
resizeCounter = 0;
for i = 3:numel(imList)
    imgPath = imList(i);
    imgFullpath = fullfile(imgPath.folder, imgPath.name);
    img = imread(imgFullpath);
    s = size(img);
    if s(1) < s(2)
        disp(['Resizing: ', imgPath.name])
        resizeCounter = resizeCounter + 1;
        img = padarray(img, [ floor((s(2)-s(1))/2), 0]);
        s2 = size(img);
        if s2(1) < s2(2)
            img = padarray(img, [1,0], 0, 'pre');
        end
    elseif s(2) < s(1)
        disp(['Resizing: ', imgPath.name])
        resizeCounter = resizeCounter + 1;
        img = padarray(img, [0, floor((s(1)-s(2))/2)], 0);
        s2 = size(img);
        if s2(2) < s2(1)
            img = padarray(img, [0,1], 0, 'pre');
        end
    end
    imwrite(img, imgFullpath);
end
disp(['NUMBER OF RESIZED IMAGES =', num2str(resizeCounter)])