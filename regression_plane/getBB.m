function BB = getBB(center,size)

BB(1) = round(center(1) - size(1)/2);
BB(2) = BB(1) + size(1) - 1;
BB(3) = round(center(2) - size(2)/2);
BB(4) = BB(3) + size(2) - 1;