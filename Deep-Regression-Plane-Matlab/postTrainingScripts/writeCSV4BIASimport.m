function writeCSV4BIASimport(baseFolder,expPathSub,exportPath,preds_filtered,r)
path = fullfile(baseFolder,expPathSub,['r',num2str(r)]);
if ~exist(path,'dir')
    mkdir(path)
end
if ~exist(fullfile(path,exportPath),'dir')
    mkdir(fullfile(path,exportPath))
end
imNames = unique(preds_filtered.ImageName);
midCoor = [0.5, 0.5];
for i = 1:length(imNames)
    
    idx = strcmp(preds_filtered.ImageName,imNames{i});
    [~,fileExEx,~] = fileparts(imNames{i});
    id = preds_filtered.ObjectNumber(idx);
    classID = ones(length(id),1);
    predCoor = [preds_filtered.regPosX(idx), preds_filtered.regPosY(idx)];
    Cluster_1 = round(vecnorm(midCoor - predCoor,2,2) * 10000);

%     if length(id) == 1
%         Cluster_1 = {repmat('Inf',length(id),1)};
%     else
%         Cluster_1 = repmat('Inf',length(id),1);
%     end
    biasIDX = readtable(fullfile(baseFolder,'extra',[fileExEx,'.txt']));
    outputTable = table(biasIDX{id,1},classID,Cluster_1);
    outputTable.Properties.VariableNames = {'id','PREDICTED CLASS ID','CLASS 1 #d5ff00 Cluster_1'};
    writetable(outputTable,fullfile(path,exportPath,[fileExEx,'.csv']));
end