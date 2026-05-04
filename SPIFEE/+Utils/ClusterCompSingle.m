function [TPercents, idx, ClusterMeans] = ClusterCompSingle(params, name, data,  FullSetID)

% Determine Optimal Number of Clusters
Klist = 1:6;
switch params.Score
    case "DaviesBouldin"
        eva = evalclusters(data,'kmeans','DaviesBouldin', 'KList', Klist);
    case "CalinskiHarabasz"
        eva = evalclusters(data,'kmeans','CalinskiHarabasz', 'KList', Klist);
    case "Gap"
        eva = evalclusters(data,'kmeans','Gap', 'KList', Klist);
    otherwise
        eva = evalclusters(data,'kmeans','silhouette', 'KList', Klist);
end

K = eva.OptimalK;

% Manual override
if params.ManClustAll > 0
    K = str2double(params.ManClustAll);
end

if K > min(size(data))
    warning("Not enough traces to cluster, setting K=1")
    K = 1;
end

%Cluster
idx = kmeans(data', K);  % transpose so each column = observation

legendNames = strings(1,K);
%clustMeans = [];

% Cluster colors
% colors = [0.0 0.8 0.6;   % teal/cyan
%           0.6 0.0 0.6;   % purple
%           0.5 0.5 0.5;   % grey
%           0.8 0.0 0.0];  % red

colors  = [0.988, 0.008, 0; %Red
           0.98 0.678 0.216; %Orange
           1, 0.929, 0.349]; %Yellow ]

% Compute cluster means
clustMeans = zeros(length(data,2),K);
for i = 1:K
    clusterTraces = data(:, idx == i);
    clustMeans(:,i) = mean(clusterTraces,2);
    legendNames(i) = "Cluster " + string(i) + " (" + string(size(clusterTraces,2)) + ")";
end

% Percentages per Treatment
uniqueSets = unique(FullSetID);
numTreats = numel(uniqueSets);

percentages = zeros(numTreats, K);

for i = 1:numTreats
    idx2 = FullSetID == uniqueSets(i);
    totalPoints = sum(idx2);
    for c = 1:K
        percentages(i,c) = sum(idx(idx2) == c) / totalPoints;
    end
end

% Make tables
TPercents = [];
ClusterMeans = [];

% Plot Average Cluster Traces
avgClusterTraceFig = figure(); hold on
for i = 1:K
    temp = data(:, idx == i);
    plot(mean(temp,2), 'LineWidth', 3, 'Color', colors(i,:))
end
hold off
legend(legendNames,'Interpreter','none')
title("Average Cluster Traces",'Interpreter','none')

% Stacked Bar Plot for Cluster Composition

x = 1;
ClustCompositionFig= figure();
% Force percentages as columns for stacking
b = bar(x,percentages, 'stacked');

% Apply custom colors
for k = 1:numel(b)
    if k <= size(colors,1)
        b(k).FaceColor = colors(k,:);
    else
        b(k).FaceColor = rand(1,3);  % fallback random color if K > 4
    end
end

ylabel('Fraction')
title('Cluster Composition per Treatment')

xticks(1:numTreats)
xticklabels(strrep(name, "_", " "))
%xtickangle(45)

legend("Cluster " + string(1:K), 'Location','eastoutside')
ylim([0 1])

% Save Figures
Utils.PlotLogic(params, "AllClustAvg", avgClusterTraceFig)
Utils.PlotLogic(params, "ClusterComposition", ClustCompositionFig)

end