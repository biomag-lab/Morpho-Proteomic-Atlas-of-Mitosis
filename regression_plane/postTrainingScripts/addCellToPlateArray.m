function plateArray = addCellToPlateArray(plateArray,plateIdx,imgName,objNumber,xLoc,yLoc,xReg,yReg)
    if isempty(plateArray{plateIdx})
        plateArray{plateIdx} = containers.Map;
        plateArray{plateIdx}(imgName) = [objNumber xLoc yLoc xReg yReg];
    else
        if plateArray{plateIdx}.isKey(imgName)
            currentData = plateArray{plateIdx}(imgName);
            currentData = [currentData; objNumber xLoc yLoc xReg yReg];
            plateArray{plateIdx}(imgName) = currentData;
        else
            plateArray{plateIdx}(imgName) = [objNumber xLoc yLoc xReg yReg];
        end
    end
end