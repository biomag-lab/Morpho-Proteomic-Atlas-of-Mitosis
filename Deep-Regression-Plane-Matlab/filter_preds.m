preds_path = 'drp_predictions_210528-HelaKyoto-PFAfixed-frame_ ACC_PROJECT_nuc.csv';
theta_min = 270; % degrees, standard Euclidean plane, i.e. X axis is 0 degrees.
theta_max = 30; % degrees, periodicity applied
radius_min = 1000; % 'pixels', on 10^4-by-10^4

%% load and transform
preds = readtable(preds_path);
p = [preds.xPixelPos, preds.yPixelPos] - [5000,5000];
X = repmat([10000,0], length(preds.xPixelPos), 1);
theta = acosd( sum(X.*p, 2) ./ (hypot(X(:,1),X(:,2)) .* hypot(p(:,1),p(:,2))) );
theta(p(:,2)<0) = 360-theta(p(:,2)<0);
radius = sqrt(sum(p.^2,2));

%% filter
radius_filter = radius>=radius_min;
theta_min_filter = theta >= theta_min;
theta_max_filter = theta <= theta_max;
if theta_min < theta_max
    theta_filter = theta_min_filter & theta_max_filter;
else
    theta_filter = theta_min_filter | theta_max_filter;
end
filter = radius_filter & theta_filter;

%% result
preds_filtered = preds(filter,:);
