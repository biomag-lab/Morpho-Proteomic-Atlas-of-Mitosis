function bdImg = fillBoundaries(inImg,extendedImg,maxRange,preoutImg,outSize,pixDists,xOffset,yOffset,mmm)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if(mmm=="mean")
    if(preoutImg(1,1)==-10 || preoutImg(outSize,outSize)==-10)
        red=preoutImg(:,:,1);
        green=preoutImg(:,:,2);
        blue=preoutImg(:,:,3);
        
        [row1,col1]=find(red>-10,1,'first');
        [row2,col2]=find(red>-10,1,'last');
        
        rAvg=round(mean2(red(row1:row2,col1:col2)));
        gAvg=round(mean2(green(row1:row2,col1:col2)));
        bAvg=round(mean2(blue(row1:row2,col1:col2)));
        
        bdImg=zeros(outSize, outSize, 3, 'uint8');
        bdImg(:,:,1)=rAvg;
        bdImg(:,:,2)=gAvg;
        bdImg(:,:,3)=bAvg;
        bdImg(row1:row2,col1:col2,:)=preoutImg(row1:row2,col1:col2,:);

        
    else bdImg=uint8(preoutImg);
    end

    
elseif(mmm=="median")
    if(preoutImg(1,1)==-10 || preoutImg(outSize,outSize)==-10)
        red=preoutImg(:,:,1);
        green=preoutImg(:,:,2);
        blue=preoutImg(:,:,3);
        
        [row1,col1]=find(red>-10,1,'first');
        [row2,col2]=find(red>-10,1,'last');
        
        rAvg=round(median(red(row1:row2,col1:col2),'all'));
        gAvg=round(median(green(row1:row2,col1:col2),'all'));
        bAvg=round(median(blue(row1:row2,col1:col2),'all'));
        
        bdImg=zeros(outSize, outSize, 3, 'uint8');
        bdImg(:,:,1)=rAvg;
        bdImg(:,:,2)=gAvg;
        bdImg(:,:,3)=bAvg;
        bdImg(row1:row2,col1:col2,:)=preoutImg(row1:row2,col1:col2,:);        
        
    else bdImg=uint8(preoutImg);
    end
    
    
elseif(mmm=="mirror")
    if(preoutImg(1,1)==-10 || preoutImg(outSize,outSize)==-10)
        eiSize=size(extendedImg);
        iiSize=size(inImg);

        extendedImg(1:maxRange,(maxRange+1):(eiSize(2)-maxRange),:)=flip(inImg(1:maxRange,:,:),1);
        extendedImg(maxRange+1:maxRange+iiSize(1),(maxRange+iiSize(2)+1):eiSize(2),:)=flip(inImg(:,(iiSize(2)-maxRange+1):iiSize(2),:),2);
        extendedImg((maxRange+iiSize(1)+1):eiSize(1),maxRange+1:maxRange+iiSize(2),:)=flip(inImg((iiSize(1)-maxRange+1):iiSize(1),:,:),1);
        extendedImg(maxRange+1:maxRange+iiSize(1),1:maxRange,:)=flip(inImg(:,1:maxRange,:),2);
        
        extendedImg(1:maxRange,(maxRange+iiSize(2)+1):eiSize(2),:)=rot90(extendedImg(maxRange+1:maxRange+maxRange,(maxRange+iiSize(2)+1):eiSize(2),:),1);
        extendedImg((maxRange+iiSize(1)+1):eiSize(1),(maxRange+iiSize(2)+1):eiSize(2),:)=rot90(extendedImg((maxRange+iiSize(1)+1):eiSize(1),iiSize(2)+1:maxRange+iiSize(2),:),1);
        extendedImg((maxRange+iiSize(1)+1):eiSize(1),1:maxRange,:)=rot90(extendedImg(iiSize(1)+1:maxRange+iiSize(1),1:maxRange,:),1);
        extendedImg(1:maxRange,1:maxRange,:)=rot90(extendedImg(1:maxRange,maxRange+1:maxRange+maxRange,:),1);
        
        preoutImg = extendedImg(:, round(pixDists+xOffset)+1, :);
        preoutImg = preoutImg(round(pixDists+yOffset)+1, :, :);
        bdImg=uint8(preoutImg);

    else bdImg=preoutImg;
    end
end

