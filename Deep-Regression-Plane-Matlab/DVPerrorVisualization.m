function DVPerrorVisualization(annotatedData,prediction)

n = size(annotatedData,1);
hold on

for i = 1:n
    dist = norm(double(annotatedData(i,:)) - prediction(i,:));
%     if dist < 1000
%         color = 'red';
%         plot([annotatedData(i,1);prediction(i,1)],[annotatedData(i,2);prediction(i,2)],'Marker','o','MarkerIndices',1, 'Color', color)
%     else
% %         color = '#EDB120';
%     end
    plot([annotatedData(i,1);prediction(i,1)],[annotatedData(i,2);prediction(i,2)],'Marker','o','MarkerIndices',1)
end