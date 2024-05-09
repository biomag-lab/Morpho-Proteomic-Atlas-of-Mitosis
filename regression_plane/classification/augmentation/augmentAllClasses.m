augmentTrainingSet('/home/koosk/images-data/class41/train/interphase/', '/home/koosk/images-data/class41/train_aug/interphase/', 0, 2000);
for i=1:40
   
    augmentTrainingSet(['/home/koosk/images-data/class41/train/' num2str(i) '/'], ['/home/koosk/images-data/class41/train_aug/' num2str(i) '/'], 0, 2000);
    
end