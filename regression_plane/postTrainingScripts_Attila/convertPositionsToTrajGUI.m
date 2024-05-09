function [trajInfo,corrIdx] = convertPositionsToTrajGUI(tmpPositions, trackTable)
%input: n by 2 matrix with the positions, but can contain NaNs
%output: 1 by 12 cellarray obeying the requirements for the TrajectoryGUI.
%The 12th entry is as long as the first and encodes if a position is an
%interpolation OR real regression position
%corrIdx gives back the indices that are real regression positions

if all(all(isnan(tmpPositions)))
    trajInfo = [];
    return;
end

trajInfo = cell(1,15);

corrIdx = find(all(~isnan(tmpPositions),2));
actTrajLength = corrIdx(end)-corrIdx(1)+1;
corrPos = zeros(actTrajLength,2);
for i=1:actTrajLength
    tmpIdx = corrIdx(1)+i-1;
    if all(isnan(tmpPositions(tmpIdx,:)))
        nextReal = corrIdx(find(corrIdx == prevReal)+1);
        corrPos(i,:) = ((nextReal-tmpIdx)*tmpPositions(prevReal,:)+(tmpIdx-prevReal)*tmpPositions(nextReal,:)) / (nextReal-prevReal);
    else
        corrPos(i,:) = tmpPositions(tmpIdx,:);
        prevReal = tmpIdx;
    end
end
realPos = zeros(1,actTrajLength);
realPos(corrIdx - corrIdx(1)+1) = 1;

trajInfo{1} = corrPos; %positions to show
trajInfo{2} = sum(vecnorm(corrPos(1:end-1,:)-corrPos(2:end,:),2,2)); %total length of trajectory
trajInfo{3} = actTrajLength; %length of the trajectory (frames) (slider #2)
trajInfo{4} = norm(corrPos(1,:)-corrPos(end,:)); %distance between start and end (slider #1)
trajInfo{5} = [trackTable.tracking__center_x, trackTable.tracking__center_y]; % Original Coordinates
trajInfo{6} = convertFileNames_BIAS2Operetta(trackTable.ImageName); % Original Image Name
trajInfo{7} = corrPos(1,:); %start point
trajInfo{8} = corrPos(end,:); %end point
trajInfo{9} = 1; %visibility 1
trajInfo{10} = 1; %visibility 2
trajInfo{11} = 1; %visibility 3
trajInfo{12} = 1; %visibility 4
trajInfo{13} = realPos; %Bool array indicating if a position is real or interpolated
trajInfo{15} = trackTable.Frame(corrIdx(1):corrIdx(end));
end