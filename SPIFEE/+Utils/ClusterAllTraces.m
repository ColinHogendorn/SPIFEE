function[TPercents,idx, ClusterMeans] = ClusterAllTraces(params,name,data,feats, FeatureNames, FullSetID)

%These will throw an error if K > 6. TO DO: Handle K>6
if params.Score == "DaviesBouldin"
    eva = evalclusters(data,'kmeans','DaviesBouldin', 'Klist', 1:6);
    K = eva.OptimalK();
elseif params.Score == "CalinskiHarabasz"
    eva = evalclusters(data,'kmeans','CalinskiHarabasz', 'Klist', 1:6);
    K = eva.OptimalK();
elseif params.Score == "Gap"
    eva = evalclusters(data,'kmeans','Gap', 'Klist', 1:6); 
    K = eva.OptimalK();
else
    eva = evalclusters(data,'kmeans','silhouette', 'Klist', 1:6); 
    K = eva.OptimalK();
end


%Manual Clustering Number
K_manual = str2double(params.ManClustAll);

if ~isnan(K_manual) && K_manual > 0
    K = K_manual;
end

if K > min(size(data))
    disp("Not enough traces to cluster")
    K = 1;
end
idx =  kmeans(transpose(data), K);
SpaceNames = string(name);
SpaceNames = strrep(SpaceNames, "_", " ");



%Color Schemes

colors = lines(6);

nFeatures = size(feats,1);    % number of rows in feats
clustMeans = zeros(nFeatures, K);
legendNames = strings(1, K);

%Parse ClusterAssignments
for i = 1:K
    [~, num] = size(data(:,idx == i)); %Double check size()
    TraceNums = find(idx == i);
    peaks = ismember(feats(8,:), TraceNums);
    clustMeans(:,i) = mean(feats(:,peaks), 2);
    legendNames(i) = "Cluster " + i + " (" + num + ")";
end

uniqueSets = unique(FullSetID);
%uniqueSets2 = unique()
numTreats = numel(uniqueSets);

% Calculate Percentages
percentages = zeros(numTreats, K);

for i = 1:numTreats
    idx2 = FullSetID == uniqueSets(i);  % points from this dataset
    totalPoints = sum(idx2);

    for c = 1:K
        percentages(i, c) = (sum(idx(idx2) == c) / totalPoints);
    end
end
FullK = 1:K;

%Make Table
clusterNames = "Cluster_" + string(FullK);
TPercents = array2table(percentages, ...
    'VariableNames', clusterNames, ...
    'RowNames', SpaceNames);

FeatureNames2 = transpose(FeatureNames);
ClusterMeans = array2table(clustMeans,'Rownames',FeatureNames2, 'VariableNames', legendNames);

%Plot avg traces
avgClusterTraceFig = figure();
hold on
for i = 1:K
    temp = data(:,idx == i);
    temp2 = mean(temp,2);
    plot(temp2, 'LineWidth',3, 'Color', colors(i,:))
end
hold off
legend(legendNames,'Interpreter','none')
title("Average Cluster Traces",'Interpreter','none')


%Stacked bar plots of Treatment composition
ClustCompositionFig = figure();

% For bar plots
b = bar(percentages, 'stacked');
colormap(parula(7))


ylabel('Fraction')
title('Cluster composition per treatment')
xticks(1:numTreats)
xticklabels(SpaceNames)
xtickangle(45)
legend("Cluster " + string(1:numel(b)), ...
       'Location','eastoutside')

ylim([0 1])
addName = cellstr(params.Name);
%Save Average Cluster Fig
Utils.PlotLogic(params, (addName + "_AllClustAvg"), avgClusterTraceFig)

%Save ClusterComposition Fig
Utils.PlotLogic(params, (addName + "_ClusterComposition"), ClustCompositionFig)

end
