% split TrainValid

% startFolder = 'c:\receive\projects\projects\BRC\projects\DVP2\annotations\60x\fourty_all\fourty\';
% targetFolder = 'c:\receive\projects\projects\BRC\projects\DVP2\annotations\60x\fourty_valid\';

startFolder = '/home/koosk/images-data/class41/train/';
targetFolder = '/home/koosk/images-data/class41/val/';

classNameList = ['interphase', arrayfun(@num2str, 1:40, 'UniformOutput', 0)];
for i=1:numel(classNameList)
    className = classNameList{i};
    
    mkdir([targetFolder className]);
    
    inFolder = [startFolder className '/*.jpg'];        
    
    fileList = dir(inFolder);
    
    fileOrder = randperm(numel(fileList));
    
    if (numel(fileList) < 100)
        fileNB = 10;                
    elseif (numel(fileList) < 300)
        fileNB = 20;        
    else
        fileNB = 30;        
    end

        for j=1:fileNB
           
            % move 10 files
            movefile([startFolder className '/' fileList(fileOrder(j)).name], [targetFolder className '/' fileList(fileOrder(j)).name]);
            
        end
    
    
end