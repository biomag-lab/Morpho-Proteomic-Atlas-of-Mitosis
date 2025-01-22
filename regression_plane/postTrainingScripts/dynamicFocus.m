function newIm = dynamicFocus(imgPath,imNames,dilateImage,doBlure)


numImage = numel(imNames);

% Parameters
discSize=20; %Size of dilation disc in pixels
se = strel('disk',discSize);
convFilter = ones(3)/9;
blurSize = 10;

%Load images
ImageArray=cell(1,numImage);
for i=1:numImage
    disp(['Loading Image ',num2str(i),'/',num2str(numImage)]);
    ImageArray{i}=imread(fullfile(imgPath,[imNames{i}]));
end

imsize = size(ImageArray{1});

% b1 = mean2(ImageArray{1});
% for i=2:numImage
%     b2 = mean2(ImageArray{i});
%     ImageArray{i} = ImageArray{i} + (b1-b2);
% end


mask = zeros(imsize(1),imsize(2),numImage-1);
%run edge detection on loaded images
for i=1:numImage-1
    temp = imgradient(ImageArray{i+1})-imgradient(ImageArray{i}); % calc gradient differance
    temp = conv2(temp,convFilter,'same'); % smoothening
    mask(:,:,i) = temp>max(temp,[],'all')*0.25; % thresholdin
    mask(:,:,i) = imclose(mask(:,:,i),se); % closeing objects
    mask(:,:,i) = bwareaopen(mask(:,:,i), 1500); % removing small objects
    if dilateImage
        mask(:,:,i) = imdilate(mask(:,:,i),se); % dilating final objects
    end
end

% Merge sharpness
newIm = uint16(zeros(imsize(1),imsize(2)));
for i=1:numImage-1
    newIm = newIm + ImageArray{i+1}.*uint16(mask(:,:,i));
end
newIm = newIm + ImageArray{1}.*uint16(~max(mask,[],3));

% Add blure
if doBlure
    newIm = uint16(conv2(newIm,fspecial('gaussian', blurSize),'same'));
end