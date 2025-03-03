inFolder = '/home/koosk/data/data/DRP/DRP_HeLa_trSet_1201db/split/images/train/';
regFolder = '/home/koosk/data/data/DRP/DRP_HeLa_trSet_1201db/split/labels/train/';

outFolder = '/home/koosk/data/data/DRP/DRP_HeLa_trSet_1201db/split/images/trainAug/';
outRegFolder = '/home/koosk/data/data/DRP/DRP_HeLa_trSet_1201db/split/labels/trainAug/';
folderList = dir(inFolder);

for i=3:numel(folderList)
    
    fileList = dir([inFolder folderList(i).name filesep '*.tif']);
    
    for j=1:numel(fileList)

        fileName = [inFolder folderList(i).name filesep fileList(j).name];
        fileRegName = [regFolder folderList(i).name filesep fileList(j).name(1:end-4) '.png'];
        
        inImg = imread(fileName);
        regImg = imread(fileRegName);
        
        
        for k=1:5
            outFileName = randHexString(10);
            outImg = transformIntensity(inImg);
            outImg = addNoise(outImg);
            imwrite(outImg, [outFolder outFileName '.tif']);
            imwrite(regImg, [outRegFolder outFileName '.tif']);            
        end
        
    end
    
    
end