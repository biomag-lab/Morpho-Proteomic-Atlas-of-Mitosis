rp = uint16(zeros(10000,10000,3));
[cropY,cropX] = size(images_101, 1, 2);

for i = 1:size(preds,1)
    coor = preds(i,:);
    BB = getBB(coor, [cropY,cropX]);
    if ~any(BB<1) && ~any(BB>10000)
        rp(BB(3):BB(4),BB(1):BB(2), :) = images_101(:,:,:,i);
    end
end

f = figure;
ax = axes(f);
imshow(rp,'Parent',ax)
ax.YDir = 'normal';