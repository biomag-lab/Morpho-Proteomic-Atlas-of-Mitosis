function dataOut = addNoise(dataIn, variance)
if nargin < 2
    variance = 0.001;
end

dataOut = (dataIn);
dataOut = imnoise(dataOut,'gaussian', 0, variance);

% dataOut = im2double(dataIn);
% dataOut = imnoise(dataOut, 'gaussian', 0, 0.001);
% dataOut = uint16(dataOut*65535);
