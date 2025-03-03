function dataOut = transformIntensity(dataIn, intensityRange)
if nargin < 2
    intensityRange = 5000;
else
    intensityRange = double(intensityRange);
end

multiplier = rand(1) + 0.5;
% shifter = randi(intensityRange)-intensityRange/2;
shifter = randi(round(intensityRange*0.3)) - intensityRange*0.15;

dIn= double((dataIn));
% doOut = dIn*multiplier + shifter;
dataOut = uint16(dIn*multiplier + shifter);


