augmentTrainingSetRegression('/home/koosk/images-data/class41/train/interphase/', '/home/koosk/images-data/class41/regression_augmented/images/', '/home/koosk/images-data/mix_labels/', '/home/koosk/images-data/class41/regression_augmented/labels/', 0, 2000);
for i=1:40
   
%     augmentTrainingSetRegression(['/home/koosk/images-data/class41/train/' num2str(i) '/'], ['/home/koosk/images-data/class41/train_aug/' num2str(i) '/'], 0, 2000);
    augmentTrainingSetRegression(['/home/koosk/images-data/class41/train/' num2str(i) '/'], '/home/koosk/images-data/class41/regression_augmented/images/', '/home/koosk/images-data/mix_labels/', '/home/koosk/images-data/class41/regression_augmented/labels/', 0, 2000);
    
end