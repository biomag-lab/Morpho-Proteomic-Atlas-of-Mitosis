function [mostFreqRGB_col, idx] = findMostFrequentColor(im,bitRate)

hsvIm = rgb2hsv(im);

ch1 = hsvIm(:,:,1);
ch2 = hsvIm(:,:,2);
ch3 = hsvIm(:,:,3);

modeColor = mode(ch1,'all');

idx = (hsvIm(:,:,1)<modeColor*1.05) & (hsvIm(:,:,1)>modeColor*0.95);

medianSatration = median(ch2(idx),'all');
medianValue =  median(ch3(idx),'all');

if isnan(medianSatration)
    medianSatration = 0;
end

if isnan(medianValue)
    medianValue = 0;
end

mostFreqRGB_col = hsv2rgb(cat(3,modeColor,medianSatration,medianValue));
