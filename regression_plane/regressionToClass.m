function classCat = regressionToClass(coord)
%UNTITLED Convert regression plane coordinates to class of 41 (categorical)
%   

splitDeg = (360 - 30) / 40; % bottom 15-15 degrees are interphase cells
[theta, ~] = regplaneToPolar(coord(1), coord(2)); % in degrees
if theta >= 15 && theta <= 345 % mitotic
    classCat = categorical(floor((theta-15) / splitDeg)+1);
else % interphase
    classCat = categorical({'interphase'});
end
end

