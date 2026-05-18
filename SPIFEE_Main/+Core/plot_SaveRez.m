% plot_SaveRez
% ------------------------------------------------------------
% Generates visualizations and compiles final results structure.
%
%  Per-condition feature storage
%  Mean trace visualization
%  (optional) Heatmaps and optional plots
%  (optional) per condition clustering
%  (optional) 1st Peak Features / means 
%  Saving results
%
% Input:
%   analysisStruct - aggregated analysis results
%   params - processing5 parameters
%
% Output:
%   results - final structured output for downstream use

function results = plot_SaveRez(analysisStruct, params)

results = struct;
fs = analysisStruct.featureStruct;

% Per Condition
for i=1:length(fs)
    name = fs(i).Fullname;
    results.(name).Features = fs(i).Features;
    results.(name).FullFiltTraces = fs(i).Filtered;
    results.(name).SmoothedTraces = fs(i).Smoothed;
    results.(name).TracesUsedID = fs(i).IDs;
    %If Field Means
    if isfield(fs(i),'Means') && ~any(cellfun(@isempty, {fs.Means}) ) %Checks if field exists and if its empty
        FeatureNames = fs(i).Features.Properties.RowNames;
        T = array2table(fs(i).Means,'RowNames',FeatureNames,'VariableNames',"Averages");
        T([2,7:12],:) = []; %Get rid of book keeping features for the ouptut
        results.(name).Means = T;
        results.(name).AvgTrace = fs(i).AvgTrace;
    end

    %1st Peaks
    if params.FirstPeak == 1
        numExp = length(fs);
        FirstPeakMeans = zeros(12, numExp);
        for j = 1:numExp
            tempFeat = fs(j).Features;
            firstCols = tempFeat{7, :} == 1;
            justOnes = tempFeat(:, firstCols);
            firstMeans = mean(justOnes, 2);
            firstMeans = table2array(firstMeans);
            FirstPeakMeans(:,i) = firstMeans;
        end
        FirstPeakMeans = array2table(FirstPeakMeans,'Rownames',FeatureNames, 'VariableNames', analysisStruct.names);
        FirstPeakMeans([7,8,9,10,11,12],:) = [];
        results.("FirstPeakMeans") = FirstPeakMeans;
    end

    % Heatmap
    if params.Heats == 1
        Utils.TraceHeatmap(fs(i).Filtered, fs(i).name, params);
    end

    %Clust Single
    %Run clust on smoothed or filtered?
    if params.Clusters == 1
        [SoloPercents, SoloClustIDX, SoloClustMeans] = Utils.ConditionClusteringFig(params, fs(i).name, fs(i).Filtered, fs(i).Features, FeatureNames);
        results.(name).SoloPercents = SoloPercents;
        results.(name).SoloClustIDX = SoloClustIDX;
        results.(name).SoloClustMeans = SoloClustMeans;
    end

    %Clust Eval
    if params.Eval == 1
        Utils.ClustEvalFig(params, fs(i).Filtered,fs(i).name); %double check for bugs
    end



end

% Combined
results.AnalysisOrder = cellstr(analysisStruct.names);
nFiles = length(fs);
traceLen = length(fs(1).AvgTrace);
avgTraces = zeros(traceLen, nFiles);

%Averages
if params.Avg
    for i = 1:nFiles
        avgTraces(:, i) = fs(i).AvgTrace;
    end
    results.AvgTraces = avgTraces;
    if length(fs) > 1
        figure;
        plot(avgTraces,'LineWidth',3)
        legend(results.AnalysisOrder, 'Interpreter', 'none')
        title("Average Traces")
    end
end



% Stats
if isfield(analysisStruct,'stats')
    results.Stats = analysisStruct.stats;
end

% Cluster All
if isfield(analysisStruct,'clusterAll')
    results.ClusterAllConditionsMeans = analysisStruct.clusterAll.means;
    results.ClusterAllIndexes = analysisStruct.clusterAll.idx;
    results.ClusterPercentages = analysisStruct.clusterAll.perc;
end
%Plain English
Data = analysisStruct.featureStruct.Smoothed; %For size calcs in plain eng
txt = Utils.structToPlainEnglish(params, ...
    {analysisStruct.featureStruct.name}, ...
    {analysisStruct.featureStruct.Details}, Data);
results.("ReprodTxt") = txt;

% Save
save(fullfile(params.Folder, params.Name + "_Results.mat"), "results");
disp("SPIFEE Analysis complete")

end