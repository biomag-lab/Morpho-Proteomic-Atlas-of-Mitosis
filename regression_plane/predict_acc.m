%% params
model_path = '/home/koosk/data/data/DRP/resnet50_reg_flora.mat';
model_input_size = [224, 224]; % img size reguired by the model
% input_folder = '/home/koosk/data/data/DRP/210424-HelaKyoto_ACC_Project_Nuc';
acc_folder = '/home/koosk/data/data/DRP/210528-HelaKyoto-PFAfixed-frame_ ACC_PROJECT_nuc/';


%% real stuff
an2_folder = fullfile(acc_folder, 'anal2');
an3_folder = fullfile(acc_folder, 'anal3');

model = load(model_path);
model = model.net;
if an3_folder(end) ~= filesep
    an3_folder = [an3_folder, filesep];
end
image_files = dir(an3_folder);

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

for img_idx = 1:numel(image_files)
    file = image_files(img_idx);
    if strcmp(file.name, '.') || strcmp(file.name, '..')
        continue
    end
    
    image = imread(fullfile(an3_folder, file.name));
    [im_sy, im_sx, ~] = size(image);
    [~, fname, ext] = fileparts(file.name);
    cell_data = read_anal2(fullfile(an2_folder, [fname, '.txt']));
    cell_data  = [cell_data{1}, cell_data{2}, cell_data{3}];
    num_cells = size(cell_data, 1);
    crops = zeros(model_input_size(1), model_input_size(2),3, size(cell_data,1));
    for cell_idx = 1:num_cells
        cx = cell_data(cell_idx, 1);
        cy = cell_data(cell_idx, 2);
        crop = image(max(1,cy-50):min(im_sy, cy+50), max(1,cx-50):min(im_sx, cx+50), :);
        crop = im2uint16(crop);
        if cy < 51
            crop = padarray(crop, [51-cy, 0], 'pre');
        end
        if cy > im_sy-50
            crop = padarray(crop, [50-(im_sy-cy), 0], 'post');
        end
        if cx < 51
            crop = padarray(crop, [0, 51-cx], 'pre');
        end
        if cx > im_sx-50
            crop = padarray(crop, [50-(im_sx-cx), 0], 'post');
        end
        
        crop = imresize(crop, [model_input_size(1), model_input_size(2)]);
%         fig=figure; imshow(crop);
%         close(fig);
        crops(:,:,:,cell_idx) = crop;
        xPixelPos = [xPixelPos, cx];
        yPixelPos = [yPixelPos, cy];
    end
    preds = predict(model,crops);
    
   
    
    PlateName(end+1:end+num_cells) = {'induced'};
    f = file.name;
    row_value = f(strfind(f, '_w')+2);
    col_value = f(strfind(f, '_w')+3);
    Row(end+1:end+num_cells) = {row_value};
    Col(end+1:end+num_cells) = {col_value};
    ImageName(end+1:end+num_cells) = {f};
    ImageNumber(end+1:end+num_cells) = ones(num_cells, 1);
    ObjectNumber(end+1:end+num_cells) = 1:num_cells;
    regPosX(end+1:end+num_cells) = preds(:,1)./10000;
    regPosY(end+1:end+num_cells) = preds(:,2)./10000;
end

t = table(PlateName', Row', Col', ImageName', ImageNumber', ObjectNumber', xPixelPos', yPixelPos', regPosX', regPosY');
t.Properties.VariableNames = {'PlateName','row','col','ImageName','ImageNumber','ObjectNumber','xPixelPos','yPixelPos','regPosX','regPosY'};
writetable(t, 'drp_predictions.csv')




