function [regPos, frameID] = matchCellFromTrackTable(plateArray, relevantTable, i)
%extractDataFromTrackingTable
%   Identifies the features, the cellnumber, imagename of the project from
%   the csv file which stores the tracking data.
%
%   INPUTS:
%       relevantTable   is a table format, stores the trajectory data
%       i is the index within that table
%       GLOBAL input: CommonHandles
%   OUTPUTS:
%       the usual ones: feature contains features of the cell, image is the
%       view etc.
%       str is a structure that can be used for jumpToCell
%       regPos is the predicted regression position
%       frameID the index of the frame
%       NOTE: if the cell is not found in the plateArray (this can happen,
%       in case of classification) then NaNs are returned and str is empty

%     plateName = relevantTable.Plate{i};
%     plateNumber = getPlateNumberByName(plateName);
    plateNumber = 1;
    [~,imageName,~] = fileparts(relevantTable.ImageName{i});
    mindist = Inf;
    frameID = relevantTable.Frame(i);
    
    if ~isempty(plateArray{plateNumber}) && plateArray{plateNumber}.isKey(imageName)
        posMatrixForImage = plateArray{plateNumber}(imageName);
        if ismember('ObjectID',relevantTable.Properties.VariableNames)
            objID = relevantTable.ObjectID(i);
            for j=1:size(posMatrixForImage,1)
                if posMatrixForImage(j,1) == objID
                    mindist = 0;
                    cellIdx = j;
                    break
                end
            end
        else
            coords = posMatrixForImage(:,[2 3]);
            [mindist,cellIdx] = min(pdist2([relevantTable.tracking__center_x(i) relevantTable.tracking__center_y(i)],coords));
        end
        
        if mindist>5 %Note: if the match is within 5 pixel it is considered as a match, otherwise not
            if exist('objID','var')
                str.CellNumber = objID;
            else
                str = [];
            end
            regPos = [NaN NaN];
        else
            cellNumber = posMatrixForImage(cellIdx,1);
            str.CellNumber = cellNumber;
            regPos = posMatrixForImage(cellIdx,[4 5]);
        end
    else
       str = [];
       regPos = [NaN NaN];
    end
end