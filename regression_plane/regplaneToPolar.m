function [theta, radius] = regplaneToPolar(xCoords, yCoords, regplaneSize, fixRotation)
%REGPLANETOPOLAR Convert regression plane coordinates to polar coordinates
%   The Euclidean space is used for determining the rotation, i.e. the rotation direction is
%   CCW and rotated by -90 degrees.
%
%   Input:
%       - preds: structure with xPixelPos and yPixelPos fields
%       - xCoords: x coordinates from regression plane
%       - yCoords: y coordinates from regression plane
%       - regplaneSize: number, size of square regression plane in pixels,
%       default = 10000
%       - fixRotation: use regression plane conception rotation and
%       direction
%
%   Output:
%       - theta: rotation in degrees
%       - radius: radius in pixels

if nargin < 3
    regplaneSize = 10000;
end
if nargin < 4
    fixRotation = true;
end

xCoords = double(xCoords(:));
yCoords = double(yCoords(:));
p = [xCoords, yCoords] - repmat(cast([regplaneSize,regplaneSize]./2, class(xCoords)), numel(xCoords), 1);
X = repmat(cast([regplaneSize,0], class(xCoords)), length(xCoords), 1);
theta = acosd( sum(X.*p, 2) ./ (hypot(X(:,1),X(:,2)) .* hypot(p(:,1),p(:,2))) );
theta(p(:,2)<0) = 360-theta(p(:,2)<0);
radius = sqrt(sum(p.^2,2));

if fixRotation
    theta = theta + 90;
    theta = -theta;
    theta = mod(theta, 360);
end

end

