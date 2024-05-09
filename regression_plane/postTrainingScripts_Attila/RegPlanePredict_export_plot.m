% Script for plotting the training set
clear
plateName = 'ACC_211109-HK-60x-RNAseq__2021-11-09T23_54_49-Measurement3';
baseFolder = fullfile('/mnt','HDD2_10TB','Attila','DVP');
regResultFileName = 'DRP_train_result_ws-21-Nov-2021_03_21_18_v20.csv';
regResultPath = fullfile(baseFolder,plateName,regResultFileName);
imPath = fullfile(baseFolder,plateName,'anal3');
metaPath = fullfile(baseFolder,plateName,'anal2');
imExt = 'tif';
cropSize = 299; % cut size applied as +/- to both side, so use halved values
resizeValue = 50; % imsize to visualize on regPlane plot
padding = 1;
%     padVal = 'symmetric';
padVal = 0;
numOfSections = 1; % number of section on regression plane
r = 3800; % Threshold for filtering in radius
maxTheta = 330;
theta0 = 255;
direction = 'clockwise';

for s = 1:numOfSections
    if numOfSections > 1
        if ~exist('theta_min','var')
            theta_min = 0;
        else
            theta_min = theta_max;
        end
        theta_max = round((maxTheta/numOfSections)*s);
        exportPath = sprintf('Theta_%d-%d_r%d',theta_min,theta_max,r);
        fprintf('Theta min: %d\n',theta_min)
        fprintf('Theta max: %d\n',theta_max)
        
        if strcmp(direction,'clockwise')
            transformedTheta_min = theta0 - theta_max;
            transformedTheta_max = theta0 - theta_min;
        else
            transformedTheta_min = theta0 + theta_min;
            transformedTheta_max = theta0 + theta_max;
        end
        preds_filtered = filter_preds(regResultPath,transformedTheta_min,transformedTheta_max,r);
    else
        exportPath = 'full';
        preds_filtered = filter_preds(regResultPath,0,360,0);
    end
    disp(size(preds_filtered))
    halfCropSize = round(cropSize/2);

    rp = uint8(zeros(10000,10000,3));
    for i = 1:size(preds_filtered,1)
        if i == 1 || ~strcmp(imName,preds_filtered.ImageName{i})
            imName = preds_filtered.ImageName{i};
            im = imread(fullfile(imPath,imName));
            [im_sy, im_sx, ~] = size(im);
            slitImName = strsplit(imName,imExt);
            metaName = [slitImName{1},'txt'];
            data = readtable(fullfile(metaPath,metaName));
        end
        
        cellID = preds_filtered.ObjectNumber(i);
        cx = data{cellID,1};
        cy = data{cellID,2};
        cropX = [cx - halfCropSize, cx - halfCropSize + cropSize - 1];
        cropY = [cy - halfCropSize, cy - halfCropSize + cropSize - 1];
        crop = im(max(1,cropY(1)):min(im_sy, cropY(2)), max(1,cropX(1)):min(im_sx,cropX(2)), :);
        if padding
            if cropY(1) < 1
                crop = padarray(crop, [1-cropY(1), 0], padVal, 'pre');
            end
            if cropY(2) > im_sy
                crop = padarray(crop, [(cropY(2)-im_sy), 0], padVal, 'post');
            end
            if cropX(1) < 1
                crop = padarray(crop, [0, 1-cropX(1)], padVal, 'pre');
            end
            if cropX(2) > im_sx
                crop = padarray(crop, [0, cropX(2)-im_sx], padVal, 'post');
            end
        end
        crop = imresize(crop,[100,100]);
        RegCoor = [preds_filtered.regPosX(i), preds_filtered.regPosY(i)]*10000;
        rpX = round([RegCoor(1) - 50, RegCoor(1) + 50 - 1]);
        rpY = round([RegCoor(2) - 50, RegCoor(2) + 50 - 1]);
        %         if ~any(BB<1) && ~any(BB>10000)
        rp(rpY(1):rpY(2),rpX(1):rpX(2), :) = crop;
        %         end
        if mod(i,100) == 0
            disp(i)
        end
    end

%     f = figure;
%     ax = axes(f);
    frp = flip(rp,1);
%     imshow(frp,'Parent',ax)
    
%     save(fullfile(baseFolder,['rp_',regResultFileName,'.mat']),'frp')
    expPathSub = ['RegionExport',regResultFileName(1:end-4)];
    if numOfSections ~= 1
        writeCSV4BIASimport(fullfile(baseFolder,plateName),expPathSub,exportPath,preds_filtered,r)
    end
    imwrite(frp,fullfile(baseFolder,plateName,expPathSub,['r',num2str(r)],[exportPath,'.png']))
    %     imwrite(frp,fullfile(baseFolder,plateName,['full_',regResultFileName,'.png']))
    
end