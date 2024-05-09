function outImg = convertFishEyeOptics(x, y, inImg, outSize, maxRange, maxViewAngle)

% bounderies with -10s
extendedImg = zeros(size(inImg, 1)+2*maxRange, size(inImg, 2)+2*maxRange, 3, class(inImg))-10;
extendedImg(maxRange + 1:maxRange + size(inImg, 1), maxRange + 1:maxRange + size(inImg, 2), :) = inImg;


xOffset = x + maxRange;
yOffset = y + maxRange;

angles = -maxViewAngle:maxViewAngle/(outSize/2):maxViewAngle;

% rectilinear
focalDist = maxRange / tand(maxViewAngle);
pixDists =  focalDist .* tand(angles) ;

% stereographic
% focalDist = maxRange / (2 .* tand(maxViewAngle/2));
% pixDists = 2 .* focalDist .* tand(angles/2);

% equidistant
% focalDist = maxRange / maxViewAngle;
% pixDists = focalDist .* angles;

% equisolid angle 
% focalDist = maxRange / (2 .* sind(maxViewAngle/2));
% pixDists = 2 .* focalDist .* sind(angles/2);

% orthographic
% focalDist = maxRange / sind(maxViewAngle);
% pixDists = focalDist .* sind(angles);

pixDists = pixDists(1:end-1);

preoutImg = extendedImg(:, round(pixDists+xOffset)+1, :);
preoutImg = preoutImg(round(pixDists+yOffset)+1, :, :);

outImg=fillBoundaries(inImg,extendedImg,maxRange,preoutImg,outSize,pixDists,xOffset,yOffset,"mirror");

% figure(1);
% imshow(outImg);
%     
