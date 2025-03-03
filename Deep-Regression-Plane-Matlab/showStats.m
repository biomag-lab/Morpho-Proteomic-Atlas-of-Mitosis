% s20x = load('20x-statistics.mat');
% s40x1 = load('40x1-statistics.mat');
% s40x2 = load('40x2-statistics.mat');
% s60x = load('60x-statistics.mat');

% plotFcn(s20x, s40x1, s40x2, s60x, 'avgValues', 'avg')
% plotFcn(s20x, s40x1, s40x2, s60x, 'minValues', 'min')
% plotFcn(s20x, s40x1, s40x2, s60x, 'maxValues', 'max')
% plotFcn(s20x, s40x1, s40x2, s60x, 'sumValues', 'sum')
% 
% s20xMean = [mean(s20x.avgValues(:,1)), mean(s20x.avgValues(:,2))];
% s40x1Mean = [mean(s40x1.avgValues(:,1)), mean(s40x1.avgValues(:,2))];
% s40x2Mean = [mean(s40x2.avgValues(:,1)), mean(s40x2.avgValues(:,2))];
% s60xMean = [mean(s60x.avgValues(:,1)), mean(s60x.avgValues(:,2))];
% 
% maxMean = max([s20xMean; s40x1Mean; s40x2Mean; s60xMean]);
% multiplierFor20x = maxMean ./ s20xMean
% multiplierFor40x1 = maxMean ./ s40x1Mean
% multiplierFor40x2 = maxMean ./ s40x2Mean
% multiplierFor60x = maxMean ./ s60xMean

plotFcn(s20xf, s40x1, s40x2f, s60xf, 'avgValues', 'avg');
plotFcn(s20xf, s40x1, s40x2f, s60xf, 'minValues', 'min');
plotFcn(s20xf, s40x1, s40x2f, s60xf, 'maxValues', 'max');
plotFcn(s20xf, s40x1, s40x2f, s60xf, 'sumValues', 'sum');


function plotFcn(s20x, s40x1, s40x2, s60x, fieldName, statNameToPrint)
    figure,
    subplot(4,2,1)
    plot(s20x.(fieldName)(:,1))
    title(['Red ', statNameToPrint, ' intensity'])
    ylabel({'20x','intensity'})
    subplot(4,2,2)
    plot(s20x.(fieldName)(:,2))
    title(['Green ', statNameToPrint, ' intensity'])
    subplot(4,2,3)
    plot(s40x1.(fieldName)(:,1))
    ylabel({'40x pt1','intensity'})
    subplot(4,2,4)
    plot(s40x1.(fieldName)(:,2))
    subplot(4,2,5)
    plot(s40x2.(fieldName)(:,1))
    ylabel({'40x pt2','intensity'})
    subplot(4,2,6)
    plot(s40x2.(fieldName)(:,2))
    subplot(4,2,7)
    plot(s60x.(fieldName)(:,1))
    ylabel({'60x','intensity'})
    xlabel('#image')
    subplot(4,2,8)
    plot(s60x.(fieldName)(:,2))
    xlabel('#image')
end
