%% params
% model_path = '/home/koosk/data/data/DRP/resnet50_reg_flora.mat';
model_path = '/home/koosk/data/data/DRP/Flora_grid_1222/Flora_grid_1222_net.mat';
input_img_size = [224, 224]; % img size reguired by the model
% input_folder = '/home/koosk/data/data/DRP/210424-HelaKyoto_ACC_Project_Nuc';
% input_folder = '/home/koosk/data/data/DRP/HeLa trSet/Images/';
input_folder = '/home/koosk/data/data/DRP/Flora_grid_1222/split/test/images/';


%% real stuff
model = load(model_path);
model = model.net;
if input_folder(end) ~= filesep
    input_folder = [input_folder, filesep];
end
image_files = dir(input_folder);
num_files = numel(image_files)-2;
images = zeros(input_img_size(1), input_img_size(2),3, num_files);
images_101 = zeros(101, 101, 3, num_files);

for idx = 1:num_files
    file = image_files(idx);
    if strcmp(file.name, '.') || strcmp(file.name, '..')
        continue
    end
    image_orig = imread(fullfile(input_folder, file.name));
    images_101(:,:,:,idx) = imresize(image_orig, [101, 101]);
    image = imresize(image_orig, input_img_size);
    images(:,:,:,idx) = image;
end

preds = predict(model,images);





