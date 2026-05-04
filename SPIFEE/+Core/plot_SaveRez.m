% plot_SaveRez
% ------------------------------------------------------------
% Generates visualizations and compiles final results structure.
%
%  Per-condition feature storage
%  Mean trace visualization
%  Heatmaps and optional plots
%  Saving results
%
% Input:
% analysisStruct: aggregated analysis results
% params: output and plotting parameters
%
% Output:
%   results: final structured output for downstream use

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
    % Heatmap
    if params.Heats
        Utils.TraceHeatmap(fs(i).Filtered, fs(i).name, params);
    end
end

% Combined
results.AnalysisOrder = cellstr(analysisStruct.names);
nFiles = length(fs);
traceLen = length(fs(1).AvgTrace);
avgTraces = zeros(traceLen, nFiles);

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
txt = Utils.structToPlainEnglish( ...
    params, ...
    {analysisStruct.featureStruct.name}, ...
    {analysisStruct.featureStruct.Details}, Data);
results.("ReprodTxt") = txt;

% Save
save(fullfile(params.Folder, params.Name + "_Results.mat"), "results");
disp("SPIFEE Analysis complete")

end