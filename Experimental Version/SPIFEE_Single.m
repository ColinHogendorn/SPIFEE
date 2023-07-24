function [means,idx,ClusterMeans, avgTraceFig,ClusterEvalFig,OptimalClusterFig,ClustAssignmentFig,avgClusterTraceFig]= SPIFEE_Single(name,data,feats,hours, lenPulse)

%Means
means = mean(feats, 2)

%Average Trace
avgTrace = mean(data,2)

[Points, NumCells] = size(data);
PointPerHour = Points/hours ;
smoothed = smoothdata(avgTrace, 'gaussian', (lenPulse * PointPerHour) / 3)
avgTraceFig = figure;
plot(smoothed, 'LineWidth', 4, 'color', 'b')

%TO DO: Clusters, Fourier Transforms.

%Fourier Transforms

% y = fft(smoothed)
% y2 = fft(avgTrace)
% Fourierfig = figure;
% 
% Ts = length(data) / hours
% fs = 1 /Ts
% 
% f = (0:length(y) -1) * fs / length(y)
% plot(f,abs(y), 'LineWidth', 2, 'color', 'red')
% 
% f2 = (0:length(y2) -1) * fs / length(y2)
% plot(f2,abs(y2), 'LineWidth', 2, 'color', 'blue')
% 
% xlabel('Frequency')
% ylabel('Magnitude')
% title('Magnitude')

%Clusters: Code taken from mathworks ...
%https://www.mathworks.com/help/stats/clustering.evaluation.calinskiharabaszevaluation.plot.html
ClusterEvalFig = figure;
calinskiEvaluation = evalclusters(data,"kmeans","CalinskiHarabasz","KList",1:6);
daviesEvaluation = evalclusters(data,"kmeans","DaviesBouldin", "KList",1:6);
gapEvaluation = evalclusters(data,"kmeans","gap","KList",1:6);
silhouetteEvaluation = evalclusters(data,"kmeans","silhouette","KList",1:6);

OptimalClusterFig = tiledlayout(2,2);
title(OptimalClusterFig,"Optimal Number of Clusters for Different Criteria")
colors = lines(4);

% Calinski-Harabasz Criterion Plot
nexttile
h1 = plot(calinskiEvaluation);
h1.Color = colors(1,:);
hold on
xline(calinskiEvaluation.OptimalK,"--","Optimal K", ...
    "LabelVerticalAlignment","middle")
hold off

% Davies-Bouldin Criterion Plot
nexttile
h2 = plot(daviesEvaluation);
h2.Color = colors(2,:);
hold on
xline(daviesEvaluation.OptimalK,"--","Optimal K", ...
    "LabelVerticalAlignment","middle")
hold off

% Gap Criterion Plot
nexttile
h3 = plot(gapEvaluation);
h3.Color = colors(3,:);
hold on
xline(gapEvaluation.OptimalK,"--","Optimal K", ...
    "LabelVerticalAlignment","middle")
hold off

% Silhouette Criterion Plot
nexttile
h4 = plot(silhouetteEvaluation);
h4.Color = colors(4,:);
hold on
xline(silhouetteEvaluation.OptimalK,"--","Optimal K", ...
    "LabelVerticalAlignment","middle")
hold off


BestK = round(mean([silhouetteEvaluation.OptimalK,gapEvaluation.OptimalK,daviesEvaluation.OptimalK,calinskiEvaluation.OptimalK] ))

ClustAssignmentFig = figure()
idx =  kmeans(transpose(data), BestK)
legendNames = []
clustMeans = []
hold on
for i = 1:BestK
plot(data(:,idx == i))
[length, num] = size(data(:,idx == i))
cellNums = find(idx == i)
peaks = find(any(feats(9,:) == cellNums))
clustMeans = [clustMeans, mean(feats(:,peaks),2)]
legendNames = [legendNames, ("Cluster " + string(i)) + " (" + string(num) + ")"]
end
hold off
legend(legendNames)
title 'Cluster Assignments'

Features = ["Height", "Location", "Width", "Prominence", "Frequency", "Duration", "Integral", "Peak", "Cell", "AvgMax",...
    "AvgMin", "Peak over Basal"]
Features = transpose(Features)
ClusterMeans = array2table(clustMeans,'Rownames',Features, 'VariableNames', legendNames)

avgClusterTraceFig = figure()
hold on
for i = 1:BestK
temp = data(:,idx == i)
temp2 = mean(temp,2)
plot(temp2, 'LineWidth',3)
end
hold off
legend(legendNames)
title 'Average Cluster Trace'

save(name, 'means','idx','ClusterMeans', 'avgTraceFig', 'ClusterEvalFig', 'ClustAssignmentFig', 'avgClusterTraceFig')

end