% collect script
% imageFolder = 'c:\receive\projects_tmp\NeighbourDL\Neighbourhood_datasets\image_datasets\MCF-7_High-Content-Screening_Dataset\';
% annotationFile = 'c:\receive\projects_tmp\NeighbourDL\Neighbourhood_datasets\trainings\cell_culture_training_set.xlsx';
% outFolder = 'c:\receive\projects_tmp\NeighbourDL\Neighbourhood_datasets\trainingData\fishEye\cellsSmall\';

imageFolder = 'D:\Munka_elements\Neighbourhood\adathalmazok_maszkok_tanitasok\adathalmazok\UBC\';
annotationFile = 'D:\Munka_elements\Neighbourhood\adathalmazok_maszkok_tanitasok\tanitasok\slic35_training_set.xlsx';
outFolder = 'D:\fishEye\tissue_a85_n256_mirror_rectilinear\';


[numData, charData] = xlsread(annotationFile);

maxClass = max(numData(:,1));

smallImageSize = 256;
smallImageSizeHalf = smallImageSize / 2;

for i=1:maxClass
   
    mkdir([outFolder num2str(i)]);
    
end

numCells = numel(numData(:,1));

for i=1:numCells
    
   inImage = imread([imageFolder charData{i, 1}]);
%    inImageLarge = zeros(size(inImage, 1)+smallImageSize, size(inImage , 2)+smallImageSize, 3, 'uint8');
%    inImageLarge(smallImageSizeHalf:smallImageSizeHalf+size(inImage, 1)-1, smallImageSizeHalf:smallImageSizeHalf+size(inImage, 2)-1, :) = inImage;
   
   yc = numData(i, 3);
   xc = numData(i, 2);

   smallImg = convertFishEyeOptics(xc, yc, inImage, smallImageSize, 256, 85);

   imwrite(smallImg, [outFolder num2str(numData(i, 1)) '\' randHexString(10) '.png']);
   
   disp(i);
   
end