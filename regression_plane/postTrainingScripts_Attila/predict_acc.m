for mdl = 1:1
    %% params
%     modelName = {'DRP_train_result_ws-07-Oct-2021_04_56_26_train_40x_2000_v11';... % [299 299]
%         'DRP_train_result_ws-06-Oct-2021_07_22_49_train_40x_2000_v10';... % [224 224]
%         'DRP_train_result_ws-07-Oct-2021_15_56_38_train_40x_2000_v9';... % [224 224]
%         'DRP_train_result_ws-08-Nov-2021_11_23_07_train_40x_2000_v16';... % [224 224]
%         'DRP_train_result_ws-07-Oct-2021_04_56_26_train_40x_2000_v11'}; % [224 224]
    modelName = {'DRP_train_result_ws-21-Nov-2021_03_21_18_v20'};
    % az első 10x3-as kivágás modelje: DRP_train_result_ws-05-Jul-2021_04_49_14_Flora1603
%     model_input_size = {[299, 299];...
%         [224, 224];...
%         [224, 224];...
%         [224, 224];...
%         [224, 224]};
    useOrigIms = 1;
    padding = 1;
%     padVal = 'symmetric';
    padVal = 0;
    onlyTheta = 0;
    dynaFocus = 1;
    intensityScaler = 6;
    % img size reguired by the model originally 224, [v9_d5 model -> 299]
    baseFolder = fullfile('/mnt','HDD2_10TB','Attila','DVP');
    plateName = 'ACC_211109-HK-60x-RNAseq__2021-11-09T23_54_49-Measurement3';
    accProjectfolder = fullfile(baseFolder,plateName);
    origImFolder = fullfile(baseFolder,'RawImages','211109-HK-60x-RNAseq__2021-11-09T23_54_49-Measurement3','Images');
    cropSize = 299; % depends on the objective magnification [20x->101] [40x->224]
    
    channelOrder = {'ch1';'ch2'};
    
    model_path = fullfile(baseFolder,'Models',[modelName{mdl},'.mat']);
    
    %% real stuff
    an2_folder = fullfile(accProjectfolder, 'anal2');
    an3_folder = fullfile(accProjectfolder, 'anal3');
    
    model = load(model_path);
    model = model.net;
    model_input_size = model.Layers(1).InputSize(1:2);
    
    if an3_folder(end) ~= filesep
        an3_folder = [an3_folder, filesep];
    end
    imFiles = dir(an3_folder);
    %     frameFilterIDX = [];
    %     for ii = 1:length(imFiles)
    %         if contains(imFiles(ii).name,'_t1_m')
    %             lastFrameIDX = [lastFrameIDX;ii];
    %         end
    %     end
    frameFilterIDX = 3:length(imFiles);
    filtered_image_files = imFiles(frameFilterIDX);
    halfCropSize = round(cropSize/2);
    PlateName = {};
    Row = {};
    Col = {};
    ImageName = {};
    ImageNumber = [];
    ObjectNumber = [];
    xPixelPos = [];
    yPixelPos = [];
    regPosX = [];
    regPosY = [];
    
    for img_idx = 1:numel(filtered_image_files)
        disp(img_idx);
        if useOrigIms
            origName = convertFileNames_BIAS2Operetta(filtered_image_files(img_idx).name);
            splitOrigName = strsplit(origName{1},'ch0');
            if dynaFocus
                imNames2focus1 = [splitOrigName{1}(1:end-2),'*',channelOrder{1},splitOrigName{2},'.tiff'];
                imList2focus1 = dir(fullfile(origImFolder,imNames2focus1));
                ch1 = dynamicFocus(origImFolder,{imList2focus1.name},0,0);

                imNames2focus2 = [splitOrigName{1}(1:end-2),'*',channelOrder{2},splitOrigName{2},'.tiff'];
                imList2focus2 = dir(fullfile(origImFolder,imNames2focus2));
                ch2 = dynamicFocus(origImFolder,{imList2focus2.name},0,0);
            else
                ch1 = imread(fullfile(origImFolder,[splitOrigName{1},channelOrder{1},splitOrigName{2},'.tiff']));
                ch2 = imread(fullfile(origImFolder,[splitOrigName{1},channelOrder{2},splitOrigName{2},'.tiff']));
            end
            imToCrop = cat(3,ch1,ch2,zeros(size(ch1)));
            
        else
            imToCrop = im2uint16(imread(fullfile(accProjectfolder,'anal3',filtered_image_files(img_idx).name)));
        end
        [im_sy, im_sx, ~] = size(imToCrop);
        [~, fname, ext] = fileparts(filtered_image_files(img_idx).name);
        cell_data = readtable(fullfile(an2_folder, [fname, '.txt']));
        %         cell_data  = [cell_data{1}, cell_data{2}, cell_data{3}];
        num_cells = size(cell_data, 1);
        crops = zeros(model_input_size(1), model_input_size(2),3, size(cell_data,1));
        for cell_idx = 1:num_cells
            if ~isnan(cell_data{cell_idx, 3})
                cx = cell_data{cell_idx, 1};
                cy = cell_data{cell_idx, 2};
                cropX = [cx - halfCropSize, cx - halfCropSize + cropSize - 1];
                cropY = [cy - halfCropSize, cy - halfCropSize + cropSize - 1];
                crop = imToCrop(max(1,cropY(1)):min(im_sy, cropY(2)), max(1,cropX(1)):min(im_sx,cropX(2)), :);
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
                
                crop = imresize(crop, [model_input_size(1), model_input_size(2)]);
%                 fig=figure; imshow(crop);
%                 close(fig);
                crops(:,:,:,cell_idx) = crop*intensityScaler;
            end
        end
        preds = predict(model,crops);
        
        
        
        PlateName(end+1:end+num_cells) = {plateName};
        f = filtered_image_files(img_idx).name;
        row_value = f(strfind(f, '_w')+2);
        col_value = f(strfind(f, '_w')+3);
        Row(end+1:end+num_cells) = {row_value};
        Col(end+1:end+num_cells) = {col_value};
        ImageName(end+1:end+num_cells) = {f};
        ImageNumber(end+1:end+num_cells) = ones(num_cells, 1);
        ObjectNumber(end+1:end+num_cells) = 1:num_cells;
        xPixelPos(end+1:end+num_cells) = cell_data.Var1;
        yPixelPos(end+1:end+num_cells) = cell_data.Var2;
        if onlyTheta
            rho = randi([4300, 4500], numel(preds),1);
            [xCoor,yCoor] = pol2cart(deg2rad(preds),rho);
            regPosX(end+1:end+num_cells) = (xCoor+5000)./10000;
            regPosY(end+1:end+num_cells) = (yCoor+5000)./10000;
        else
            regPosX(end+1:end+num_cells) = preds(:,1)./10000;
            regPosY(end+1:end+num_cells) = preds(:,2)./10000;
        end
    end
    
    t = table(PlateName', Row', Col', ImageName', ImageNumber', ObjectNumber', xPixelPos', yPixelPos', regPosX', regPosY');
    t.Properties.VariableNames = {'PlateName','row','col','ImageName','ImageNumber','ObjectNumber','xPixelPos','yPixelPos','regPosX','regPosY'};
    writetable(t, fullfile(accProjectfolder,[modelName{mdl},'.csv']))
    clear
end