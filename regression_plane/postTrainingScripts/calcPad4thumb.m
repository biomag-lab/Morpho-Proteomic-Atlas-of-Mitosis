function crop = calcPad4thumb(cropY, cropX, im_sy, im_sx, padValue, crop)

if cropY(1) < 1
    paddedCrop(:,:,1) = padarray(crop(:,:,1), [1-cropY(1), 0],padValue(1), 'pre');
    paddedCrop(:,:,2) = padarray(crop(:,:,2), [1-cropY(1), 0],padValue(2), 'pre');
    paddedCrop(:,:,3) = padarray(crop(:,:,3), [1-cropY(1), 0],padValue(3), 'pre');
    crop = paddedCrop;
    paddedCrop = [];
end
if cropY(2) > im_sy
    paddedCrop(:,:,1) = padarray(crop(:,:,1), [(cropY(2)-im_sy), 0],padValue(1), 'post');
    paddedCrop(:,:,2) = padarray(crop(:,:,2), [(cropY(2)-im_sy), 0],padValue(2), 'post');
    paddedCrop(:,:,3) = padarray(crop(:,:,3), [(cropY(2)-im_sy), 0],padValue(3), 'post');
    crop = paddedCrop;
    paddedCrop = [];
end
if cropX(1) < 1
    paddedCrop(:,:,1) = padarray(crop(:,:,1), [0, 1-cropX(1)],padValue(1), 'pre');
    paddedCrop(:,:,2) = padarray(crop(:,:,2), [0, 1-cropX(1)],padValue(2), 'pre');
    paddedCrop(:,:,3) = padarray(crop(:,:,3), [0, 1-cropX(1)],padValue(3), 'pre');
    crop = paddedCrop;
    paddedCrop = [];
end
if cropX(2) > im_sx
    paddedCrop(:,:,1) = padarray(crop(:,:,1), [0, cropX(2)-im_sx],padValue(1), 'post');
    paddedCrop(:,:,2) = padarray(crop(:,:,2), [0, cropX(2)-im_sx],padValue(2), 'post');
    paddedCrop(:,:,3) = padarray(crop(:,:,3), [0, cropX(2)-im_sx],padValue(3), 'post');
    crop = paddedCrop;
    paddedCrop = [];
end