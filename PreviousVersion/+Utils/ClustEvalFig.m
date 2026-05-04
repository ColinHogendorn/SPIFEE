%Clustering within each treatement
function ClustEvalFig(params, data, name)
ClusterEvalFig = figure;
calinskiEvaluation = evalclusters(data,"kmeans","CalinskiHarabasz","KList",1:6);
daviesEvaluation = evalclusters(data,"kmeans","DaviesBouldin", "KList",1:6);
gapEvaluation = evalclusters(data,"kmeans","gap","KList",1:6);
silhouetteEvaluation = evalclusters(data,"kmeans","silhouette","KList",1:6);

OptimalClusterFig = tiledlayout(2,2);
title(OptimalClusterFig,"Comparison of Clustering Algorithims on " + name, "Interpreter", 'none')
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

%savefig(ClusterEvalFig, (strcat(name, "_ClustEval.fig")));
Utils.PlotLogic(params.Output, strcat(name, "_ClustEval"), ClusterEvalFig );
end