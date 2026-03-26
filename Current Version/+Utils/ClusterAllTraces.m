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
    
    %Optional: K value evaluated from all 4 metrics? Not recommended.
    %BestK = round(mean([silhouetteEvaluation.OptimalK,gapEvaluation.OptimalK,daviesEvaluation.OptimalK,calinskiEvaluation.OptimalK] ));
    
    %Manual Clustering Number
    if params.ManClustAll > 0
        K = params.ManClustAll;
        K = str2double(K);
    end
    
    %If less traces than K
    if K > min(size(data))
        disp("Not enough traces to cluster")
        K = 1;
    end
    
    %Store K values.
    idx =  kmeans(transpose(data), K); %kmeans wants data in rows.
    legendNames = [];
    SpaceNames = strrep(name, "_", " ");
    clustMeans = [];
    hold on
    h = gobjects(1,K);
    colors = lines(6);
    temp = transpose(FullSetID);
    
    %Parse ClusterAssignments
    for i = 1:K
        [~, num] = size(data(:,idx == i)); %Double check size()
        TraceNums = find(idx == i);
        peaks = find(any(feats(8,:) == TraceNums));
        clustMeans = [clustMeans, mean(feats(:,peaks),2)];
        legendNames = [legendNames, ("Cluster " + string(i)) + " (" + string(num) + ")"];
    
    end
    
    
    uniqueSets = unique(FullSetID);
    numTreats = numel(uniqueSets);
    
    % Calculate Percentages
    percentages = zeros(numTreats, K);
    
    for i = 1:numTreats
        idx2 = FullSetID == uniqueSets(i);      % points from this dataset
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
        'RowNames', name);
    
    FeatureNames2 = transpose(FeatureNames);
    ClusterMeans = array2table(clustMeans,'Rownames',FeatureNames2, 'VariableNames', legendNames);
    
    %Plot avg traces
    avgClusterTraceFig = figure();
    hold on
    for i = 1:K
        temp = data(:,idx == i);
        temp2 = mean(temp,2);
        plot(temp2, 'LineWidth',3)
    end
    hold off
    legend(legendNames,'Interpreter','none')
    title("Average Cluster Traces",'Interpreter','none')
    
    % %Plot Box plots of how much cluster k shows up
    % figure; hold on
    % 
    % nClusters = K;
    % data = [];
    % group = [];
    % 
    % for c = 1:nClusters
    %     data  = [data; percentages(:,c)];
    %     group = [group; c * ones(size(percentages,1),1)];
    % end
    % 
    % boxplot(data, group, ...
    %     'Labels', "Cluster " + string(FullK), ...
    %     'Symbol', 'k.')
    % 
    % ylabel('Fraction of treatment')
    % xlabel('Cluster')
    % title('Cluster composition across treatments')
    % ylim([0 1])
    % grid on
    
    %Stacked bar plots of Treatment composition
    ClustCompositionFig = figure();
    bar(percentages, 'stacked')
    colormap(parula(7))
    
    
    ylabel('Fraction')
    title('Cluster composition per treatment')
    xticks(FullK)
    
    xticklabels(SpaceNames)
    legend("Cluster " + string(FullK), ...
           'Location','eastoutside')
    
    ylim([0 1])
    
    %Save Average Cluster Fig
    Utils.PlotLogic(params.Output, "AllClustAvg", avgClusterTraceFig)
    
    %Save ClusterComposition Fig
    Utils.PlotLogic(params.Output, "ClusterComposition", ClustCompositionFig)

end
