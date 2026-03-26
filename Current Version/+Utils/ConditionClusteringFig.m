function[idx, ClusterMeans] = ConditionClusteringFig(params,name,data,feats, FeatureNames)
if params.Score == "DaviesBouldin"
    eva = evalclusters(data,'kmeans','DaviesBouldin', 'Klist', [1:6]);
    K = eva.OptimalK();
elseif params.Score == "CalinskiHarabasz"
    eva = evalclusters(data,'kmeans','CalinskiHarabasz', 'Klist', [1:6]);
    K = eva.OptimalK();
elseif params.Score == "Gap"
    eva = evalclusters(data,'kmeans','Gap', 'Klist', [1:6]); %This might throw an error. if K >6
    K = eva.OptimalK();
else
    eva = evalclusters(data,'kmeans','silhouette', 'Klist', [1:6]); %This might throw an error. if K >6
    K = eva.OptimalK();
end
%BestK = round(mean([silhouetteEvaluation.OptimalK,gapEvaluation.OptimalK,daviesEvaluation.OptimalK,calinskiEvaluation.OptimalK] ));
%BestK = calinskiEvaluation.OptimalK

%Manual Clustering Number
if params.ManClust > 0
    K = params.ManClust;
end

ClustAssignmentFig = figure();
if K > min(size(data))
    disp("Not enough traces to cluster")
    K = 1;
end
idx =  kmeans(transpose(data), K);
legendNames = [];
clustMeans = [];
hold on
h = gobjects(1,K);
colors = lines(6);

%Parse ClusterAssignments
for i = 1:K

    p = plot(data(:,idx == i), 'color',colors(i,:));
    h(i) = p(1);
    [~, num] = size(data(:,idx == i)); %Double check size()
    TraceNums = find(idx == i);
    peaks = find(any(feats(8,:) == TraceNums))
    clustMeans = [clustMeans, mean(feats(:,peaks),2)];
    legendNames = [legendNames, ("Cluster " + string(i)) + " (" + string(num) + ")"];
end


title("Cluster Assignments " + name, 'Interpreter','none');
legend(h, arrayfun(@(x) sprintf('Cluster %d', x), 1:K, 'UniformOutput', false),'Interpreter','none');
%legend(legendNames)
hold off

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
title("Average Cluster Trace"+ name,'Interpreter','none')


Utils.PlotLogic(params.Output, strcat(name, "_ClustAssigns"), ClustAssignmentFig)
Utils.PlotLogic(params.Output, strcat(name, "_ClustAvg"), avgClusterTraceFig)

end
