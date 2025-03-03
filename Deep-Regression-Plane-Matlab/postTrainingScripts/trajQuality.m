function trajTable = trajQuality(coors)

N = size(coors,1);
VariableNames = {'Coordinates';'DistFromOrigin';'NumOfFrames';'LengthOfTraj';'DistFromO_Max';'DistFromO_Min';...
                 'DistFromO_Mean';'DistFromO_Median';'DistFromO_Range';'DistFromO_Sum';'Smoothness'};
varNum = numel(VariableNames);

trajTable = array2table(zeros(N,varNum));
trajTable.Properties.VariableNames = VariableNames;
trajTable.Coordinates = coors;
origo = [0.5 0.5];


for i = 1:N
    % Distance from origin
    trajTable.DistFromOrigin(i) = norm(trajTable.Coordinates{i, 1}(1,:)-trajTable.Coordinates{i, 1}(end,:));
    % Number of Frames
    trajTable.NumOfFrames(i) = size(trajTable.Coordinates{i, 1}, 1);
    % Length of trajectory
    sumLength = 0;
    for j=1:size(trajTable.Coordinates{i, 1},1)-1
        sumLength = sumLength + norm(trajTable.Coordinates{i, 1}(j+1,:) - trajTable.Coordinates{i, 1}(j,:));
    end
    trajTable.LengthOfTraj(i) = sumLength;


    % Distance from origo

    % Max
    trajTable.DistFromO_Max(i) = max(vecnorm(origo - trajTable.Coordinates{i, 1},2,2));

    % Min
    trajTable.DistFromO_Min(i) = min(vecnorm(origo - trajTable.Coordinates{i, 1},2,2));

    % Mean
    trajTable.DistFromO_Mean(i) = mean(vecnorm(origo - trajTable.Coordinates{i, 1},2,2));


    % Median
    trajTable.DistFromO_Median(i) = median(vecnorm(origo - trajTable.Coordinates{i, 1},2,2));


    % Range
    trajTable.DistFromO_Range(i) = range(vecnorm(origo - trajTable.Coordinates{i, 1},2,2));
    
    % Sum
    trajTable.DistFromO_Sum(i) = sum(vecnorm(origo - trajTable.Coordinates{i, 1},2,2));
    
    % Smoothness
    Smoothness = 0;
    for k = 1:size(trajTable.Coordinates{i, 1},1)-2
        v1 = trajTable.Coordinates{i, 1}(k+1,:) - trajTable.Coordinates{i, 1}(k,:);
        v2 = trajTable.Coordinates{i, 1}(k+2,:) - trajTable.Coordinates{i, 1}(k+1,:);
%         if norm(v2) > 0.03
            Smoothness = Smoothness + (acos(dot(v1 / norm(v1), v2 / norm(v2))) * norm(v2));
%         end
    end
    trajTable.Smoothness(i) = Smoothness / trajTable.NumOfFrames(i);
end