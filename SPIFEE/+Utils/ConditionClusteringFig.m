function[percentages, idx, ClusterMeans] = ConditionClusteringFig(params,name,data,feats, FeatureNames)
if params.Score == "DaviesBouldin"
    eva = evalclusters(data,'kmeans','DaviesBouldin', 'Klist', 1:6);
    K = eva.OptimalK();
elseif params.Score == "CalinskiHarabasz"
    eva = evalclusters(data,'kmeans','CalinskiHarabasz', 'Klist', 1:6);
    K = eva.OptimalK();
elseif params.Score == "Gap"
    eva = evalclusters(data,'kmeans','Gap', 'Klist', 1:6); %This might throw an error. if K >6
    K = eva.OptimalK();
else
    eva = evalclusters(data,'kmeans','silhouette', 'Klist', 1:6); %This might throw an error. if K >6
    K = eva.OptimalK();
end
%BestK = round(mean([silhouetteEvaluation.OptimalK,gapEvaluation.OptimalK,daviesEvaluation.OptimalK,calinskiEvaluation.OptimalK] ));
%BestK = calinskiEvaluation.OptimalK

%Manual Clustering Number. I dont'r remember why I need the params to have
% this number in string format. Maybe it was because of the updated
% clustering window logic? either way, this handles that.
K_manual = str2double(params.ManClustAll);

if ~isnan(K_manual) && K_manual > 0
    K = K_manual;
end
ClustAssignmentFig = figure();
if K > min(size(data))
    disp("Not enough traces to cluster")
    K = 1;
end
idx =  kmeans(transpose(data), K);
hold on
h = gobjects(1,K);
colors = lines(6);
% Preallocate
clustMeans   = zeros(size(feats,1), K);
legendNames  = strings(1, K);
for i = 1:K

    % Cluster membership
    clusterIdx = (idx == i);
    % Plot cluster
    p = plot(data(:, clusterIdx), 'Color', colors(i,:));
    h(i) = p(1);
    % Number of traces in cluster
    numTraces = sum(clusterIdx);
    % Trace indices in this cluster
    TraceNums = find(clusterIdx);
    % Peaks belonging to those traces
    peaks = ismember(feats(8,:), TraceNums);
    % Cluster mean feature vector
    clustMeans(:, i) = mean(feats(:, peaks), 2, 'omitnan');
    % Legend entry
    legendNames(i) = "Cluster " + i + " (" + numTraces + ")";
end
title("Cluster Assignments " + name, 'Interpreter','none');
legend(h, arrayfun(@(x) sprintf('Cluster %d', x), 1:K, 'UniformOutput', false),'Interpreter','none');
hold off

%Average Clusters Figure
FeatureNames2 = transpose(FeatureNames);
ClusterMeans = array2table(clustMeans,'Rownames',FeatureNames2, 'VariableNames', legendNames);

avgClusterTraceFig = figure();
hold on
for i = 1:K
    temp = data(:,idx == i);
    temp2 = mean(temp,2);
    plot(temp2, 'LineWidth',3)
end
hold off
legend(legendNames,'Interpreter','none')
title("Average Cluster Trace "+ name,'Interpreter','none')

%ClusterComposition
ClustCompositionFig = figure();
percentages = zeros(1, K);

%Simplify
totalPoints = length(idx);
for c = 1:K
    percentages(c) = sum(idx == c) / totalPoints;
end

x = 1;

% Force percentages as columns for stacking
bar(x,percentages, 'stacked');
colormap(parula(7))
ylabel('Fraction')
title('Cluster Composition per Treatment')
xticklabels(strrep(name, "_", " "))
%xtickangle(45)

legend("Cluster " + string(1:K), 'Location','eastoutside')
ylim([0 1])


Utils.PlotLogic(params, strcat(name, "_ClustAssigns"), ClustAssignmentFig)
Utils.PlotLogic(params, strcat(name, "_ClustAvg"), avgClusterTraceFig)
Utils.PlotLogic(params, strcat(name, "_ClustComposition"), ClustCompositionFig)


end
